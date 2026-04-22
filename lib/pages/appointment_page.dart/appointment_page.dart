// ============================================================
// NurHealth — Système de Rendez-vous Complet
// Fichier : lib/pages/appointment_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ══════════════════════════════════════════════════════════════
// MODÈLE RENDEZ-VOUS
// ══════════════════════════════════════════════════════════════
class Appointment {
  final String id;
  final String patientId;
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String specialite;
  final DateTime date;
  final String timeSlot;
  final String motif;
  final String status; // 'en_attente', 'confirme', 'annule', 'termine'
  final String paymentMethod; // 'orange_money', 'moov_money', 'especes'
  final double montant;
  final String? notes;
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.specialite,
    required this.date,
    required this.timeSlot,
    required this.motif,
    required this.status,
    required this.paymentMethod,
    required this.montant,
    this.notes,
    required this.createdAt,
  });

  factory Appointment.fromMap(Map<String, dynamic> m, String id) {
    return Appointment(
      id: id,
      patientId: m['patientId'] ?? '',
      patientName: m['patientName'] ?? '',
      patientPhone: m['patientPhone'] ?? '',
      doctorId: m['doctorId'] ?? '',
      doctorName: m['doctorName'] ?? '',
      specialite: m['specialite'] ?? '',
      date: (m['date'] as Timestamp).toDate(),
      timeSlot: m['timeSlot'] ?? '',
      motif: m['motif'] ?? '',
      status: m['status'] ?? 'en_attente',
      paymentMethod: m['paymentMethod'] ?? 'especes',
      montant: (m['montant'] ?? 0).toDouble(),
      notes: m['notes'],
      createdAt: (m['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'patientId': patientId,
    'patientName': patientName,
    'patientPhone': patientPhone,
    'doctorId': doctorId,
    'doctorName': doctorName,
    'specialite': specialite,
    'date': Timestamp.fromDate(date),
    'timeSlot': timeSlot,
    'motif': motif,
    'status': status,
    'paymentMethod': paymentMethod,
    'montant': montant,
    'notes': notes,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ══════════════════════════════════════════════════════════════
// SERVICE RENDEZ-VOUS
// ══════════════════════════════════════════════════════════════
class AppointmentService {
  final _db = FirebaseFirestore.instance;

  // Créer un RDV
  Future<String?> createAppointment(Appointment appt) async {
    try {
      final ref = await _db.collection('appointments').add(appt.toMap());
      return ref.id;
    } catch (e) {
      return null;
    }
  }

  // RDV du patient connecté
  Stream<List<Appointment>> getPatientAppointments(String patientId) {
    return _db
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Appointment.fromMap(d.data(), d.id))
            .toList());
  }

  // RDV du médecin
  Stream<List<Appointment>> getDoctorAppointments(String doctorId) {
    return _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => Appointment.fromMap(d.data(), d.id))
            .toList());
  }

  // Créneaux déjà pris pour un médecin/date
  Future<List<String>> getTakenSlots(String doctorId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final snap = await _db
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(end))
        .where('status', whereIn: ['en_attente', 'confirme'])
        .get();
    return snap.docs.map((d) => d.data()['timeSlot'] as String).toList();
  }

  // Mettre à jour le statut
  Future<bool> updateStatus(String apptId, String status, {String? notes}) async {
    try {
      final data = {'status': status};
      if (notes != null) data['notes'] = notes;
      await _db.collection('appointments').doc(apptId).update(data);
      return true;
    } catch (_) { return false; }
  }

  // Annuler un RDV
  Future<bool> cancelAppointment(String apptId) =>
      updateStatus(apptId, 'annule');

  // Liste médecins disponibles
  Future<List<Map<String, dynamic>>> getDoctors() async {
    final snap = await _db
        .collection('users')
        .where('role', isEqualTo: 'doctor')
        .where('isApproved', isEqualTo: true)
        .get();
    return snap.docs.map((d) => {...d.data(), 'uid': d.id}).toList();
  }
}

