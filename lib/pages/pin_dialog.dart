// ============================================================
// NurHealth — Widget Dialog PIN Sécurisé
// Fichier : lib/widgets/pin_dialog.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/pin_service.dart';

// ─────────────────────────────────────────────────────────────
// DIALOG VÉRIFICATION PIN
// ─────────────────────────────────────────────────────────────
class PinVerifyDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final String title;
  final String subtitle;

  const PinVerifyDialog({
    super.key,
    required this.onSuccess,
    this.title = 'Module Vidal',
    this.subtitle = 'Entrez votre PIN médecin',
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onSuccess,
    String title = 'Module Vidal',
    String subtitle = 'Entrez votre PIN médecin',
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinVerifyDialog(
        onSuccess: onSuccess,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  @override
  State<PinVerifyDialog> createState() => _PinVerifyDialogState();
}

class _PinVerifyDialogState extends State<PinVerifyDialog>
    with SingleTickerProviderStateMixin {
  static const Color _primary = Color(0xFF1B4F72);
  static const Color _danger  = Color(0xFFE74C3C);
  static const Color _gold    = Color(0xFFD4AC0D);
  static const Color _accent  = Color(0xFF2ECC71);

  final PinService _pinService = PinService();
  final List<TextEditingController> _ctrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  bool _isLoading = false;
  bool _isLocked  = false;
  String _errorMsg = '';
  int _remainingAttempts = 5;
  Duration _lockRemaining = Duration.zero;

  String get _pinValue => _ctrl.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn),
    );
    // Focus sur premier champ
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _focus[0].requestFocus();
    });
    // Vérifier si PIN est configuré
    _checkPinExists();
  }

  @override
  void dispose() {
    for (final c in _ctrl) c.dispose();
    for (final f in _focus) f.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkPinExists() async {
    final hasPIN = await _pinService.hasPinConfigured();
    if (!hasPIN && mounted) {
      Navigator.pop(context);
      // Rediriger vers création PIN
      await PinSetupDialog.show(context, isFirstTime: true);
    }
  }

  Future<void> _verifyPin() async {
    if (_pinValue.length < 4) return;
    setState(() { _isLoading = true; _errorMsg = ''; });

    final result = await _pinService.verifyPin(_pinValue);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      // Shake animation
      _shakeCtrl.forward(from: 0);
      _clearPin();

      setState(() {
        _errorMsg = result.message;
        if (result.status == PinStatus.locked) {
          _isLocked = true;
          _lockRemaining = result.lockDuration ?? Duration.zero;
        } else if (result.remainingAttempts != null) {
          _remainingAttempts = result.remainingAttempts!;
        }
      });
    }
  }

  void _clearPin() {
    for (final c in _ctrl) c.clear();
    _focus[0].requestFocus();
  }

  void _onDigitEntered(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focus[index + 1].requestFocus();
    }
    if (_pinValue.length == 6) {
      Future.delayed(const Duration(milliseconds: 100), _verifyPin);
    }
  }

  void _onBackspace(int index) {
    if (_ctrl[index].text.isEmpty && index > 0) {
      _focus[index - 1].requestFocus();
      _ctrl[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isLocked
                    ? _danger.withOpacity(0.1)
                    : _primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLocked ? Icons.lock : Icons.medical_information,
                color: _isLocked ? _danger : _primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _primary)),
            const SizedBox(height: 4),
            Text(
              _isLocked ? 'Compte temporairement verrouillé' : widget.subtitle,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Champs PIN
            if (!_isLocked) ...[
              AnimatedBuilder(
                animation: _shakeAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(
                    10 * (0.5 - _shakeAnim.value) * (1 - _shakeAnim.value),
                    0,
                  ),
                  child: child,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => _pinBox(i)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Message erreur / verrouillage
            if (_errorMsg.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (_isLocked ? _danger : _gold).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_isLocked ? _danger : _gold).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isLocked ? Icons.lock_clock : Icons.warning_amber,
                      color: _isLocked ? _danger : _gold,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMsg,
                        style: TextStyle(
                          color: _isLocked ? _danger : _gold,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                if (!_isLocked) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _verifyPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                          : const Text('Valider',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ],
            ),

            // Lien changer PIN
            if (!_isLocked) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  PinSetupDialog.show(context, isFirstTime: false);
                },
                child: const Text('Changer mon PIN',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _pinBox(int index) {
    return SizedBox(
      width: 42,
      height: 52,
      child: TextField(
        controller: _ctrl[index],
        focusNode: _focus[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        obscureText: true,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.bold, color: _primary),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFF0F4F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _danger, width: 2),
          ),
        ),
        onChanged: (v) => _onDigitEntered(index, v),
        onSubmitted: (_) => _verifyPin(),
        // Gérer backspace
        onTapOutside: (_) {},
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DIALOG CRÉATION / CHANGEMENT PIN
// ─────────────────────────────────────────────────────────────
class PinSetupDialog extends StatefulWidget {
  final bool isFirstTime;

  const PinSetupDialog({super.key, required this.isFirstTime});

  static Future<void> show(BuildContext context,
      {required bool isFirstTime}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinSetupDialog(isFirstTime: isFirstTime),
    );
  }

  @override
  State<PinSetupDialog> createState() => _PinSetupDialogState();
}

class _PinSetupDialogState extends State<PinSetupDialog> {
  static const Color _primary = Color(0xFF1B4F72);
  static const Color _accent  = Color(0xFF2ECC71);
  static const Color _danger  = Color(0xFFE74C3C);

  final PinService _pinService = PinService();
  final _newPinCtrl  = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _oldPinCtrl  = TextEditingController();

  bool _isLoading   = false;
  bool _obscureNew  = true;
  bool _obscureConf = true;
  bool _obscureOld  = true;
  String _errorMsg  = '';
  String _successMsg = '';

  @override
  void dispose() {
    _newPinCtrl.dispose();
    _confirmCtrl.dispose();
    _oldPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _savePin() async {
    setState(() { _errorMsg = ''; _successMsg = ''; });

    if (_newPinCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMsg = 'Les PIN ne correspondent pas');
      return;
    }

    setState(() => _isLoading = true);

    final result = await _pinService.setPin(
      _newPinCtrl.text,
      oldPin: widget.isFirstTime ? null : _oldPinCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _successMsg = result.message);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _errorMsg = result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_outline, color: _primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isFirstTime
                            ? 'Créer votre PIN'
                            : 'Changer votre PIN',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: _primary),
                      ),
                      Text(
                        widget.isFirstTime
                            ? 'Sécurisez l\'accès Vidal'
                            : 'Modifiez votre PIN médecin',
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Ancien PIN (si changement)
            if (!widget.isFirstTime) ...[
              _pinInput(
                controller: _oldPinCtrl,
                label: 'Ancien PIN',
                obscure: _obscureOld,
                onToggle: () => setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 12),
            ],

            _pinInput(
              controller: _newPinCtrl,
              label: 'Nouveau PIN (4-6 chiffres)',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 12),
            _pinInput(
              controller: _confirmCtrl,
              label: 'Confirmer le PIN',
              obscure: _obscureConf,
              onToggle: () => setState(() => _obscureConf = !_obscureConf),
            ),
            const SizedBox(height: 8),

            // Info sécurité
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, color: _primary, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PIN chiffré SHA-256 et stocké sur Firebase. Verrouillage après 5 tentatives.',
                      style: TextStyle(fontSize: 11, color: _primary),
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            if (_errorMsg.isNotEmpty) ...[
              const SizedBox(height: 10),
              _messageBox(_errorMsg, _danger, Icons.error_outline),
            ],
            if (_successMsg.isNotEmpty) ...[
              const SizedBox(height: 10),
              _messageBox(_successMsg, _accent, Icons.check_circle_outline),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 18, height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pinInput({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.pin_outlined, color: _primary, size: 20),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey, size: 20,
          ),
          onPressed: onToggle,
        ),
        filled: true,
        fillColor: const Color(0xFFF0F4F8),
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  Widget _messageBox(String msg, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(msg,
                style: TextStyle(
                    color: color, fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
