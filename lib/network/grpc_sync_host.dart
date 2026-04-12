import 'dart:io';

import 'package:grpc/grpc.dart' as grpc;

import 'delta_sync_service.dart';
import 'grpc_sync_config.dart';

/// Binds [DeltaSyncGrpcService] on LAN (TCP). Peers connect to this device IP.
class GrpcSyncHost {
  GrpcSyncHost(this._service);

  final DeltaSyncGrpcService _service;
  grpc.Server? _server;

  bool get isRunning => _server != null;

  /// Port after [start], for showing to the peer.
  int? get boundPort => _server?.port;

  Future<void> start({int port = kDeltaSyncGrpcPort}) async {
    if (_server != null) return;
    final s = grpc.Server.create(services: [_service]);
    await s.serve(address: InternetAddress.anyIPv4, port: port);
    _server = s;
  }

  Future<void> stop() async {
    final s = _server;
    _server = null;
    await s?.shutdown();
  }
}
