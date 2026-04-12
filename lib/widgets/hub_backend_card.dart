import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../presentation/controllers/hub_session_controller.dart';

/// Optional gRPC connection to the Digital Delta server (host, port, JWT).
///
/// **Android emulator:** use `10.0.2.2` as host to reach your dev machine.
/// **Physical device:** use your PC’s LAN IP (same Wi‑Fi as the phone).
/// **JWT:** paste the same access token the server expects (e.g. from the web dashboard login).
class HubBackendCard extends StatefulWidget {
  const HubBackendCard({super.key});

  @override
  State<HubBackendCard> createState() => _HubBackendCardState();
}

class _HubBackendCardState extends State<HubBackendCard> {
  late final TextEditingController _grpcHost;
  late final TextEditingController _grpcPort;
  late final TextEditingController _jwt;
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _grpcHost = TextEditingController();
    _grpcPort = TextEditingController();
    _jwt = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final h = context.read<HubSessionController>();
    _grpcHost.text = h.grpcHost ?? '';
    _grpcPort.text = '${h.grpcPort}';
    _jwt.text = h.accessToken ?? '';
  }

  @override
  void dispose() {
    _grpcHost.dispose();
    _grpcPort.dispose();
    _jwt.dispose();
    super.dispose();
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backend hub (gRPC)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'App sign-in uses offline TOTP only. For Ping below, paste a JWT from the web dashboard (localStorage dd_token). Health needs no token.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _grpcHost,
              decoration: const InputDecoration(
                labelText: 'gRPC host',
                hintText: '192.168.x.x or 10.0.2.2 (emulator)',
                border: OutlineInputBorder(),
              ),
              autocorrect: false,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _grpcPort,
              decoration: const InputDecoration(
                labelText: 'gRPC port',
                hintText: '50051',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _jwt,
              decoration: const InputDecoration(
                labelText: 'JWT (for Ping)',
                hintText: 'Paste access token',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            Consumer<HubSessionController>(
              builder: (context, h, _) {
                final tok = h.accessToken;
                return Text(
                  tok != null && tok.isNotEmpty
                      ? 'JWT saved (${tok.length} chars)'
                      : 'No JWT saved — Health still works',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                );
              },
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    final h = context.read<HubSessionController>();
                    final port = int.tryParse(_grpcPort.text.trim());
                    await h.saveGrpc(
                      grpcHostValue: _grpcHost.text,
                      grpcPortValue: port,
                    );
                    if (context.mounted) _snack(context, 'Hub: gRPC address saved');
                  },
                  child: const Text('Save gRPC'),
                ),
                FilledButton(
                  onPressed: () async {
                    await context.read<HubSessionController>().saveAccessToken(_jwt.text);
                    if (context.mounted) _snack(context, 'Hub: JWT saved');
                  },
                  child: const Text('Save JWT'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      final s = await context.read<HubSessionController>().callHealth();
                      if (context.mounted) _snack(context, 'gRPC Health: $s');
                    } catch (e) {
                      if (context.mounted) _snack(context, 'Hub: $e');
                    }
                  },
                  child: const Text('Health'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    try {
                      final s = await context.read<HubSessionController>().callPing();
                      if (context.mounted) _snack(context, 'gRPC Ping: $s');
                    } catch (e) {
                      if (context.mounted) _snack(context, 'Hub: $e');
                    }
                  },
                  child: const Text('Ping'),
                ),
                TextButton(
                  onPressed: () async {
                    _jwt.clear();
                    await context.read<HubSessionController>().clearToken();
                    if (context.mounted) _snack(context, 'Hub: JWT cleared');
                  },
                  child: const Text('Clear JWT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
