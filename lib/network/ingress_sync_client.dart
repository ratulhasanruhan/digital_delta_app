import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pb.dart' as sync_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pbgrpc.dart';
import 'package:grpc/grpc.dart';

import '../data/supply_repository.dart';
import 'grpc_transport.dart';

/// Default gRPC port for `server/cmd/syncd` (`SYNC_LISTEN`, e.g. `:50551`).
const int kDeltaSyncIngressDefaultPort = 50551;

/// Push local CRDT snapshot to **DeltaSyncIngress** (optional hub). Uses protobuf on the wire (C1).
/// Intended for **first-time / occasional** upload when internet is available (contest C5).
Future<sync_pb.SyncAck> pushSupplyToIngress({
  required SupplyRepository repo,
  required String host,
  int port = kDeltaSyncIngressDefaultPort,
}) async {
  final channel = ClientChannel(
    host,
    port: port,
    options: deltaGrpcChannelOptions(),
  );
  try {
    final client = DeltaSyncIngressClient(channel);
    final chunk = await repo.buildExportChunk();
    return await client.ingest(Stream.value(chunk));
  } finally {
    await channel.shutdown();
  }
}
