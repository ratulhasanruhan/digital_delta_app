import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/ui_tokens.dart';
import '../../../widgets/floating_disaster_nav.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/shell_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../drone/drone_ops_view.dart';
import '../hospital/field_hospital_view.dart';
import '../supplies/relief_supplies_view.dart';

/// Floating bottom nav + tab bodies (GetX [ShellController]).
class MainShellView extends GetView<ShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = Get.find<AuthController>();

    return Obx(
      () => Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            controller.title,
            style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
          ),
          actions: [
            IconButton(
              tooltip: 'Sign out',
              onPressed: () async {
                final ok = await Get.dialog<bool>(
                  AlertDialog(
                    title: const Text('Sign out?'),
                    content: const Text(
                      'You can sign in again with OTP on this device.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('Sign out'),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await auth.signOut();
                }
              },
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      cs.primary.withValues(alpha: 0.06),
                      cs.surfaceContainerLowest,
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: UiTokens.fabClearance(context) - 8,
                ),
                child: IndexedStack(
                  index: controller.currentTab.value,
                  children: const [
                    DashboardView(),
                    ReliefSuppliesView(),
                    DroneOpsView(),
                    FieldHospitalView(),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: FloatingDisasterNav(
          currentIndex: controller.currentTab.value,
          onSelect: controller.selectTab,
        ),
      ),
    );
  }
}
