import '../data/disaster_map_loader.dart';
import '../domain/vehicle_profile.dart';
import 'typed_route_planner.dart';

/// One contiguous leg driven by a single vehicle class (M4.3).
class RouteSegment {
  RouteSegment({
    required this.vehicle,
    required this.nodeIds,
    required this.minutes,
  });

  final VehicleKind vehicle;
  final List<String> nodeIds;
  final double minutes;
}

/// Cross-mode transfer at a hub (M4.3 handoff).
class HandoffEvent {
  HandoffEvent({
    required this.nodeId,
    required this.nodeName,
    required this.fromVehicle,
    required this.toVehicle,
  });

  final String nodeId;
  final String nodeName;
  final VehicleKind fromVehicle;
  final VehicleKind toVehicle;
}

/// M4 — shortest path with optional zero-cost vehicle switches at any node.
class MultiModalPathResult {
  MultiModalPathResult({
    required this.totalMinutes,
    required this.segments,
    required this.handoffs,
  });

  final double totalMinutes;
  final List<RouteSegment> segments;
  final List<HandoffEvent> handoffs;
}

String _stateKey(String nodeId, VehicleKind v) => '${nodeId}__${v.name}';

(String, VehicleKind) _parseState(String key) {
  final i = key.lastIndexOf('__');
  if (i < 0) {
    throw FormatException('bad state $key');
  }
  final node = key.substring(0, i);
  final name = key.substring(i + 2);
  final vk = VehicleKind.values.firstWhere((e) => e.name == name);
  return (node, vk);
}

TypedEdge? _edgeBetween(DisasterMapData map, String a, String b) {
  for (final e in map.typedEdges) {
    if (e.from == a && e.to == b) return e;
    if (e.to == a && e.from == b) return e;
  }
  return null;
}

bool _edgeOkForVehicle({
  required TypedEdge e,
  required VehicleKind vk,
  required double payloadKg,
  required Set<String> closedEdgeIds,
  Map<String, double> onnxRiskByEdgeId = const {},
}) {
  if (closedEdgeIds.contains(e.id)) return false;
  if (e.isFlooded) return false;
  if (!vk.canUseEdgeMode(e.mode)) return false;
  if (payloadKg > vk.maxPayloadKg) return false;
  if (payloadKg > e.capacityKg) return false;
  return true;
}

double _edgeWeight(TypedEdge e, Map<String, double> onnxRiskByEdgeId) {
  final onnx = onnxRiskByEdgeId[e.id] ?? 0;
  return e.effectiveMinutes(onnxImpassabilityProb: onnx);
}

String _nodeName(DisasterMapData map, String id) {
  for (final n in map.nodes) {
    if (n.id == id) return n.name;
  }
  return id;
}

/// Dijkstra on expanded states (node × vehicle). Handoffs cost 0 at the same node.
MultiModalPathResult? shortestMultiModalPath({
  required DisasterMapData map,
  required String startId,
  required String goalId,
  required VehicleKind startVehicle,
  double payloadKg = 500,
  Map<String, double> onnxRiskByEdgeId = const {},
}) {
  final nodeIds = map.nodes.map((n) => n.id).toList();
  if (!nodeIds.contains(startId) || !nodeIds.contains(goalId)) {
    return null;
  }
  if (startId == goalId) {
    return MultiModalPathResult(
      totalMinutes: 0,
      segments: [
        RouteSegment(vehicle: startVehicle, nodeIds: [startId], minutes: 0),
      ],
      handoffs: [],
    );
  }

  final vehicles = VehicleKind.values;
  final states = <String>[
    for (final n in nodeIds)
      for (final v in vehicles) _stateKey(n, v),
  ];

  final dist = <String, double>{for (final s in states) s: double.infinity};
  final prev = <String, String?>{for (final s in states) s: null};
  final done = <String>{};

  final s0 = _stateKey(startId, startVehicle);
  dist[s0] = 0;

  while (true) {
    String? u;
    var best = double.infinity;
    for (final st in states) {
      if (done.contains(st)) continue;
      final d = dist[st] ?? double.infinity;
      if (d < best) {
        best = d;
        u = st;
      }
    }
    if (u == null || best == double.infinity) break;

    done.add(u);
    final (nodeU, vkU) = _parseState(u);

    // Zero-cost vehicle switch at nodeU
    for (final vk2 in vehicles) {
      if (vk2 == vkU) continue;
      final vKey = _stateKey(nodeU, vk2);
      final alt = best;
      if (alt < (dist[vKey] ?? double.infinity)) {
        dist[vKey] = alt;
        prev[vKey] = u;
      }
    }

    // Move along an edge with vehicle vkU
    for (final e in map.typedEdges) {
      String? other;
      if (e.from == nodeU) {
        other = e.to;
      } else if (e.to == nodeU) {
        other = e.from;
      } else {
        continue;
      }
      if (!_edgeOkForVehicle(
        e: e,
        vk: vkU,
        payloadKg: payloadKg,
        closedEdgeIds: map.closedEdgeIds,
        onnxRiskByEdgeId: onnxRiskByEdgeId,
      )) {
        continue;
      }
      final w = _edgeWeight(e, onnxRiskByEdgeId);
      final vKey = _stateKey(other, vkU);
      final alt = best + w;
      if (alt < (dist[vKey] ?? double.infinity)) {
        dist[vKey] = alt;
        prev[vKey] = u;
      }
    }
  }

  String? bestGoal;
  var bestT = double.infinity;
  for (final vk in vehicles) {
    final k = _stateKey(goalId, vk);
    final t = dist[k] ?? double.infinity;
    if (t < bestT) {
      bestT = t;
      bestGoal = k;
    }
  }
  if (bestGoal == null || bestT == double.infinity) {
    return null;
  }

  final raw = <String>[];
  String? cur = bestGoal;
  while (cur != null) {
    raw.add(cur);
    cur = prev[cur];
  }
  final chain = raw.reversed.toList();

  final segments = <RouteSegment>[];
  final handoffs = <HandoffEvent>[];

  var nodes = <String>[_parseState(chain.first).$1];
  var vk = _parseState(chain.first).$2;
  var acc = 0.0;

  for (var i = 1; i < chain.length; i++) {
    final p = _parseState(chain[i - 1]);
    final c = _parseState(chain[i]);
    if (p.$1 == c.$1 && p.$2 != c.$2) {
      segments.add(RouteSegment(vehicle: vk, nodeIds: List<String>.from(nodes), minutes: acc));
      handoffs.add(
        HandoffEvent(
          nodeId: c.$1,
          nodeName: _nodeName(map, c.$1),
          fromVehicle: p.$2,
          toVehicle: c.$2,
        ),
      );
      vk = c.$2;
      nodes = [c.$1];
      acc = 0;
      continue;
    }
    if (p.$1 != c.$1 && p.$2 == c.$2) {
      final e = _edgeBetween(map, p.$1, c.$1);
      if (e != null) {
        acc += _edgeWeight(e, onnxRiskByEdgeId);
      }
      nodes.add(c.$1);
      continue;
    }
  }
  segments.add(RouteSegment(vehicle: vk, nodeIds: List<String>.from(nodes), minutes: acc));

  return MultiModalPathResult(
    totalMinutes: bestT,
    segments: segments,
    handoffs: handoffs,
  );
}