// ══════════════════════════════════════════════════════════════
// PAGE RÉSERVATION
// ══════════════════════════════════════════════════════════════
class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  // ── Couleurs ──────────────────────────────────────────────
  static const Color _primary   = Color(0xFF1B4F72);
  static const Color _secondary = Color(0xFF2980B9);
  static const Color _accent    = Color(0xFF2ECC71);
  static const Color _gold      = Color(0xFFD4AC0D);
  static const Color _bg        = Color(0xFFF0F4F8);

  final AppointmentService _service = AppointmentService();
  final _nameCtrl   = TextEditingController();
  final _phoneCtrl  = TextEditingController();
  final _motifCtrl  = TextEditingController();

  // Étapes de réservation
  int _step = 0; // 0=médecin 1=date 2=créneau 3=infos 4=paiement 5=confirmation

  // Sélections
  Map<String, dynamic>? _selectedDoctor;
  DateTime? _selectedDate;
  String? _selectedSlot;
  String _selectedPayment = 'especes';

  // Data
  List<Map<String, dynamic>> _doctors = [];
  List<String> _takenSlots = [];
  bool _loading = false;
  bool _submitting = false;

  // Créneaux horaires disponibles
  final List<String> _allSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '14:00', '14:30', '15:00', '15:30',
    '16:00', '16:30', '17:00', '17:30',
  ];

  // Motifs fréquents
  final List<String> _motifsSuggeres = [
    'Consultation générale', 'Fièvre / Paludisme', 'Douleurs abdominales',
    'Suivi diabète', 'Tension artérielle', 'Consultation enfant',
    'Grossesse / Suivi', 'Renouvellement ordonnance',
  ];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _motifCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadDoctors() async {
    setState(() => _loading = true);
    final docs = await _service.getDoctors();
    // Si pas de médecins en base, afficher des exemples
    setState(() {
      _doctors = docs.isNotEmpty ? docs : _mockDoctors();
      _loading = false;
    });
  }

  List<Map<String, dynamic>> _mockDoctors() => [
    {
      'uid': 'doc1',
      'email': 'dr.moussa@nurhealth.ne',
      'specialite': 'Médecine Générale',
      'tarif': 3000,
      'isApproved': true,
    },
    {
      'uid': 'doc2',
      'email': 'dr.fatima@nurhealth.ne',
      'specialite': 'Pédiatrie',
      'tarif': 4000,
      'isApproved': true,
    },
    {
      'uid': 'doc3',
      'email': 'dr.ibrahim@nurhealth.ne',
      'specialite': 'Cardiologie',
      'tarif': 5000,
      'isApproved': true,
    },
    {
      'uid': 'doc4',
      'email': 'dr.aissa@nurhealth.ne',
      'specialite': 'Gynécologie',
      'tarif': 4500,
      'isApproved': true,
    },
  ];

  Future<void> _loadTakenSlots() async {
    if (_selectedDoctor == null || _selectedDate == null) return;
    final taken = await _service.getTakenSlots(
      _selectedDoctor!['uid'], _selectedDate!);
    setState(() => _takenSlots = taken);
  }

  Future<void> _submitAppointment() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _submitting = true);

    final appt = Appointment(
      id: '',
      patientId: uid,
      patientName: _nameCtrl.text.trim(),
      patientPhone: '+227${_phoneCtrl.text.trim()}',
      doctorId: _selectedDoctor!['uid'],
      doctorName: _selectedDoctor!['email'].toString().split('@').first,
      specialite: _selectedDoctor!['specialite'],
      date: _selectedDate!,
      timeSlot: _selectedSlot!,
      motif: _motifCtrl.text.trim(),
      status: 'en_attente',
      paymentMethod: _selectedPayment,
      montant: (_selectedDoctor!['tarif'] ?? 3000).toDouble(),
      createdAt: DateTime.now(),
    );

    final id = await _service.createAppointment(appt);
    if (mounted) {
      setState(() { _submitting = false; _step = 5; });
    }
  }

  // ── BUILD ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Prendre Rendez-vous',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: _buildProgressBar(),
        ),
      ),
      body: _step == 5
          ? _buildConfirmation()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepIndicator(),
                  const SizedBox(height: 20),
                  _buildStepContent(),
                ],
              ),
            ),
      bottomNavigationBar: _step < 5 ? _buildBottomBar() : null,
    );
  }

  // ── Barre progression ─────────────────────────────────────
  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (_step + 1) / 5,
      backgroundColor: Colors.white.withOpacity(0.3),
      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2ECC71)),
      minHeight: 6,
    );
  }

  // ── Indicateur étapes ─────────────────────────────────────
  Widget _buildStepIndicator() {
    final steps = ['Médecin', 'Date', 'Créneau', 'Infos', 'Paiement'];
    return Row(
      children: List.generate(steps.length, (i) {
        final done = i < _step;
        final active = i == _step;
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: done
                            ? _accent
                            : active ? _primary : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text('${i + 1}',
                                style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey.shade500,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(steps[i],
                        style: TextStyle(
                            fontSize: 9,
                            color: active ? _primary : Colors.grey.shade400,
                            fontWeight: active
                                ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
              if (i < steps.length - 1)
                Container(
                  height: 2, width: 16,
                  color: done ? _accent : Colors.grey.shade300,
                ),
            ],
          ),
        );
      }),
    );
  }

  // ── Contenu selon étape ───────────────────────────────────
  Widget _buildStepContent() {
    switch (_step) {
      case 0: return _buildStepDoctor();
      case 1: return _buildStepDate();
      case 2: return _buildStepSlot();
      case 3: return _buildStepInfo();
      case 4: return _buildStepPayment();
      default: return const SizedBox();
    }
  }

  // ── Étape 0 : Choix médecin ───────────────────────────────
  Widget _buildStepDoctor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Choisissez un médecin', 'Médecins disponibles à Zinder'),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator(color: _primary))
        else
          ..._doctors.map((doc) {
            final selected = _selectedDoctor?['uid'] == doc['uid'];
            final name = doc['email'].toString().split('@').first;
            return GestureDetector(
              onTap: () => setState(() => _selectedDoctor = doc),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? _primary : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _primary.withOpacity(0.1),
                      child: Text(
                        name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            color: _primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dr. ${name.toUpperCase()}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: _primary, fontSize: 14)),
                          Text(doc['specialite'] ?? '',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${doc['tarif'] ?? 3000} FCFA',
                            style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: _gold, fontSize: 14)),
                        if (selected)
                          const Icon(Icons.check_circle,
                              color: _accent, size: 20),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  // ── Étape 1 : Choix date ──────────────────────────────────
  Widget _buildStepDate() {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i + 1)));
    final jours = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final mois = ['Jan','Fév','Mar','Avr','Mai','Jun',
                  'Jul','Aoû','Sep','Oct','Nov','Déc'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Choisissez une date', '14 prochains jours disponibles'),
        const SizedBox(height: 16),
        // Médecin sélectionné
        _selectedDoctorBadge(),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemCount: dates.length,
          itemBuilder: (_, i) {
            final date = dates[i];
            final isWeekend = date.weekday == 7; // Dimanche
            final selected = _selectedDate != null &&
                _selectedDate!.day == date.day &&
                _selectedDate!.month == date.month;
            return GestureDetector(
              onTap: isWeekend ? null : () async {
                setState(() => _selectedDate = date);
                await _loadTakenSlots();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isWeekend
                      ? Colors.grey.shade100
                      : selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _primary : Colors.grey.shade200),
                  boxShadow: selected ? [BoxShadow(
                      color: _primary.withOpacity(0.3),
                      blurRadius: 8, offset: const Offset(0, 3))] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(jours[date.weekday - 1],
                        style: TextStyle(
                            fontSize: 10,
                            color: isWeekend
                                ? Colors.grey.shade400
                                : selected ? Colors.white70 : Colors.grey,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text('${date.day}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: isWeekend
                                ? Colors.grey.shade300
                                : selected ? Colors.white : _primary)),
                    Text(mois[date.month - 1],
                        style: TextStyle(
                            fontSize: 10,
                            color: isWeekend
                                ? Colors.grey.shade400
                                : selected ? Colors.white70 : Colors.grey)),
                  ],
                ),
              ),
            );
          },
        ),
        if (_selectedDate != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available, color: _accent, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Sélectionné : ${jours[_selectedDate!.weekday - 1]} '
                  '${_selectedDate!.day} ${mois[_selectedDate!.month - 1]}',
                  style: const TextStyle(
                      color: _accent, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Étape 2 : Créneaux ────────────────────────────────────
  Widget _buildStepSlot() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Choisissez un créneau', 'Horaires disponibles'),
        const SizedBox(height: 16),
        _selectedDoctorBadge(),
        const SizedBox(height: 8),
        if (_selectedDate != null)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: _secondary, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                  style: const TextStyle(
                      color: _secondary, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        // Matin
        _slotSection('Matin', _allSlots.where((s) {
          final h = int.parse(s.split(':')[0]);
          return h < 12;
        }).toList()),
        const SizedBox(height: 16),
        // Après-midi
        _slotSection('Après-midi', _allSlots.where((s) {
          final h = int.parse(s.split(':')[0]);
          return h >= 12;
        }).toList()),
      ],
    );
  }

  Widget _slotSection(String title, List<String> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w700,
                fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: slots.map((slot) {
            final taken = _takenSlots.contains(slot);
            final selected = _selectedSlot == slot;
            return GestureDetector(
              onTap: taken ? null : () => setState(() => _selectedSlot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: taken
                      ? Colors.grey.shade100
                      : selected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: taken
                        ? Colors.grey.shade200
                        : selected ? _primary : Colors.grey.shade300,
                  ),
                ),
                child: Text(slot,
                    style: TextStyle(
                        color: taken
                            ? Colors.grey.shade400
                            : selected ? Colors.white : _primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        decoration: taken
                            ? TextDecoration.lineThrough : null)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Étape 3 : Informations patient ────────────────────────
  Widget _buildStepInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Vos informations', 'Renseignez vos coordonnées'),
        const SizedBox(height: 16),
        _inputField(_nameCtrl, 'Nom complet', Icons.person_outline),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text('🇳🇪 +227',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _inputField(
                _phoneCtrl, 'Numéro téléphone',
                Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Motif
        const Text('Motif de consultation',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _primary, fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _motifsSuggeres.map((m) => GestureDetector(
            onTap: () => setState(() => _motifCtrl.text = m),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _motifCtrl.text == m
                    ? _primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _motifCtrl.text == m
                      ? _primary : Colors.grey.shade300),
              ),
              child: Text(m,
                  style: TextStyle(
                      fontSize: 11,
                      color: _motifCtrl.text == m
                          ? _primary : Colors.grey.shade600,
                      fontWeight: _motifCtrl.text == m
                          ? FontWeight.w700 : FontWeight.w500)),
            ),
          )).toList(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _motifCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Ou décrivez votre motif...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: _primary, width: 2)),
          ),
        ),
      ],
    );
  }

  // ── Étape 4 : Paiement ────────────────────────────────────
  Widget _buildStepPayment() {
    final tarif = (_selectedDoctor?['tarif'] ?? 3000) as int;
    final methods = [
      {
        'id': 'orange_money',
        'label': 'Orange Money',
        'number': '69 XX XX XX',
        'color': const Color(0xFFFF6600),
        'icon': Icons.phone_android,
      },
      {
        'id': 'moov_money',
        'label': 'Moov Money',
        'number': '96 XX XX XX',
        'color': const Color(0xFF0070C0),
        'icon': Icons.phone_android,
      },
      {
        'id': 'especes',
        'label': 'Espèces (sur place)',
        'number': 'Au cabinet',
        'color': const Color(0xFF2ECC71),
        'icon': Icons.payments_outlined,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stepTitle('Mode de paiement', 'Choisissez comment payer'),
        const SizedBox(height: 16),

        // Récapitulatif
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            children: [
              _recapRow('Médecin',
                  'Dr. ${(_selectedDoctor?['email'] ?? '').toString().split('@').first}'),
              _recapRow('Spécialité',
                  _selectedDoctor?['specialite'] ?? ''),
              _recapRow('Date',
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : ''),
              _recapRow('Créneau', _selectedSlot ?? ''),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total à payer',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: _primary)),
                  Text('$tarif FCFA',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _gold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Modes paiement
        ...methods.map((m) {
          final selected = _selectedPayment == m['id'];
          final color = m['color'] as Color;
          return GestureDetector(
            onTap: () => setState(() => _selectedPayment = m['id'] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? color : Colors.grey.shade200,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(m['icon'] as IconData,
                        color: color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['label'] as String,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: selected ? color : _primary)),
                        Text(m['number'] as String,
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle, color: color, size: 22),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Confirmation ──────────────────────────────────────────
  Widget _buildConfirmation() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F8F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle,
                  color: _accent, size: 60),
            ),
            const SizedBox(height: 24),
            const Text('Rendez-vous confirmé !',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _primary),
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              'Votre rendez-vous avec Dr. ${(_selectedDoctor?['email'] ?? '').toString().split('@').first} '
              'le ${_selectedDate?.day}/${_selectedDate?.month} à $_selectedSlot a été enregistré.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              child: const Text(
                '⏳ En attente de confirmation du médecin.\nVous serez notifié par SMS.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _gold, fontSize: 13, height: 1.5),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Retour à l\'accueil',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(
                  context, '/mes-rdv'),
              child: const Text('Voir mes rendez-vous',
                  style: TextStyle(color: _secondary)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Barre navigation bas ──────────────────────────────────
  Widget _buildBottomBar() {
    final canNext = _canGoNext();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retour',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canNext
                  ? () {
                      if (_step == 4) {
                        _submitAppointment();
                      } else {
                        setState(() => _step++);
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _step == 4 ? 'Confirmer le RDV' : 'Suivant →',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }

  bool _canGoNext() {
    switch (_step) {
      case 0: return _selectedDoctor != null;
      case 1: return _selectedDate != null;
      case 2: return _selectedSlot != null;
      case 3: return _nameCtrl.text.isNotEmpty &&
                     _phoneCtrl.text.isNotEmpty &&
                     _motifCtrl.text.isNotEmpty;
      case 4: return true;
      default: return false;
    }
  }

  // ── Widgets réutilisables ─────────────────────────────────
  Widget _stepTitle(String title, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w800, color: _primary)),
        Text(sub,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }

  Widget _selectedDoctorBadge() {
    if (_selectedDoctor == null) return const SizedBox();
    final name = _selectedDoctor!['email'].toString().split('@').first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, color: _primary, size: 16),
          const SizedBox(width: 6),
          Text('Dr. ${name.toUpperCase()} — ${_selectedDoctor!['specialite']}',
              style: const TextStyle(
                  color: _primary, fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ],
      ),
    );
  }

  Widget _recapRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: _primary)),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary, size: 20),
        filled: true,
        fillColor: Colors.white,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 2)),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// PAGE MES RENDEZ-VOUS (PATIENT)
// ══════════════════════════════════════════════════════════════
class MesRendezVousPage extends StatelessWidget {
  const MesRendezVousPage({super.key});

  static const Color _primary   = Color(0xFF1B4F72);
  static const Color _secondary = Color(0xFF2980B9);
  static const Color _accent    = Color(0xFF2ECC71);
  static const Color _gold      = Color(0xFFD4AC0D);
  static const Color _danger    = Color(0xFFE74C3C);
  static const Color _bg        = Color(0xFFF0F4F8);

  Color _statusColor(String status) {
    switch (status) {
      case 'confirme':    return _accent;
      case 'en_attente':  return _gold;
      case 'annule':      return _danger;
      case 'termine':     return Colors.grey;
      default:            return _secondary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'confirme':    return 'Confirmé ✓';
      case 'en_attente':  return 'En attente ⏳';
      case 'annule':      return 'Annulé ✗';
      case 'termine':     return 'Terminé';
      default:            return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final service = AppointmentService();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Mes Rendez-vous',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/book-appointment'),
            tooltip: 'Nouveau RDV',
          ),
        ],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: service.getPatientAppointments(uid),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _primary));
          }
          final appts = snap.data ?? [];
          if (appts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 70, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Aucun rendez-vous',
                      style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/book-appointment'),
                    icon: const Icon(Icons.add),
                    label: const Text('Prendre rendez-vous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appts.length,
            itemBuilder: (_, i) {
              final a = appts[i];
              final statusColor = _statusColor(a.status);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8, offset: const Offset(0, 3))],
                ),
                child: Column(
                  children: [
                    // En-tête statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.08),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(_statusLabel(a.status),
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12)),
                          const Spacer(),
                          Text(
                            '${a.date.day}/${a.date.month}/${a.date.year} à ${a.timeSlot}',
                            style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    // Corps
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: _primary.withOpacity(0.1),
                                child: Text(
                                  a.doctorName.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                      color: _primary,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. ${a.doctorName.toUpperCase()}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: _primary),
                                    ),
                                    Text(a.specialite,
                                        style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text('${a.montant.toInt()} FCFA',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _gold)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.notes_outlined,
                                    color: Colors.grey.shade500, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(a.motif,
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13)),
                                ),
                              ],
                            ),
                          ),
                          // Bouton annuler
                          if (a.status == 'en_attente') ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () async {
                                  final ok = await service
                                      .cancelAppointment(a.id);
                                  if (ok && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text('RDV annulé'),
                                      backgroundColor: _danger,
                                    ));
                                  }
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _danger,
                                  side: const BorderSide(color: _danger),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                ),
                                child: const Text('Annuler ce RDV',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
