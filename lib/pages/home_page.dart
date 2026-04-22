// ============================================================
// NurHealth — Page d'Accueil Patient
// Fichier : lib/pages/home_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // ── Couleurs NurHealth ────────────────────────────────────
  static const Color _primary   = Color(0xFF1B4F72);
  static const Color _secondary = Color(0xFF2980B9);
  static const Color _accent    = Color(0xFF2ECC71);
  static const Color _gold      = Color(0xFFD4AC0D);
  static const Color _danger    = Color(0xFFE74C3C);
  static const Color _bg        = Color(0xFFF0F4F8);

  // ── State ─────────────────────────────────────────────────
  final AuthService _authService = AuthService();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  UserModel? _patient;
  bool _loadingUser = true;
  int _selectedIndex = 0;

  // Données dashboard
  String _prayerTime     = '--:--';
  String _nextPrayer     = 'Fajr';
  String _hijriDate      = '-- -- ----';
  double _sadaqaTotal    = 0;
  int _appointmentsCount = 0;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadPatient();
    _loadDashboardData();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Chargement données ────────────────────────────────────
  Future<void> _loadPatient() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() {
        _patient = UserModel.fromMap(doc.data()!);
        _loadingUser = false;
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      // Rendez-vous
      final appts = await FirebaseFirestore.instance
          .collection('appointments')
          .where('patientId', isEqualTo: uid)
          .where('status', isEqualTo: 'Confirmé')
          .get();
      // Sadaqa
      final sadaqa = await FirebaseFirestore.instance
          .collection('sadaqa')
          .doc(uid)
          .get();
      if (mounted) {
        setState(() {
          _appointmentsCount = appts.docs.length;
          _sadaqaTotal =
              (sadaqa.data()?['total'] ?? 0).toDouble();
          // Calcul simplifié heure prière (Zinder UTC+1)
          final now = DateTime.now().toUtc().add(
              const Duration(hours: 1));
          final h = now.hour;
          if (h < 5) { _nextPrayer = 'Fajr';    _prayerTime = '05:15'; }
          else if (h < 13) { _nextPrayer = 'Dhuhr'; _prayerTime = '13:00'; }
          else if (h < 16) { _nextPrayer = 'Asr';   _prayerTime = '16:20'; }
          else if (h < 19) { _nextPrayer = 'Maghrib';_prayerTime = '19:05'; }
          else { _nextPrayer = 'Isha';   _prayerTime = '20:25'; }
          // Date Hijri simplifiée
          _hijriDate = _getHijriDate();
        });
      }
    } catch (_) {}
  }

  String _getHijriDate() {
    final now = DateTime.now();
    // Algorithme Kuwayti simplifié
    final jd = _toJulian(now.year, now.month, now.day);
    final l = jd - 1948440 + 10632;
    final n = ((l - 1) ~/ 10631);
    final l2 = l - 10631 * n + 354;
    final j = ((10985 - l2) ~/ 5316) * ((50 * l2) ~/ 17719) +
        (l2 ~/ 5670) * ((43 * l2) ~/ 15238);
    final l3 = l2 - ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
        (j ~/ 16) * ((15238 * j) ~/ 43) + 29;
    final month = (24 * l3) ~/ 709;
    final day = l3 - (709 * month) ~/ 24;
    final year = 30 * n + j - 30;
    const months = [
      'Muharram','Safar','Rabi I','Rabi II',
      'Joumada I','Joumada II','Rajab','Chaabane',
      'Ramadan','Chawwal','Dhul Qadah','Dhul Hijja'
    ];
    final mName = (month >= 1 && month <= 12)
        ? months[month - 1] : '?';
    return '$day $mName $year H';
  }

  int _toJulian(int y, int m, int d) {
    final a = (14 - m) ~/ 12;
    final yy = y + 4800 - a;
    final mm = m + 12 * a - 3;
    return d + (153 * mm + 2) ~/ 5 + 365 * yy +
        yy ~/ 4 - yy ~/ 100 + yy ~/ 400 - 32045;
  }

  Future<void> _logout() async {
    await _authService.signOut();
    if (mounted) Navigator.of(context).pushReplacementNamed('/auth');
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: _loadingUser
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : FadeTransition(
              opacity: _fadeAnim,
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildDashboard(),
                  _buildIslamicTab(),
                  _buildHealthTab(),
                  _buildConsultationTab(),
                  _buildProfileTab(),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Dashboard principal ───────────────────────────────────
  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        // AppBar animée
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          backgroundColor: _primary,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Colors.white),
              onPressed: () => _showSnack('Notifications bientôt disponibles'),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Bannière prière
              _buildPrayerBanner(),
              const SizedBox(height: 16),

              // Cartes stats
              Row(children: [
                _statCard('Rendez-vous', '$_appointmentsCount',
                    Icons.calendar_today, _secondary),
                const SizedBox(width: 12),
                _statCard('Sadaqa', '${_sadaqaTotal.toStringAsFixed(0)} FCFA',
                    Icons.volunteer_activism, _gold),
                const SizedBox(width: 12),
                _statCard('IMC', '—', Icons.monitor_weight_outlined, _accent),
              ]),
              const SizedBox(height: 20),

              // Services rapides
              _sectionTitle('Services'),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _serviceCard('Consultation', Icons.medical_services_outlined,
                      _primary, () => setState(() => _selectedIndex = 3)),
                  _serviceCard('Islamique', Icons.menu_book_outlined,
                      _gold, () => setState(() => _selectedIndex = 1)),
                  _serviceCard('Santé', Icons.favorite_outline,
                      _danger, () => setState(() => _selectedIndex = 2)),
                  _serviceCard('Prières', Icons.access_time_outlined,
                      _secondary, () => _showPrayerTimes()),
                  _serviceCard('Dhikr', Icons.loop_outlined,
                      _accent, () => _showDhikrSheet()),
                  _serviceCard('Urgence', Icons.emergency_outlined,
                      _danger, () => _showEmergency()),
                ],
              ),
              const SizedBox(height: 20),

              // Prochain RDV
              _sectionTitle('Prochain rendez-vous'),
              const SizedBox(height: 12),
              _buildNextAppointment(),
              const SizedBox(height: 20),

              // Hadith du jour
              _sectionTitle('Hadith du jour'),
              const SizedBox(height: 12),
              _buildHadithCard(),
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────
  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Bonjour' : hour < 18 ? 'Bon après-midi' : 'Bonsoir';
    final name = _patient?.email.split('@').first ?? 'Frère/Sœur';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B4F72), Color(0xFF154360)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$greeting,',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13)),
                    Text(name.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ],
                ),
              ),
              // Date hijri
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('نور الصحة',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(_hijriDate,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Bannière prière ───────────────────────────────────────
  Widget _buildPrayerBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D3349), Color(0xFF1B4F72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _primary.withOpacity(0.3),
            blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.mosque_outlined, color: Colors.white70, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prochaine prière',
                    style: TextStyle(color: Colors.white60, fontSize: 11)),
                Text(_nextPrayer,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_prayerTime,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 22)),
              Text('Zinder, Niger',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stat Card ─────────────────────────────────────────────
  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w800, color: color)),
            Text(label,
                style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // ── Service Card ──────────────────────────────────────────
  Widget _serviceCard(String label, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700)),
          ],
        ),
      ),
    );
  }

  // ── Prochain RDV ──────────────────────────────────────────
  Widget _buildNextAppointment() {
    if (_appointmentsCount == 0) {
      return GestureDetector(
        onTap: () => setState(() => _selectedIndex = 3),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: _secondary.withOpacity(0.3), style: BorderStyle.solid),
          ),
          child: Row(
            children: [
              Icon(Icons.add_circle_outline, color: _secondary, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aucun rendez-vous',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, color: _primary)),
                    Text('Prenez rendez-vous avec un médecin',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_available, color: _accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consultation Générale',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: _primary)),
                Text('$_appointmentsCount rendez-vous confirmé(s)',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Confirmé',
                style: TextStyle(
                    color: _accent, fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Hadith du jour ────────────────────────────────────────
  Widget _buildHadithCard() {
    const hadiths = [
      {
        'texte':
            'Aucun de vous ne croit vraiment jusqu\'à ce qu\'il aime pour son frère ce qu\'il aime pour lui-même.',
        'source': 'Bukhari & Muslim',
      },
      {
        'texte':
            'Le musulman est celui dont les musulmans sont à l\'abri de sa langue et de sa main.',
        'source': 'Bukhari',
      },
      {
        'texte':
            'La meilleure des actions est la prière en son temps, puis la bonté envers les parents.',
        'source': 'Bukhari & Muslim',
      },
    ];
    final h = hadiths[DateTime.now().day % hadiths.length];
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_gold.withOpacity(0.08), _gold.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _gold.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote, color: _gold, size: 20),
              const SizedBox(width: 8),
              const Text('Hadith du jour',
                  style: TextStyle(
                      color: _gold,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(h['source']!,
                    style: const TextStyle(
                        color: _gold, fontSize: 10,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(h['texte']!,
              style: const TextStyle(
                  fontSize: 14, height: 1.6,
                  color: Color(0xFF2C3E50))),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ONGLET ISLAMIQUE
  // ══════════════════════════════════════════════════════════
  Widget _buildIslamicTab() {
    final items = [
      {'label': 'Quran', 'icon': Icons.menu_book,
          'color': _primary, 'route': '/quran'},
      {'label': 'Audio Quran', 'icon': Icons.headphones,
          'color': _secondary, 'route': '/audio-quran'},
      {'label': '40 Hadiths', 'icon': Icons.collections_bookmark,
          'color': _gold, 'route': '/hadiths'},
      {'label': 'Riyad As-Salihin', 'icon': Icons.auto_stories,
          'color': Color(0xFF8E44AD), 'route': '/riyad'},
      {'label': 'Bulugh Al-Maram', 'icon': Icons.library_books,
          'color': Color(0xFF16A085), 'route': '/bulugh'},
      {'label': 'Dhikr & Dua', 'icon': Icons.loop,
          'color': _accent, 'route': '/dhikr'},
      {'label': 'Tasbih', 'icon': Icons.radio_button_checked,
          'color': _danger, 'route': '/tasbih'},
      {'label': 'Horaires Prières', 'icon': Icons.access_time,
          'color': Color(0xFFF39C12), 'route': '/prayers'},
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Bibliothèque Islamique',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.2,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) {
            final item = items[i];
            final color = item['color'] as Color;
            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                  context, item['route'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData,
                          color: color, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(item['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Colors.grey.shade800)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ONGLET SANTÉ
  // ══════════════════════════════════════════════════════════
  Widget _buildHealthTab() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _danger,
        title: const Text('Ma Santé',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Calculateur IMC
            _healthCard(
              title: 'Calculateur IMC',
              subtitle: 'Indice de Masse Corporelle',
              icon: Icons.monitor_weight_outlined,
              color: _danger,
              onTap: () => _showBmiCalculator(),
            ),
            const SizedBox(height: 12),
            _healthCard(
              title: 'Médecine Prophétique',
              subtitle: 'Plantes & remèdes sunnah',
              icon: Icons.local_florist_outlined,
              color: _accent,
              onTap: () => _showSnack('Bientôt disponible'),
            ),
            const SizedBox(height: 12),
            _healthCard(
              title: 'Suivi Glycémie',
              subtitle: 'Diabète & surveillance',
              icon: Icons.monitor_heart_outlined,
              color: _secondary,
              onTap: () => _showSnack('Bientôt disponible'),
            ),
            const SizedBox(height: 12),
            _healthCard(
              title: 'Tension Artérielle',
              subtitle: 'Hypertension & suivi',
              icon: Icons.favorite_outline,
              color: _danger,
              onTap: () => _showSnack('Bientôt disponible'),
            ),
            const SizedBox(height: 12),
            _healthCard(
              title: 'Rappels Médicaments',
              subtitle: 'Alarmes personnalisées',
              icon: Icons.medication_outlined,
              color: _gold,
              onTap: () => _showSnack('Bientôt disponible'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _healthCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15, color: _primary)),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ONGLET CONSULTATION
  // ══════════════════════════════════════════════════════════
  Widget _buildConsultationTab() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _secondary,
        title: const Text('Consultations',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bouton RDV
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4F72), Color(0xFF2980B9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                    color: _primary.withOpacity(0.35),
                    blurRadius: 14, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  const Icon(Icons.medical_services,
                      color: Colors.white, size: 36),
                  const SizedBox(height: 10),
                  const Text('Prendre un rendez-vous',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text('Consultez nos médecins à Zinder',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13)),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/book-appointment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: _primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                    ),
                    child: const Text('Réserver maintenant',
                        style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Spécialités disponibles'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                'Médecine générale', 'Pédiatrie', 'Gynécologie',
                'Cardiologie', 'Diabétologie', 'Dermatologie',
              ].map((s) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _secondary.withOpacity(0.3)),
                    ),
                    child: Text(s,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _secondary)),
                  )).toList(),
            ),
            const SizedBox(height: 20),

            _sectionTitle('Paiement accepté'),
            const SizedBox(height: 12),
            Row(
              children: [
                _paymentBadge('Orange Money', const Color(0xFFFF6600)),
                const SizedBox(width: 12),
                _paymentBadge('Moov Money', const Color(0xFF0070C0)),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _paymentBadge(String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // ONGLET PROFIL
  // ══════════════════════════════════════════════════════════
  Widget _buildProfileTab() {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _primary,
        title: const Text('Mon Profil',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [_primary, _secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.person,
                        color: Colors.white, size: 38),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _patient?.email.split('@').first.toUpperCase() ?? '---',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18),
                  ),
                  Text(_patient?.email ?? '',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: _accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accent.withOpacity(0.5)),
                    ),
                    child: const Text('Patient NurHealth',
                        style: TextStyle(
                            color: _accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _profileItem(Icons.email_outlined, 'Email',
                _patient?.email ?? '---'),
            _profileItem(Icons.phone_outlined, 'Téléphone',
                _patient?.phone ?? 'Non renseigné'),
            _profileItem(Icons.location_on_outlined, 'Ville', 'Zinder, Niger'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Se déconnecter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _danger,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: _primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade400, fontSize: 11)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14, color: _primary)),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BOTTOM NAV
  // ══════════════════════════════════════════════════════════
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.white,
        selectedItemColor: _primary,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Accueil'),
          BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Islamique'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Santé'),
          BottomNavigationBarItem(
              icon: Icon(Icons.medical_services_outlined),
              activeIcon: Icon(Icons.medical_services),
              label: 'Consulter'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil'),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BOTTOM SHEETS & DIALOGS
  // ══════════════════════════════════════════════════════════

  // Horaires prières
  void _showPrayerTimes() {
    final prayers = [
      {'name': 'Fajr',    'time': '05:15', 'arabic': 'الفجر'},
      {'name': 'Dhuhr',   'time': '13:00', 'arabic': 'الظهر'},
      {'name': 'Asr',     'time': '16:20', 'arabic': 'العصر'},
      {'name': 'Maghrib', 'time': '19:05', 'arabic': 'المغرب'},
      {'name': 'Isha',    'time': '20:25', 'arabic': 'العشاء'},
    ];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Horaires de Prières — Zinder',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16, color: _primary)),
            const SizedBox(height: 4),
            Text(_hijriDate,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
            const SizedBox(height: 16),
            ...prayers.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: p['name'] == _nextPrayer
                        ? _primary.withOpacity(0.08)
                        : const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(12),
                    border: p['name'] == _nextPrayer
                        ? Border.all(color: _primary.withOpacity(0.3))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Text(p['arabic']!,
                          style: const TextStyle(
                              fontSize: 16, color: _gold)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(p['name']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _primary)),
                      ),
                      Text(p['time']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16, color: _primary)),
                      if (p['name'] == _nextPrayer) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _accent, borderRadius: BorderRadius.circular(6)),
                          child: const Text('Prochaine',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 9,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // Dhikr rapide
  void _showDhikrSheet() {
    int count = 0;
    final dhikrs = [
      {'text': 'سُبْحَانَ اللَّه', 'trans': 'Subhanallah', 'target': 33},
      {'text': 'الْحَمْدُ لِلَّه', 'trans': 'Alhamdulillah', 'target': 33},
      {'text': 'اللَّهُ أَكْبَر', 'trans': 'Allahu Akbar', 'target': 34},
    ];
    int dhikrIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(dhikrs[dhikrIndex]['text'] as String,
                  style: const TextStyle(
                      fontSize: 32, color: _gold,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(dhikrs[dhikrIndex]['trans'] as String,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  final target = dhikrs[dhikrIndex]['target'] as int;
                  setS(() {
                    count++;
                    if (count >= target) {
                      count = 0;
                      dhikrIndex = (dhikrIndex + 1) % dhikrs.length;
                    }
                  });
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_primary, _secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: _primary.withOpacity(0.4),
                        blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Center(
                    child: Text('$count',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Objectif : ${dhikrs[dhikrIndex]['target']}x',
                  style: TextStyle(color: Colors.grey.shade500)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => setS(() => count = 0),
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Urgence
  void _showEmergency() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.emergency, color: _danger, size: 28),
            SizedBox(width: 10),
            Text('Urgence médicale',
                style: TextStyle(color: _danger, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _emergencyBtn('SAMU Zinder', '15', Icons.local_hospital),
            const SizedBox(height: 10),
            _emergencyBtn('Police', '17', Icons.local_police_outlined),
            const SizedBox(height: 10),
            _emergencyBtn('Sapeurs-Pompiers', '18', Icons.fire_truck_outlined),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  Widget _emergencyBtn(String label, String num, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _danger.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: _danger, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _primary)),
          ),
          Text(num,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: _danger, fontSize: 18)),
        ],
      ),
    );
  }

  // Calculateur IMC
  void _showBmiCalculator() {
    final weightCtrl = TextEditingController();
    final heightCtrl = TextEditingController();
    double? bmi;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
              left: 24, right: 24, top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calculateur IMC',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18, color: _primary)),
              const SizedBox(height: 20),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Poids (kg)',
                  filled: true, fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 2)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Taille (cm)',
                  filled: true, fillColor: _bg,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 2)),
                ),
              ),
              const SizedBox(height: 16),
              if (bmi != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _getBmiColor(bmi!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _getBmiColor(bmi!).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(bmi!.toStringAsFixed(1),
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w800,
                              color: _getBmiColor(bmi!))),
                      const SizedBox(width: 12),
                      Text(_getBmiLabel(bmi!),
                          style: TextStyle(
                              color: _getBmiColor(bmi!),
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final w = double.tryParse(weightCtrl.text);
                    final h = double.tryParse(heightCtrl.text);
                    if (w != null && h != null && h > 0) {
                      setS(() => bmi = w / ((h / 100) * (h / 100)));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Calculer',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return _secondary;
    if (bmi < 25) return _accent;
    if (bmi < 30) return _gold;
    return _danger;
  }

  String _getBmiLabel(double bmi) {
    if (bmi < 18.5) return 'Insuffisance pondérale';
    if (bmi < 25) return 'Poids normal ✓';
    if (bmi < 30) return 'Surpoids';
    return 'Obésité';
  }

  // ── Utilitaires ───────────────────────────────────────────
  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _primary));
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
}
