import 'package:get/get.dart';

import '../../presentation/views/auth/otp_login_view.dart';
import '../../presentation/views/shell/main_shell_view.dart';
import '../bindings/shell_binding.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<void>(
      name: AppRoutes.login,
      page: () => const OtpLoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage<void>(
      name: AppRoutes.home,
      page: () => const MainShellView(),
      binding: ShellBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
