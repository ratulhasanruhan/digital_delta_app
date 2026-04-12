//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/crdt.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'crdt.pbenum.dart';

export 'crdt.pbenum.dart';

/// M2.3 — When two LWW writes compete; surfaced to UI for operator resolution.
class ConflictRecord extends $pb.GeneratedMessage {
  factory ConflictRecord({
    $core.String? fieldKey,
    $core.List<$core.int>? valueA,
    $core.List<$core.int>? valueB,
    $1.VectorClock? clockA,
    $1.VectorClock? clockB,
    $core.bool? resolved,
    $core.List<$core.int>? resolvedValue,
    $1.ReplicaId? resolvedBy,
  }) {
    final $result = create();
    if (fieldKey != null) {
      $result.fieldKey = fieldKey;
    }
    if (valueA != null) {
      $result.valueA = valueA;
    }
    if (valueB != null) {
      $result.valueB = valueB;
    }
    if (clockA != null) {
      $result.clockA = clockA;
    }
    if (clockB != null) {
      $result.clockB = clockB;
    }
    if (resolved != null) {
      $result.resolved = resolved;
    }
    if (resolvedValue != null) {
      $result.resolvedValue = resolvedValue;
    }
    if (resolvedBy != null) {
      $result.resolvedBy = resolvedBy;
    }
    return $result;
  }
  ConflictRecord._() : super();
  factory ConflictRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConflictRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConflictRecord', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'fieldKey')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'valueA', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'valueB', $pb.PbFieldType.OY)
    ..aOM<$1.VectorClock>(4, _omitFieldNames ? '' : 'clockA', subBuilder: $1.VectorClock.create)
    ..aOM<$1.VectorClock>(5, _omitFieldNames ? '' : 'clockB', subBuilder: $1.VectorClock.create)
    ..aOB(6, _omitFieldNames ? '' : 'resolved')
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'resolvedValue', $pb.PbFieldType.OY)
    ..aOM<$1.ReplicaId>(8, _omitFieldNames ? '' : 'resolvedBy', subBuilder: $1.ReplicaId.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConflictRecord clone() => ConflictRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConflictRecord copyWith(void Function(ConflictRecord) updates) => super.copyWith((message) => updates(message as ConflictRecord)) as ConflictRecord;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConflictRecord create() => ConflictRecord._();
  ConflictRecord createEmptyInstance() => create();
  static $pb.PbList<ConflictRecord> createRepeated() => $pb.PbList<ConflictRecord>();
  @$core.pragma('dart2js:noInline')
  static ConflictRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConflictRecord>(create);
  static ConflictRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get fieldKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set fieldKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFieldKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearFieldKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get valueA => $_getN(1);
  @$pb.TagNumber(2)
  set valueA($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasValueA() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueA() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get valueB => $_getN(2);
  @$pb.TagNumber(3)
  set valueB($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasValueB() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueB() => clearField(3);

  @$pb.TagNumber(4)
  $1.VectorClock get clockA => $_getN(3);
  @$pb.TagNumber(4)
  set clockA($1.VectorClock v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasClockA() => $_has(3);
  @$pb.TagNumber(4)
  void clearClockA() => clearField(4);
  @$pb.TagNumber(4)
  $1.VectorClock ensureClockA() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.VectorClock get clockB => $_getN(4);
  @$pb.TagNumber(5)
  set clockB($1.VectorClock v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasClockB() => $_has(4);
  @$pb.TagNumber(5)
  void clearClockB() => clearField(5);
  @$pb.TagNumber(5)
  $1.VectorClock ensureClockB() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.bool get resolved => $_getBF(5);
  @$pb.TagNumber(6)
  set resolved($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasResolved() => $_has(5);
  @$pb.TagNumber(6)
  void clearResolved() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get resolvedValue => $_getN(6);
  @$pb.TagNumber(7)
  set resolvedValue($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasResolvedValue() => $_has(6);
  @$pb.TagNumber(7)
  void clearResolvedValue() => clearField(7);

  @$pb.TagNumber(8)
  $1.ReplicaId get resolvedBy => $_getN(7);
  @$pb.TagNumber(8)
  set resolvedBy($1.ReplicaId v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasResolvedBy() => $_has(7);
  @$pb.TagNumber(8)
  void clearResolvedBy() => clearField(8);
  @$pb.TagNumber(8)
  $1.ReplicaId ensureResolvedBy() => $_ensure(7);
}

/// Generic mutation wrapper: embed oneof payload per CRDT type in supply.proto / other domain protos.
class CrdtMutationEnvelope extends $pb.GeneratedMessage {
  factory CrdtMutationEnvelope({
    $core.String? collectionId,
    CrdtKind? kind,
    $1.ReplicaId? origin,
    $1.VectorClock? vectorClock,
    $core.List<$core.int>? payload,
  }) {
    final $result = create();
    if (collectionId != null) {
      $result.collectionId = collectionId;
    }
    if (kind != null) {
      $result.kind = kind;
    }
    if (origin != null) {
      $result.origin = origin;
    }
    if (vectorClock != null) {
      $result.vectorClock = vectorClock;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    return $result;
  }
  CrdtMutationEnvelope._() : super();
  factory CrdtMutationEnvelope.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CrdtMutationEnvelope.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CrdtMutationEnvelope', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'collectionId')
    ..e<CrdtKind>(2, _omitFieldNames ? '' : 'kind', $pb.PbFieldType.OE, defaultOrMaker: CrdtKind.CRDT_KIND_UNSPECIFIED, valueOf: CrdtKind.valueOf, enumValues: CrdtKind.values)
    ..aOM<$1.ReplicaId>(3, _omitFieldNames ? '' : 'origin', subBuilder: $1.ReplicaId.create)
    ..aOM<$1.VectorClock>(4, _omitFieldNames ? '' : 'vectorClock', subBuilder: $1.VectorClock.create)
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CrdtMutationEnvelope clone() => CrdtMutationEnvelope()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CrdtMutationEnvelope copyWith(void Function(CrdtMutationEnvelope) updates) => super.copyWith((message) => updates(message as CrdtMutationEnvelope)) as CrdtMutationEnvelope;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CrdtMutationEnvelope create() => CrdtMutationEnvelope._();
  CrdtMutationEnvelope createEmptyInstance() => create();
  static $pb.PbList<CrdtMutationEnvelope> createRepeated() => $pb.PbList<CrdtMutationEnvelope>();
  @$core.pragma('dart2js:noInline')
  static CrdtMutationEnvelope getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CrdtMutationEnvelope>(create);
  static CrdtMutationEnvelope? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get collectionId => $_getSZ(0);
  @$pb.TagNumber(1)
  set collectionId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCollectionId() => $_has(0);
  @$pb.TagNumber(1)
  void clearCollectionId() => clearField(1);

  @$pb.TagNumber(2)
  CrdtKind get kind => $_getN(1);
  @$pb.TagNumber(2)
  set kind(CrdtKind v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasKind() => $_has(1);
  @$pb.TagNumber(2)
  void clearKind() => clearField(2);

  @$pb.TagNumber(3)
  $1.ReplicaId get origin => $_getN(2);
  @$pb.TagNumber(3)
  set origin($1.ReplicaId v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasOrigin() => $_has(2);
  @$pb.TagNumber(3)
  void clearOrigin() => clearField(3);
  @$pb.TagNumber(3)
  $1.ReplicaId ensureOrigin() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.VectorClock get vectorClock => $_getN(3);
  @$pb.TagNumber(4)
  set vectorClock($1.VectorClock v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasVectorClock() => $_has(3);
  @$pb.TagNumber(4)
  void clearVectorClock() => clearField(4);
  @$pb.TagNumber(4)
  $1.VectorClock ensureVectorClock() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.List<$core.int> get payload => $_getN(4);
  @$pb.TagNumber(5)
  set payload($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPayload() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayload() => clearField(5);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
