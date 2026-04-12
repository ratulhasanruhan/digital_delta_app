import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/identity/services/identity_service.dart';
import 'shell_controller.dart';

const _kLoggedIn = 'dd_auth_session_v3';
const _kPhone = 'dd_auth_phone_v3';

/// Offline-first auth: phone + **TOTP** (RFC 6238, SHA-256) verified locally — no server.
class AuthController extends ChangeNotifier {
  AuthController(this._identity, this._shell);

  final IdentityService _identity;
  final ShellController _shell;

  bool _isLoggedIn = false;
  String? _phoneDisplay;

  bool get isLoggedIn => _isLoggedIn;
  String? get phoneDisplay => _phoneDisplay;

  Future<void> loadFromStorage() async {
    try {
      final p = await SharedPreferences.getInstance();
      _isLoggedIn = p.getBool(_kLoggedIn) ?? false;
      _phoneDisplay = p.getString(_kPhone);
      notifyListeners();
    } catch (e) {
      debugPrint('AuthController.loadFromStorage: $e');
    }
  }

  /// Call from [main] before [runApp] so [Consumer] shows the right screen.
  Future<void> hydrateBeforeFirstFrame() async {
    await loadFromStorage();
  }

  Future<bool> verifyOtp({
    required String phoneDigits,
    required String otp,
  }) async {
    try {
      if (!_identity.verifyTotpInput(otp)) {
        await _identity.logOtpFailure();
        return false;
      }
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kLoggedIn, true);
      await p.setString(_kPhone, phoneDigits.trim());
      _isLoggedIn = true;
      _phoneDisplay = phoneDigits.trim();
      await _identity.logLoginSuccess();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AuthController.verifyOtp: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_kLoggedIn);
      await p.remove(_kPhone);
      _isLoggedIn = false;
      _phoneDisplay = null;
      _shell.reset();
      notifyListeners();
    } catch (e) {
      debugPrint('AuthController.signOut: $e');
      rethrow;
    }
  }
}
