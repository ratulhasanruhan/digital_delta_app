import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:provider/provider.dart';

import '../app/sync_status_controller.dart';
import '../app/ui_tokens.dart';
import '../widgets/dd_page_intro.dart';
import '../widgets/dd_section_header.dart';
import '../core/rbac.dart';
import '../data/supply_repository.dart';
import '../features/identity/services/identity_service.dart';
import '../features/mesh/ble_mesh_controller.dart';
import '../network/delta_sync_service.dart';
import '../network/grpc_sync_client.dart';
import '../network/grpc_sync_config.dart';
import '../network/grpc_sync_host.dart';

/// gRPC `DeltaSync` over **LAN TCP** with **mDNS discovery** (no manual IP).
class MeshSyncPage extends StatefulWidget {
  const MeshSyncPage({
    super.key,
    required this.repository,
  });

  final SupplyRepository repository;

  @override
  State<MeshSyncPage> createState() => _MeshSyncPageState();
}

class _MeshSyncPageState extends State<MeshSyncPage> {
  final _host = TextEditingController();
  final _port = TextEditingController(text: '$kDeltaSyncGrpcPort');
  late final DeltaSyncGrpcService _syncService;
  late final GrpcSyncHost _grpcHost;

  BonsoirDiscovery? _discovery;
  StreamSubscription<BonsoirDiscoveryEvent>? _discoverySub;
  final Map<String, BonsoirService> _peers = {};

  BonsoirBroadcast? _broadcast;

  String? _wifiIpv4;
  String? _status;
  bool _listening = false;
  bool _busy = false;
  bool _discoveryReady = false;

  @override
  void initState() {
    super.initState();
    _syncService = DeltaSyncGrpcService(widget.repository);
    _grpcHost = GrpcSyncHost(_syncService);
    unawaited(_loadWifiIp());
    unawaited(_startDiscovery());
  }

  Future<void> _loadWifiIp() async {
    try {
      final ip = await NetworkInfo().getWifiIP();
      if (mounted) setState(() => _wifiIpv4 = ip);
    } catch (_) {
      if (mounted) setState(() => _wifiIpv4 = 'unknown');
    }
  }

