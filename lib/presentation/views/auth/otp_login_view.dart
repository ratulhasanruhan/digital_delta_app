import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../../../app/app_theme.dart';
import '../../../features/identity/services/identity_service.dart';
import '../../controllers/auth_controller.dart';

/// Phone → **offline TOTP** (RFC 6238, SHA-256). Demo shows live code + expiry; no network required.
class OtpLoginView extends StatefulWidget {
  const OtpLoginView({super.key});

  @override
  State<OtpLoginView> createState() => _OtpLoginViewState();
}

class _OtpLoginViewState extends State<OtpLoginView> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpStep = false;
  bool _busy = false;
  String? _error;
  Timer? _totpTicker;

  @override
  void dispose() {
    _totpTicker?.cancel();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _ensureTotpTicker() {
    _totpTicker?.cancel();
    if (!_otpStep) return;
    _totpTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _sendOtp() async {
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10) {
      setState(() => _error = 'Enter a valid mobile number.');
      return;
    }
    setState(() {
      _error = null;
      _otpStep = true;
    });
    _ensureTotpTicker();
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
      final ok = await context.read<AuthController>().verifyOtp(
        phoneDigits: digits,
        otp: _otp.text.trim(),
      );
      if (!mounted) return;
      if (!ok) {
        setState(() => _error = 'Invalid TOTP. Use the 6-digit code shown below (±2×30s clock skew).');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final id = context.watch<IdentityService>();
    final basePinTheme = PinTheme(
      width: 50,
      height: 56,
      textStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: cs.onSurface,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
    );

    final remain = id.isReady ? id.totpSecondsRemaining() : 0;
    final progress = id.isReady ? 1.0 - (remain / 30.0).clamp(0.0, 1.0) : 0.0;
    String demoCode;
    try {
      demoCode = id.isReady ? id.currentTotp() : '------';
    } catch (_) {
      demoCode = '------';
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.floodDeep.withValues(alpha: 0.92),
                    cs.surfaceContainerLowest,
                    AppTheme.waterAccent.withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HeroHeader(cs: cs),
                            const SizedBox(height: 40),
                            Text(
                              _otpStep ? 'Enter TOTP' : 'Responder sign-in',
                              style: GoogleFonts.dmSans(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _otpStep
                                  ? 'Time-based code (RFC 6238) — generated on this device only. Works fully offline.'
                                  : 'Flood disaster management — offline TOTP after enrollment.',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                height: 1.45,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 28),
                            if (!_otpStep) ...[
                              TextField(
                                controller: _phone,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(11),
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Mobile number',
                                  hintText: '01XXXXXXXXX',
                                  prefixIcon: Icon(Icons.phone_android_rounded, color: cs.primary),
                                ),
                                onSubmitted: (_) => _sendOtp(),
                              ),
                            ] else ...[
                              if (id.isReady) ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Demo — current TOTP (rotates every 30s)',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: cs.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      SelectableText(
                                        demoCode,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 6,
                                          color: cs.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Next code in ${remain}s',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: cs.onSurfaceVariant,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 6,
                                          backgroundColor: cs.surfaceContainerHighest,
                                          color: cs.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Type the digits above into the boxes — same as authenticator apps; no SMS or server.',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          height: 1.35,
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                              Text(
                                '6-digit TOTP',
                                style: GoogleFonts.dmSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Pinput(
                                controller: _otp,
                                length: 6,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                defaultPinTheme: basePinTheme,
                                focusedPinTheme: basePinTheme.copyDecorationWith(
                                  border: Border.all(color: cs.primary, width: 1.6),
                                ),
                                submittedPinTheme: basePinTheme.copyDecorationWith(
                                  border: Border.all(color: cs.primary.withValues(alpha: 0.55)),
                                ),
                                errorPinTheme: basePinTheme.copyDecorationWith(
                                  border: Border.all(color: cs.error),
                                ),
                                separatorBuilder: (index) => const SizedBox(width: 8),
                                onCompleted: (_) {
                                  if (!_busy) _verify();
                                },
                                onSubmitted: (_) {
                                  if (!_busy) _verify();
                                },
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _busy
                                      ? null
                                      : () {
                                          setState(() {
                                            _otpStep = false;
                                            _error = null;
                                            _otp.clear();
                                          });
                                          _totpTicker?.cancel();
                                        },
                                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                  label: const Text('Change number'),
                                ),
                              ),
                            ],
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                _error!,
                                style: GoogleFonts.dmSans(
                                  color: cs.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(height: 28),
                            FilledButton(
                              onPressed: _busy ? null : (_otpStep ? _verify : _sendOtp),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: _busy
                                    ? SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: cs.onPrimary,
                                        ),
                                      )
                                    : Text(
                                        _otpStep ? 'Verify & continue' : 'Continue',
                                        style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cs.primaryContainer.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.offline_bolt_rounded, color: cs.primary, size: 22),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Offline-first: TOTP never leaves the device; data syncs when connectivity returns.',
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        height: 1.4,
                                        color: cs.onSurfaceVariant,
                                      ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                cs.primary,
                AppTheme.waterAccent.withValues(alpha: 0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.water_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Digital Delta',
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: cs.onSurface,
                ),
              ),
              Text(
                'Flood response · Field ops',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
