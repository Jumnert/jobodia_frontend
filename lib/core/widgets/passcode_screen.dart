import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/services/app_security_service.dart';

Future<bool> requestAppAuthentication(
  BuildContext context, {
  required String reason,
}) async {
  final security = AppSecurityService.to;
  await security.ready;
  if (!security.hasPin.value) return true;
  if (!context.mounted) return false;

  return await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => PasscodeScreen(reason: reason),
        ),
      ) ??
      false;
}

Future<bool> createAppPasscode(BuildContext context) async {
  return await Navigator.of(context, rootNavigator: true).push<bool>(
        MaterialPageRoute<bool>(
          fullscreenDialog: true,
          builder: (_) => const _CreatePasscodeScreen(),
        ),
      ) ??
      false;
}

class PasscodeScreen extends StatefulWidget {
  const PasscodeScreen({required this.reason, super.key});

  final String reason;

  @override
  State<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends State<PasscodeScreen> {
  String _digits = '';
  String? _error;
  bool _checking = false;
  bool _canUseBiometrics = false;

  @override
  void initState() {
    super.initState();
    _loadBiometrics();
  }

  Future<void> _loadBiometrics() async {
    final available =
        AppSecurityService.to.biometricEnabled.value &&
        await AppSecurityService.to.canUseBiometrics();
    if (mounted) setState(() => _canUseBiometrics = available);
  }

  void _enter(String digit) {
    if (_checking || _digits.length == 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _digits += digit;
    });
    if (_digits.length == 4) _verify();
  }

  void _erase() {
    if (_checking || _digits.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _digits = _digits.substring(0, _digits.length - 1);
    });
  }

  Future<void> _verify() async {
    setState(() => _checking = true);
    final accepted = await AppSecurityService.to.verifyPin(_digits);
    if (!mounted) return;
    if (accepted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() {
      _checking = false;
      _digits = '';
      _error = 'Incorrect passcode. Try again or use Face ID.';
    });
  }

  Future<void> _scanFace() async {
    if (_checking) return;
    setState(() {
      _checking = true;
      _error = null;
    });
    final accepted = await AppSecurityService.to.authenticateBiometrically(
      widget.reason,
    );
    if (!mounted) return;
    if (accepted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _checking = false;
      _error = 'Face scan was not completed. Enter your passcode.';
    });
  }

  @override
  Widget build(BuildContext context) => _PasscodeLayout(
    title: 'Confirm it’s you',
    subtitle: widget.reason,
    digits: _digits.length,
    error: _error,
    checking: _checking,
    showBiometric: _canUseBiometrics,
    onDigit: _enter,
    onErase: _erase,
    onBiometric: _scanFace,
  );
}

class _CreatePasscodeScreen extends StatefulWidget {
  const _CreatePasscodeScreen();

  @override
  State<_CreatePasscodeScreen> createState() => _CreatePasscodeScreenState();
}

class _CreatePasscodeScreenState extends State<_CreatePasscodeScreen> {
  String _digits = '';
  String? _firstPin;
  String? _error;
  bool _saving = false;

  void _enter(String digit) {
    if (_saving || _digits.length == 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      _digits += digit;
    });
    if (_digits.length == 4) _continue();
  }

  void _erase() {
    if (_saving || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  Future<void> _continue() async {
    if (_firstPin == null) {
      final pin = _digits;
      await Future<void>.delayed(const Duration(milliseconds: 160));
      if (!mounted) return;
      setState(() {
        _firstPin = pin;
        _digits = '';
      });
      return;
    }

    if (_digits != _firstPin) {
      HapticFeedback.heavyImpact();
      setState(() {
        _digits = '';
        _firstPin = null;
        _error = 'Passcodes did not match. Start again.';
      });
      return;
    }

    setState(() => _saving = true);
    await AppSecurityService.to.setPin(_digits);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) => _PasscodeLayout(
    title: _firstPin == null ? 'Create a passcode' : 'Confirm your passcode',
    subtitle: _firstPin == null
        ? 'Use four digits to protect sensitive actions.'
        : 'Enter the same four digits again.',
    digits: _digits.length,
    error: _error,
    checking: _saving,
    showBiometric: false,
    onDigit: _enter,
    onErase: _erase,
  );
}

class _PasscodeLayout extends StatelessWidget {
  const _PasscodeLayout({
    required this.title,
    required this.subtitle,
    required this.digits,
    required this.checking,
    required this.showBiometric,
    required this.onDigit,
    required this.onErase,
    this.error,
    this.onBiometric,
  });

  final String title;
  final String subtitle;
  final int digits;
  final String? error;
  final bool checking;
  final bool showBiometric;
  final ValueChanged<String> onDigit;
  final VoidCallback onErase;
  final VoidCallback? onBiometric;

  @override
  Widget build(BuildContext context) {
    const foreground = Colors.white;
    const muted = Color(0xFF858A8A);

    return Scaffold(
      backgroundColor: const Color(0xFF060808),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: FButton.icon(
                variant: FButtonVariant.ghost,
                onPress: checking
                    ? null
                    : () => Navigator.of(context).pop(false),
                child: const Icon(FLucideIcons.x, size: 20, color: foreground),
              ),
            ),
            const Spacer(),
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withValues(alpha: 0.14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brandPrimary.withValues(alpha: 0.42),
                ),
              ),
              child: const Icon(
                FLucideIcons.shieldCheck,
                color: AppColors.brandPrimary,
                size: 29,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: foreground,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: muted, fontSize: 13, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                4,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: index < digits
                        ? foreground
                        : const Color(0xFF5A5E5E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 46,
              child: Center(
                child: checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brandPrimary,
                        ),
                      )
                    : error == null
                    ? null
                    : Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFF7A7A),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              child: Column(
                children: [
                  for (final row in const [
                    ['1', '2', '3'],
                    ['4', '5', '6'],
                    ['7', '8', '9'],
                  ])
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: row
                          .map(
                            (digit) => _NumberKey(digit: digit, onTap: onDigit),
                          )
                          .toList(growable: false),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 72,
                        height: 64,
                        child: showBiometric
                            ? IconButton(
                                tooltip: 'Use Face ID',
                                onPressed: onBiometric,
                                icon: const Icon(
                                  FLucideIcons.scanFace,
                                  color: foreground,
                                  size: 25,
                                ),
                              )
                            : null,
                      ),
                      _NumberKey(digit: '0', onTap: onDigit),
                      SizedBox(
                        width: 72,
                        height: 64,
                        child: IconButton(
                          tooltip: 'Delete digit',
                          onPressed: onErase,
                          icon: const Icon(
                            FLucideIcons.delete,
                            color: foreground,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _NumberKey extends StatelessWidget {
  const _NumberKey({required this.digit, required this.onTap});

  final String digit;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 72,
    height: 64,
    child: InkResponse(
      radius: 32,
      onTap: () => onTap(digit),
      child: Center(
        child: Text(
          digit,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 27,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}
