import 'dart:async';
import 'dart:math' as math;

import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../app/ui_tokens.dart';
import '../../widgets/dd_page_intro.dart';
import '../../data/disaster_map_loader.dart';
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
              title: 'Fleet & handoff',
              description:
                  'Trucks follow roads; boats follow rivers. Places neither can reach are marked for drone or other air support.',
            ),
            const SizedBox(height: 16),
            _reachabilitySection(context, map, nodes),
            const SizedBox(height: 24),
            Text(
              'Meet point (demo)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              _rendezvousText(map),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Boat → drone handoff',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Use Proof of delivery when the boat hands off to the drone team — same signing flow as other QR handoffs.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Text(
              'Battery & broadcast pace',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            FutureBuilder<int>(
              future: _battery.batteryLevel,
              builder: (context, bat) {
                final level = bat.data ?? 0;
                var intervalSec = level < 20 ? 120 : level < 50 ? 60 : 20;
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
        Text('Unreachable by truck from $start', style: Theme.of(context).textTheme.titleSmall),
        Text(truckUnreachable.isEmpty ? '—' : truckUnreachable.join(', ')),
        const SizedBox(height: 8),
        Text('Unreachable by boat from $start', style: Theme.of(context).textTheme.titleSmall),
        Text(boatUnreachable.isEmpty ? '—' : boatUnreachable.join(', ')),
        const SizedBox(height: 8),
        Text('Drone-required (neither)', style: Theme.of(context).textTheme.titleSmall),
        Text(
          droneOnly.isEmpty ? '—' : droneOnly.join(', '),
          style: TextStyle(
            color: droneOnly.isEmpty ? null : Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _rendezvousText(DisasterMapData map) {
    final boat = map.nodeLatLng['N3'];
    final base = map.nodeLatLng['N2'];
    final dest = map.nodeLatLng['N6'];
    if (boat == null || base == null || dest == null) {
      return 'Missing nodes for demo triplet.';
    }
    final meet = _weiszfeld(
      [
        (boat, 1.2),
        (base, 1.0),
        (dest, 1.0),
      ],
    );
    return 'Boat@${_fmt(boat)} • Drone base@${_fmt(base)} • Dest@${_fmt(dest)}\n'
        'Weiszfeld rendezvous (weighted Fermat–Weber): ${_fmt(meet)}';
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
