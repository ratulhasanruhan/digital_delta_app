import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/session_controller.dart';
import '../app/ui_tokens.dart';
import '../core/rbac.dart';
import '../data/supply_repository.dart';
import '../features/identity/services/identity_service.dart';
import '../network/ingress_sync_client.dart';

/// First-run: mission context, offline guarantee, default role.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  UserRole _role = UserRole.fieldVolunteer;
  bool _busy = false;
  final _hubHost = TextEditingController();
  final _hubPort = TextEditingController(text: '$kDeltaSyncIngressDefaultPort');

  @override
  void dispose() {
    _hubHost.dispose();
    _hubPort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.14),
              cs.surfaceContainerLowest,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: UiTokens.maxContentWidth),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(Icons.water_drop_rounded, size: 44, color: cs.onPrimaryContainer),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Digital Delta',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Coordinate relief when towers and power are down: keep routes, supplies, and delivery proof on your phone, '
                      'and share updates when another device is in range. Core operations do not need the public internet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.45,
                            color: cs.onSurface.withValues(alpha: 0.9),
                          ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Your role',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick the role that matches your duty (volunteer, driver, camp lead, etc.). '
                      'You can change this later under Security.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final r in UserRole.values)
                          FilterChip(
                            selected: _role == r,
                            showCheckmark: false,
                            label: Text(r.label),
                            onSelected: _busy ? null : (_) => setState(() => _role = r),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Optional hub sync (first time)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Contest rules allow internet for initial sync and dashboard. If your team runs syncd, '
                      'enter its hostname or IP to upload your local snapshot once. Leave blank to skip.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.35,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hubHost,
                      decoration: const InputDecoration(
                        labelText: 'Hub host (optional)',
                        hintText: 'e.g. 192.168.1.10 or sync.example.com',
                      ),
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _hubPort,
                      decoration: const InputDecoration(
                        labelText: 'gRPC port',
                      ),
                      keyboardType: TextInputType.number,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 36),
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              final id = context.read<IdentityService>();
                              final session = context.read<SessionController>();
                              final repo = context.read<SupplyRepository>();
                              final messenger = ScaffoldMessenger.of(context);
                              setState(() => _busy = true);
                              try {
                                await id.setRole(_role);
                                final host = _hubHost.text.trim();
                                if (host.isNotEmpty) {
                                  final port =
                                      int.tryParse(_hubPort.text.trim()) ?? kDeltaSyncIngressDefaultPort;
                                  final net = await Connectivity().checkConnectivity();
                                  final offline = net.isEmpty ||
                                      net.every((r) => r == ConnectivityResult.none);
                                  if (offline) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'No network — skipped hub sync. Use Sync tab later when online.',
                                        ),
                                      ),
                                    );
                                  } else {
                                    try {
                                      final ack = await pushSupplyToIngress(
                                        repo: repo,
                                        host: host,
                                        port: port,
                                      );
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Hub received snapshot (seq ${ack.lastSequence}).',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      messenger.showSnackBar(
                                        SnackBar(content: Text('Hub sync failed: $e')),
                                      );
                                    }
                                  }
                                }
                                await session.completeOnboarding();
                              } finally {
                                if (mounted) setState(() => _busy = false);
                              }
                            },
                      child: _busy
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Continue'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
