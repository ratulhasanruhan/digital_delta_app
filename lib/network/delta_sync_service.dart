import 'dart:async';

import 'package:digital_delta_app/gen/digitaldelta/v1/common.pb.dart' as pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pb.dart' as sync_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pbgrpc.dart';
import 'package:grpc/grpc.dart' as grpc;

import '../data/supply_repository.dart';

/// `DeltaSync` gRPC service — Protobuf on wire only (C1).
class DeltaSyncGrpcService extends DeltaSyncServiceBase {
  DeltaSyncGrpcService(this._repo);

  final SupplyRepository _repo;

  @override
  Future<sync_pb.SyncHandshakeResponse> handshake(
    grpc.ServiceCall call,
    sync_pb.SyncHandshakeRequest request,
  ) async {
    return sync_pb.SyncHandshakeResponse()
      ..peerId = (pb.ReplicaId()..value = _repo.replicaId)
      ..watermark = await _repo.currentProtoClock()
      ..accepted = true
      ..rejectReason = '';
  }

  @override
  Future<sync_pb.SyncAck> pushDeltas(
    grpc.ServiceCall call,
    Stream<sync_pb.SyncDeltaChunk> request,
  ) async {
    var lastSeq = 0;
    await for (final chunk in request) {
      if (chunk.sequence > lastSeq) {
        lastSeq = chunk.sequence;
      }
      await _repo.applyCrdtEnvelopes(chunk.mutations);
    }
    return sync_pb.SyncAck()
      ..newWatermark = await _repo.currentProtoClock()
      ..lastSequence = lastSeq;
  }

  @override
  Stream<sync_pb.SyncDeltaChunk> pullDeltas(
    grpc.ServiceCall call,
    sync_pb.SyncCursor request,
  ) async* {
    final wm = request.hasSince() ? request.since : pb.VectorClock();
    yield await _repo.buildDeltaChunkSince(wm);
  }
}
