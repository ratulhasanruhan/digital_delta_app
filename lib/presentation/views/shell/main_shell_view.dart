import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../app/ui_tokens.dart';
import '../../../widgets/floating_disaster_nav.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/shell_controller.dart';
import '../dashboard/dashboard_view.dart';
import '../drone/drone_ops_view.dart';
import '../supplies/relief_supplies_view.dart';
import '../../../features/risk/ml_road_risk_hub_page.dart';

/// Floating bottom nav + tab bodies (Provider [ShellController]).
class MainShellView extends StatelessWidget {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<ShellController>(
      builder: (context, shell, _) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text(
              shell.title,
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w700),
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Sign out',
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Sign out?'),
                      content: const Text(
                        'You can sign in again with TOTP on this device.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Sign out'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    await context.read<AuthController>().signOut();
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
                    index: shell.currentTab,
                    children: const [
                      DashboardView(),
                      ReliefSuppliesView(),
                      DroneOpsView(),
                      MlRoadRiskHubPage(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: FloatingDisasterNav(
            currentIndex: shell.currentTab,
            onSelect: shell.selectTab,
          ),
        );
      },
    );
  }
}
