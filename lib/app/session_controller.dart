import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/identity/services/identity_service.dart';

const _kOnboarding = 'dd_onboarding_complete_v1';
const _kTrustUntilMs = 'dd_session_trust_until_ms';
const _kTrustHours = 8;

/// First-launch onboarding + time-limited session trust after successful TOTP verification.
class SessionController extends ChangeNotifier {
  SessionController(this._identity);

  final IdentityService _identity;

  bool _onboardingComplete = false;
  int? _trustUntilMs;

  bool get onboardingComplete => _onboardingComplete;

  /// After onboarding, user must unlock unless trust window is valid.
  bool get needsUnlock {
    if (!_onboardingComplete) return false;
    final t = _trustUntilMs;
    if (t == null) return true;
    return DateTime.now().millisecondsSinceEpoch >= t;
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _onboardingComplete = p.getBool(_kOnboarding) ?? false;
      _trustUntilMs = p.getInt(_kTrustUntilMs);
      notifyListeners();
    } catch (e) {
      debugPrint('SessionController.load: $e');
    }
  }

  Future<void> completeOnboarding() async {
    try {
      _onboardingComplete = true;
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kOnboarding, true);
      notifyListeners();
    } catch (e) {
      debugPrint('SessionController.completeOnboarding: $e');
      rethrow;
    }
  }

  /// Returns true if TOTP accepted and session trusted for [_kTrustHours].
  Future<bool> unlockWithTotp(String entered) async {
    try {
      if (!_identity.verifyTotpInput(entered)) {
        await _identity.logOtpFailure();
        return false;
      }
      await _identity.logLoginSuccess();
      final until = DateTime.now().add(const Duration(hours: _kTrustHours));
      _trustUntilMs = until.millisecondsSinceEpoch;
      final p = await SharedPreferences.getInstance();
      await p.setInt(_kTrustUntilMs, _trustUntilMs!);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('SessionController.unlockWithTotp: $e');
      rethrow;
    }
  }

  Future<void> lockSession() async {
    try {
      _trustUntilMs = null;
      final p = await SharedPreferences.getInstance();
      await p.remove(_kTrustUntilMs);
      notifyListeners();
    } catch (e) {
      debugPrint('SessionController.lockSession: $e');
    }
  }
}
