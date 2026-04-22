import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════
//  NURHEALTH — نور الصحة — Version 3.0
//  SOCIETE ANY-SERVICE SARL — Zinder, Niger
// ═══════════════════════════════════════════════════════════════

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const NurHealthApp());
}

// ── COULEURS ──────────────────────────────────────────────────
const Color kVert = Color(0xFF1B4332);
const Color kVertClair = Color(0xFF2D6A4F);
const Color kOr = Color(0xFFD4AF37);
const Color kOrClair = Color(0xFFF0D060);
const Color kBlanc = Color(0xFFFFFFFF);
const Color kGrisClair = Color(0xFFF5F5F5);
const Color kGris = Color(0xFF9E9E9E);
const Color kRouge = Color(0xFFE53935);
const Color kBleu = Color(0xFF1565C0);

// ── MODÈLES DE DONNÉES ────────────────────────────────────────

class UserProfile {
  String id;
  String nom;
  String prenom;
  String email;
  String telephone;
  String dateNaissance;
  String sexe;
  String groupe_sanguin;
  List<String> allergies;
  List<String> maladiesChroniques;
  double poids;
  double taille;
  double solde;

  UserProfile({
    this.id = '',
    this.nom = '',
    this.prenom = '',
    this.email = '',
    this.telephone = '',
    this.dateNaissance = '',
    this.sexe = 'Homme',
    this.groupe_sanguin = 'A+',
    this.allergies = const [],
    this.maladiesChroniques = const [],
    this.poids = 0,
    this.taille = 0,
    this.solde = 0,
  });
}

class Medecin {
  final String id;
  final String nom;
  final String specialite;
  final String photo;
  final double tarif;
  final double note;
  final int consultations;
  final bool disponible;
  final String ville;

  const Medecin({
    required this.id,
    required this.nom,
    required this.specialite,
    required this.photo,
    required this.tarif,
    required this.note,
    required this.consultations,
    required this.disponible,
    required this.ville,
  });
}

class Medicament {
  final String id;
  final String nom;
  final String description;
  final String categorie;
  final double prix;
  final bool disponible;
  final bool ordonnanceRequise;
  final String image;

  const Medicament({
    required this.id,
    required this.nom,
    required this.description,
    required this.categorie,
    required this.prix,
    required this.disponible,
    required this.ordonnanceRequise,
    required this.image,
  });
}

class CommandeLivraison {
  String id;
  List<Map<String, dynamic>> articles;
  String adresse;
  String methodePaiement;
  double total;
  String statut;
  DateTime dateCommande;

  CommandeLivraison({
    required this.id,
    required this.articles,
    required this.adresse,
    required this.methodePaiement,
    required this.total,
    required this.statut,
    required this.dateCommande,
  });
}

// ── DONNÉES STATIQUES ─────────────────────────────────────────

final List<Medecin> kMedecins = [
  const Medecin(
    id: 'm1',
    nom: 'Dr. Abdoulaye Mahamane',
    specialite: 'Médecin Généraliste',
    photo: '👨‍⚕️',
    tarif: 5000,
    note: 4.8,
    consultations: 234,
    disponible: true,
    ville: 'Zinder',
  ),
  const Medecin(
    id: 'm2',
    nom: 'Dr. Fatouma Issaka',
    specialite: 'Pédiatre',
    photo: '👩‍⚕️',
    tarif: 7500,
    note: 4.9,
    consultations: 189,
    disponible: true,
    ville: 'Zinder',
  ),
  const Medecin(
    id: 'm3',
    nom: 'Dr. Ibrahim Sani',
    specialite: 'Cardiologue',
    photo: '👨‍⚕️',
    tarif: 10000,
    note: 4.7,
    consultations: 312,
    disponible: false,
    ville: 'Niamey',
  ),
  const Medecin(
    id: 'm4',
    nom: 'Dr. Halima Moussa',
    specialite: 'Gynécologue',
    photo: '👩‍⚕️',
    tarif: 8000,
    note: 4.9,
    consultations: 156,
    disponible: true,
    ville: 'Zinder',
  ),
  const Medecin(
    id: 'm5',
    nom: 'Dr. Oumarou Tahirou',
    specialite: 'Ophtalmologue',
    photo: '👨‍⚕️',
    tarif: 6000,
    note: 4.6,
    consultations: 98,
    disponible: true,
    ville: 'Zinder',
  ),
];

final List<Medicament> kMedicaments = [
  const Medicament(
    id: 'med1',
    nom: 'Paracétamol 500mg',
    description:
        'Antalgique et antipyrétique. Soulage la douleur et la fièvre.',
    categorie: 'Antalgiques',
    prix: 500,
    disponible: true,
    ordonnanceRequise: false,
    image: '💊',
  ),
  const Medicament(
    id: 'med2',
    nom: 'Amoxicilline 500mg',
    description: 'Antibiotique à large spectre. Sur ordonnance uniquement.',
    categorie: 'Antibiotiques',
    prix: 2500,
    disponible: true,
    ordonnanceRequise: true,
    image: '💊',
  ),
  const Medicament(
    id: 'med3',
    nom: 'Artéméther-Luméfantrine',
    description: 'Traitement du paludisme non compliqué.',
    categorie: 'Antipaludéens',
    prix: 3500,
    disponible: true,
    ordonnanceRequise: true,
    image: '💊',
  ),
  const Medicament(
    id: 'med4',
    nom: 'Vitamine C 1000mg',
    description: 'Renforce le système immunitaire.',
    categorie: 'Vitamines',
    prix: 1500,
    disponible: true,
    ordonnanceRequise: false,
    image: '🍊',
  ),
  const Medicament(
    id: 'med5',
    nom: 'Metformine 850mg',
    description: 'Traitement du diabète de type 2.',
    categorie: 'Antidiabétiques',
    prix: 2000,
    disponible: true,
    ordonnanceRequise: true,
    image: '💊',
  ),
  const Medicament(
    id: 'med6',
    nom: 'Nigelle (Habba Sawda)',
    description: 'Médecine prophétique. Renforce l\'immunité et la vitalité.',
    categorie: 'Médecine Prophétique',
    prix: 1200,
    disponible: true,
    ordonnanceRequise: false,
    image: '🌿',
  ),
  const Medicament(
    id: 'med7',
    nom: 'Miel naturel pur',
    description: 'Médecine prophétique. Antibactérien naturel, cicatrisant.',
    categorie: 'Médecine Prophétique',
    prix: 3000,
    disponible: true,
    ordonnanceRequise: false,
    image: '🍯',
  ),
  const Medicament(
    id: 'med8',
    nom: 'Sirop toux enfants',
    description: 'Calme la toux sèche et grasse chez l\'enfant.',
    categorie: 'Pédiatrie',
    prix: 1800,
    disponible: true,
    ordonnanceRequise: false,
    image: '🍶',
  ),
];

