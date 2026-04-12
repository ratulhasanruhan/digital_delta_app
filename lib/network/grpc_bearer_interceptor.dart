import 'package:grpc/grpc.dart';

/// Attaches `authorization: Bearer <token>` to every unary/streaming call (matches Go server).
class GrpcBearerInterceptor extends ClientInterceptor {
  GrpcBearerInterceptor(this.token);

  final String token;

  @override
  ResponseFuture<R> interceptUnary<Q, R>(
    ClientMethod<Q, R> method,
    Q request,
    CallOptions options,
    ClientUnaryInvoker<Q, R> invoker,
  ) {
    final next = CallOptions(
      metadata: {'authorization': 'Bearer $token'},
    ).mergedWith(options);
    return invoker(method, request, next);
  }

  @override
  ResponseStream<R> interceptStreaming<Q, R>(
    ClientMethod<Q, R> method,
    Stream<Q> requests,
    CallOptions options,
    ClientStreamingInvoker<Q, R> invoker,
  ) {
    final next = CallOptions(
      metadata: {'authorization': 'Bearer $token'},
    ).mergedWith(options);
    return invoker(method, requests, next);
  }
}
