import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// M1.4 — append-only hash-chained audit log (local tamper evidence).
class AuditLogService {
  AuditLogService();

  static const String _genesis = 'GENESIS';

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = p.join(dir.path, 'audit_chain.db');
      _db = await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
CREATE TABLE audit_chain (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ts INTEGER NOT NULL,
  event TEXT NOT NULL,
  payload TEXT NOT NULL,
  prev_hash TEXT NOT NULL,
  row_hash TEXT NOT NULL
)''');
        },
      );
    } catch (e, st) {
      Error.throwWithStackTrace(e, st);
    }
  }

  Database get _database {
    final d = _db;
    if (d == null) throw StateError('AuditLogService.init() first');
    return d;
  }

  Future<String> _lastRowHash() async {
    final rows = await _database.rawQuery(
      'SELECT row_hash FROM audit_chain ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty) return _genesis;
    return rows.first['row_hash']! as String;
  }

  String _computeRowHash({
    required String prevHash,
    required int ts,
    required String event,
    required String payload,
  }) {
    final input = '$prevHash|$ts|$event|$payload';
    return sha256.convert(utf8.encode(input)).toString();
  }

  /// Append event; returns new row hash (tip of chain).
  Future<String> append({
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    await init();
    final prev = await _lastRowHash();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final payloadStr = jsonEncode(payload);
    final rowHash = _computeRowHash(
      prevHash: prev,
      ts: ts,
      event: event,
      payload: payloadStr,
    );
    await _database.insert('audit_chain', {
      'ts': ts,
      'event': event,
      'payload': payloadStr,
      'prev_hash': prev,
      'row_hash': rowHash,
    });
    return rowHash;
  }

  /// Recompute chain; false if any row was edited or ordering broke.
  Future<bool> verifyIntegrity() async {
    final reason = await integrityFailureReason();
    return reason == null;
  }

  /// When the chain is invalid, explains why (for demos / debugging). Null if OK.
  Future<String?> integrityFailureReason() async {
    await init();
    final rows = await _database.query('audit_chain', orderBy: 'id ASC');
    var expectedPrev = _genesis;
    for (final r in rows) {
      final id = r['id'] as int;
      final prev = r['prev_hash']! as String;
      final ts = r['ts']! as int;
      final event = r['event']! as String;
      final payload = r['payload']! as String;
      final stored = r['row_hash']! as String;
      if (prev != expectedPrev) {
        return 'Broken link at row #$id: prev_hash does not match previous row tip (chain order or prev tampered).';
      }
      final h = _computeRowHash(
        prevHash: prev,
        ts: ts,
        event: event,
        payload: payload,
      );
      if (h != stored) {
        return 'Row #$id fails SHA-256 check: recomputed ${h.substring(0, 12)}… ≠ stored ${stored.substring(0, 12)}… (payload or fields tampered).';
      }
      expectedPrev = stored;
    }
    return null;
  }

  /// Tip of the chain (empty log → genesis).
  Future<String> chainTipHash() async {
    await init();
    return _lastRowHash();
  }

  /// Demo hook: corrupt newest row to show detection (do not use in prod).
  Future<void> injectCorruptionInLatestRow() async {
    await init();
    final rows = await _database.rawQuery(
      'SELECT id FROM audit_chain ORDER BY id DESC LIMIT 1',
    );
    if (rows.isEmpty) return;
    final id = rows.first['id']! as int;
    await _database.update(
      'audit_chain',
      {'payload': '{"tampered":true}'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, Object?>>> recent({int limit = 30}) async {
    await init();
    return _database.query(
      'audit_chain',
      orderBy: 'id DESC',
      limit: limit,
    );
  }
}
