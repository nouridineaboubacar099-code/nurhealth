// ============================================================
// NurHealth — Service PIN Firebase Sécurisé
// Fichier : lib/services/pin_service.dart
// ============================================================

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinService {
  static final PinService _instance = PinService._internal();
  factory PinService() => _instance;
  PinService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ── Clés stockage local ───────────────────────────────────
  static const String _pinAttemptKey   = 'pin_attempts';
  static const String _pinLockedUntil  = 'pin_locked_until';
  static const String _pinCachedHash   = 'pin_cached_hash';
  static const int    _maxAttempts     = 5;
  static const int    _lockDurationMin = 30;

  // ─────────────────────────────────────────────────────────
  // HASH DU PIN (SHA-256 + salt UID)
  // ─────────────────────────────────────────────────────────
  String _hashPin(String pin, String uid) {
    final saltedPin = '$pin:$uid:nurhealth_vidal_2025';
    final bytes = utf8.encode(saltedPin);
    return sha256.convert(bytes).toString();
  }

  // ─────────────────────────────────────────────────────────
  // CRÉER / DÉFINIR LE PIN
  // ─────────────────────────────────────────────────────────
  Future<PinResult> setPin(String newPin, {String? oldPin}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return PinResult.error('Utilisateur non connecté');

      // Valider format PIN
      if (newPin.length < 4 || newPin.length > 6) {
        return PinResult.error('Le PIN doit contenir 4 à 6 chiffres');
      }
      if (!RegExp(r'^\d+$').hasMatch(newPin)) {
        return PinResult.error('Le PIN doit contenir uniquement des chiffres');
      }

      // Vérifier PIN simple (séquences interdites)
      if (_isWeakPin(newPin)) {
        return PinResult.error('PIN trop simple. Évitez 123456, 000000, etc.');
      }

      // Si PIN existant, vérifier l'ancien avant de changer
      final doc = await _db.collection('doctors_pin').doc(uid).get();
      if (doc.exists && oldPin != null) {
        final verify = await verifyPin(oldPin);
        if (!verify.success) return PinResult.error('Ancien PIN incorrect');
      }

      // Hasher et sauvegarder dans Firestore
      final hash = _hashPin(newPin, uid);
      await _db.collection('doctors_pin').doc(uid).set({
        'pinHash': hash,
        'uid': uid,
        'updatedAt': FieldValue.serverTimestamp(),
        'attempts': 0,
        'lockedUntil': null,
      }, SetOptions(merge: true));

      // Mettre en cache local (chiffré)
      await _secureStorage.write(key: _pinCachedHash, value: hash);
      await _secureStorage.write(key: _pinAttemptKey, value: '0');

      return PinResult.success('PIN défini avec succès');
    } catch (e) {
      return PinResult.error('Erreur : $e');
    }
  }

  // ─────────────────────────────────────────────────────────
  // VÉRIFIER LE PIN
  // ─────────────────────────────────────────────────────────
  Future<PinResult> verifyPin(String pin) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return PinResult.error('Utilisateur non connecté');

      // Vérifier verrouillage local
      final lockCheck = await _checkLock();
      if (lockCheck != null) return lockCheck;

      // Hash du PIN saisi
      final inputHash = _hashPin(pin, uid);

      // 1. Vérifier cache local d'abord (mode hors ligne)
      final cachedHash = await _secureStorage.read(key: _pinCachedHash);
      if (cachedHash != null && cachedHash == inputHash) {
        await _resetAttempts();
        return PinResult.success('PIN vérifié');
      }

      // 2. Vérifier Firestore
      final doc = await _db.collection('doctors_pin').doc(uid).get();
      if (!doc.exists) return PinResult.error('PIN non configuré');

      final data = doc.data()!;

      // Vérifier verrouillage Firestore
      final lockedUntil = data['lockedUntil'] as Timestamp?;
      if (lockedUntil != null &&
          lockedUntil.toDate().isAfter(DateTime.now())) {
        final remaining = lockedUntil.toDate().difference(DateTime.now());
        return PinResult.locked(
          'Compte verrouillé. Réessayez dans ${remaining.inMinutes} min',
          remaining,
        );
      }

      final storedHash = data['pinHash'] as String?;
      if (storedHash == null) return PinResult.error('PIN non configuré');

      if (storedHash == inputHash) {
        // PIN correct
        await _db.collection('doctors_pin').doc(uid).update({
          'attempts': 0,
          'lockedUntil': null,
          'lastAccess': FieldValue.serverTimestamp(),
        });
        await _secureStorage.write(key: _pinCachedHash, value: storedHash);
        await _resetAttempts();
        return PinResult.success('PIN vérifié');
      } else {
        // PIN incorrect
        return await _handleFailedAttempt(uid, data);
      }
    } catch (e) {
      // Fallback mode hors ligne
      return await _offlineVerify(pin);
    }
  }

  // ─────────────────────────────────────────────────────────
  // VÉRIFICATION HORS LIGNE
  // ─────────────────────────────────────────────────────────
  Future<PinResult> _offlineVerify(String pin) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return PinResult.error('Hors ligne — connexion requise');
    final cachedHash = await _secureStorage.read(key: _pinCachedHash);
    if (cachedHash == null) return PinResult.error('Aucun PIN en cache');
    final inputHash = _hashPin(pin, uid);
    if (cachedHash == inputHash) {
      return PinResult.success('PIN vérifié (hors ligne)');
    }
    return await _handleFailedAttemptLocal();
  }

  // ─────────────────────────────────────────────────────────
  // GESTION TENTATIVES ÉCHOUÉES
  // ─────────────────────────────────────────────────────────
  Future<PinResult> _handleFailedAttempt(
      String uid, Map<String, dynamic> data) async {
    final attempts = (data['attempts'] ?? 0) + 1;
    final remaining = _maxAttempts - attempts;

    if (attempts >= _maxAttempts) {
      // Verrouiller le compte
      final lockUntil =
          DateTime.now().add(Duration(minutes: _lockDurationMin));
      await _db.collection('doctors_pin').doc(uid).update({
        'attempts': attempts,
        'lockedUntil': Timestamp.fromDate(lockUntil),
      });
      await _lockLocal(lockUntil);
      return PinResult.locked(
        'Trop de tentatives. Compte verrouillé $_lockDurationMin minutes.',
        Duration(minutes: _lockDurationMin),
      );
    } else {
      await _db.collection('doctors_pin').doc(uid).update({
        'attempts': attempts,
      });
      await _incrementLocalAttempts();
      return PinResult.wrongPin(
        'PIN incorrect. $remaining tentative${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}',
        remaining,
      );
    }
  }

  Future<PinResult> _handleFailedAttemptLocal() async {
    final attemptsStr = await _secureStorage.read(key: _pinAttemptKey) ?? '0';
    final attempts = int.parse(attemptsStr) + 1;
    final remaining = _maxAttempts - attempts;

    if (attempts >= _maxAttempts) {
      final lockUntil =
          DateTime.now().add(Duration(minutes: _lockDurationMin));
      await _lockLocal(lockUntil);
      return PinResult.locked(
        'Trop de tentatives. Réessayez dans $_lockDurationMin minutes.',
        Duration(minutes: _lockDurationMin),
      );
    }
    await _secureStorage.write(
        key: _pinAttemptKey, value: attempts.toString());
    return PinResult.wrongPin(
      'PIN incorrect. $remaining tentative${remaining > 1 ? 's' : ''} restante${remaining > 1 ? 's' : ''}',
      remaining,
    );
  }

  // ─────────────────────────────────────────────────────────
  // UTILITAIRES
  // ─────────────────────────────────────────────────────────
  Future<PinResult?> _checkLock() async {
    final lockedUntilStr =
        await _secureStorage.read(key: _pinLockedUntil);
    if (lockedUntilStr == null) return null;
    final lockUntil = DateTime.parse(lockedUntilStr);
    if (lockUntil.isAfter(DateTime.now())) {
      final remaining = lockUntil.difference(DateTime.now());
      return PinResult.locked(
        'Compte verrouillé. Réessayez dans ${remaining.inMinutes} min',
        remaining,
      );
    }
    await _secureStorage.delete(key: _pinLockedUntil);
    return null;
  }

  Future<void> _lockLocal(DateTime until) async {
    await _secureStorage.write(
        key: _pinLockedUntil, value: until.toIso8601String());
    await _secureStorage.write(
        key: _pinAttemptKey, value: _maxAttempts.toString());
  }

  Future<void> _resetAttempts() async {
    await _secureStorage.write(key: _pinAttemptKey, value: '0');
    await _secureStorage.delete(key: _pinLockedUntil);
  }

  Future<void> _incrementLocalAttempts() async {
    final str = await _secureStorage.read(key: _pinAttemptKey) ?? '0';
    await _secureStorage.write(
        key: _pinAttemptKey, value: (int.parse(str) + 1).toString());
  }

  bool _isWeakPin(String pin) {
    const weakPins = [
      '123456', '654321', '000000', '111111', '222222',
      '333333', '444444', '555555', '666666', '777777',
      '888888', '999999', '123123', '112233', '1234', '0000',
    ];
    return weakPins.contains(pin);
  }

  // ─────────────────────────────────────────────────────────
  // RÉINITIALISER PIN (par admin)
  // ─────────────────────────────────────────────────────────
  Future<PinResult> resetPinByAdmin(String doctorUid) async {
    try {
      final adminUid = _auth.currentUser?.uid;
      if (adminUid == null) return PinResult.error('Non connecté');

      // Vérifier que c'est bien un admin
      final adminDoc =
          await _db.collection('users').doc(adminUid).get();
      if (adminDoc.data()?['role'] != 'admin') {
        return PinResult.error('Accès refusé — admin uniquement');
      }

      await _db.collection('doctors_pin').doc(doctorUid).update({
        'pinHash': null,
        'attempts': 0,
        'lockedUntil': null,
        'resetBy': adminUid,
        'resetAt': FieldValue.serverTimestamp(),
      });
      return PinResult.success('PIN réinitialisé. Le médecin doit créer un nouveau PIN.');
    } catch (e) {
      return PinResult.error('Erreur : $e');
    }
  }

  // Vérifier si PIN configuré
  Future<bool> hasPinConfigured() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _db.collection('doctors_pin').doc(uid).get();
    return doc.exists && doc.data()?['pinHash'] != null;
  }

  // Effacer cache local (déconnexion)
  Future<void> clearLocalCache() async {
    await _secureStorage.deleteAll();
  }
}

// ═════════════════════════════════════════════════════════════
// MODÈLE RÉSULTAT
// ═════════════════════════════════════════════════════════════
class PinResult {
  final bool success;
  final String message;
  final PinStatus status;
  final int? remainingAttempts;
  final Duration? lockDuration;

  const PinResult._({
    required this.success,
    required this.message,
    required this.status,
    this.remainingAttempts,
    this.lockDuration,
  });

  factory PinResult.success(String msg) => PinResult._(
        success: true,
        message: msg,
        status: PinStatus.correct,
      );

  factory PinResult.error(String msg) => PinResult._(
        success: false,
        message: msg,
        status: PinStatus.error,
      );

  factory PinResult.wrongPin(String msg, int remaining) => PinResult._(
        success: false,
        message: msg,
        status: PinStatus.wrong,
        remainingAttempts: remaining,
      );

  factory PinResult.locked(String msg, Duration duration) => PinResult._(
        success: false,
        message: msg,
        status: PinStatus.locked,
        lockDuration: duration,
      );
}

enum PinStatus { correct, wrong, locked, error }
