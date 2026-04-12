import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/ui_tokens.dart';
import '../../../widgets/dd_page_intro.dart';
import '../../../core/rbac.dart';
import '../../../data/supply_repository.dart';
import '../services/identity_service.dart';

/// Security: TOTP, keys, role, audit (plain-language UI).
class IdentityHubPage extends StatefulWidget {
  const IdentityHubPage({super.key});

  @override
  State<IdentityHubPage> createState() => _IdentityHubPageState();
}

class _IdentityHubPageState extends State<IdentityHubPage> {
  int _auditRefresh = 0;
  Timer? _totpTimer;

  void _bumpAudit() => setState(() => _auditRefresh++);

  @override
  void initState() {
    super.initState();
    _totpTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _totpTimer?.cancel();
    super.dispose();
  }

  /// Avoid showing the same long key twice: ledger rows that match this device say so.
  String _ledgerKeyLine(String? rowPk, String? currentPk) {
    if (rowPk == null || rowPk.isEmpty) return '';
    if (currentPk != null && rowPk == currentPk) {
      return 'This phone — matches the key above';
    }
    return rowPk.length > 36 ? '${rowPk.substring(0, 34)}…' : rowPk;
  }

  String _formatAuditTime(Object? ts) {
    if (ts is int) {
      return DateTime.fromMillisecondsSinceEpoch(ts).toLocal().toString().split('.').first;
    }
    return '$ts';
  }

  @override
  Widget build(BuildContext context) {
    final id = context.watch<IdentityService>();
    final cs = Theme.of(context).colorScheme;
    if (!id.isReady) {
      return const Center(child: CircularProgressIndicator());
    }
    final totp = id.currentTotp();
    final remain = id.totpSecondsRemaining();
    final hotp = id.currentHotp();
    final repo = context.watch<SupplyRepository>();
    final currentPk = id.publicKeyHex;

    return ListView(
      padding: UiTokens.pageInsets.copyWith(bottom: 28),
      children: [
        DdPageIntro(
          title: 'Security in simple terms',
          description:
              '• Role — what this app lets you change (supplies, sync, etc.). You can switch role here anytime.\n'
              '• Unlock code — the 6-digit number below is only for this phone. After you tap Lock on the home screen, '
              'type that same code to open the app again. No internet or server is involved.\n'
              '• Your key — a long id used for signing; others never need to type it by hand.',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your unlock code (6 digits)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Use these digits when the app asks after Lock — same as on the lock screen.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  totp,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                        color: cs.onSurface,
                      ),
                ),
                Text(
                  'Updates in ${remain}s',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () async {
                    await id.logLoginSuccess();
                    _bumpAudit();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved to activity log')),
                      );
                    }
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('Record “opened app” in log'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your public key (one place)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Used for signed messages and delivery proof. Copy if a teammate needs to verify this device.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  currentPk ?? '—',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 10),
                FilledButton.tonalIcon(
                  onPressed: currentPk == null
                      ? null
                      : () async {
                          await Clipboard.setData(ClipboardData(text: currentPk));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied')),
                            );
                          }
                        },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy key'),
                ),
                if (id.role.can(Permission.manageIdentity)) ...[
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      try {
                        await id.rotateSigningKeys();
                        _bumpAudit();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New keys created; list below updates')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.key_off_outlined),
                    label: const Text('Create new keys (advanced)'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Registered keys (history)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Each line is an event. Your phone’s key is not repeated as a second long block — see note on each row.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, Object?>>>(
                  key: ValueKey(_auditRefresh),
                  future: repo.publicKeyLedgerEntries(limit: 24),
                  builder: (context, snap) {
                    final rows = snap.data;
                    if (rows == null) {
                      return const LinearProgressIndicator();
                    }
                    if (rows.isEmpty) {
                      return Text('Nothing yet', style: Theme.of(context).textTheme.bodySmall);
                    }
                    return Column(
                      children: [
                        for (final r in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              '${r['event']} · ${r['replica_id']}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            subtitle: Text(
                              _ledgerKeyLine(r['pubkey_hex'] as String?, currentPk),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your role',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pick what matches your job. This only changes what you can tap in the app — not a server account.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final r in UserRole.values)
                      FilterChip(
                        label: Text(r.label),
                        selected: id.role == r,
                        showCheckmark: false,
                        onSelected: (_) async {
                          await id.setRole(r);
                          _bumpAudit();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ExpansionTile(
          title: Text(
            'Extra: contest / testing tools',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            'HOTP demo, fake “wrong code” log, audit tamper test',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('HOTP (counter code)', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 8),
                  SelectableText(
                    hotp,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          letterSpacing: 3,
                          color: cs.onSurface,
                        ),
                  ),
                  Text('Counter: ${id.hotpCounter}'),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () async {
                      try {
                        await id.advanceHotpCounter();
                        _bumpAudit();
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.exposure_plus_1_outlined),
                    label: const Text('Advance counter (demo)'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      await id.logOtpFailure();
                      _bumpAudit();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged as failed attempt')),
                        );
                      }
                    },
                    child: const Text('Log a fake “wrong code” (demo)'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Activity log (tamper check)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                FutureBuilder<bool>(
                  key: ValueKey(_auditRefresh),
                  future: id.audit.verifyIntegrity(),
                  builder: (context, snap) {
                    final ok = snap.data;
                    if (ok == null) {
                      return const LinearProgressIndicator();
                    }
                    return Row(
                      children: [
                        Icon(
                          ok ? Icons.check_circle : Icons.error,
                          color: ok ? cs.primary : cs.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ok ? 'Log looks intact' : 'Problem detected in log',
                            style: TextStyle(
                              color: ok ? cs.onSurface : cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                ExpansionTile(
                  title: const Text('Technical checks (judges)'),
                  children: [
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed: () async {
                            await id.audit.injectCorruptionInLatestRow();
                            _bumpAudit();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Test: damaged last row')),
                              );
                            }
                          },
                          child: const Text('Simulate tamper'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () async {
                            await id.audit.append(
                              event: 'manual_verify',
                              payload: {'source': 'identity_hub'},
                            );
                            _bumpAudit();
                          },
                          child: const Text('Add test event'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Map<String, Object?>>>(
                  key: ValueKey(_auditRefresh),
                  future: id.audit.recent(limit: 12),
                  builder: (context, snap) {
                    final rows = snap.data;
                    if (rows == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        for (final r in rows)
                          ListTile(
                            dense: true,
                            title: Text('${r['event']}', style: TextStyle(color: cs.onSurface)),
                            subtitle: Text(
                              _formatAuditTime(r['ts']),
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
