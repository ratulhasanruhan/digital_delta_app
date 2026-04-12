import 'package:digital_delta_app/gen/digitaldelta/v1/node.pb.dart' as node_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/node.pbgrpc.dart';
import 'package:grpc/grpc.dart';

import 'grpc_bearer_interceptor.dart';
import 'grpc_transport.dart';

/// gRPC [NodeService] client for the Digital Delta server (field / hub).
class HubNodeClient {
  HubNodeClient({
    required this.host,
    this.port = 50051,
  });

  final String host;
  final int port;

  /// No JWT required (liveness).
  Future<node_pb.HealthResponse> health() async {
    final channel = ClientChannel(
      host,
      port: port,
      options: deltaGrpcChannelOptions(),
    );
    try {
      final client = NodeServiceClient(channel);
      return await client.health(node_pb.HealthRequest());
    } finally {
      await channel.shutdown();
    }
  }

  /// Requires the same Bearer token as REST (`hubRestLogin`).
  Future<node_pb.PingResponse> ping({
    required String accessToken,
    String clientVersion = 'digital_delta_app',
  }) async {
    final channel = ClientChannel(
      host,
      port: port,
      options: deltaGrpcChannelOptions(),
    );
    try {
      final client = NodeServiceClient(
        channel,
        interceptors: [GrpcBearerInterceptor(accessToken)],
      );
      return await client.ping(
        node_pb.PingRequest()..clientVersion = clientVersion,
      );
    } finally {
      await channel.shutdown();
    }
  }
}
