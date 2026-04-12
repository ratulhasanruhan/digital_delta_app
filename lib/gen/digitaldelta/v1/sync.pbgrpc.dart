//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/sync.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'sync.pb.dart' as $0;

export 'sync.pb.dart';

@$pb.GrpcServiceName('digitaldelta.v1.DeltaSync')
class DeltaSyncClient extends $grpc.Client {
  static final _$handshake = $grpc.ClientMethod<$0.SyncHandshakeRequest, $0.SyncHandshakeResponse>(
      '/digitaldelta.v1.DeltaSync/Handshake',
      ($0.SyncHandshakeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SyncHandshakeResponse.fromBuffer(value));
  static final _$pushDeltas = $grpc.ClientMethod<$0.SyncDeltaChunk, $0.SyncAck>(
      '/digitaldelta.v1.DeltaSync/PushDeltas',
      ($0.SyncDeltaChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SyncAck.fromBuffer(value));
  static final _$pullDeltas = $grpc.ClientMethod<$0.SyncCursor, $0.SyncDeltaChunk>(
      '/digitaldelta.v1.DeltaSync/PullDeltas',
      ($0.SyncCursor value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SyncDeltaChunk.fromBuffer(value));

  DeltaSyncClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.SyncHandshakeResponse> handshake($0.SyncHandshakeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$handshake, request, options: options);
  }

  $grpc.ResponseFuture<$0.SyncAck> pushDeltas($async.Stream<$0.SyncDeltaChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$pushDeltas, request, options: options).single;
  }

  $grpc.ResponseStream<$0.SyncDeltaChunk> pullDeltas($0.SyncCursor request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$pullDeltas, $async.Stream.fromIterable([request]), options: options);
  }
}

@$pb.GrpcServiceName('digitaldelta.v1.DeltaSync')
abstract class DeltaSyncServiceBase extends $grpc.Service {
  $core.String get $name => 'digitaldelta.v1.DeltaSync';

  DeltaSyncServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SyncHandshakeRequest, $0.SyncHandshakeResponse>(
        'Handshake',
        handshake_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SyncHandshakeRequest.fromBuffer(value),
        ($0.SyncHandshakeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SyncDeltaChunk, $0.SyncAck>(
        'PushDeltas',
        pushDeltas,
        true,
        false,
        ($core.List<$core.int> value) => $0.SyncDeltaChunk.fromBuffer(value),
        ($0.SyncAck value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SyncCursor, $0.SyncDeltaChunk>(
        'PullDeltas',
        pullDeltas_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.SyncCursor.fromBuffer(value),
        ($0.SyncDeltaChunk value) => value.writeToBuffer()));
  }

  $async.Future<$0.SyncHandshakeResponse> handshake_Pre($grpc.ServiceCall call, $async.Future<$0.SyncHandshakeRequest> request) async {
    return handshake(call, await request);
  }

  $async.Stream<$0.SyncDeltaChunk> pullDeltas_Pre($grpc.ServiceCall call, $async.Future<$0.SyncCursor> request) async* {
    yield* pullDeltas(call, await request);
  }

  $async.Future<$0.SyncHandshakeResponse> handshake($grpc.ServiceCall call, $0.SyncHandshakeRequest request);
  $async.Future<$0.SyncAck> pushDeltas($grpc.ServiceCall call, $async.Stream<$0.SyncDeltaChunk> request);
  $async.Stream<$0.SyncDeltaChunk> pullDeltas($grpc.ServiceCall call, $0.SyncCursor request);
}
@$pb.GrpcServiceName('digitaldelta.v1.DeltaSyncIngress')
class DeltaSyncIngressClient extends $grpc.Client {
  static final _$ingest = $grpc.ClientMethod<$0.SyncDeltaChunk, $0.SyncAck>(
      '/digitaldelta.v1.DeltaSyncIngress/Ingest',
      ($0.SyncDeltaChunk value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SyncAck.fromBuffer(value));
  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/digitaldelta.v1.DeltaSyncIngress/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PingResponse.fromBuffer(value));

  DeltaSyncIngressClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.SyncAck> ingest($async.Stream<$0.SyncDeltaChunk> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$ingest, request, options: options).single;
  }

  $grpc.ResponseFuture<$0.PingResponse> ping($0.PingRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }
}

@$pb.GrpcServiceName('digitaldelta.v1.DeltaSyncIngress')
abstract class DeltaSyncIngressServiceBase extends $grpc.Service {
  $core.String get $name => 'digitaldelta.v1.DeltaSyncIngress';

  DeltaSyncIngressServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.SyncDeltaChunk, $0.SyncAck>(
        'Ingest',
        ingest,
        true,
        false,
        ($core.List<$core.int> value) => $0.SyncDeltaChunk.fromBuffer(value),
        ($0.SyncAck value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PingResponse> ping_Pre($grpc.ServiceCall call, $async.Future<$0.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.SyncAck> ingest($grpc.ServiceCall call, $async.Stream<$0.SyncDeltaChunk> request);
  $async.Future<$0.PingResponse> ping($grpc.ServiceCall call, $0.PingRequest request);
}
