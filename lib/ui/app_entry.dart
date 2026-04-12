import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/session_controller.dart';
import '../data/supply_repository.dart';
import '../features/identity/services/identity_service.dart';
import 'onboarding_page.dart';
import 'operator_shell.dart';
import 'unlock_page.dart';

/// Routes first-time users through onboarding, then TOTP unlock, then the main shell.
class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final id = context.watch<IdentityService>();
    final session = context.watch<SessionController>();

    if (!id.isReady) {
      final cs = Theme.of(context).colorScheme;
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: cs.primaryContainer,
                child: Icon(Icons.water_drop_rounded, size: 32, color: cs.onPrimaryContainer),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!session.onboardingComplete) {
      return const OnboardingPage();
    }

    if (session.needsUnlock) {
      return const UnlockPage();
    }

    return OperatorShell(repository: context.read<SupplyRepository>());
  }
}
