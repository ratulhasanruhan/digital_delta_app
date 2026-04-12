import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../network/hub_node_client.dart';

const _kGrpcHost = 'dd_hub_grpc_host';
const _kGrpcPort = 'dd_hub_grpc_port';
const _kToken = 'dd_hub_access_token';

/// Persists gRPC endpoint + JWT for hub calls (same Bearer token the server issued).
class HubSessionController extends ChangeNotifier {
  String? _grpcHost;
  int _grpcPort = 50051;
  String? _accessToken;

  String? get grpcHost => _grpcHost;
  int get grpcPort => _grpcPort;
  String? get accessToken => _accessToken;

  /// Call once at startup (after [WidgetsFlutterBinding.ensureInitialized]).
  Future<void> loadPersisted() async {
    try {
      final p = await SharedPreferences.getInstance();
      _grpcHost = p.getString(_kGrpcHost);
      final port = p.getInt(_kGrpcPort);
      if (port != null && port > 0) _grpcPort = port;
      _accessToken = p.getString(_kToken);
      await p.remove('dd_hub_http_base');
      notifyListeners();
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
    final port = grpcPortValue ?? _grpcPort;
    await p.setInt(_kGrpcPort, port);
    _grpcHost = grpcHostValue.trim();
    _grpcPort = port;
    notifyListeners();
  }

  Future<void> saveAccessToken(String raw) async {
    final token = raw.trim();
    final p = await SharedPreferences.getInstance();
    if (token.isEmpty) {
      await p.remove(_kToken);
      _accessToken = null;
      notifyListeners();
      return;
    }
    await p.setString(_kToken, token);
    _accessToken = token;
    notifyListeners();
  }

  Future<void> clearToken() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    _accessToken = null;
    notifyListeners();
  }

  Future<String> callHealth() async {
    final h = _grpcHost;
    if (h == null || h.isEmpty) {
      throw StateError('Set gRPC host first');
    }
    final c = HubNodeClient(host: h, port: _grpcPort);
    final res = await c.health();
    return res.status;
  }

  Future<String> callPing() async {
    final h = _grpcHost;
    final tok = _accessToken;
    if (h == null || h.isEmpty) {
      throw StateError('Set gRPC host first');
    }
    if (tok == null || tok.isEmpty) {
      throw StateError('Paste and save JWT first (Bearer token for Ping)');
    }
    final c = HubNodeClient(host: h, port: _grpcPort);
    final res = await c.ping(accessToken: tok);
    final uid = res.authenticatedUserId.isEmpty ? '—' : res.authenticatedUserId;
    final em = res.authenticatedEmail.isEmpty ? '—' : res.authenticatedEmail;
    return 'v=${res.serverVersion} t=${res.serverTimeUnixMs} user=$uid email=$em role=${res.role}';
  }
}
