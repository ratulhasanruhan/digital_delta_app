import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Track A5 — explicit UX states for connectivity + sync lifecycle.
enum SyncSurfaceState {
  offline,
  online,
  syncing,
  conflict,
  verified,
}

/// Lightweight, performance-friendly: one subscription, debounced notify.
class SyncStatusController extends ChangeNotifier {
  SyncStatusController() {
    _subscription = _connectivity.onConnectivityChanged.listen(_onConnectivity);
    unawaited(_refresh());
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  List<ConnectivityResult> _last = const [ConnectivityResult.none];
  SyncSurfaceState _phase = SyncSurfaceState.online;

  List<ConnectivityResult> get connectivityResults => _last;

  bool get isOffline {
    return _last.isEmpty ||
        _last.every((r) => r == ConnectivityResult.none);
  }

  SyncSurfaceState get phase => _phase;

  /// Composite banner state: offline wins; else explicit phase.
  SyncSurfaceState get surface {
    if (isOffline) return SyncSurfaceState.offline;
    return _phase;
  }

  Future<void> _refresh() async {
    try {
      final r = await _connectivity.checkConnectivity();
      _onConnectivity(r);
    } catch (_) {
      notifyListeners();
    }
  }

  void _onConnectivity(List<ConnectivityResult> results) {
    _last = results;
    notifyListeners();
  }

  void setPhase(SyncSurfaceState next) {
    if (_phase == next) return;
    _phase = next;
    notifyListeners();
  }

  /// Call when mesh/gRPC sync starts or stops.
  void markSyncing(bool active) {
    if (active) {
      setPhase(SyncSurfaceState.syncing);
    } else if (_phase == SyncSurfaceState.syncing) {
      setPhase(SyncSurfaceState.online);
    }
  }

  void markConflict(bool active) {
    if (active) {
      setPhase(SyncSurfaceState.conflict);
    } else if (_phase == SyncSurfaceState.conflict) {
      setPhase(SyncSurfaceState.online);
    }
  }

  /// Brief positive acknowledgment (e.g. PoD verified).
  void flashVerified({Duration hold = const Duration(seconds: 2)}) {
    setPhase(SyncSurfaceState.verified);
    Future<void>.delayed(hold, () {
      if (_phase == SyncSurfaceState.verified) {
        setPhase(SyncSurfaceState.online);
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel() ?? Future<void>.value());
    super.dispose();
  }
}
