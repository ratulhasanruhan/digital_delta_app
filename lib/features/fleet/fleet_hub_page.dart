import 'dart:async';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app/ui_tokens.dart';
import '../../core/rbac.dart';
import '../../widgets/dd_page_intro.dart';
import '../../data/disaster_map_loader.dart';
import '../pod/pod_service.dart';
import '../../domain/vehicle_profile.dart';
import '../../routing/simple_route_planner.dart';

/// M8 — reachability, rendezvous, handoff + battery-aware throttling.
class FleetHubPage extends StatefulWidget {
  const FleetHubPage({super.key});

  @override
  State<FleetHubPage> createState() => _FleetHubPageState();
}

class _FleetHubPageState extends State<FleetHubPage> {
  Future<DisasterMapData>? _map;
  final _battery = Battery();
  StreamSubscription<AccelerometerEvent>? _accelSub;
  double _accelMag = 0;

  @override
  void initState() {
    super.initState();
    _map = DisasterMapData.load();
    _accelSub = accelerometerEventStream().listen((e) {
      final m = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (mounted) setState(() => _accelMag = m);
    });
  }

  @override
  void dispose() {
    unawaited(_accelSub?.cancel() ?? Future<void>.value());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DisasterMapData>(
      future: _map,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final map = snap.data!;
        final nodes = map.nodeLatLng.keys.toList()..sort();

        return ListView(
          padding: UiTokens.pageInsets.copyWith(bottom: 28),
          children: [
            DdPageIntro(
              title: 'Fleet & handoff (M8)',
              description:
                  'Trucks follow roads; boats follow rivers. Places neither can reach are marked for drone or other air support. '
                  'M8.2 shows three Weiszfeld rendezvous points on live node coordinates; M8.3 runs a signed PoD into the CRDT supply ledger.',
            ),
            const SizedBox(height: 16),
            _reachabilitySection(context, map, nodes),
            const SizedBox(height: 24),
            Text(
              'M8.2 — rendezvous scenarios (Weiszfeld median)',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Weighted geometric median minimizes sum of weighted great‑circle distances to the chosen nodes (same math as the single demo, now on three named triplets).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            ..._m8ScenarioCards(context, map),
            const SizedBox(height: 24),
            Text(
              'M8.3 — boat → drone PoD + CRDT ledger',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Builds a signed challenge, verifies payload hash + nonce, countersigns, and appends a POD receipt row to the supply OR‑set (same path as other deliveries). Requires writeSupply.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: _runBoatDroneHandoff,
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Run boat→drone handoff (demo)'),
            ),
            const SizedBox(height: 24),
            Text(
              'Battery & broadcast pace',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: _battery.batteryLevel,
              builder: (context, bat) {
                final level = bat.data ?? 0;
                var intervalSec = level < 20
                    ? 120
                    : level < 50
                    ? 60
                    : 20;
                if (_accelMag > 12) {
                  intervalSec += 30;
                }
                return Text(
                  'Battery $level% · motion ${_accelMag.toStringAsFixed(1)} m/s² '
                  '→ suggested beacon interval ~ ${intervalSec}s (longer when power is low or you are moving).',
                  style: Theme.of(context).textTheme.bodyMedium,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _runBoatDroneHandoff() async {
    final messenger = ScaffoldMessenger.of(context);
    final pod = context.read<PodService>();
    const payload =
        '{"handoff":"boat_to_drone","demo":"M8.3","ts":"2026-04-13"}';
    final id = 'M8-HANDOFF-${DateTime.now().millisecondsSinceEpoch}';
    try {
      final ch = await pod.buildChallenge(deliveryId: id, payloadUtf8: payload);
      final err = await pod.finalizeDelivery(ch: ch, cargoPayloadUtf8: payload);
      if (!mounted) return;
      if (err != null) {
        messenger.showSnackBar(SnackBar(content: Text('PoD: $err')));
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'PoD challenge verified; receipt appended to CRDT supply ledger.',
            ),
          ),
        );
      }
    } on RbacDeniedException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Need writeSupply permission: $e')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  List<Widget> _m8ScenarioCards(BuildContext context, DisasterMapData map) {
    final n = map.nodeLatLng;
    final scenarios = <({String name, List<(LatLng, double)> pts})>[
      (
        name: 'A · Camp supply run (N3 camp, N2 air hub, N6 hospital)',
        pts: [(n['N3']!, 1.2), (n['N2']!, 1.0), (n['N6']!, 1.0)],
      ),
      (
        name: 'B · Eastern corridor (N1 hub, N4 outpost, N5 waypoint)',
        pts: [(n['N1']!, 1.0), (n['N4']!, 1.1), (n['N5']!, 0.9)],
      ),
      (
        name: 'C · Cross-mode triage (N2, N4, N6)',
        pts: [(n['N2']!, 1.0), (n['N4']!, 1.0), (n['N6']!, 1.0)],
      ),
    ];
    return scenarios.map((s) {
      final meet = _weiszfeld(s.pts);
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Weiszfeld geometric median: ${_fmt(meet)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _reachabilitySection(
    BuildContext context,
    DisasterMapData map,
    List<String> nodes,
  ) {
    const start = 'N1';
    final truckUnreachable = <String>[];
    final boatUnreachable = <String>[];
    final droneOnly = <String>[];

    final gTruck = map.graphForVehicle(vehicle: VehicleKind.truck);
    final gBoat = map.graphForVehicle(vehicle: VehicleKind.speedboat);
    for (final n in nodes) {
      if (n == start) continue;
      final t = shortestPathMinutes(graph: gTruck, startId: start, goalId: n);
      final b = shortestPathMinutes(graph: gBoat, startId: start, goalId: n);
      if (t == null) truckUnreachable.add(n);
      if (b == null) boatUnreachable.add(n);
      if (t == null && b == null) droneOnly.add(n);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unreachable by truck from $start',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(truckUnreachable.isEmpty ? '—' : truckUnreachable.join(', ')),
        const SizedBox(height: 8),
        Text(
          'Unreachable by boat from $start',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(boatUnreachable.isEmpty ? '—' : boatUnreachable.join(', ')),
        const SizedBox(height: 8),
        Text(
          'Drone-required (neither)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          droneOnly.isEmpty ? '—' : droneOnly.join(', '),
          style: TextStyle(
            color: droneOnly.isEmpty
                ? null
                : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// M8.2 — iterative geometric median (minimizes sum of weighted distances).
  LatLng _weiszfeld(List<(LatLng, double)> weighted, {int iterations = 12}) {
    if (weighted.isEmpty) {
      return const LatLng(0, 0);
    }
    var x = 0.0;
    var y = 0.0;
    var wsum = 0.0;
    for (final (p, w) in weighted) {
      x += p.latitude * w;
      y += p.longitude * w;
      wsum += w;
    }
    var cur = LatLng(x / wsum, y / wsum);
    const dist = Distance();
    for (var k = 0; k < iterations; k++) {
      double numLat = 0, numLng = 0, den = 0;
      for (final (p, w) in weighted) {
        final d = math.max(dist(cur, p), 1e-6);
        final t = w / d;
        numLat += p.latitude * t;
        numLng += p.longitude * t;
        den += t;
      }
      if (den == 0) break;
      cur = LatLng(numLat / den, numLng / den);
    }
    return cur;
  }

  String _fmt(LatLng ll) =>
      '${ll.latitude.toStringAsFixed(4)}, ${ll.longitude.toStringAsFixed(4)}';
}
