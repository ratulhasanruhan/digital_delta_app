import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/routes/app_routes.dart';
import 'shell_controller.dart';

const _kLoggedIn = 'dd_auth_session_v3';
const _kPhone = 'dd_auth_phone_v3';

/// Offline-first auth: phone + OTP persisted locally.
/// Demo OTP: **123456**.
class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxnString phoneDisplay = RxnString();

  Future<void> loadFromStorage() async {
    try {
      final p = await SharedPreferences.getInstance();
      isLoggedIn.value = p.getBool(_kLoggedIn) ?? false;
      phoneDisplay.value = p.getString(_kPhone);
    } catch (e) {
      debugPrint('AuthController.loadFromStorage: $e');
    }
  }

  /// Call from [main] before [runApp] so initial route is correct.
  Future<void> hydrateBeforeFirstFrame() async {
    await loadFromStorage();
  }

  Future<bool> verifyOtp({
    required String phoneDigits,
    required String otp,
  }) async {
    try {
      final normalized = otp.trim();
      if (normalized != '123456') {
        return false;
      }
      final p = await SharedPreferences.getInstance();
      await p.setBool(_kLoggedIn, true);
      await p.setString(_kPhone, phoneDigits.trim());
      isLoggedIn.value = true;
      phoneDisplay.value = phoneDigits.trim();
      Get.offAllNamed<void>(AppRoutes.home);
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
      isLoggedIn.value = false;
      phoneDisplay.value = null;
      if (Get.isRegistered<ShellController>()) {
        Get.delete<ShellController>(force: true);
      }
      Get.offAllNamed<void>(AppRoutes.login);
    } catch (e) {
      debugPrint('AuthController.signOut: $e');
      rethrow;
    }
  }
}