// ── APP PRINCIPALE ────────────────────────────────────────────

class NurHealthApp extends StatelessWidget {
  const NurHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NurHealth — نور الصحة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: kVert,
          primary: kVert,
          secondary: kOr,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: kVert,
          foregroundColor: kBlanc,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kVert,
            foregroundColor: kBlanc,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  SPLASH SCREEN ANIMÉ
// ══════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<double> _progress;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));

    _logoScale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    _textOpacity = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _progress = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward();
    Future.delayed(
        const Duration(milliseconds: 600), () => _textCtrl.forward());
    Future.delayed(
        const Duration(milliseconds: 800), () => _progressCtrl.forward());
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (mounted) _checkAuth();
    });
  }

  void _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (!mounted) return;
    if (isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const MainScreen()));
    } else {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const AuthScreen()));
    }
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kVert, kVertClair, Color(0xFF1A3A2A)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Logo animé
              AnimatedBuilder(
                animation: _logoCtrl,
                builder: (_, __) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: kBlanc.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: kOr, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: kOr.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('☪️', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Texte animé
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    const Text(
                      'نور الصحة',
                      style: TextStyle(
                        color: kOr,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'NurHealth',
                      style: TextStyle(
                        color: kBlanc,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Santé & Bien-être Islamique',
                      style: TextStyle(
                        color: kBlanc.withValues(alpha: 0.8),
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Zinder, Niger',
                      style: TextStyle(
                        color: kOr.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              // Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          backgroundColor: kBlanc.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(kOr),
                          minHeight: 4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Chargement...',
                      style: TextStyle(
                        color: kBlanc.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'SOCIETE ANY-SERVICE SARL',
                style: TextStyle(
                  color: kBlanc.withValues(alpha: 0.4),
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  AUTHENTIFICATION
// ══════════════════════════════════════════════════════════════

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _loading = false;

  // Contrôleurs connexion
  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  // Contrôleurs inscription
  final _regNomCtrl = TextEditingController();
  final _regPrenomCtrl = TextEditingController();
  final _regEmailCtrl = TextEditingController();
  final _regTelCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regDobCtrl = TextEditingController();
  String _regSexe = 'Homme';
  String _regGroupe = 'A+';
  double _regPoids = 70;
  double _regTaille = 170;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _login() async {
    if (_loginEmailCtrl.text.isEmpty || _loginPassCtrl.text.isEmpty) {
      _showMsg('Remplissez tous les champs');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userEmail', _loginEmailCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _register() async {
    if (_regNomCtrl.text.isEmpty ||
        _regEmailCtrl.text.isEmpty ||
        _regPassCtrl.text.isEmpty) {
      _showMsg('Remplissez les champs obligatoires');
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userNom', _regNomCtrl.text);
    await prefs.setString('userPrenom', _regPrenomCtrl.text);
    await prefs.setString('userEmail', _regEmailCtrl.text);
    await prefs.setString('userTel', _regTelCtrl.text);
    await prefs.setString('userSexe', _regSexe);
    await prefs.setString('userGroupe', _regGroupe);
    await prefs.setDouble('userPoids', _regPoids);
    await prefs.setDouble('userTaille', _regTaille);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [kVert, kVertClair],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              const Text('☪️', style: TextStyle(fontSize: 50)),
              const SizedBox(height: 8),
              const Text('نور الصحة',
                  style: TextStyle(
                      color: kOr, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: kBlanc,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    TabBar(
                      controller: _tabCtrl,
                      labelColor: kVert,
                      unselectedLabelColor: kGris,
                      indicatorColor: kOr,
                      tabs: const [
                        Tab(text: 'Connexion'),
                        Tab(text: 'Inscription'),
                      ],
                    ),
                    SizedBox(
                      height: 480,
                      child: TabBarView(
                        controller: _tabCtrl,
                        children: [
                          _buildLogin(),
                          _buildRegister(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogin() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _field(_loginEmailCtrl, 'Email ou téléphone', Icons.email_outlined),
          const SizedBox(height: 16),
          _field(_loginPassCtrl, 'Mot de passe', Icons.lock_outline,
              obscure: true),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: kBlanc, strokeWidth: 2))
                  : const Text('Se connecter'),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text('Mot de passe oublié ?',
                style: TextStyle(color: kGris)),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text('Informations personnelles',
              style: TextStyle(
                  color: kVert, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(_regNomCtrl, 'Nom *', Icons.person_outline)),
            const SizedBox(width: 10),
            Expanded(
                child: _field(_regPrenomCtrl, 'Prénom', Icons.person_outline)),
          ]),
          const SizedBox(height: 12),
          _field(_regEmailCtrl, 'Email *', Icons.email_outlined),
          const SizedBox(height: 12),
          _field(_regTelCtrl, 'Téléphone', Icons.phone_outlined),
          const SizedBox(height: 12),
          _field(_regPassCtrl, 'Mot de passe *', Icons.lock_outline,
              obscure: true),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _regSexe,
                decoration: _inputDeco('Sexe', Icons.people_outline),
                items: ['Homme', 'Femme']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _regSexe = v!),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _regGroupe,
                decoration: _inputDeco('Groupe', Icons.bloodtype_outlined),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _regGroupe = v!),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text('Poids: ${_regPoids.round()} kg',
              style: const TextStyle(color: kGris, fontSize: 12)),
          Slider(
            value: _regPoids,
            min: 20,
            max: 150,
            activeColor: kVert,
            onChanged: (v) => setState(() => _regPoids = v),
          ),
          Text('Taille: ${_regTaille.round()} cm',
              style: const TextStyle(color: kGris, fontSize: 12)),
          Slider(
            value: _regTaille,
            min: 100,
            max: 220,
            activeColor: kVert,
            onChanged: (v) => setState(() => _regTaille = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: kBlanc, strokeWidth: 2))
                  : const Text('Créer mon compte'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {bool obscure = false}) {
    return TextFormField(
      controller: c,
      obscureText: obscure,
      decoration: _inputDeco(label, icon),
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: kVert, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kVert, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  ÉCRAN PRINCIPAL — NAVIGATION
// ══════════════════════════════════════════════════════════════

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    AccueilPage(),
    PriereePage(),
    SantePage(),
    ConsultationPage(),
    BibliothequePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: kVert,
          unselectedItemColor: kGris,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Accueil'),
            BottomNavigationBarItem(
                icon: Icon(Icons.access_time_outlined),
                activeIcon: Icon(Icons.access_time),
                label: 'Prières'),
            BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline),
                activeIcon: Icon(Icons.favorite),
                label: 'Santé'),
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined),
                activeIcon: Icon(Icons.medical_services),
                label: 'Consultation'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book),
                label: 'Bibliothèque'),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE ACCUEIL
// ══════════════════════════════════════════════════════════════

class AccueilPage extends StatefulWidget {
  const AccueilPage({super.key});
  @override
  State<AccueilPage> createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  String _userName = 'Cher utilisateur';
  final double _sadaqaTotal = 127500;
  final double _sadaqaObjectif = 500000;
  final int _orphelins = 23;
  final int _familles = 8;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final nom = prefs.getString('userNom') ?? '';
    final prenom = prefs.getString('userPrenom') ?? '';
    if (mounted && nom.isNotEmpty) {
      setState(() => _userName = '$prenom $nom'.trim());
    }
  }

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrisClair,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: kVert,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kVert, kVertClair],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_getGreeting()}, $_userName',
                                  style: const TextStyle(
                                      color: kBlanc,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'بسم الله الرحمن الرحيم',
                                  style: TextStyle(color: kOr, fontSize: 14),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProfilPage())),
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: kBlanc.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: kOr, width: 2),
                                ),
                                child: const Icon(Icons.person,
                                    color: kBlanc, size: 28),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Solde
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: kBlanc.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.account_balance_wallet,
                                  color: kOr, size: 18),
                              const SizedBox(width: 8),
                              const Text('Solde: ',
                                  style:
                                      TextStyle(color: kBlanc, fontSize: 13)),
                              const Text('0 FCFA',
                                  style: TextStyle(
                                      color: kOr,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () => _showRecharge(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: kOr,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text('Recharger',
                                      style: TextStyle(
                                          color: kVert,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Services rapides
                  _sectionTitle('Services rapides'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 8,
                    children: [
                      _serviceBtn('👨‍⚕️', 'Médecin', kVert),
                      _serviceBtn('💊', 'Pharmacie', kBleu),
                      _serviceBtn('🚚', 'Livraison', kRouge),
                      _serviceBtn('📖', 'Quran', kOr),
                      _serviceBtn('🌙', 'Prières', kVert),
                      _serviceBtn('❤️', 'Santé', kRouge),
                      _serviceBtn('📿', 'Dhikr', Color(0xFF6A1B9A)),
                      _serviceBtn('💰', 'Sadaqa', kOr),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sadaqa dashboard
                  _sectionTitle('صدقة — Caisse Sadaqa Zinder'),
                  const SizedBox(height: 12),
                  _buildSadaqaCard(),
                  const SizedBox(height: 20),

                  // Stats orphelins
                  _sectionTitle('Bénéficiaires du mois'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                          child: _statCard(
                              '$_orphelins', 'Orphelins\naidés', '🧒', kVert)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _statCard('$_familles',
                              'Familles\nvulnérables', '👨‍👩‍👧', kBleu)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Article santé du jour
                  _sectionTitle('Conseil santé du jour'),
                  const SizedBox(height: 12),
                  _buildArticleCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: kVert));
  }

  Widget _serviceBtn(String emoji, String label, Color color) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 10, color: kGris),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSadaqaCard() {
    final pct = _sadaqaTotal / _sadaqaObjectif;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [kVert, kVertClair],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: kVert.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Collecte mensuelle',
                  style: TextStyle(
                      color: kBlanc,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text('${(pct * 100).round()}%',
                  style: const TextStyle(
                      color: kOr, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_sadaqaTotal.toStringAsFixed(0)} / ${_sadaqaObjectif.toStringAsFixed(0)} FCFA',
            style:
                TextStyle(color: kBlanc.withValues(alpha: 0.85), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: kBlanc.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(kOr),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDon(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kOr,
                foregroundColor: kVert,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text('Faire un don',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String val, String label, String emoji, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(val,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: kGris),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildArticleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kVert.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('🌿', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Les bienfaits du jeûne selon la médecine moderne',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14, color: kVert),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Le jeûne intermittent, pratiqué dans l\'Islam depuis 14 siècles, '
            'est aujourd\'hui reconnu par la science pour ses effets bénéfiques '
            'sur la santé métabolique, la longévité et la prévention des maladies...',
            style: TextStyle(fontSize: 13, color: kGris, height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () {},
            child:
                const Text('Lire la suite →', style: TextStyle(color: kVert)),
          ),
        ],
      ),
    );
  }

  void _showRecharge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const PaiementSheet(titre: 'Recharger mon compte'),
    );
  }

  void _showDon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => const PaiementSheet(titre: 'Faire un don Sadaqa'),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FEUILLE DE PAIEMENT (réutilisable partout)
// ══════════════════════════════════════════════════════════════

class PaiementSheet extends StatefulWidget {
  final String titre;
  final double? montantFixe;
  const PaiementSheet({super.key, required this.titre, this.montantFixe});
  @override
  State<PaiementSheet> createState() => _PaiementSheetState();
}

class _PaiementSheetState extends State<PaiementSheet> {
  String _methode = 'Orange Money';
  final _montantCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  bool _loading = false;

  final List<Map<String, dynamic>> _methodes = [
    {'nom': 'Orange Money', 'emoji': '🟠', 'couleur': Color(0xFFFF6D00)},
    {'nom': 'Moov Money', 'emoji': '🔵', 'couleur': Color(0xFF1565C0)},
    {'nom': 'Wave', 'emoji': '🌊', 'couleur': Color(0xFF00BCD4)},
    {'nom': 'Banque', 'emoji': '🏦', 'couleur': Color(0xFF37474F)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.montantFixe != null) {
      _montantCtrl.text = widget.montantFixe!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _montantCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  void _payer() async {
    if (_montantCtrl.text.isEmpty || _telCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Remplissez tous les champs')));
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Paiement de ${_montantCtrl.text} FCFA via $_methode en attente de confirmation'),
        backgroundColor: kVert,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: kGris.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 16),
          Text(widget.titre,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: kVert)),
          const SizedBox(height: 16),
          // Méthodes de paiement
          const Text('Mode de paiement',
              style: TextStyle(color: kGris, fontSize: 13)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _methodes.map((m) {
              final selected = _methode == m['nom'];
              return GestureDetector(
                onTap: () => setState(() => _methode = m['nom']),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? (m['couleur'] as Color).withValues(alpha: 0.15)
                        : kGrisClair,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selected ? m['couleur'] : Colors.transparent,
                        width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(m['emoji'], style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(m['nom'],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: selected ? m['couleur'] : kGris)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _montantCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Montant (FCFA)',
              prefixIcon: const Icon(Icons.payments_outlined, color: kOr),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabled: widget.montantFixe == null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _telCtrl,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: const Icon(Icons.phone_outlined, color: kVert),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _payer,
              style: ElevatedButton.styleFrom(
                backgroundColor: kOr,
                foregroundColor: kVert,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _loading
                  ? const CircularProgressIndicator(
                      color: kVert, strokeWidth: 2)
                  : const Text('Confirmer le paiement',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE PRIÈRES
// ══════════════════════════════════════════════════════════════

class PriereePage extends StatefulWidget {
  const PriereePage({super.key});
  @override
  State<PriereePage> createState() => _PrierePageState();
}

class _PrierePageState extends State<PriereePage> {
  // Horaires fixes Zinder (approximatifs)
  final Map<String, String> _horaires = {
    'Fajr': '05:02',
    'Shurouq': '06:28',
    'Dhuhr': '12:35',
    'Asr': '15:52',
    'Maghrib': '18:42',
    'Isha': '20:02',
  };

  final Map<String, String> _icons = {
    'Fajr': '🌙',
    'Shurouq': '🌅',
    'Dhuhr': '☀️',
    'Asr': '🌤',
    'Maghrib': '🌇',
    'Isha': '🌃',
  };

  String _getProchainePrere() {
    final now = TimeOfDay.now();
    final nowMin = now.hour * 60 + now.minute;
    for (final entry in _horaires.entries) {
      final parts = entry.value.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      if (h * 60 + m > nowMin) return entry.key;
    }
    return 'Fajr';
  }

  @override
  Widget build(BuildContext context) {
    final prochaine = _getProchainePrere();
    return Scaffold(
      backgroundColor: kGrisClair,
      appBar: AppBar(
        title: const Text('🕌 Horaires des Prières'),
        actions: [
          IconButton(
              icon: const Icon(Icons.location_on_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte date/lieu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kVert, kVertClair]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  const Text('📍 Zinder, Niger',
                      style: TextStyle(color: kOr, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(
                    _formatDate(),
                    style: const TextStyle(
                        color: kBlanc,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Prochaine prière : $prochaine à ${_horaires[prochaine]}',
                    style: const TextStyle(color: kOr, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Liste des prières
            ...(_horaires.entries.map((e) {
              final isNext = e.key == prochaine;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isNext ? kVert : kBlanc,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    Text(_icons[e.key]!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        e.key,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isNext ? kBlanc : kVert),
                      ),
                    ),
                    Text(
                      e.value,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isNext ? kOr : kGris),
                    ),
                    if (isNext)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kOr,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Prochaine',
                            style: TextStyle(
                                color: kVert,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
              );
            }).toList()),
            const SizedBox(height: 20),
            // Qibla direction
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: kBlanc,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: kOr.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                        child: Text('🧭', style: TextStyle(fontSize: 30))),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Direction de la Qibla',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kVert,
                                fontSize: 15)),
                        SizedBox(height: 4),
                        Text('Zinder → La Mecque: ~25° Nord-Est',
                            style: TextStyle(color: kGris, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    const mois = [
      '',
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre'
    ];
    const jours = [
      '',
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche'
    ];
    return '${jours[now.weekday]} ${now.day} ${mois[now.month]} ${now.year}';
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE SANTÉ
// ══════════════════════════════════════════════════════════════

class SantePage extends StatefulWidget {
  const SantePage({super.key});
  @override
  State<SantePage> createState() => _SantePageState();
}

class _SantePageState extends State<SantePage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  final List<Map<String, dynamic>> _panier = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGrisClair,
      appBar: AppBar(
        title: const Text('❤️ Santé & Pharmacie'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => _showPanier(context),
              ),
              if (_panier.isNotEmpty)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                        color: kRouge, shape: BoxShape.circle),
                    child: Center(
                      child: Text('${_panier.length}',
                          style: const TextStyle(
                              color: kBlanc,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: kOr,
          unselectedLabelColor: kBlanc.withValues(alpha: 0.7),
          indicatorColor: kOr,
          tabs: const [
            Tab(text: 'BMI'),
            Tab(text: 'Pharmacie'),
            Tab(text: 'Articles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _buildBMI(),
          _buildPharmacie(),
          _buildArticles(),
        ],
      ),
    );
  }

  // ── BMI ──
  double _poids = 70;
  double _taille = 170;

  Widget _buildBMI() {
    final bmi = _poids / math.pow(_taille / 100, 2);
    final cat = bmi < 18.5
        ? 'Insuffisance pondérale'
        : bmi < 25
            ? 'Poids normal ✅'
            : bmi < 30
                ? 'Surpoids'
                : 'Obésité';
    final couleur = bmi < 18.5
        ? kBleu
        : bmi < 25
            ? kVert
            : bmi < 30
                ? kOr
                : kRouge;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kBlanc,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                Text(
                  bmi.toStringAsFixed(1),
                  style: TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      color: couleur),
                ),
                Text(cat,
                    style: TextStyle(
                        fontSize: 16,
                        color: couleur,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 24),
                _slider('Poids', _poids, 30, 150, 'kg', (v) {
                  setState(() => _poids = v);
                }),
                _slider('Taille', _taille, 100, 220, 'cm', (v) {
                  setState(() => _taille = v);
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Conseil prophétique
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kVert.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: kVert.withValues(alpha: 0.2)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌿 Conseil du Prophète ﷺ',
                    style:
                        TextStyle(color: kVert, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(
                  '"Le fils d\'Adam ne remplit pas de récipient pire que son ventre. '
                  'Il suffit à l\'être humain de manger quelques bouchées pour tenir droit."',
                  style: TextStyle(
                      color: kGris,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.5),
                ),
                SizedBox(height: 4),
                Text('— Tirmidhi',
                    style: TextStyle(color: kVert, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(String label, double val, double min, double max, String unit,
      ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: kGris)),
            Text('${val.round()} $unit',
                style:
                    const TextStyle(color: kVert, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: val,
          min: min,
          max: max,
          activeColor: kVert,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ── PHARMACIE ──
  String _categorie = 'Tous';
  final List<String> _categories = [
    'Tous',
    'Antalgiques',
    'Antibiotiques',
    'Antipaludéens',
    'Vitamines',
    'Médecine Prophétique',
    'Pédiatrie',
    'Antidiabétiques'
  ];

  Widget _buildPharmacie() {
    final filtered = _categorie == 'Tous'
        ? kMedicaments
        : kMedicaments.where((m) => m.categorie == _categorie).toList();

    return Column(
      children: [
        // Filtre catégories
        SizedBox(
          height: 46,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: _categories.length,
            itemBuilder: (_, i) {
              final selected = _categories[i] == _categorie;
              return GestureDetector(
                onTap: () => setState(() => _categorie = _categories[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: selected ? kVert : kBlanc,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: selected ? kVert : kGris.withValues(alpha: 0.3)),
                  ),
                  child: Center(
                    child: Text(
                      _categories[i],
                      style: TextStyle(
                          color: selected ? kBlanc : kGris,
                          fontSize: 12,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Liste médicaments
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: filtered.length,
            itemBuilder: (_, i) {
              final med = filtered[i];
              final inCart = _panier.any((p) => p['id'] == med.id);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: kBlanc,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kVert.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                          child: Text(med.image,
                              style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(med.nom,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13)),
                              ),
                              if (med.ordonnanceRequise)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: kRouge.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('Ordonnance',
                                      style: TextStyle(
                                          color: kRouge, fontSize: 9)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(med.description,
                              style:
                                  const TextStyle(color: kGris, fontSize: 11),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                            '${med.prix.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                                color: kVert,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (inCart) {
                            _panier.removeWhere((p) => p['id'] == med.id);
                          } else {
                            _panier.add({
                              'id': med.id,
                              'nom': med.nom,
                              'prix': med.prix,
                              'qty': 1,
                            });
                          }
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(inCart
                                ? '${med.nom} retiré'
                                : '${med.nom} ajouté au panier'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: Icon(
                        inCart
                            ? Icons.remove_shopping_cart
                            : Icons.add_shopping_cart,
                        color: inCart ? kRouge : kVert,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPanier(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx2, set2) {
        final total = _panier.fold<double>(
            0, (sum, p) => sum + (p['prix'] as double) * (p['qty'] as int));
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🛒 Mon Panier',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: kVert)),
              const SizedBox(height: 12),
              if (_panier.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Panier vide', style: TextStyle(color: kGris)),
                )
              else
                ...(_panier.map((p) => ListTile(
                      title: Text(p['nom']),
                      subtitle: Text(
                          '${(p['prix'] as double).toStringAsFixed(0)} FCFA'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: () {
                              set2(() {
                                if (p['qty'] > 1) {
                                  p['qty']--;
                                } else {
                                  _panier.remove(p);
                                }
                              });
                              setState(() {});
                            },
                          ),
                          Text('${p['qty']}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () {
                              set2(() => p['qty']++);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ))),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${total.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                          color: kVert,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              if (_panier.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      showModalBottomSheet(
                        context: ctx,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24))),
                        isScrollControlled: true,
                        builder: (_) => LivraisonSheet(
                          articles: _panier,
                          total: total,
                          onConfirm: () => setState(() => _panier.clear()),
                        ),
                      );
                    },
                    child: const Text('Commander avec livraison 🚚'),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      }),
    );
  }

  // ── ARTICLES ──
  Widget _buildArticles() {
    final articles = [
      {
        'titre': 'Prévention du paludisme en saison des pluies',
        'resume':
            'Comment protéger votre famille avec des méthodes naturelles et médicales...',
        'emoji': '🦟',
        'temps': '5 min',
      },
      {
        'titre': 'La nigelle (Habba Sawda) : vertus médicales prouvées',
        'resume':
            'La science confirme les bienfaits de cette plante mentionnée dans la Sunna...',
        'emoji': '🌿',
        'temps': '7 min',
      },
      {
        'titre': 'Diabète et Ramadan : conseils pratiques',
        'resume':
            'Tout ce que vous devez savoir pour jeûner en toute sécurité...',
        'emoji': '🩸',
        'temps': '8 min',
      },
      {
        'titre': 'Hygiène bucco-dentaire selon la Sunna',
        'resume': 'Le Siwak et ses bienfaits scientifiquement reconnus...',
        'emoji': '🦷',
        'temps': '4 min',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: articles.length,
      itemBuilder: (_, i) {
        final a = articles[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kBlanc,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a['emoji']!, style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a['titre']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: kVert)),
                    const SizedBox(height: 4),
                    Text(a['resume']!,
                        style: const TextStyle(color: kGris, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 12, color: kGris),
                        const SizedBox(width: 4),
                        Text(a['temps']!,
                            style: const TextStyle(color: kGris, fontSize: 11)),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {},
                          child: const Text('Lire →',
                              style: TextStyle(
                                  color: kVert,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  FEUILLE LIVRAISON
// ══════════════════════════════════════════════════════════════

class LivraisonSheet extends StatefulWidget {
  final List<Map<String, dynamic>> articles;
  final double total;
  final VoidCallback onConfirm;
  const LivraisonSheet(
      {super.key,
      required this.articles,
      required this.total,
      required this.onConfirm});
  @override
  State<LivraisonSheet> createState() => _LivraisonSheetState();
}

class _LivraisonSheetState extends State<LivraisonSheet> {
  final _adresseCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  String _zone = 'Centre-ville Zinder';
  String _methode = 'Orange Money';
  bool _loading = false;

  final List<String> _zones = [
    'Centre-ville Zinder',
    'Quartier Zengou',
    'Quartier Dan Baram',
    'Quartier Lazaret',
    'Banlieue Zinder',
  ];

  @override
  void dispose() {
    _adresseCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  double get _fraisLivraison => _zone == 'Banlieue Zinder' ? 1500 : 500;
  double get _totalFinal => widget.total + _fraisLivraison;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🚚 Livraison à domicile',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: kVert)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _zone,
              decoration: InputDecoration(
                labelText: 'Zone de livraison',
                prefixIcon:
                    const Icon(Icons.location_on_outlined, color: kVert),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _zones
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (v) => setState(() => _zone = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _adresseCtrl,
              decoration: InputDecoration(
                labelText: 'Adresse précise / repère',
                prefixIcon: const Icon(Icons.home_outlined, color: kVert),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Téléphone de contact',
                prefixIcon: const Icon(Icons.phone_outlined, color: kVert),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Récapitulatif
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: kGrisClair,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _ligne(
                      'Sous-total', '${widget.total.toStringAsFixed(0)} FCFA'),
                  _ligne('Frais de livraison',
                      '${_fraisLivraison.toStringAsFixed(0)} FCFA'),
                  const Divider(),
                  _ligne('TOTAL', '${_totalFinal.toStringAsFixed(0)} FCFA',
                      bold: true),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Paiement
            Wrap(
              spacing: 8,
              children:
                  ['Orange Money', 'Moov Money', 'Wave', 'Banque'].map((m) {
                final sel = _methode == m;
                return GestureDetector(
                  onTap: () => setState(() => _methode = m),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: sel ? kVert.withValues(alpha: 0.1) : kGrisClair,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? kVert : Colors.transparent, width: 2),
                    ),
                    child: Text(m,
                        style: TextStyle(
                            color: sel ? kVert : kGris,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading
                    ? null
                    : () async {
                        if (_adresseCtrl.text.isEmpty ||
                            _telCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Remplissez l\'adresse et le téléphone')),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(seconds: 2));
                        if (!mounted) return;
                        widget.onConfirm();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                '✅ Commande confirmée ! Livraison dans 30-60 min'),
                            backgroundColor: kVert,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOr,
                  foregroundColor: kVert,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: kVert, strokeWidth: 2)
                    : const Text('Confirmer la commande 🚚',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _ligne(String label, String val, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? kVert : kGris)),
          Text(val,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                  color: bold ? kVert : kGris,
                  fontSize: bold ? 15 : 13)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE CONSULTATION
// ══════════════════════════════════════════════════════════════

class ConsultationPage extends StatefulWidget {
  const ConsultationPage({super.key});
  @override
  State<ConsultationPage> createState() => _ConsultationPageState();
}

class _ConsultationPageState extends State<ConsultationPage> {
  String _specialite = 'Tous';
  final List<String> _specialites = [
    'Tous',
    'Médecin Généraliste',
    'Pédiatre',
    'Cardiologue',
    'Gynécologue',
    'Ophtalmologue'
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _specialite == 'Tous'
        ? kMedecins
        : kMedecins.where((m) => m.specialite == _specialite).toList();

    return Scaffold(
      backgroundColor: kGrisClair,
      appBar: AppBar(
        title: const Text('👨‍⚕️ Consultations'),
      ),
      body: Column(
        children: [
          // Filtre spécialités
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _specialites.length,
              itemBuilder: (_, i) {
                final sel = _specialites[i] == _specialite;
                return GestureDetector(
                  onTap: () => setState(() => _specialite = _specialites[i]),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: sel ? kVert : kBlanc,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? kVert : kGris.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Text(
                        _specialites[i],
                        style: TextStyle(
                            color: sel ? kBlanc : kGris,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Liste médecins
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final med = filtered[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kBlanc,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8)
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: kVert.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                                child: Text(med.photo,
                                    style: const TextStyle(fontSize: 28))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(med.nom,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: kVert)),
                                Text(med.specialite,
                                    style: const TextStyle(
                                        color: kGris, fontSize: 13)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: kOr, size: 14),
                                    Text(' ${med.note}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        ' · ${med.consultations} consultations',
                                        style: const TextStyle(
                                            color: kGris, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: med.disponible
                                      ? kVert.withValues(alpha: 0.1)
                                      : kRouge.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  med.disponible
                                      ? '🟢 Disponible'
                                      : '🔴 Occupé',
                                  style: TextStyle(
                                      color: med.disponible ? kVert : kRouge,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${med.tarif.toStringAsFixed(0)} FCFA',
                                style: const TextStyle(
                                    color: kVert,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.chat_outlined, size: 16),
                              label: const Text('Chat'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: kVert,
                                side: const BorderSide(color: kVert),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: med.disponible
                                  ? () => _reserverConsultation(context, med)
                                  : null,
                              icon: const Icon(Icons.video_call, size: 16),
                              label: const Text('Consulter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: med.disponible ? kVert : kGris,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _reserverConsultation(BuildContext context, Medecin med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ReservationSheet(medecin: med),
    );
  }
}

// ── FEUILLE RÉSERVATION ──
class ReservationSheet extends StatefulWidget {
  final Medecin medecin;
  const ReservationSheet({super.key, required this.medecin});
  @override
  State<ReservationSheet> createState() => _ReservationSheetState();
}

class _ReservationSheetState extends State<ReservationSheet> {
  String? _creneau;
  String _methode = 'Orange Money';
  bool _loading = false;
  final _symptoCtrl = TextEditingController();

  final List<String> _creneaux = [
    'Aujourd\'hui 10:00',
    'Aujourd\'hui 14:00',
    'Aujourd\'hui 16:30',
    'Demain 09:00',
    'Demain 11:00',
    'Demain 15:00',
  ];

  @override
  void dispose() {
    _symptoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.medecin.photo,
                    style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.medecin.nom,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: kVert,
                              fontSize: 15)),
                      Text(widget.medecin.specialite,
                          style: const TextStyle(color: kGris, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  '${widget.medecin.tarif.toStringAsFixed(0)} FCFA',
                  style: const TextStyle(
                      color: kVert, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Choisir un créneau',
                style: TextStyle(color: kVert, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _creneaux.map((c) {
                final sel = _creneau == c;
                return GestureDetector(
                  onTap: () => setState(() => _creneau = c),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? kVert : kGrisClair,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? kVert : kGris.withValues(alpha: 0.3)),
                    ),
                    child: Text(c,
                        style: TextStyle(
                            color: sel ? kBlanc : kGris, fontSize: 12)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _symptoCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Décrivez vos symptômes',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            // Paiement
            Wrap(
              spacing: 8,
              children:
                  ['Orange Money', 'Moov Money', 'Wave', 'Banque'].map((m) {
                final sel = _methode == m;
                return GestureDetector(
                  onTap: () => setState(() => _methode = m),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: sel ? kVert.withValues(alpha: 0.1) : kGrisClair,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: sel ? kVert : Colors.transparent, width: 2),
                    ),
                    child: Text(m,
                        style: TextStyle(
                            color: sel ? kVert : kGris,
                            fontSize: 12,
                            fontWeight:
                                sel ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_creneau == null || _loading)
                    ? null
                    : () async {
                        setState(() => _loading = true);
                        await Future.delayed(const Duration(seconds: 2));
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '✅ RDV confirmé avec ${widget.medecin.nom} — $_creneau'),
                            backgroundColor: kVert,
                          ),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kOr,
                  foregroundColor: kVert,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: kVert, strokeWidth: 2)
                    : Text(
                        'Payer ${widget.medecin.tarif.toStringAsFixed(0)} FCFA & Confirmer',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE BIBLIOTHÈQUE
// ══════════════════════════════════════════════════════════════

class BibliothequePage extends StatelessWidget {
  const BibliothequePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📚 Bibliothèque Islamique'),
          bottom: const TabBar(
            labelColor: kOr,
            unselectedLabelColor: Colors.white70,
            indicatorColor: kOr,
            isScrollable: true,
            tabs: [
              Tab(text: '📖 Quran'),
              Tab(text: '📜 Hadiths'),
              Tab(text: '📿 Dhikr'),
              Tab(text: '🤲 Dua'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QuranTab(),
            HadithsTab(),
            DhikrTab(),
            DuaTab(),
          ],
        ),
      ),
    );
  }
}

// ── QURAN ──
class QuranTab extends StatelessWidget {
  const QuranTab({super.key});

  static const List<Map<String, dynamic>> _surahs = [
    {
      'num': 1,
      'nom': 'Al-Fatiha',
      'ar': 'الفاتحة',
      'versets': 7,
      'type': 'Mecquoise'
    },
    {
      'num': 2,
      'nom': 'Al-Baqara',
      'ar': 'البقرة',
      'versets': 286,
      'type': 'Médinoise'
    },
    {
      'num': 3,
      'nom': 'Al-Imran',
      'ar': 'آل عمران',
      'versets': 200,
      'type': 'Médinoise'
    },
    {
      'num': 4,
      'nom': 'An-Nisa',
      'ar': 'النساء',
      'versets': 176,
      'type': 'Médinoise'
    },
    {
      'num': 5,
      'nom': 'Al-Maida',
      'ar': 'المائدة',
      'versets': 120,
      'type': 'Médinoise'
    },
    {
      'num': 36,
      'nom': 'Ya-Sin',
      'ar': 'يس',
      'versets': 83,
      'type': 'Mecquoise'
    },
    {
      'num': 67,
      'nom': 'Al-Mulk',
      'ar': 'الملك',
      'versets': 30,
      'type': 'Mecquoise'
    },
    {
      'num': 112,
      'nom': 'Al-Ikhlas',
      'ar': 'الإخلاص',
      'versets': 4,
      'type': 'Mecquoise'
    },
    {
      'num': 113,
      'nom': 'Al-Falaq',
      'ar': 'الفلق',
      'versets': 5,
      'type': 'Mecquoise'
    },
    {
      'num': 114,
      'nom': 'An-Nas',
      'ar': 'الناس',
      'versets': 6,
      'type': 'Mecquoise'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _surahs.length,
      itemBuilder: (_, i) {
        final s = _surahs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: kBlanc,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kVert.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text('${s['num']}',
                    style: const TextStyle(
                        color: kVert,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
            ),
            title: Row(
              children: [
                Text(s['nom'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: kVert)),
                const Spacer(),
                Text(s['ar'],
                    style: const TextStyle(
                        color: kOr, fontSize: 16, fontFamily: 'serif')),
              ],
            ),
            subtitle: Text('${s['versets']} versets · ${s['type']}',
                style: const TextStyle(color: kGris, fontSize: 11)),
            trailing:
                const Icon(Icons.arrow_forward_ios, size: 14, color: kGris),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SurahDetailPage(surah: s),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── DÉTAIL SOURATE ──
class SurahDetailPage extends StatelessWidget {
  final Map<String, dynamic> surah;
  const SurahDetailPage({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${surah['nom']} — ${surah['ar']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kVert, kVertClair]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(surah['ar'],
                      style: const TextStyle(color: kOr, fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(surah['nom'],
                      style: const TextStyle(color: kBlanc, fontSize: 18)),
                  Text('${surah['versets']} versets',
                      style: TextStyle(
                          color: kBlanc.withValues(alpha: 0.7), fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
              style: TextStyle(fontSize: 22, color: kVert, fontFamily: 'serif'),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux',
              style: TextStyle(
                  color: kGris, fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kGrisClair,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Le contenu complet de la sourate sera chargé depuis les données locales (quran_data.dart)',
                style: TextStyle(color: kGris, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── HADITHS ──
class HadithsTab extends StatelessWidget {
  const HadithsTab({super.key});

  static const List<Map<String, String>> _hadiths = [
    {
      'num': '1',
      'titre': 'Les actes selon les intentions',
      'texte':
          'Les actes ne valent que par les intentions, et chaque homme n\'aura que ce qu\'il a eu l\'intention de faire...',
      'source': 'Rapporté par Bukhari et Muslim',
    },
    {
      'num': '2',
      'titre': 'L\'Islam, la foi et l\'excellence',
      'texte':
          'L\'islam c\'est de témoigner qu\'il n\'y a de dieu qu\'Allah et que Muhammad est le Messager d\'Allah...',
      'source': 'Rapporté par Muslim',
    },
    {
      'num': '3',
      'titre': 'Les piliers de l\'Islam',
      'texte':
          'L\'Islam est bâti sur cinq piliers: témoigner qu\'il n\'y a de dieu qu\'Allah et que Muhammad est son Messager...',
      'source': 'Rapporté par Bukhari et Muslim',
    },
    {
      'num': '6',
      'titre': 'Le licite et l\'illicite',
      'texte':
          'Le licite est clair et l\'illicite est clair. Entre les deux, il y a des choses ambiguës que beaucoup de gens ne connaissent pas...',
      'source': 'Rapporté par Bukhari et Muslim',
    },
    {
      'num': '13',
      'titre': 'Aimer pour son frère',
      'texte':
          'Nul d\'entre vous n\'est croyant (parfait) tant qu\'il n\'aime pas pour son frère ce qu\'il aime pour lui-même.',
      'source': 'Rapporté par Bukhari et Muslim',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _hadiths.length,
      itemBuilder: (_, i) {
        final h = _hadiths[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kBlanc,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration:
                        const BoxDecoration(color: kOr, shape: BoxShape.circle),
                    child: Center(
                      child: Text(h['num']!,
                          style: const TextStyle(
                              color: kVert,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(h['titre']!,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kVert,
                            fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(h['texte']!,
                  style: const TextStyle(
                      color: kGris,
                      fontSize: 13,
                      height: 1.6,
                      fontStyle: FontStyle.italic)),
              const SizedBox(height: 6),
              Text('— ${h['source']}',
                  style: const TextStyle(color: kVert, fontSize: 11)),
            ],
          ),
        );
      },
    );
  }
}

// ── DHIKR ──
class DhikrTab extends StatefulWidget {
  const DhikrTab({super.key});
  @override
  State<DhikrTab> createState() => _DhikrTabState();
}

class _DhikrTabState extends State<DhikrTab> {
  int _compteur = 0;
  int _objectif = 33;
  String _dhikr = 'سُبْحَانَ اللَّه';
  String _traduction = 'Gloire à Allah';

  final List<Map<String, String>> _dhikrs = [
    {'ar': 'سُبْحَانَ اللَّه', 'fr': 'Gloire à Allah', 'obj': '33'},
    {'ar': 'الحَمْدُ لِلَّه', 'fr': 'Louange à Allah', 'obj': '33'},
    {'ar': 'اللَّهُ أَكْبَر', 'fr': 'Allah est le Plus Grand', 'obj': '33'},
    {
      'ar': 'لَا إِلَهَ إِلَّا اللَّه',
      'fr': 'Pas de divinité sauf Allah',
      'obj': '100'
    },
    {
      'ar': 'أَسْتَغْفِرُ اللَّه',
      'fr': 'Je demande pardon à Allah',
      'obj': '100'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final pct = _objectif > 0 ? (_compteur / _objectif).clamp(0.0, 1.0) : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Sélecteur dhikr
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dhikrs.map((d) {
              final sel = _dhikr == d['ar'];
              return GestureDetector(
                onTap: () => setState(() {
                  _dhikr = d['ar']!;
                  _traduction = d['fr']!;
                  _objectif = int.parse(d['obj']!);
                  _compteur = 0;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? kVert : kBlanc,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? kVert : kGris.withValues(alpha: 0.3)),
                  ),
                  child: Text(d['fr']!,
                      style: TextStyle(
                          color: sel ? kBlanc : kGris,
                          fontSize: 12,
                          fontWeight:
                              sel ? FontWeight.bold : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          // Tasbih principal
          GestureDetector(
            onTap: () {
              setState(() {
                if (_compteur < _objectif) _compteur++;
              });
              if (_compteur >= _objectif) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🎉 Mashallah ! Objectif atteint !'),
                    backgroundColor: kVert,
                  ),
                );
              }
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const RadialGradient(colors: [kVertClair, kVert]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: kVert.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 5)
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_compteur',
                    style: const TextStyle(
                        color: kBlanc,
                        fontSize: 56,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '/ $_objectif',
                    style: TextStyle(
                        color: kBlanc.withValues(alpha: 0.7), fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(_dhikr,
              style: const TextStyle(
                  fontSize: 28, color: kVert, fontFamily: 'serif')),
          const SizedBox(height: 6),
          Text(_traduction, style: const TextStyle(color: kGris, fontSize: 14)),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: kGrisClair,
              valueColor: const AlwaysStoppedAnimation<Color>(kOr),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () => setState(() => _compteur = 0),
            icon: const Icon(Icons.refresh, color: kGris),
            label: const Text('Réinitialiser', style: TextStyle(color: kGris)),
          ),
        ],
      ),
    );
  }
}

// ── DUA ──
class DuaTab extends StatelessWidget {
  const DuaTab({super.key});

  static const List<Map<String, String>> _duas = [
    {
      'occasion': 'Matin',
      'emoji': '🌅',
      'ar': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ',
      'fr': 'Nous entrons dans le matin et la royauté appartient à Allah...',
    },
    {
      'occasion': 'Soir',
      'emoji': '🌙',
      'ar': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
      'fr': 'Nous entrons dans le soir et la royauté appartient à Allah...',
    },
    {
      'occasion': 'Avant de dormir',
      'emoji': '😴',
      'ar': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'fr': 'En Ton nom, ô Allah, je meurs et je vis...',
    },
    {
      'occasion': 'En mangeant',
      'emoji': '🍽️',
      'ar': 'بِسْمِ اللَّهِ',
      'fr': 'Au nom d\'Allah...',
    },
    {
      'occasion': 'Pour la guérison',
      'emoji': '💊',
      'ar': 'اللَّهُمَّ رَبَّ النَّاسِ أَذْهِبِ الْبَأْسَ',
      'fr': 'Ô Allah, Seigneur des hommes, fais disparaître le mal...',
    },
    {
      'occasion': 'En sortant de chez soi',
      'emoji': '🚪',
      'ar': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ',
      'fr': 'Au nom d\'Allah, je me confie à Allah...',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _duas.length,
      itemBuilder: (_, i) {
        final d = _duas[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kBlanc,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(d['emoji']!, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(d['occasion']!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kVert,
                          fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Text(d['ar']!,
                  style: const TextStyle(
                      fontSize: 18,
                      color: kVert,
                      fontFamily: 'serif',
                      height: 1.8),
                  textAlign: TextAlign.right),
              const SizedBox(height: 6),
              Text(d['fr']!,
                  style: const TextStyle(
                      color: kGris, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAGE PROFIL
// ══════════════════════════════════════════════════════════════

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});
  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String _nom = '';
  String _prenom = '';
  String _email = '';
  String _tel = '';
  String _sexe = '';
  String _groupe = '';
  double _poids = 0;
  double _taille = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() {
      _nom = p.getString('userNom') ?? 'Non renseigné';
      _prenom = p.getString('userPrenom') ?? '';
      _email = p.getString('userEmail') ?? '';
      _tel = p.getString('userTel') ?? '';
      _sexe = p.getString('userSexe') ?? '';
      _groupe = p.getString('userGroupe') ?? '';
      _poids = p.getDouble('userPoids') ?? 0;
      _taille = p.getDouble('userTaille') ?? 0;
    });
  }

  void _logout() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('isLoggedIn', false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: kVert.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: kOr, width: 3),
              ),
              child: const Icon(Icons.person, size: 50, color: kVert),
            ),
            const SizedBox(height: 12),
            Text('$_prenom $_nom',
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: kVert)),
            Text(_email, style: const TextStyle(color: kGris, fontSize: 13)),
            const SizedBox(height: 24),
            // Infos médicales
            _infoCard('Informations médicales', [
              _infoRow(Icons.bloodtype_outlined, 'Groupe sanguin', _groupe),
              _infoRow(Icons.people_outline, 'Sexe', _sexe),
              _infoRow(Icons.monitor_weight_outlined, 'Poids',
                  '${_poids.round()} kg'),
              _infoRow(Icons.height, 'Taille', '${_taille.round()} cm'),
            ]),
            const SizedBox(height: 12),
            _infoCard('Contact', [
              _infoRow(Icons.phone_outlined, 'Téléphone', _tel),
              _infoRow(Icons.email_outlined, 'Email', _email),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout, color: kRouge),
                label: const Text('Se déconnecter',
                    style: TextStyle(color: kRouge)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: kRouge),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String titre, List<Widget> rows) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlanc,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titre,
              style: const TextStyle(
                  color: kVert, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, size: 18, color: kVert),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: kGris, fontSize: 13)),
          const Spacer(),
          Text(val.isEmpty ? '—' : val,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13, color: kVert)),
        ],
      ),
    );
  }
}
