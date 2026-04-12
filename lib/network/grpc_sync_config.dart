/// Default gRPC port for peer sync over **LAN TCP** (Step 4).
/// Same Protobuf + gRPC can be framed over BLE/Wi‑Fi Direct later.
const int kDeltaSyncGrpcPort = 5333;

/// mDNS / Bonjour / Android NSD — advertised when listener is on (no manual IP).
/// Must match `NSBonjourServices` on iOS.
const String kMeshMdnsServiceType = '_digitaldelta._tcp';
