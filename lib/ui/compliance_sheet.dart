import 'package:flutter/material.dart';

/// Maps HackFusion Track A + M1–M8 to what this build implements (judge-facing).
void showComplianceSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.45,
        builder: (context, scroll) {
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              Text('Implementation map', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Aligned with Digital Delta problem statement. gRPC/protobuf on mesh (C1); '
                'Ed25519 + AES-256-GCM + SHA-256 (C5/C6).',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              _section(ctx, 'Track A — UI/UX', [
                _row('A1 Design system', 'Material 3, DM Sans, green primary seed palette'),
                _row('A2 Responsive', 'Grid + breakpoints on dashboard & map'),
                _row('A3 Dashboard', 'Ops home + map + SLA + ML overlays'),
                _row('A4 Accessibility', 'Semantics on status bar; contrast via Material tokens'),
                _row('A5 Sync UX', 'Top strip: offline / online / syncing / conflict / verified'),
              ]),
              _section(ctx, 'M1 Identity', [
                _row('TOTP/HOTP', 'RFC 6238/4226 SHA-256 offline'),
                _row('Keys', 'Ed25519 in secure storage + pubkey ledger (SQLite)'),
                _row('RBAC', 'Enforced in SupplyRepository + mesh actions'),
                _row('Audit', 'Hash-chained log + integrity check'),
              ]),
              _section(ctx, 'M2 CRDT & sync', [
                _row('Model', 'OR-Set supply + vector clock'),
                _row('Sync', 'gRPC DeltaSync LAN + mDNS; protobuf-only on wire'),
                _row('Conflicts', 'Pending queue + resolve + audit'),
                _row('Bandwidth', 'Delta chunk size surfaced in UI'),
              ]),
              _section(ctx, 'M3 Mesh relay', [
                _row('Store-forward', 'SQLite outbox + TTL + hop count'),
                _row('E2E', 'X25519 + AES-256-GCM sealed payloads'),
                _row('BLE', 'Proximity fingerprint beacons; bulk on Wi‑Fi'),
              ]),
              _section(ctx, 'M4 Routing', [
                _row('Graph', 'Road / water / air edges + weights'),
                _row('Failure', 'Edge closure + Dijkstra recompute'),
                _row('Map', 'flutter_map + offline JSON graph'),
              ]),
              _section(ctx, 'M5 PoD', [
                _row('QR', 'Signed challenge + countersign + nonce store'),
                _row('Ledger', 'PoD rows in CRDT supply'),
              ]),
              _section(ctx, 'M6 Triage', [
                _row('SLA', 'P0–P3 windows + breach when route slows'),
                _row('Preemption', 'Logged when commander/sync admin executes'),
              ]),
              _section(ctx, 'M7 ML', [
                _row('ONNX', 'Edge risk classifier on-device'),
                _row('Map', 'Risk-weighted routing integration'),
              ]),
              _section(ctx, 'M8 Fleet', [
                _row('Reachability', 'Drone-required zones from graph'),
                _row('Rendezvous', 'Time-optimal meet point heuristic'),
                _row('Throttle', 'Battery + accelerometer-aware cadence'),
              ]),
            ],
          );
        },
      );
    },
  );
}

Widget _section(BuildContext context, String title, List<Widget> rows) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ...rows,
    ],
  );
}

Widget _row(String a, String b) {
  return Builder(
    builder: (context) {
      final base = Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 13, height: 1.35) ??
          const TextStyle(fontSize: 13, height: 1.35);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: base,
                  children: [
                    TextSpan(text: '$a — ', style: const TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: b),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
