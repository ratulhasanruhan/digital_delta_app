/// Undirected weighted graph for M4 demos (minutes per edge).
class RouteGraph {
  RouteGraph({required this.adjacency});

  final Map<String, List<AdjEdge>> adjacency;
}

class AdjEdge {
  AdjEdge({
    required this.to,
    required this.weight,
    required this.isFlooded,
  });

  final String to;
  final double weight;
  final bool isFlooded;
}

class PathResult {
  PathResult({required this.nodeIds, required this.totalMinutes});

  final List<String> nodeIds;
  final double totalMinutes;
}

/// Dijkstra — shortest path by summed `base_weight_mins`.
/// O(V²) scan (fine for small disaster graphs bundled in JSON).
PathResult? shortestPathMinutes({
  required RouteGraph graph,
  required String startId,
  required String goalId,
}) {
  if (startId == goalId) {
    return PathResult(nodeIds: [startId], totalMinutes: 0);
  }
  final adj = graph.adjacency;
  if (!adj.containsKey(startId) || !adj.containsKey(goalId)) {
    return null;
  }

  final nodes = adj.keys.toList();
  final dist = <String, double>{for (final n in nodes) n: double.infinity};
  final prev = <String, String?>{for (final n in nodes) n: null};
  final done = <String>{};

  dist[startId] = 0;

  while (true) {
    String? u;
    var best = double.infinity;
    for (final n in nodes) {
      if (done.contains(n)) continue;
      final d = dist[n] ?? double.infinity;
      if (d < best) {
        best = d;
        u = n;
      }
    }
    if (u == null || best == double.infinity) break;
    if (u == goalId) break;
    done.add(u);
    for (final e in adj[u] ?? const <AdjEdge>[]) {
      if (e.isFlooded) continue;
      final alt = best + e.weight;
      if (alt < (dist[e.to] ?? double.infinity)) {
        dist[e.to] = alt;
        prev[e.to] = u;
      }
    }
  }

  if ((dist[goalId] ?? double.infinity) == double.infinity) {
    return null;
  }

  final rev = <String>[];
  String? cur = goalId;
  while (cur != null) {
    rev.add(cur);
    cur = prev[cur];
  }
  return PathResult(
    nodeIds: rev.reversed.toList(),
    totalMinutes: dist[goalId]!,
  );
}
