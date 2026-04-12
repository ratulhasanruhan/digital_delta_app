import 'package:digital_delta_app/gen/digitaldelta/v1/common.pb.dart' as pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pb.dart' as sync_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pbgrpc.dart';
import 'package:grpc/grpc.dart';

import '../data/supply_repository.dart';
import 'grpc_sync_config.dart';
import 'grpc_transport.dart';

/// Push local supply OR-set to a peer over **gRPC + Protobuf** (LAN TCP).
Future<sync_pb.SyncAck> pushSupplyToPeer({
  required SupplyRepository repo,
  required String host,
  int port = kDeltaSyncGrpcPort,
}) async {
  final channel = ClientChannel(
    host,
    port: port,
    options: deltaGrpcChannelOptions(),
  );
  try {
    final client = DeltaSyncClient(channel);
    final hs = await client.handshake(
      sync_pb.SyncHandshakeRequest()
        ..peerId = (pb.ReplicaId()..value = repo.replicaId)
        ..watermark = await repo.currentProtoClock()
        ..publicKey = pb.PublicKey(),
    );
    if (!hs.accepted) {
      throw StateError('Handshake rejected: ${hs.rejectReason}');
    }
    // Peer’s merged watermark: send only ops not already dominated by it (M2.4 delta).
    final chunk = await repo.buildDeltaChunkSince(hs.watermark);
    final ack = await client.pushDeltas(Stream.value(chunk));
    return ack;
  } finally {
    await channel.shutdown();
  }
}
