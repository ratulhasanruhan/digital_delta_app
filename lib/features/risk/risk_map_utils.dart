import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../app/app_theme.dart';
import '../../data/disaster_map_loader.dart';
import '../../routing/typed_route_planner.dart';

/// Base color for transport mode (road / river / air).
Color modeBaseColor(String mode) {
  switch (mode) {
    case 'road':
      return const Color(0xFF92400E);
    case 'river':
      return AppTheme.waterAccent;
    case 'air':
      return const Color(0xFF7C3AED);
    default:
      return Colors.grey;
  }
}

/// Visual blend of mode color with ONNX impassability [0,1] for polylines.
Color riskPolylineColor({
  required TypedEdge edge,
  required DisasterMapData map,
  required double risk01,
}) {
  if (map.closedEdgeIds.contains(edge.id) || edge.isFlooded) {
    return Colors.red.withValues(alpha: 0.38);
  }
  final base = modeBaseColor(edge.mode);
  final p = risk01.clamp(0.0, 1.0);
  return Color.lerp(base.withValues(alpha: 0.34), Colors.red, p * 0.88) ?? base;
}

/// [0,1] risk → display color for list tiles / legend.
Color riskHeatColor(double risk01) {
  final p = risk01.clamp(0.0, 1.0);
  return Color.lerp(const Color(0xFF16A34A), const Color(0xFFDC2626), p) ??
      Colors.grey;
}

String riskBandLabel(double p) {
  if (p < 0.25) return 'Low';
  if (p < 0.5) return 'Moderate';
  if (p < 0.75) return 'Elevated';
  return 'Severe';
}

double distToEdgeMeters(DisasterMapData map, TypedEdge e, LatLng tap) {
  final a = map.nodeLatLng[e.from];
  final b = map.nodeLatLng[e.to];
  if (a == null || b == null) return double.infinity;
  const dist = Distance();
  var best = dist(tap, a);
  final db = dist(tap, b);
  if (db < best) best = db;
  for (var t = 0.15; t < 1.0; t += 0.15) {
    final q = LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
    final d = dist(tap, q);
    if (d < best) best = d;
  }
  return best;
}

(TypedEdge?, double) nearestEdgeToTap(
  DisasterMapData map,
  LatLng tap, {
  Iterable<TypedEdge>? edges,
}) {
  TypedEdge? best;
  var bestD = double.infinity;
  for (final e in edges ?? map.typedEdges) {
    final d = distToEdgeMeters(map, e, tap);
    if (d < bestD) {
      bestD = d;
      best = e;
    }
  }
  return (best, bestD);
}