  Future<void> _startDiscovery() async {
    try {
      final d = BonsoirDiscovery(type: kMeshMdnsServiceType);
      await d.initialize();
      _discoverySub = d.eventStream?.listen(_onDiscoveryEvent);
      await d.start();
      _discovery = d;
      if (mounted) setState(() => _discoveryReady = true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _discoveryReady = false;
          _status = 'Discovery failed: $e';
        });
      }
    }
  }

  Future<void> _onDiscoveryEvent(BonsoirDiscoveryEvent e) async {
    final d = _discovery;
    if (d == null) return;

    if (e is BonsoirDiscoveryServiceFoundEvent) {
      try {
        await d.serviceResolver.resolveService(e.service);
      } catch (_) {}
      return;
    }

    if (e is BonsoirDiscoveryServiceResolvedEvent) {
      final s = e.service;
      final rid = s.attributes['rid'] ?? '';
      if (rid == widget.repository.replicaId) return;
      if (s.host == null || s.host!.isEmpty) return;
      if (!mounted) return;
      setState(() => _peers[_peerKey(s)] = s);
      return;
    }

    if (e is BonsoirDiscoveryServiceLostEvent) {
      if (!mounted) return;
      setState(() => _peers.remove(_peerKey(e.service)));
    }
  }

  String _peerKey(BonsoirService s) => '${s.name}|${s.port}';

  Future<void> _stopBroadcast() async {
    final b = _broadcast;
    _broadcast = null;
    if (b != null) {
      try {
        await b.stop();
      } catch (_) {}
    }
  }

  Future<void> _startBroadcast(int port) async {
    await _stopBroadcast();
    final id = widget.repository.replicaId;
    final short = id.length > 14 ? id.substring(0, 14) : id;
    final b = BonsoirBroadcast(
      service: BonsoirService(
        name: 'DD $short',
        type: kMeshMdnsServiceType,
        port: port,
        attributes: {
          ...BonsoirService.defaultAttributes,
          'rid': id,
        },
      ),
    );
    await b.initialize();
    await b.start();
    _broadcast = b;
  }

  Future<void> _toggleListen() async {
    if (_busy) return;
    if (!_listening) {
      final id = context.read<IdentityService>();
      if (!id.role.can(Permission.executeSync)) {
        if (mounted) {
          setState(() => _status = 'Listener requires Sync Admin (executeSync).');
        }
        return;
      }
    }
    setState(() => _busy = true);
    try {
      if (_listening) {
        await _stopBroadcast();
        await _grpcHost.stop();
        if (mounted) {
          setState(() {
            _listening = false;
            _status = 'Listener stopped.';
          });
        }
      } else {
        await _grpcHost.start();
        final p = _grpcHost.boundPort ?? kDeltaSyncGrpcPort;
        await _startBroadcast(p);
        if (mounted) {
          setState(() {
            _listening = true;
            _status =
                'Listening — peers see you as “DD …” on the same Wi‑Fi. Port $p.';
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pushToHost(String host, int port) async {
    if (_busy) return;
    final id = context.read<IdentityService>();
    if (!id.role.can(Permission.executeSync)) {
      if (mounted) {
        setState(() => _status = 'Push sync requires Sync Admin (executeSync).');
      }
      return;
    }
    final syncUi = context.read<SyncStatusController>();
    setState(() {
      _busy = true;
      _status = 'Connecting to $host:$port …';
    });
    syncUi.markSyncing(true);
    try {
      final ack = await pushSupplyToPeer(
        repo: widget.repository,
        host: host,
        port: port,
      );
      if (!mounted) return;
      setState(() {
        _status =
            'Sync OK — ack seq=${ack.lastSequence}, watermark components=${ack.newWatermark.components.length}';
      });
      syncUi.flashVerified();
    } catch (e) {
      if (mounted) setState(() => _status = 'Sync failed: $e');
    } finally {
      syncUi.markSyncing(false);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pushFromFields() async {
    final host = _host.text.trim();
    if (host.isEmpty) {
      setState(() => _status = 'Pick a peer below or enter IP in Advanced.');
      return;
    }
    final p = int.tryParse(_port.text.trim()) ?? kDeltaSyncGrpcPort;
    await _pushToHost(host, p);
  }

  Future<void> _pushFromService(BonsoirService s) async {
    final h = s.host;
    if (h == null || h.isEmpty) {
      setState(() => _status = 'Peer still resolving — try again in a second.');
      return;
    }
    _host.text = h;
    _port.text = '${s.port}';
    await _pushToHost(h, s.port);
  }

  @override
  void dispose() {
    _host.dispose();
    _port.dispose();
    unawaited(_stopBroadcast());
    unawaited(_grpcHost.stop());
    unawaited(_discovery?.stop());
    unawaited(_discoverySub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        padding: UiTokens.pageInsets.copyWith(bottom: 32),
        children: [
          DdPageIntro(
            title: 'Peer sync',
            description:
                'Stay on the same Wi‑Fi or hotspot. Start the listener on one phone; the other taps a peer below. '
                'Bluetooth helps you see who is near; full data sync uses Wi‑Fi.',
          ),
          const SizedBox(height: 10),
          Consumer<BleMeshController>(
            builder: (context, ble, _) {
              return Material(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bluetooth_searching_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ble.isBeaconSessionActive
                              ? 'M8.4: beacon session active — duty ≈ ${(ble.beaconDutyCycle * 100).round()}% (${ble.throttleSummary}). '
                                  'Hardware TX may pulse to save battery.'
                              : 'Starting nearby beacon… allow Bluetooth if asked.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.35,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          DdSectionHeader(
            title: 'Bluetooth (nearby)',
            subtitle: 'Advertise or scan short beacons. Payload sync is still over Wi‑Fi / LAN.',
          ),
          const SizedBox(height: 4),
          Consumer<BleMeshController>(
            builder: (context, ble, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (ble.lastError != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ble.lastError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  SwitchListTile(
                    title: const Text('BLE beacon session (M8.4 throttled)'),
                    subtitle: Text(
                      'Duty ${(ble.beaconDutyCycle * 100).round()}% · ${ble.throttleSummary}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: ble.isBeaconSessionActive,
                    onChanged: _busy
                        ? null
                        : (v) async {
                            if (v) {
                              await ble.startAdvertising();
                            } else {
                              await ble.stopAdvertising();
                            }
                            if (mounted) setState(() {});
                          },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: _busy
                              ? null
                              : () async {
                                  await ble.startScan();
                                  if (mounted) setState(() {});
                                },
                          child: Text(ble.isScanning ? 'Scanning…' : 'Scan for peers'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: ble.isScanning
                            ? () async {
                                await ble.stopScan();
                                if (mounted) setState(() {});
                              }
                            : null,
                        child: const Text('Stop scan'),
                      ),
                    ],
                  ),
                  if (ble.peers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Seen fingerprints',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    for (final p in ble.peers)
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.bluetooth_searching),
                        title: Text('${p.fingerprintHex.substring(0, 16)}…'),
                        subtitle: Text(
                          'RSSI ${p.rssi ?? "—"} · ${(p.advName == null || p.advName!.isEmpty) ? "no name" : p.advName}',
                        ),
                      ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('This device Wi‑Fi IP (hint)'),
            subtitle: Text(_wifiIpv4 ?? '…'),
            trailing: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadWifiIp,
            ),
          ),
          FutureBuilder<int>(
            future: widget.repository.estimateDeltaChunkBytes(),
            builder: (context, snap) {
              final b = snap.data;
              if (b == null) {
                return const SizedBox.shrink();
              }
              return ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Protobuf delta payload (M2.4)'),
                subtitle: Text(
                  '$b bytes — gRPC SyncDeltaChunk (compare to 10 KB budget)',
                ),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('gRPC listener (DeltaSync)'),
            subtitle: Text(
              _listening
                  ? 'Advertising $kMeshMdnsServiceType on port ${_grpcHost.boundPort ?? kDeltaSyncGrpcPort}'
                  : 'Off — turn on to be discoverable',
            ),
            value: _listening,
            onChanged: _busy ? null : (_) => unawaited(_toggleListen()),
          ),
          if (_listening)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                'Port: ${_grpcHost.boundPort ?? kDeltaSyncGrpcPort}\n'
                'Other peer: open this screen — your device appears under Nearby peers.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Nearby peers (tap to sync)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          if (!_discoveryReady)
            const ListTile(
              leading: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              title: Text('Starting peer discovery…'),
            )
          else if (_peers.isEmpty)
            const ListTile(
              title: Text('No peers found yet'),
              subtitle: Text(
                'Ensure the other phone has Listener ON and both are on the same network.',
              ),
            )
          else
            ..._peers.values.map(
              (s) => ListTile(
                leading: const Icon(Icons.phone_android_outlined),
                title: Text(s.name),
                subtitle: Text('${s.host ?? '…'}:${s.port}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _busy ? null : () => unawaited(_pushFromService(s)),
              ),
            ),
          const SizedBox(height: 16),
          ExpansionTile(
            initiallyExpanded: false,
            title: const Text('Advanced (manual IP)'),
            children: [
              TextField(
                controller: _host,
                decoration: const InputDecoration(
                  labelText: 'Peer IP or hostname',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _port,
                decoration: const InputDecoration(
                  labelText: 'Port',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _busy ? null : () => unawaited(_pushFromFields()),
                icon: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: const Text('Push sync (manual target)'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Replica',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SelectableText(widget.repository.replicaId),
          const SizedBox(height: 12),
          Text(
            'Status',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SelectableText(_status ?? '—'),
        ],
    );
  }
}
