// ============================================================
// NurHealth — Page Authentification
// Fichier : lib/pages/auth_page.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _specialiteCtrl = TextEditingController();

  // ── State ─────────────────────────────────────────────────
  final AuthService _auth = AuthService();
  late TabController _tabController;

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showOtpField = false;
  bool _isDoctor = false;
  String _verificationId = '';
  String _selectedMethod = 'email'; // 'email' ou 'phone'

  // ── Colors NurHealth ──────────────────────────────────────
  static const Color _primary = Color(0xFF1B4F72);
  static const Color _accent = Color(0xFF2ECC71);
  static const Color _gold = Color(0xFFD4AC0D);
  static const Color _bg = Color(0xFFF4F6F9);
  static const Color _cardBg = Colors.white;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _specialiteCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red.shade700 : _accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _navigateHome(UserModel user) {
    Navigator.of(context).pushReplacementNamed(
      user.role == 'doctor' ? '/doctor-home' : '/home',
      arguments: user,
    );
  }

  // ── Actions Email ─────────────────────────────────────────
  Future<void> _handleEmailAuth() async {
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      _showSnack('Veuillez remplir tous les champs', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      UserModel? user;
      if (_isLogin) {
        user = await _auth.loginWithEmail(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
      } else {
        user = await _auth.registerWithEmail(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          role: _isDoctor ? 'doctor' : 'user',
          specialite: _isDoctor ? _specialiteCtrl.text.trim() : null,
        );
      }
      if (user != null) {
        _showSnack(_isLogin ? 'Connexion réussie !' : 'Compte créé avec succès !');
        _navigateHome(user);
      } else {
        _showSnack('Identifiants incorrects ou erreur réseau', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Actions SMS ───────────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.isEmpty) {
      _showSnack('Entrez votre numéro de téléphone', isError: true);
      return;
    }
    final fullPhone = phone.startsWith('+') ? phone : '+227$phone';
    setState(() => _isLoading = true);
    await _auth.sendSmsOtp(
      phoneNumber: fullPhone,
      onCodeSent: (id) {
        setState(() {
          _verificationId = id;
          _showOtpField = true;
          _isLoading = false;
        });
        _showSnack('Code OTP envoyé au $fullPhone');
      },
      onError: (e) {
        setState(() => _isLoading = false);
        _showSnack('Erreur : $e', isError: true);
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpCtrl.text.length < 6) {
      _showSnack('Entrez le code à 6 chiffres', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await _auth.verifySmsOtp(
        verificationId: _verificationId,
        smsCode: _otpCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
      );
      if (user != null) {
        _showSnack('Connexion réussie !');
        _navigateHome(user);
      } else {
        _showSnack('Code OTP incorrect', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 32),
              _buildMethodSelector(),
              const SizedBox(height: 24),
              _buildCard(),
              const SizedBox(height: 16),
              if (_selectedMethod == 'email') _buildToggleMode(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_primary, Color(0xFF2980B9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'نور',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'NurHealth',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: _primary,
            letterSpacing: 1.2,
          ),
        ),
        const Text(
          'نور الصحة',
          style: TextStyle(
            fontSize: 14,
            color: _gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Sélecteur méthode Email / SMS ─────────────────────────
  Widget _buildMethodSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _methodTab('email', Icons.email_outlined, 'Email'),
          _methodTab('phone', Icons.phone_outlined, 'Téléphone'),
        ],
      ),
    );
  }

  Widget _methodTab(String method, IconData icon, String label) {
    final selected = _selectedMethod == method;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedMethod = method;
          _showOtpField = false;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: selected ? Colors.white : Colors.grey),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.grey,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Card principale ───────────────────────────────────────
  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Text(
            _selectedMethod == 'email'
                ? (_isLogin ? 'Connexion' : 'Créer un compte')
                : 'Connexion par SMS',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _primary,
            ),
          ),
          const SizedBox(height: 20),

          // Contenu selon méthode
          if (_selectedMethod == 'email') _buildEmailForm(),
          if (_selectedMethod == 'phone') _buildPhoneForm(),
        ],
      ),
    );
  }

  // ── Formulaire Email ──────────────────────────────────────
  Widget _buildEmailForm() {
    return Column(
      children: [
        _inputField(
          controller: _emailCtrl,
          label: 'Adresse email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _inputField(
          controller: _passwordCtrl,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),

        // Options inscription
        if (!_isLogin) ...[
          const SizedBox(height: 16),
          _buildRoleSelector(),
          if (_isDoctor) ...[
            const SizedBox(height: 16),
            _inputField(
              controller: _specialiteCtrl,
              label: 'Spécialité médicale',
              icon: Icons.medical_services_outlined,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: _gold, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Votre compte médecin sera validé par l\'administrateur avant activation du module Vidal.',
                      style: TextStyle(fontSize: 11, color: _gold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],

        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: _isLogin ? 'Se connecter' : 'Créer mon compte',
          onTap: _handleEmailAuth,
        ),
      ],
    );
  }

  // ── Sélecteur rôle ────────────────────────────────────────
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Je suis :',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: _primary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _roleChip(
              label: 'Patient',
              icon: Icons.person_outline,
              selected: !_isDoctor,
              onTap: () => setState(() => _isDoctor = false),
            ),
            const SizedBox(width: 12),
            _roleChip(
              label: 'Médecin',
              icon: Icons.medical_services_outlined,
              selected: _isDoctor,
              onTap: () => setState(() => _isDoctor = true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? _primary.withOpacity(0.1) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? _primary : Colors.grey, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _primary : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Formulaire SMS ────────────────────────────────────────
  Widget _buildPhoneForm() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Text(
                '🇳🇪 +227',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _inputField(
                controller: _phoneCtrl,
                label: 'Numéro de téléphone',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        if (_showOtpField) ...[
          const SizedBox(height: 16),
          _inputField(
            controller: _otpCtrl,
            label: 'Code OTP (6 chiffres)',
            icon: Icons.pin_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),
        ],
        const SizedBox(height: 24),
        _buildPrimaryButton(
          label: _showOtpField ? 'Vérifier le code' : 'Envoyer le code SMS',
          onTap: _showOtpField ? _verifyOtp : _sendOtp,
        ),
        if (_showOtpField) ...[
          const SizedBox(height: 12),
          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _showOtpField = false),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Renvoyer le code'),
              style: TextButton.styleFrom(foregroundColor: _primary),
            ),
          ),
        ],
      ],
    );
  }

  // ── Input générique ───────────────────────────────────────
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _primary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: _bg,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // ── Bouton principal ──────────────────────────────────────
  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: _primary.withOpacity(0.4),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // ── Toggle Login / Register ───────────────────────────────
  Widget _buildToggleMode() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isLogin ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _isLogin = !_isLogin;
            _isDoctor = false;
          }),
          child: Text(
            _isLogin ? 'S\'inscrire' : 'Se connecter',
            style: const TextStyle(
              color: _primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
