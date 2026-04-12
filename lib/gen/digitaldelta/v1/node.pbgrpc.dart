//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/node.proto
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

import 'node.pb.dart' as $0;

export 'node.pb.dart';

@$pb.GrpcServiceName('digitaldelta.v1.NodeService')
class NodeServiceClient extends $grpc.Client {
  static final _$ping = $grpc.ClientMethod<$0.PingRequest, $0.PingResponse>(
      '/digitaldelta.v1.NodeService/Ping',
      ($0.PingRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.PingResponse.fromBuffer(value));
  static final _$health = $grpc.ClientMethod<$0.HealthRequest, $0.HealthResponse>(
      '/digitaldelta.v1.NodeService/Health',
      ($0.HealthRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.HealthResponse.fromBuffer(value));

  NodeServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.PingResponse> ping($0.PingRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$ping, request, options: options);
  }

  $grpc.ResponseFuture<$0.HealthResponse> health($0.HealthRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$health, request, options: options);
  }
}

@$pb.GrpcServiceName('digitaldelta.v1.NodeService')
abstract class NodeServiceBase extends $grpc.Service {
  $core.String get $name => 'digitaldelta.v1.NodeService';

  NodeServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.PingRequest, $0.PingResponse>(
        'Ping',
        ping_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PingRequest.fromBuffer(value),
        ($0.PingResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HealthRequest, $0.HealthResponse>(
        'Health',
        health_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HealthRequest.fromBuffer(value),
        ($0.HealthResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.PingResponse> ping_Pre($grpc.ServiceCall call, $async.Future<$0.PingRequest> request) async {
    return ping(call, await request);
  }

  $async.Future<$0.HealthResponse> health_Pre($grpc.ServiceCall call, $async.Future<$0.HealthRequest> request) async {
    return health(call, await request);
  }

  $async.Future<$0.PingResponse> ping($grpc.ServiceCall call, $0.PingRequest request);
  $async.Future<$0.HealthResponse> health($grpc.ServiceCall call, $0.HealthRequest request);
}
