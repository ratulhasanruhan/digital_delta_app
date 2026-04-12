import 'package:grpc/grpc.dart';

/// Set `--dart-define=DELTA_GRPC_TLS=true` to use TLS 1.3 (C5) when the hub presents a cert.
/// For self-signed lab certs, the client accepts them only when [allowBadCertificates] is used
/// (development — replace with pinned certs in production).
const bool kDeltaGrpcTls = bool.fromEnvironment('DELTA_GRPC_TLS', defaultValue: false);

/// Channel options for DeltaSync / DeltaSyncIngress clients.
ChannelOptions deltaGrpcChannelOptions() {
  if (kDeltaGrpcTls) {
    return ChannelOptions(
      credentials: ChannelCredentials.secure(
        onBadCertificate: allowBadCertificates,
      ),
    );
  }
  return const ChannelOptions(
    credentials: ChannelCredentials.insecure(),
  );
}
