import 'package:flutter/material.dart';

import '../../data/disaster_map_loader.dart';
import '../../routing/typed_route_planner.dart';
import 'risk_map_utils.dart';
import 'route_risk_controller.dart';

/// Shared detail sheet for an edge’s ONNX risk + inputs.
void showEdgeRiskDetailDialog(
  BuildContext context,
  DisasterMapData map,
  TypedEdge edge,
  RouteRiskController risk,
) {
  final p = risk.riskForEdge(edge.id);
  final at = risk.lastComputedAt;
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('${edge.id} · ${edge.mode}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              riskBandLabel(p),
              style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: riskHeatColor(p),
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(p * 100).toStringAsFixed(1)}% · impassability probability',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: p.clamp(0.0, 1.0),
              backgroundColor: Theme.of(
                ctx,
              ).colorScheme.surfaceContainerHighest,
            ),
            const SizedBox(height: 12),
            Text('${edge.from} → ${edge.to}'),
            Text(
              'Base ${edge.baseWeightMins.toStringAsFixed(0)} min · catalog risk ${edge.riskScore.toStringAsFixed(2)}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Weather inputs: rain ${risk.rainMmPerH.toStringAsFixed(1)} mm/h × '
              '${risk.stormHours.toStringAsFixed(1)} h · elev ${risk.elevationM.toStringAsFixed(0)} m · '
              'soil ${risk.soilSaturation.toStringAsFixed(2)}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
            if (at != null)
              Text(
                'Computed ${at.toIso8601String()}',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            if (risk.loadError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Model: ${risk.loadError} — values use rainfall heuristic.',
                  style: TextStyle(
                    color: Theme.of(ctx).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}
