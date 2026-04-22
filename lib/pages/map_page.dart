import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

// ============================================================
//  NurHealth — Carte Niger / Zinder + GPS Livraison
//  SOCIETE ANY-SERVICE SARL — Zinder, Niger
// ============================================================

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  // ── Couleurs NurHealth ──────────────────────────────────
  static const Color kVert       = Color(0xFF1B5E20);
  static const Color kVertClair  = Color(0xFF4CAF50);
  static const Color kOr         = Color(0xFFFFD700);
  static const Color kOrClair    = Color(0xFFFFF9C4);
  static const Color kBlanc      = Color(0xFFFFFFFF);
  static const Color kGrisFond   = Color(0xFFF5F5F5);

  // ── Coordonnées de référence ───────────────────────────
  static const LatLng _nigerCenter  = LatLng(17.6078, 8.0817);
  static const LatLng _zinderCenter = LatLng(13.8067, 8.9881);

  // ── Quartiers de Zinder ────────────────────────────────
  final List<_Lieu> _quartiersZinder = [
    _Lieu('Centre-ville Zinder',    LatLng(13.8067, 8.9881),  TypeLieu.quartier),
    _Lieu('Birni Quartier',         LatLng(13.8120, 8.9920),  TypeLieu.quartier),
    _Lieu('Zengou',                 LatLng(13.7980, 8.9750),  TypeLieu.quartier),
    _Lieu('Kara Kara',              LatLng(13.8200, 9.0050),  TypeLieu.quartier),
    _Lieu('Baban Tapki',            LatLng(13.7900, 8.9800),  TypeLieu.quartier),
    _Lieu('Garin Malam',            LatLng(13.8150, 8.9700),  TypeLieu.quartier),
    _Lieu('Lazaret',                LatLng(13.7850, 8.9850),  TypeLieu.quartier),
    _Lieu('Nikatawa',               LatLng(13.8300, 9.0100),  TypeLieu.quartier),
    _Lieu('Dar Es Salam',           LatLng(13.8050, 9.0000),  TypeLieu.quartier),
    _Lieu('Dan Chadoua',            LatLng(13.7950, 8.9700),  TypeLieu.quartier),
  ];

  // ── Lieux médicaux Zinder ──────────────────────────────
  final List<_Lieu> _lieuxMedicaux = [
    _Lieu('Hôpital National Zinder',        LatLng(13.8080, 8.9900), TypeLieu.hopital),
    _Lieu('Centre de Santé Intégré Birni',  LatLng(13.8110, 8.9870), TypeLieu.sante),
    _Lieu('Pharmacie Centrale',             LatLng(13.8065, 8.9875), TypeLieu.pharmacie),
    _Lieu('Maternité Régionale',            LatLng(13.8090, 8.9860), TypeLieu.sante),
    _Lieu('CSI Kara Kara',                  LatLng(13.8195, 9.0045), TypeLieu.sante),
    _Lieu('Pharmacie Al-Shifa',             LatLng(13.8055, 8.9885), TypeLieu.pharmacie),
  ];

  // ── État ──────────────────────────────────────────────
  final MapController _mapController = MapController();
  Position? _positionActuelle;
  bool _chargementGPS = false;
  bool _vueZinder = true;
  bool _montrerQuartiers = true;
  bool _montrerMedicaux = true;
  String? _lieuSelectionne;
  LatLng? _positionPartagee;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<Position>? _positionStream;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _obtenirPosition();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionStream?.cancel();
    super.dispose();
  }

  // ── GPS ───────────────────────────────────────────────
  Future<void> _obtenirPosition() async {
    setState(() => _chargementGPS = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _afficherErreur('Permission GPS refusée définitivement.\nActivez-la dans les paramètres.');
        setState(() => _chargementGPS = false);
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _positionActuelle = pos;
        _chargementGPS = false;
      });

      _mapController.move(
        LatLng(pos.latitude, pos.longitude),
        15.0,
      );

      // Écoute continue
      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((p) => setState(() => _positionActuelle = p));
    } catch (e) {
      setState(() => _chargementGPS = false);
      _afficherErreur('Impossible d\'obtenir la position GPS.');
    }
  }

  // ── Partage de position ───────────────────────────────
  Future<void> _partagerPosition() async {
    final pos = _positionActuelle;
    if (pos == null) {
      _afficherErreur('Position GPS non disponible.\nActivez d\'abord le GPS.');
      return;
    }

    final lat  = pos.latitude.toStringAsFixed(6);
    final lng  = pos.longitude.toStringAsFixed(6);
    final lien = 'https://maps.google.com/?q=$lat,$lng';
    final msg  = '📍 Ma position exacte pour la livraison NurHealth :\n$lien\n\nCoordonnées : $lat, $lng';

    setState(() => _positionPartagee = LatLng(pos.latitude, pos.longitude));

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PartageSheet(
        message: msg,
        lien: lien,
        onWhatsApp: () => _ouvrirWhatsApp(msg),
        onSMS: () => _ouvrirSMS(msg),
        onCopier: () => _copierPresse(lien),
      ),
    );
  }

  Future<void> _ouvrirWhatsApp(String msg) async {
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _ouvrirSMS(String msg) async {
    final url = Uri.parse('sms:?body=${Uri.encodeComponent(msg)}');
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  Future<void> _copierPresse(String texte) async {
    await Clipboard.setData(ClipboardData(text: texte));
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        _snackBar('Lien copié ! 📋', kVert),
      );
    }
  }

  void _allerZinder() {
    setState(() => _vueZinder = true);
    _mapController.move(_zinderCenter, 13.0);
  }

  void _allerNiger() {
    setState(() => _vueZinder = false);
    _mapController.move(_nigerCenter, 6.0);
  }

  void _afficherErreur(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(_snackBar(msg, Colors.red.shade700));
  }

  SnackBar _snackBar(String msg, Color couleur) => SnackBar(
    content: Text(msg, style: const TextStyle(color: kBlanc)),
    backgroundColor: couleur,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrisFond,
      body: Stack(
        children: [
          // ── Carte ──────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _zinderCenter,
              initialZoom: 13.0,
              minZoom: 4.0,
              maxZoom: 18.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.nurhealth.app',
                maxZoom: 18,
              ),
              // Marqueurs quartiers
              if (_montrerQuartiers)
                MarkerLayer(markers: _quartiersZinder.map(_creerMarqueur).toList()),
              // Marqueurs médicaux
              if (_montrerMedicaux)
                MarkerLayer(markers: _lieuxMedicaux.map(_creerMarqueur).toList()),
              // Position utilisateur
              if (_positionActuelle != null)
                MarkerLayer(markers: [_marqueurUtilisateur()]),
              // Position partagée
              if (_positionPartagee != null)
                MarkerLayer(markers: [_marqueurPartage()]),
            ],
          ),

          // ── AppBar personnalisée ───────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: _AppBarCarte(
              vueZinder: _vueZinder,
              onZinder: _allerZinder,
              onNiger: _allerNiger,
            ),
          ),

          // ── Filtres ────────────────────────────────────
          Positioned(
            top: 110, right: 12,
            child: _PanneauFiltres(
              montrerQuartiers: _montrerQuartiers,
              montrerMedicaux: _montrerMedicaux,
              onQuartiers: () => setState(() => _montrerQuartiers = !_montrerQuartiers),
              onMedicaux: () => setState(() => _montrerMedicaux = !_montrerMedicaux),
            ),
          ),

          // ── Info lieu sélectionné ──────────────────────
          if (_lieuSelectionne != null)
            Positioned(
              bottom: 120, left: 16, right: 16,
              child: _BulleInfo(
                nom: _lieuSelectionne!,
                onFermer: () => setState(() => _lieuSelectionne = null),
              ),
            ),

          // ── Boutons flottants bas ──────────────────────
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: _BarreBoutons(
              chargementGPS: _chargementGPS,
              aPosition: _positionActuelle != null,
              onGPS: _obtenirPosition,
              onPartager: _partagerPosition,
            ),
          ),

          // ── Légende ────────────────────────────────────
          Positioned(
            bottom: 100, left: 16,
            child: const _Legende(),
          ),
        ],
      ),
    );
  }

  Marker _creerMarqueur(_Lieu lieu) {
    return Marker(
      point: lieu.position,
      width: 40, height: 40,
      child: GestureDetector(
        onTap: () => setState(() => _lieuSelectionne = lieu.nom),
        child: _IconeMarqueur(type: lieu.type),
      ),
    );
  }

  Marker _marqueurUtilisateur() {
    return Marker(
      point: LatLng(_positionActuelle!.latitude, _positionActuelle!.longitude),
      width: 50, height: 50,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, __) => Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B5E20).withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1B5E20), width: 2),
            ),
            child: const Icon(Icons.my_location, color: Color(0xFF1B5E20), size: 28),
          ),
        ),
      ),
    );
  }

  Marker _marqueurPartage() {
    return Marker(
      point: _positionPartagee!,
      width: 44, height: 44,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFD700),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: const Icon(Icons.share_location, color: Colors.white, size: 24),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// Widgets auxiliaires
// ══════════════════════════════════════════════════════════

class _AppBarCarte extends StatelessWidget {
  final bool vueZinder;
  final VoidCallback onZinder;
  final VoidCallback onNiger;

  const _AppBarCarte({
    required this.vueZinder,
    required this.onZinder,
    required this.onNiger,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.map_outlined, color: Color(0xFFFFD700), size: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Carte NurHealth — Niger',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _BoutonVue(
                    label: '🌍 Niger',
                    actif: !vueZinder,
                    onTap: onNiger,
                  ),
                  const SizedBox(width: 10),
                  _BoutonVue(
                    label: '🏙️ Zinder',
                    actif: vueZinder,
                    onTap: onZinder,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BoutonVue extends StatelessWidget {
  final String label;
  final bool actif;
  final VoidCallback onTap;

  const _BoutonVue({required this.label, required this.actif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: actif ? const Color(0xFFFFD700) : Colors.white38,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: actif ? const Color(0xFF1B5E20) : Colors.white,
            fontWeight: actif ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PanneauFiltres extends StatelessWidget {
  final bool montrerQuartiers;
  final bool montrerMedicaux;
  final VoidCallback onQuartiers;
  final VoidCallback onMedicaux;

  const _PanneauFiltres({
    required this.montrerQuartiers,
    required this.montrerMedicaux,
    required this.onQuartiers,
    required this.onMedicaux,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          _BoutonFiltre(
            icone: Icons.place,
            label: 'Quartiers',
            actif: montrerQuartiers,
            couleur: const Color(0xFF1B5E20),
            onTap: onQuartiers,
          ),
          const SizedBox(height: 6),
          _BoutonFiltre(
            icone: Icons.local_hospital,
            label: 'Santé',
            actif: montrerMedicaux,
            couleur: Colors.red.shade700,
            onTap: onMedicaux,
          ),
        ],
      ),
    );
  }
}

class _BoutonFiltre extends StatelessWidget {
  final IconData icone;
  final String label;
  final bool actif;
  final Color couleur;
  final VoidCallback onTap;

  const _BoutonFiltre({
    required this.icone,
    required this.label,
    required this.actif,
    required this.couleur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: actif ? couleur.withValues(alpha: 0.12) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: actif ? couleur : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 16, color: actif ? couleur : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: actif ? couleur : Colors.grey,
                fontWeight: actif ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BulleInfo extends StatelessWidget {
  final String nom;
  final VoidCallback onFermer;

  const _BulleInfo({required this.nom, required this.onFermer});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF1B5E20), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              nom,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          GestureDetector(
            onTap: onFermer,
            child: const Icon(Icons.close, color: Colors.grey, size: 20),
          ),
        ],
      ),
    );
  }
}

class _BarreBoutons extends StatelessWidget {
  final bool chargementGPS;
  final bool aPosition;
  final VoidCallback onGPS;
  final VoidCallback onPartager;

  const _BarreBoutons({
    required this.chargementGPS,
    required this.aPosition,
    required this.onGPS,
    required this.onPartager,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BoutonAction(
            icone: chargementGPS
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.my_location, color: Colors.white),
            label: chargementGPS ? 'Localisation...' : 'Ma position',
            couleur: const Color(0xFF1B5E20),
            onTap: chargementGPS ? null : onGPS,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BoutonAction(
            icone: const Icon(Icons.share_location, color: Colors.white),
            label: 'Envoyer au livreur',
            couleur: const Color(0xFFFFD700),
            textCouleur: const Color(0xFF1B5E20),
            onTap: onPartager,
          ),
        ),
      ],
    );
  }
}

class _BoutonAction extends StatelessWidget {
  final Widget icone;
  final String label;
  final Color couleur;
  final Color textCouleur;
  final VoidCallback? onTap;

  const _BoutonAction({
    required this.icone,
    required this.label,
    required this.couleur,
    this.textCouleur = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: couleur.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icone,
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textCouleur,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Legende extends StatelessWidget {
  const _Legende();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _ItemLegende(couleur: Color(0xFF1B5E20), icone: Icons.place,        label: 'Quartier'),
          SizedBox(height: 4),
          _ItemLegende(couleur: Colors.redAccent,  icone: Icons.local_hospital, label: 'Hôpital'),
          SizedBox(height: 4),
          _ItemLegende(couleur: Colors.blue,       icone: Icons.medical_services, label: 'CSI / Soin'),
          SizedBox(height: 4),
          _ItemLegende(couleur: Colors.orange,     icone: Icons.local_pharmacy, label: 'Pharmacie'),
          SizedBox(height: 4),
          _ItemLegende(couleur: Color(0xFF1B5E20), icone: Icons.my_location,   label: 'Ma position'),
        ],
      ),
    );
  }
}

