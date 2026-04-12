import 'package:flutter/material.dart';
import 'package:onnxruntime/onnxruntime.dart';

import '../../app/ui_tokens.dart';
import '../../ml/edge_risk_onnx.dart' show EdgeRiskOnnx, edgeIdNorm;

/// Flood and route-leg risk (on-device model). Helps teams avoid impassable edges before travel.
class FloodRiskPage extends StatefulWidget {
  const FloodRiskPage({super.key, required this.onOpenSupply});

  final VoidCallback onOpenSupply;

  @override
  State<FloodRiskPage> createState() => _FloodRiskPageState();
}

class _FloodRiskPageState extends State<FloodRiskPage> {
  final EdgeRiskOnnx _edgeRisk = EdgeRiskOnnx();

  bool _onnxLoading = true;
  String? _onnxError;
  double? _onnxProb;

  double _rainMmPerH = 12;
  double _cumulativeHours = 3;
  double _elevationM = 35;
  double _soilSat = 0.35;
  String _selectedEdgeId = 'E1';

  double get _heuristicProb {
    final x = _rainMmPerH / 80;
    return x.clamp(0.0, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _initOnnx();
  }

  Future<void> _initOnnx() async {
    try {
      await _edgeRisk.load();
      if (!mounted) return;
      setState(() {
        _onnxLoading = false;
        _onnxError = null;
      });
      _runOnnx();
    } catch (e) {
      if (mounted) {
        setState(() {
          _onnxLoading = false;
          _onnxError = '$e';
        });
      }
    }
  }

  void _runOnnx() {
    if (!_edgeRisk.isLoaded) return;
    try {
      final cum = _rainMmPerH * _cumulativeHours;
      final p = _edgeRisk.predict(
        cumulativeRainMm: cum,
        rainRateMmPerH: _rainMmPerH,
        elevationM: _elevationM,
        soilSaturationProxy: _soilSat,
        edgeIdHashNorm: edgeIdNorm(_selectedEdgeId),
      );
      setState(() => _onnxProb = p);
    } catch (e) {
      setState(() => _onnxError = '$e');
    }
  }

  @override
  void dispose() {
    _edgeRisk.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: UiTokens.pageInsets.copyWith(bottom: 28),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan around rising water',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  'Heavy rain can wash out roads or block river legs before you get a field report. '
                  'This screen estimates how likely a given route leg is to become impassable soon, '
                  'using rainfall cues and terrain. It runs entirely on your phone—no internet required.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: widget.onOpenSupply,
                  icon: const Icon(Icons.inventory_2_outlined),
                  label: const Text('Open supply ledger'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'About the score: the app runs a trained logistic-regression classifier exported to ONNX from a '
              'synthetic flood-edge dataset (see docs/MODEL_CARD_EDGE_RISK.md). It is not a real weather service. '
              'Use it as a rough hint with map and local reports — not as an official flood forecast.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildEstimatorCard(context),
      ],
    );
  }

  Widget _buildEstimatorCard(BuildContext context) {
    final onnx = _onnxProb;
    final showOnnx = onnx != null && _onnxError == null;
    final display = showOnnx ? onnx : _heuristicProb;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leg risk estimator',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Adjust conditions to match what you see or hear from spotters. '
              'High scores suggest prioritizing alternate legs in Routes & map.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            if (_onnxLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              )
            else if (_onnxError != null)
              Text(
                'On-device model unavailable: $_onnxError\nUsing a simple rainfall fallback.',
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 13),
              ),
            Text('Rain rate (mm/h): ${_rainMmPerH.toStringAsFixed(0)}'),
            Slider(
              value: _rainMmPerH,
              min: 0,
              max: 120,
              divisions: 24,
              label: '${_rainMmPerH.round()} mm/h',
              onChanged: (v) {
                setState(() => _rainMmPerH = v);
                _runOnnx();
              },
            ),
            Text('Storm duration (h) for cumulative rain: ${_cumulativeHours.toStringAsFixed(1)}'),
            Slider(
              value: _cumulativeHours,
              min: 0.5,
              max: 24,
              divisions: 47,
              label: '${_cumulativeHours.toStringAsFixed(1)} h',
              onChanged: (v) {
                setState(() => _cumulativeHours = v);
                _runOnnx();
              },
            ),
            Text('Elevation (m): ${_elevationM.toStringAsFixed(0)}'),
            Slider(
              value: _elevationM,
              min: 0,
              max: 400,
              divisions: 40,
              onChanged: (v) {
                setState(() => _elevationM = v);
                _runOnnx();
              },
            ),
            Text('Soil saturation proxy (0–1): ${_soilSat.toStringAsFixed(2)}'),
            Slider(
              value: _soilSat,
              min: 0,
              max: 1,
              divisions: 20,
              onChanged: (v) {
                setState(() => _soilSat = v);
                _runOnnx();
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Route leg',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            DropdownButton<String>(
              isExpanded: true,
              // ignore: deprecated_member_use
              value: _selectedEdgeId,
              items: const [
                DropdownMenuItem(value: 'E1', child: Text('E1 — road (N1–N2)')),
                DropdownMenuItem(value: 'E6', child: Text('E6 — river (N1–N3)')),
                DropdownMenuItem(value: 'EA1', child: Text('EA1 — air (N2–N3)')),
                DropdownMenuItem(value: 'EA4', child: Text('EA4 — air (N3–N6)')),
              ],
              onChanged: (v) {
                setState(() => _selectedEdgeId = v ?? 'E1');
                _runOnnx();
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Chance this leg becomes impassable soon: ${(display * 100).toStringAsFixed(0)}% '
              '(${showOnnx ? 'on-device model' : 'fallback'})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(value: display.clamp(0.0, 1.0)),
            const SizedBox(height: 12),
            Text(
              'Runtime: ONNX ${OrtEnv.version}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
