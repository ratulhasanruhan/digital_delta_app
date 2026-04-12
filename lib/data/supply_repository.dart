import 'dart:convert';

import 'package:digital_delta_app/gen/digitaldelta/v1/common.pb.dart' as pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/crdt.pb.dart' as crdt_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/supply.pb.dart' as sup_pb;
import 'package:digital_delta_app/gen/digitaldelta/v1/sync.pb.dart' as sync_pb;
import 'package:fixnum/fixnum.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../core/rbac.dart';
import '../crdt/conflict_record.dart';
import '../crdt/supply_models.dart';
import '../crdt/vector_clock.dart';
import '../proto_bridge/clock_bridge.dart';
import '../proto_bridge/supply_priority_bridge.dart';

const _kReplicaId = 'device_replica_id';
const _kMetaClock = 'vector_clock_json';

/// Local OR-Set for supply rows + vector clock (M2.1). Sync with peers in a later step.
class SupplyRepository {
  SupplyRepository();

  final _uuid = const Uuid();
  Database? _db;
  String? _replicaId;

  /// M1.3 — when set, all mutating calls check [UserRole.can] via this closure.
  bool Function(Permission)? _access;

  String get replicaId {
    final id = _replicaId;
    if (id == null) throw StateError('call init() first');
    return id;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _replicaId = prefs.getString(_kReplicaId) ?? _uuid.v4();
    await prefs.setString(_kReplicaId, _replicaId!);

    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'digital_delta.db');
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createSchemaV2(db);
        await _createPubkeyLedger(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
CREATE TABLE IF NOT EXISTS crdt_conflicts (
  id TEXT NOT NULL PRIMARY KEY,
  element_id TEXT NOT NULL,
  unique_tag TEXT NOT NULL,
  field_name TEXT NOT NULL,
  left_value TEXT NOT NULL,
  right_value TEXT NOT NULL,
  left_clock_json TEXT NOT NULL,
  right_clock_json TEXT NOT NULL,
  status TEXT NOT NULL,
  resolved_value TEXT,
  resolved_at INTEGER
)''');
          await db.execute('''
CREATE TABLE IF NOT EXISTS relay_outbox (
  id TEXT NOT NULL PRIMARY KEY,
  dest_fingerprint TEXT NOT NULL,
  sealed_payload TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  ttl_seconds INTEGER NOT NULL,
  hop_count INTEGER NOT NULL,
  status TEXT NOT NULL
)''');
        }
        if (oldVersion < 3) {
          await _createPubkeyLedger(db);
        }
      },
    );
  }

  void bindAccessChecker(bool Function(Permission) check) {
    _access = check;
  }

  void _require(Permission p) {
    final fn = _access;
    if (fn != null && !fn(p)) {
      throw RbacDeniedException(p);
    }
  }

  static Future<void> _createPubkeyLedger(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS pubkey_ledger (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  replica_id TEXT NOT NULL,
  pubkey_hex TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  event TEXT NOT NULL
)''');
  }

  static Future<void> _createSchemaV2(Database db) async {
    await db.execute('''
CREATE TABLE orset_add (
  element_id TEXT NOT NULL,
  unique_tag TEXT NOT NULL PRIMARY KEY,
  sku TEXT NOT NULL,
  description TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  priority INTEGER NOT NULL,
  location_node_id TEXT NOT NULL
)''');
    await db.execute('''
CREATE TABLE orset_remove (
  element_id TEXT NOT NULL,
  unique_tag TEXT NOT NULL,
  PRIMARY KEY (element_id, unique_tag)
)''');
    await db.execute('''
CREATE TABLE meta (
  k TEXT PRIMARY KEY,
  v TEXT NOT NULL
)''');
    await db.execute('''
CREATE TABLE crdt_conflicts (
  id TEXT NOT NULL PRIMARY KEY,
  element_id TEXT NOT NULL,
  unique_tag TEXT NOT NULL,
  field_name TEXT NOT NULL,
  left_value TEXT NOT NULL,
  right_value TEXT NOT NULL,
  left_clock_json TEXT NOT NULL,
  right_clock_json TEXT NOT NULL,
  status TEXT NOT NULL,
  resolved_value TEXT,
  resolved_at INTEGER
)''');
    await db.execute('''
CREATE TABLE relay_outbox (
  id TEXT NOT NULL PRIMARY KEY,
  dest_fingerprint TEXT NOT NULL,
  sealed_payload TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  ttl_seconds INTEGER NOT NULL,
  hop_count INTEGER NOT NULL,
  status TEXT NOT NULL
)''');
  }

  Database get _database {
    final d = _db;
    if (d == null) throw StateError('call init() first');
    return d;
  }

  Future<VectorClock> currentClock() async {
    final rows = await _database.query(
      'meta',
      where: 'k = ?',
      whereArgs: [_kMetaClock],
      limit: 1,
    );
    if (rows.isEmpty) return VectorClock();
    return VectorClock.fromJsonString(rows.first['v'] as String?);
  }

  Future<void> _saveClock(VectorClock vc) async {
    await _database.insert(
      'meta',
      {'k': _kMetaClock, 'v': vc.toJsonString()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Add a new supply line (OR-Set add with fresh unique tag).
  Future<void> addLine({
    required String sku,
    required String description,
    required int quantity,
    required CargoPriority priority,
    String locationNodeId = 'N1',
  }) async {
    _require(Permission.writeSupply);
    final elementId = _uuid.v4();
    final uniqueTag = _uuid.v4();
    final clock = (await currentClock()).tick(replicaId);
    await _database.insert('orset_add', {
      'element_id': elementId,
      'unique_tag': uniqueTag,
      'sku': sku,
      'description': description,
      'quantity': quantity,
      'priority': priority.protoValue,
      'location_node_id': locationNodeId,
    });
    await _saveClock(clock);
  }

  /// Tombstone (OR-Set remove) for one add pair.
  Future<void> removeLine(String elementId, String uniqueTag) async {
    _require(Permission.writeSupply);
    final clock = (await currentClock()).tick(replicaId);
    await _database.insert(
      'orset_remove',
      {'element_id': elementId, 'unique_tag': uniqueTag},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await _saveClock(clock);
  }

  /// Merged visible supply lines (adds \ removes).
  Future<List<SupplyLine>> visibleLines() async {
    final rows = await _database.rawQuery('''
SELECT a.element_id, a.unique_tag, a.sku, a.description, a.quantity, a.priority, a.location_node_id
FROM orset_add a
WHERE NOT EXISTS (
  SELECT 1 FROM orset_remove r
  WHERE r.element_id = a.element_id AND r.unique_tag = a.unique_tag
)
ORDER BY a.unique_tag
''');
    return rows
        .map(
          (r) => SupplyLine(
            elementId: r['element_id']! as String,
            uniqueTag: r['unique_tag']! as String,
            sku: r['sku']! as String,
            description: r['description']! as String,
            quantity: r['quantity']! as int,
            priority: CargoPriority.fromInt(r['priority']! as int),
            locationNodeId: r['location_node_id']! as String,
          ),
        )
        .toList();
  }

  /// Merge remote OR-Set + clock (for future sync). Pure DB append + clock merge.
  Future<void> mergeRemoteBatch({
    required List<Map<String, dynamic>> remoteAdds,
    required List<Map<String, dynamic>> remoteRemoves,
    required VectorClock remoteClock,
  }) async {
    _require(Permission.executeSync);
    final db = _database;
    await db.transaction((txn) async {
      for (final a in remoteAdds) {
        await txn.insert(
          'orset_add',
          a,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (final r in remoteRemoves) {
        await txn.insert(
          'orset_remove',
          r,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
    final merged = (await currentClock()).merge(remoteClock);
    await _saveClock(merged);
  }

  /// Export for debugging / future Protobuf `CrdtMutationEnvelope`.
  Future<Map<String, dynamic>> debugSnapshot() async {
    final adds = await _database.query('orset_add');
    final removes = await _database.query('orset_remove');
    return {
      'replica_id': replicaId,
      'vector_clock': (await currentClock()).components,
      'orset_add': adds,
      'orset_remove': removes,
    };
  }

  // --- Step 4: Protobuf / gRPC sync (TCP LAN; BLE can wrap same bytes) ---

  Future<pb.VectorClock> currentProtoClock() async =>
      toProtoClock(await currentClock());

  /// Full OR-Set state as `CrdtMutationEnvelope` list (delta-sync can subset later).
  Future<List<crdt_pb.CrdtMutationEnvelope>> buildExportEnvelopes() async {
    final vc = await currentProtoClock();
    final origin = pb.ReplicaId()..value = replicaId;
    final adds = await _database.query('orset_add');
    final removes = await _database.query('orset_remove');
    final out = <crdt_pb.CrdtMutationEnvelope>[];
    for (final row in adds) {
      final pri = CargoPriority.fromInt(row['priority']! as int);
      final p = dartPriorityToProto(pri);
      final item = sup_pb.SupplyItem(
        id: sup_pb.SupplyItemId()..uuid = row['element_id']! as String,
        skuCode: row['sku']! as String,
        description: row['description']! as String,
        quantity: Int64(row['quantity']! as int),
        sla: sup_pb.CargoSla(
          priority: p,
          maxHours: slaHoursForProto(p),
        ),
        currentLocationNodeId: row['location_node_id']! as String,
      );
      final op = sup_pb.OrSetSupplyOperation()
        ..add = sup_pb.OrSetSupplyAdd(
          item: item,
          uniqueTag: row['unique_tag']! as String,
        );
      out.add(
        crdt_pb.CrdtMutationEnvelope(
          collectionId: 'supply_inventory',
          kind: crdt_pb.CrdtKind.CRDT_KIND_OR_SET,
          origin: origin,
          vectorClock: vc,
          payload: op.writeToBuffer(),
        ),
      );
    }
    for (final row in removes) {
      final op = sup_pb.OrSetSupplyOperation()
        ..remove = sup_pb.OrSetSupplyRemove(
          id: sup_pb.SupplyItemId()..uuid = row['element_id']! as String,
          uniqueTag: row['unique_tag']! as String,
        );
      out.add(
        crdt_pb.CrdtMutationEnvelope(
          collectionId: 'supply_inventory',
          kind: crdt_pb.CrdtKind.CRDT_KIND_OR_SET,
          origin: origin,
          vectorClock: vc,
          payload: op.writeToBuffer(),
        ),
      );
    }
    return out;
  }

  /// Apply remote protobuf mutations (OR-Set) and merge vector clocks.
  Future<void> applyCrdtEnvelopes(List<crdt_pb.CrdtMutationEnvelope> envelopes) async {
    _require(Permission.executeSync);
    if (envelopes.isEmpty) return;
    pb.VectorClock? remoteMax;
    for (final env in envelopes) {
      if (env.hasVectorClock()) {
        remoteMax = remoteMax == null
            ? env.vectorClock
            : mergeProto(remoteMax, env.vectorClock);
      }
      if (!env.hasPayload() || env.payload.isEmpty) continue;
      final op = sup_pb.OrSetSupplyOperation.fromBuffer(env.payload);
      if (op.hasAdd()) {
        final a = op.add;
        final item = a.item;
        final pri = item.hasSla()
            ? protoCargoToDart(item.sla.priority)
            : CargoPriority.p2;
        await _database.insert(
          'orset_add',
          {
            'element_id': item.id.uuid,
            'unique_tag': a.uniqueTag,
            'sku': item.skuCode,
            'description': item.description,
            'quantity': item.quantity.toInt(),
            'priority': pri.protoValue,
            'location_node_id': item.currentLocationNodeId,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } else if (op.hasRemove()) {
        final r = op.remove;
        await _database.insert(
          'orset_remove',
          {
            'element_id': r.id.uuid,
            'unique_tag': r.uniqueTag,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    }
    if (remoteMax != null) {
      final local = await currentProtoClock();
      final merged = mergeProto(local, remoteMax);
      await _saveClock(fromProtoClock(merged));
    }
  }

  Future<sync_pb.SyncDeltaChunk> buildExportChunk() async {
    final envs = await buildExportEnvelopes();
    return sync_pb.SyncDeltaChunk()
      ..sequence = 1
      ..mutations.addAll(envs);
  }

  /// M2.4 — protobuf delta size for bandwidth demo (typically under 10 KB).
  Future<int> estimateDeltaChunkBytes() async {
    final chunk = await buildExportChunk();
    return chunk.writeToBuffer().lengthInBytes;
  }

  // --- M2.3 conflicts ---

  Future<List<CrdtConflict>> pendingConflicts() async {
    final rows = await _database.query(
      'crdt_conflicts',
      where: 'status = ?',
      whereArgs: ['pending'],
      orderBy: 'rowid DESC',
    );
    return rows.map(_rowToConflict).toList();
  }

  Future<int> pendingConflictCount() async {
    final r = await _database.rawQuery(
      'SELECT COUNT(*) AS c FROM crdt_conflicts WHERE status = ?',
      ['pending'],
    );
    final n = r.first['c'];
    if (n is int) return n;
    if (n is num) return n.toInt();
    return 0;
  }

  CrdtConflict _rowToConflict(Map<String, Object?> r) {
    return CrdtConflict(
      id: r['id']! as String,
      elementId: r['element_id']! as String,
      uniqueTag: r['unique_tag']! as String,
      fieldName: r['field_name']! as String,
      leftValue: r['left_value']! as String,
      rightValue: r['right_value']! as String,
      leftClock: VectorClock.fromJsonString(r['left_clock_json'] as String?),
      rightClock: VectorClock.fromJsonString(r['right_clock_json'] as String?),
      status: r['status']! as String,
      resolvedValue: r['resolved_value'] as String?,
      resolvedAtMs: r['resolved_at'] as int?,
    );
  }

  /// Demo: create a quantity fork for the first visible line (judges can resolve in UI).
  Future<void> seedDemoConflict() async {
    _require(Permission.executeSync);
    var lines = await visibleLines();
    if (lines.isEmpty) {
      await addLine(
        sku: 'DEMO-CONFLICT',
        description: 'Seeded for M2.3',
        quantity: 10,
        priority: CargoPriority.p2,
      );
      lines = await visibleLines();
    }
    final line = lines.first;
    final left = await currentClock();
    final right = left.tick('simulated_replica_B');
    await _database.insert('crdt_conflicts', {
      'id': _uuid.v4(),
      'element_id': line.elementId,
      'unique_tag': line.uniqueTag,
      'field_name': 'quantity',
      'left_value': '${line.quantity}',
      'right_value': '${line.quantity + 42}',
      'left_clock_json': left.toJsonString(),
      'right_clock_json': right.toJsonString(),
      'status': 'pending',
      'resolved_value': null,
      'resolved_at': null,
    });
  }

  /// Apply winner; logs clock tick.
  Future<void> resolveConflict({
    required String conflictId,
    required bool pickLeft,
  }) async {
    _require(Permission.writeSupply);
    final rows = await _database.query(
      'crdt_conflicts',
      where: 'id = ?',
      whereArgs: [conflictId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final r = rows.first;
    if ((r['status'] as String) != 'pending') return;
    final field = r['field_name'] as String;
    final chosen = pickLeft ? r['left_value'] as String : r['right_value'] as String;
    final elementId = r['element_id'] as String;
    final uniqueTag = r['unique_tag'] as String;

    if (field == 'quantity') {
      final q = int.tryParse(chosen) ?? 0;
      await _database.update(
        'orset_add',
        {'quantity': q},
        where: 'element_id = ? AND unique_tag = ?',
        whereArgs: [elementId, uniqueTag],
      );
    }

    final clock = (await currentClock()).tick(replicaId);
    await _saveClock(clock);

    await _database.update(
      'crdt_conflicts',
      {
        'status': 'resolved',
        'resolved_value': chosen,
        'resolved_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [conflictId],
    );
  }

  // --- M5.3 PoD → CRDT ledger ---

  /// Append tamper-evident receipt as an OR-set element (propagates via existing sync).
  Future<void> appendPodReceiptLedger({
    required String deliveryId,
    required String driverSignatureHex,
    required String recipientSignatureHex,
    required String payloadHashHex,
    String locationNodeId = 'N1',
  }) async {
    _require(Permission.writeSupply);
    final payload = jsonEncode({
      'type': 'pod_receipt',
      'delivery_id': deliveryId,
      'driver_sig_hex': driverSignatureHex,
      'recipient_sig_hex': recipientSignatureHex,
      'payload_hash_hex': payloadHashHex,
      'ts_ms': DateTime.now().millisecondsSinceEpoch,
    });
    await addLine(
      sku: 'POD-$deliveryId',
      description: payload,
      quantity: 1,
      priority: CargoPriority.p0,
      locationNodeId: locationNodeId,
    );
  }

  Future<List<SupplyLine>> visiblePodReceipts() async {
    final all = await visibleLines();
    return all.where((l) => l.sku.startsWith('POD-')).toList();
  }

  // --- M1.2 public key ledger (append-only, tamper-evident chain is audit_log) ---

  Future<void> appendPublicKeyLedger({
    required String replicaId,
    required String pubkeyHex,
    required String event,
  }) async {
    await _database.insert('pubkey_ledger', {
      'replica_id': replicaId,
      'pubkey_hex': pubkeyHex,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'event': event,
    });
  }

  Future<List<Map<String, Object?>>> publicKeyLedgerEntries({int limit = 50}) async {
    return _database.query(
      'pubkey_ledger',
      orderBy: 'id DESC',
      limit: limit,
    );
  }

  // --- M3 relay persistence (SQLite) ---

  Future<void> relayInsertRow({
    required String id,
    required String destFingerprint,
    required String sealedPayload,
    required int ttlSeconds,
    required int hopCount,
  }) async {
    _require(Permission.executeSync);
    await _database.insert('relay_outbox', {
      'id': id,
      'dest_fingerprint': destFingerprint,
      'sealed_payload': sealedPayload,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'ttl_seconds': ttlSeconds,
      'hop_count': hopCount,
      'status': 'pending',
    });
  }

  Future<List<Map<String, Object?>>> relayPendingRows() async {
    return _database.query(
      'relay_outbox',
      where: 'status = ?',
      whereArgs: ['pending'],
    );
  }

  Future<void> relayDelete(String id) async {
    await _database.delete('relay_outbox', where: 'id = ?', whereArgs: [id]);
  }
}
