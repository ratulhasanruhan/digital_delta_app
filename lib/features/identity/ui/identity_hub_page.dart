import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../app/ui_tokens.dart';
import '../../../widgets/dd_page_intro.dart';
import '../../../widgets/hub_backend_card.dart';
import '../../pod/pod_hub_page.dart';
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

  String _shortHash(Object? rowHash) {
    final s = rowHash?.toString() ?? '';
    if (s.length <= 10) return s;
    return '${s.substring(0, 10)}…';
  }

  String _auditEventLabel(String event) {
    switch (event) {
      case 'login_success':
        return 'Login success';
      case 'otp_failure':
        return 'OTP failure';
      case 'signing_keys_rotated':
        return 'Key rotation (Ed25519)';
      case 'keypair_provisioned':
        return 'Keypair provisioned';
      case 'totp_secret_provisioned':
        return 'TOTP secret provisioned';
      case 'role_changed':
        return 'Role changed';
      case 'hotp_counter_advanced':
        return 'HOTP counter advanced';
      case 'manual_verify':
        return 'Manual test event';
      default:
        return event;
    }
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
        const HubBackendCard(),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(Icons.verified_user_rounded, color: cs.primary),
            title: Text(
              'Proof of delivery (Module 5)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Signed QR handoff — works fully offline. Needs a role that can write supplies for the ledger.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const PodHubPage()),
              );
            },
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
                  'Audit trail (M1.4 — hash chain)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Every login, OTP failure, key rotation, and other security events is appended locally. '
                  'Each row stores SHA-256(prev_hash | ts | event | payload); change any field and verification fails.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                FutureBuilder<String?>(
                  key: ValueKey('${_auditRefresh}_reason'),
                  future: id.audit.integrityFailureReason(),
                  builder: (context, snap) {
                    if (!snap.hasData && snap.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }
                    final reason = snap.data;
                    final ok = reason == null;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              ok ? Icons.verified_outlined : Icons.warning_amber_rounded,
                              color: ok ? cs.primary : cs.error,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                ok ? 'Chain OK — log is tamper-evident' : 'Tampering detected',
                                style: TextStyle(
                                  color: ok ? cs.onSurface : cs.error,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (!ok) ...[
                          const SizedBox(height: 8),
                          Text(
                            reason,
                            style: TextStyle(
                              color: cs.error,
                              fontSize: 12,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 8),
                FutureBuilder<String>(
                  key: ValueKey('${_auditRefresh}_tip'),
                  future: id.audit.chainTipHash(),
                  builder: (context, snap) {
                    final tip = snap.data;
                    if (tip == null || tip.isEmpty) return const SizedBox.shrink();
                    final short = tip.length > 12 ? '${tip.substring(0, 12)}…' : tip;
                    return Text(
                      'Chain tip: $short',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontFamily: 'monospace',
                          ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () async {
                        await id.audit.injectCorruptionInLatestRow();
                        _bumpAudit();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Injected corruption: last row payload altered. Tap “Verify” — chain should fail.',
                            ),
                            backgroundColor: cs.errorContainer,
                          ),
                        );
                      },
                      icon: const Icon(Icons.bug_report_outlined, size: 20),
                      label: const Text('Inject log corruption (demo)'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await id.audit.verifyIntegrity();
                        if (!context.mounted) return;
                        _bumpAudit();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(ok ? 'verifyIntegrity(): true' : 'verifyIntegrity(): false'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.fact_check_outlined, size: 20),
                      label: const Text('Re-verify chain'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await id.audit.append(
                          event: 'manual_verify',
                          payload: {'source': 'identity_hub'},
                        );
                        _bumpAudit();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Appended valid event — tip hash updated')),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: const Text('Append test event'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Recent events',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                FutureBuilder<List<Map<String, Object?>>>(
                  key: ValueKey(_auditRefresh),
                  future: id.audit.recent(limit: 16),
                  builder: (context, snap) {
                    final rows = snap.data;
                    if (rows == null) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        for (final r in rows)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(
                              _auditEventLabel('${r['event']}'),
                              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${_formatAuditTime(r['ts'])} · ${_shortHash(r['row_hash'])}',
                              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 11),
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