class _ItemLegende extends StatelessWidget {
  final Color couleur;
  final IconData icone;
  final String label;

  const _ItemLegende({required this.couleur, required this.icone, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone, color: couleur, size: 14),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.black87)),
      ],
    );
  }
}

// ── Sheet partage ──────────────────────────────────────────
class _PartageSheet extends StatelessWidget {
  final String message;
  final String lien;
  final VoidCallback onWhatsApp;
  final VoidCallback onSMS;
  final VoidCallback onCopier;

  const _PartageSheet({
    required this.message,
    required this.lien,
    required this.onWhatsApp,
    required this.onSMS,
    required this.onCopier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.share_location, color: Color(0xFF1B5E20), size: 24),
              SizedBox(width: 10),
              Text(
                'Envoyer ma position au livreur',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              lien,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _BoutonPartage(
                  couleur: const Color(0xFF25D366),
                  icone: Icons.chat,
                  label: 'WhatsApp',
                  onTap: onWhatsApp,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BoutonPartage(
                  couleur: Colors.blue.shade600,
                  icone: Icons.sms,
                  label: 'SMS',
                  onTap: onSMS,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _BoutonPartage(
                  couleur: Colors.grey.shade700,
                  icone: Icons.copy,
                  label: 'Copier',
                  onTap: onCopier,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _BoutonPartage extends StatelessWidget {
  final Color couleur;
  final IconData icone;
  final String label;
  final VoidCallback onTap;

  const _BoutonPartage({
    required this.couleur,
    required this.icone,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: couleur,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icone, color: Colors.white, size: 22),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

// ── Icône selon type de lieu ───────────────────────────────
class _IconeMarqueur extends StatelessWidget {
  final TypeLieu type;
  const _IconeMarqueur({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icone;
    Color couleur;
    switch (type) {
      case TypeLieu.quartier:
        icone = Icons.place;
        couleur = const Color(0xFF1B5E20);
        break;
      case TypeLieu.hopital:
        icone = Icons.local_hospital;
        couleur = Colors.redAccent;
        break;
      case TypeLieu.sante:
        icone = Icons.medical_services;
        couleur = Colors.blue;
        break;
      case TypeLieu.pharmacie:
        icone = Icons.local_pharmacy;
        couleur = Colors.orange;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: couleur,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: couleur.withValues(alpha: 0.4), blurRadius: 6)],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icone, color: Colors.white, size: 20),
    );
  }
}

// ── Modèles de données ────────────────────────────────────
enum TypeLieu { quartier, hopital, sante, pharmacie }

class _Lieu {
  final String nom;
  final LatLng position;
  final TypeLieu type;
  const _Lieu(this.nom, this.position, this.type);
}
