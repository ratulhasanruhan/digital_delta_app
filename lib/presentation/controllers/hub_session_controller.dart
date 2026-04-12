import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/hub_node_client.dart';

const _kGrpcHost = 'dd_hub_grpc_host';
const _kGrpcPort = 'dd_hub_grpc_port';
const _kToken = 'dd_hub_access_token';

/// Persists gRPC endpoint + JWT for hub calls (same Bearer token the server issued; paste from dashboard if needed).
class HubSessionController extends GetxController {
  final RxnString grpcHost = RxnString();
  final RxInt grpcPort = 50051.obs;
  final RxnString accessToken = RxnString();

  /// Call once at startup (after [WidgetsFlutterBinding.ensureInitialized]).
  Future<void> loadPersisted() async {
    try {
      final p = await SharedPreferences.getInstance();
      grpcHost.value = p.getString(_kGrpcHost);
      final port = p.getInt(_kGrpcPort);
      if (port != null && port > 0) grpcPort.value = port;
      accessToken.value = p.getString(_kToken);
      // Legacy: HTTP base URL no longer used — drop old key.
      await p.remove('dd_hub_http_base');
    } catch (e) {
      debugPrint('HubSessionController.loadPersisted: $e');
    }
  }

  Future<void> saveGrpc({
    required String grpcHostValue,
    int? grpcPortValue,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kGrpcHost, grpcHostValue.trim());
    final port = grpcPortValue ?? grpcPort.value;
    await p.setInt(_kGrpcPort, port);
    grpcHost.value = grpcHostValue.trim();
    grpcPort.value = port;
  }

  Future<void> saveAccessToken(String raw) async {
    final token = raw.trim();
    final p = await SharedPreferences.getInstance();
    if (token.isEmpty) {
      await p.remove(_kToken);
      accessToken.value = null;
      return;
    }
    await p.setString(_kToken, token);
    accessToken.value = token;
  }

  Future<void> clearToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    accessToken.value = null;
  }

  Future<String> callHealth() async {
    final h = grpcHost.value;
    if (h == null || h.isEmpty) {
      throw StateError('Set gRPC host first');
    }
    final c = HubNodeClient(host: h, port: grpcPort.value);
    final res = await c.health();
    return res.status;
  }

  Future<String> callPing() async {
    final h = grpcHost.value;
    final tok = accessToken.value;
    if (h == null || h.isEmpty) {
      throw StateError('Set gRPC host first');
    }
    if (tok == null || tok.isEmpty) {
      throw StateError('Paste and save JWT first (Bearer token for Ping)');
    }
    final c = HubNodeClient(host: h, port: grpcPort.value);
    final res = await c.ping(accessToken: tok);
    final uid = res.authenticatedUserId.isEmpty ? '—' : res.authenticatedUserId;
    final em = res.authenticatedEmail.isEmpty ? '—' : res.authenticatedEmail;
    return 'v=${res.serverVersion} t=${res.serverTimeUnixMs} user=$uid email=$em role=${res.role}';
  }
}
