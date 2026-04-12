import 'simple_route_planner.dart';

/// Rich edge for M4 / M7 — Dijkstra uses effective travel minutes.
class TypedEdge {
  TypedEdge({
    required this.id,
    required this.from,
    required this.to,
    required this.mode,
    required this.baseWeightMins,
    required this.riskScore,
    required this.capacityKg,
    required this.isFlooded,
  });

  final String id;
  final String from;
  final String to;
  final String mode;
  final double baseWeightMins;

  /// Static hazard score from graph JSON [0–1].
  final double riskScore;
  final double capacityKg;
  final bool isFlooded;

  /// M7.3 — penalize travel time when ONNX predicts high impassability.
  double effectiveMinutes({
    double onnxImpassabilityProb = 0,
    double penaltyGain = 3,
  }) {
    final p = onnxImpassabilityProb.clamp(0.0, 1.0);
    final r = riskScore.clamp(0.0, 1.0);
    return baseWeightMins * (1 + penaltyGain * r * p);
  }
}

/// Build undirected adjacency for Dijkstra from typed edges.
RouteGraph buildRouteGraph({
  required List<TypedEdge> edges,
  required bool Function(TypedEdge e) include,
  double Function(TypedEdge e)? weightForEdge,
}) {
  final adj = <String, List<AdjEdge>>{};
  void addUndirected(TypedEdge e, double w) {
    adj.putIfAbsent(e.from, () => []);
    adj.putIfAbsent(e.to, () => []);
    final flooded = e.isFlooded;
    adj[e.from]!.add(AdjEdge(to: e.to, weight: w, isFlooded: flooded));
    adj[e.to]!.add(AdjEdge(to: e.from, weight: w, isFlooded: flooded));
  }

  for (final e in edges) {
    if (!include(e)) continue;
    final w = weightForEdge != null ? weightForEdge(e) : e.baseWeightMins;
    addUndirected(e, w);
  }
  return RouteGraph(adjacency: adj);
}
