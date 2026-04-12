//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/sync.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'crdt.pb.dart' as $2;
import 'identity.pb.dart' as $3;

class SyncHandshakeRequest extends $pb.GeneratedMessage {
  factory SyncHandshakeRequest({
    $1.ReplicaId? peerId,
    $1.VectorClock? watermark,
    $1.PublicKey? publicKey,
  }) {
    final $result = create();
    if (peerId != null) {
      $result.peerId = peerId;
    }
    if (watermark != null) {
      $result.watermark = watermark;
    }
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    return $result;
  }
  SyncHandshakeRequest._() : super();
  factory SyncHandshakeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncHandshakeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncHandshakeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.ReplicaId>(1, _omitFieldNames ? '' : 'peerId', subBuilder: $1.ReplicaId.create)
    ..aOM<$1.VectorClock>(2, _omitFieldNames ? '' : 'watermark', subBuilder: $1.VectorClock.create)
    ..aOM<$1.PublicKey>(3, _omitFieldNames ? '' : 'publicKey', subBuilder: $1.PublicKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncHandshakeRequest clone() => SyncHandshakeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncHandshakeRequest copyWith(void Function(SyncHandshakeRequest) updates) => super.copyWith((message) => updates(message as SyncHandshakeRequest)) as SyncHandshakeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncHandshakeRequest create() => SyncHandshakeRequest._();
  SyncHandshakeRequest createEmptyInstance() => create();
  static $pb.PbList<SyncHandshakeRequest> createRepeated() => $pb.PbList<SyncHandshakeRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncHandshakeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncHandshakeRequest>(create);
  static SyncHandshakeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReplicaId get peerId => $_getN(0);
  @$pb.TagNumber(1)
  set peerId($1.ReplicaId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeerId() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReplicaId ensurePeerId() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.VectorClock get watermark => $_getN(1);
  @$pb.TagNumber(2)
  set watermark($1.VectorClock v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWatermark() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatermark() => clearField(2);
  @$pb.TagNumber(2)
  $1.VectorClock ensureWatermark() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.PublicKey get publicKey => $_getN(2);
  @$pb.TagNumber(3)
  set publicKey($1.PublicKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicKey() => clearField(3);
  @$pb.TagNumber(3)
  $1.PublicKey ensurePublicKey() => $_ensure(2);
}

class SyncHandshakeResponse extends $pb.GeneratedMessage {
  factory SyncHandshakeResponse({
    $1.ReplicaId? peerId,
    $1.VectorClock? watermark,
    $core.bool? accepted,
    $core.String? rejectReason,
  }) {
    final $result = create();
    if (peerId != null) {
      $result.peerId = peerId;
    }
    if (watermark != null) {
      $result.watermark = watermark;
    }
    if (accepted != null) {
      $result.accepted = accepted;
    }
    if (rejectReason != null) {
      $result.rejectReason = rejectReason;
    }
    return $result;
  }
  SyncHandshakeResponse._() : super();
  factory SyncHandshakeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncHandshakeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncHandshakeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.ReplicaId>(1, _omitFieldNames ? '' : 'peerId', subBuilder: $1.ReplicaId.create)
    ..aOM<$1.VectorClock>(2, _omitFieldNames ? '' : 'watermark', subBuilder: $1.VectorClock.create)
    ..aOB(3, _omitFieldNames ? '' : 'accepted')
    ..aOS(4, _omitFieldNames ? '' : 'rejectReason')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncHandshakeResponse clone() => SyncHandshakeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncHandshakeResponse copyWith(void Function(SyncHandshakeResponse) updates) => super.copyWith((message) => updates(message as SyncHandshakeResponse)) as SyncHandshakeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncHandshakeResponse create() => SyncHandshakeResponse._();
  SyncHandshakeResponse createEmptyInstance() => create();
  static $pb.PbList<SyncHandshakeResponse> createRepeated() => $pb.PbList<SyncHandshakeResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncHandshakeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncHandshakeResponse>(create);
  static SyncHandshakeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReplicaId get peerId => $_getN(0);
  @$pb.TagNumber(1)
  set peerId($1.ReplicaId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPeerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearPeerId() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReplicaId ensurePeerId() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.VectorClock get watermark => $_getN(1);
  @$pb.TagNumber(2)
  set watermark($1.VectorClock v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWatermark() => $_has(1);
  @$pb.TagNumber(2)
  void clearWatermark() => clearField(2);
  @$pb.TagNumber(2)
  $1.VectorClock ensureWatermark() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.bool get accepted => $_getBF(2);
  @$pb.TagNumber(3)
  set accepted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAccepted() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccepted() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get rejectReason => $_getSZ(3);
  @$pb.TagNumber(4)
  set rejectReason($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasRejectReason() => $_has(3);
  @$pb.TagNumber(4)
  void clearRejectReason() => clearField(4);
}

/// One logical delta; keep small for M2.4 sub-10KB target under normal conditions.
class SyncDeltaChunk extends $pb.GeneratedMessage {
  factory SyncDeltaChunk({
    $core.int? sequence,
    $core.Iterable<$2.CrdtMutationEnvelope>? mutations,
    $core.Iterable<$3.DeviceIdentity>? directoryUpdates,
  }) {
    final $result = create();
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (mutations != null) {
      $result.mutations.addAll(mutations);
    }
    if (directoryUpdates != null) {
      $result.directoryUpdates.addAll(directoryUpdates);
    }
    return $result;
  }
  SyncDeltaChunk._() : super();
  factory SyncDeltaChunk.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncDeltaChunk.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncDeltaChunk', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..pc<$2.CrdtMutationEnvelope>(2, _omitFieldNames ? '' : 'mutations', $pb.PbFieldType.PM, subBuilder: $2.CrdtMutationEnvelope.create)
    ..pc<$3.DeviceIdentity>(3, _omitFieldNames ? '' : 'directoryUpdates', $pb.PbFieldType.PM, subBuilder: $3.DeviceIdentity.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncDeltaChunk clone() => SyncDeltaChunk()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncDeltaChunk copyWith(void Function(SyncDeltaChunk) updates) => super.copyWith((message) => updates(message as SyncDeltaChunk)) as SyncDeltaChunk;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncDeltaChunk create() => SyncDeltaChunk._();
  SyncDeltaChunk createEmptyInstance() => create();
  static $pb.PbList<SyncDeltaChunk> createRepeated() => $pb.PbList<SyncDeltaChunk>();
  @$core.pragma('dart2js:noInline')
  static SyncDeltaChunk getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncDeltaChunk>(create);
  static SyncDeltaChunk? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sequence => $_getIZ(0);
  @$pb.TagNumber(1)
  set sequence($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequence() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$2.CrdtMutationEnvelope> get mutations => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$3.DeviceIdentity> get directoryUpdates => $_getList(2);
}

class SyncAck extends $pb.GeneratedMessage {
  factory SyncAck({
    $1.VectorClock? newWatermark,
    $core.int? lastSequence,
    $core.Iterable<$2.ConflictRecord>? conflicts,
  }) {
    final $result = create();
    if (newWatermark != null) {
      $result.newWatermark = newWatermark;
    }
    if (lastSequence != null) {
      $result.lastSequence = lastSequence;
    }
    if (conflicts != null) {
      $result.conflicts.addAll(conflicts);
    }
    return $result;
  }
  SyncAck._() : super();
  factory SyncAck.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncAck.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncAck', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.VectorClock>(1, _omitFieldNames ? '' : 'newWatermark', subBuilder: $1.VectorClock.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'lastSequence', $pb.PbFieldType.OU3)
    ..pc<$2.ConflictRecord>(3, _omitFieldNames ? '' : 'conflicts', $pb.PbFieldType.PM, subBuilder: $2.ConflictRecord.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncAck clone() => SyncAck()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncAck copyWith(void Function(SyncAck) updates) => super.copyWith((message) => updates(message as SyncAck)) as SyncAck;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncAck create() => SyncAck._();
  SyncAck createEmptyInstance() => create();
  static $pb.PbList<SyncAck> createRepeated() => $pb.PbList<SyncAck>();
  @$core.pragma('dart2js:noInline')
  static SyncAck getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncAck>(create);
  static SyncAck? _defaultInstance;

  @$pb.TagNumber(1)
  $1.VectorClock get newWatermark => $_getN(0);
  @$pb.TagNumber(1)
  set newWatermark($1.VectorClock v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNewWatermark() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewWatermark() => clearField(1);
  @$pb.TagNumber(1)
  $1.VectorClock ensureNewWatermark() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get lastSequence => $_getIZ(1);
  @$pb.TagNumber(2)
  set lastSequence($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLastSequence() => $_has(1);
  @$pb.TagNumber(2)
  void clearLastSequence() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$2.ConflictRecord> get conflicts => $_getList(2);
}

class SyncCursor extends $pb.GeneratedMessage {
  factory SyncCursor({
    $1.VectorClock? since,
  }) {
    final $result = create();
    if (since != null) {
      $result.since = since;
    }
    return $result;
  }
  SyncCursor._() : super();
  factory SyncCursor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncCursor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncCursor', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.VectorClock>(1, _omitFieldNames ? '' : 'since', subBuilder: $1.VectorClock.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncCursor clone() => SyncCursor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncCursor copyWith(void Function(SyncCursor) updates) => super.copyWith((message) => updates(message as SyncCursor)) as SyncCursor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncCursor create() => SyncCursor._();
  SyncCursor createEmptyInstance() => create();
  static $pb.PbList<SyncCursor> createRepeated() => $pb.PbList<SyncCursor>();
  @$core.pragma('dart2js:noInline')
  static SyncCursor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncCursor>(create);
  static SyncCursor? _defaultInstance;

  @$pb.TagNumber(1)
  $1.VectorClock get since => $_getN(0);
  @$pb.TagNumber(1)
  set since($1.VectorClock v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSince() => $_has(0);
  @$pb.TagNumber(1)
  void clearSince() => clearField(1);
  @$pb.TagNumber(1)
  $1.VectorClock ensureSince() => $_ensure(0);
}

/// Lightweight unary for **C2** load tests (k6) — same sync server binary.
class PingRequest extends $pb.GeneratedMessage {
  factory PingRequest() => create();
  PingRequest._() : super();
  factory PingRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PingRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PingRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PingRequest clone() => PingRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PingRequest copyWith(void Function(PingRequest) updates) => super.copyWith((message) => updates(message as PingRequest)) as PingRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingRequest create() => PingRequest._();
  PingRequest createEmptyInstance() => create();
  static $pb.PbList<PingRequest> createRepeated() => $pb.PbList<PingRequest>();
  @$core.pragma('dart2js:noInline')
  static PingRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingRequest>(create);
  static PingRequest? _defaultInstance;
}

class PingResponse extends $pb.GeneratedMessage {
  factory PingResponse({
    $core.String? serverId,
  }) {
    final $result = create();
    if (serverId != null) {
      $result.serverId = serverId;
    }
    return $result;
  }
  PingResponse._() : super();
  factory PingResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PingResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PingResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'serverId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PingResponse clone() => PingResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PingResponse copyWith(void Function(PingResponse) updates) => super.copyWith((message) => updates(message as PingResponse)) as PingResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PingResponse create() => PingResponse._();
  PingResponse createEmptyInstance() => create();
  static $pb.PbList<PingResponse> createRepeated() => $pb.PbList<PingResponse>();
  @$core.pragma('dart2js:noInline')
  static PingResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PingResponse>(create);
  static PingResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get serverId => $_getSZ(0);
  @$pb.TagNumber(1)
  set serverId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasServerId() => $_has(0);
  @$pb.TagNumber(1)
  void clearServerId() => clearField(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
