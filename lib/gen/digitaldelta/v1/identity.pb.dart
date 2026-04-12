//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/identity.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'common.pb.dart' as $1;
import 'identity.pbenum.dart';

export 'identity.pbenum.dart';

/// Published at first enrollment; stored in CRDT “directory” for verification.
class DeviceIdentity extends $pb.GeneratedMessage {
  factory DeviceIdentity({
    $1.ReplicaId? deviceId,
    $1.PublicKey? publicKey,
    AuthAlgorithm? algorithm,
    UserRole? role,
    $core.String? displayName,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (publicKey != null) {
      $result.publicKey = publicKey;
    }
    if (algorithm != null) {
      $result.algorithm = algorithm;
    }
    if (role != null) {
      $result.role = role;
    }
    if (displayName != null) {
      $result.displayName = displayName;
    }
    return $result;
  }
  DeviceIdentity._() : super();
  factory DeviceIdentity.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeviceIdentity.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeviceIdentity', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.ReplicaId>(1, _omitFieldNames ? '' : 'deviceId', subBuilder: $1.ReplicaId.create)
    ..aOM<$1.PublicKey>(2, _omitFieldNames ? '' : 'publicKey', subBuilder: $1.PublicKey.create)
    ..e<AuthAlgorithm>(3, _omitFieldNames ? '' : 'algorithm', $pb.PbFieldType.OE, defaultOrMaker: AuthAlgorithm.AUTH_ALGORITHM_UNSPECIFIED, valueOf: AuthAlgorithm.valueOf, enumValues: AuthAlgorithm.values)
    ..e<UserRole>(4, _omitFieldNames ? '' : 'role', $pb.PbFieldType.OE, defaultOrMaker: UserRole.USER_ROLE_UNSPECIFIED, valueOf: UserRole.valueOf, enumValues: UserRole.values)
    ..aOS(5, _omitFieldNames ? '' : 'displayName')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeviceIdentity clone() => DeviceIdentity()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeviceIdentity copyWith(void Function(DeviceIdentity) updates) => super.copyWith((message) => updates(message as DeviceIdentity)) as DeviceIdentity;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeviceIdentity create() => DeviceIdentity._();
  DeviceIdentity createEmptyInstance() => create();
  static $pb.PbList<DeviceIdentity> createRepeated() => $pb.PbList<DeviceIdentity>();
  @$core.pragma('dart2js:noInline')
  static DeviceIdentity getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeviceIdentity>(create);
  static DeviceIdentity? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReplicaId get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($1.ReplicaId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReplicaId ensureDeviceId() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.PublicKey get publicKey => $_getN(1);
  @$pb.TagNumber(2)
  set publicKey($1.PublicKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPublicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearPublicKey() => clearField(2);
  @$pb.TagNumber(2)
  $1.PublicKey ensurePublicKey() => $_ensure(1);

  @$pb.TagNumber(3)
  AuthAlgorithm get algorithm => $_getN(2);
  @$pb.TagNumber(3)
  set algorithm(AuthAlgorithm v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasAlgorithm() => $_has(2);
  @$pb.TagNumber(3)
  void clearAlgorithm() => clearField(3);

  @$pb.TagNumber(4)
  UserRole get role => $_getN(3);
  @$pb.TagNumber(4)
  set role(UserRole v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasRole() => $_has(3);
  @$pb.TagNumber(4)
  void clearRole() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get displayName => $_getSZ(4);
  @$pb.TagNumber(5)
  set displayName($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasDisplayName() => $_has(4);
  @$pb.TagNumber(5)
  void clearDisplayName() => clearField(5);
}

/// M1.1 — OTP metadata for offline TOTP/HOTP demos (secret never leaves device; this is public metadata).
class OtpDeviceState extends $pb.GeneratedMessage {
  factory OtpDeviceState({
    $1.ReplicaId? deviceId,
    $core.int? timeStepSec,
    $fixnum.Int64? hotpCounter,
  }) {
    final $result = create();
    if (deviceId != null) {
      $result.deviceId = deviceId;
    }
    if (timeStepSec != null) {
      $result.timeStepSec = timeStepSec;
    }
    if (hotpCounter != null) {
      $result.hotpCounter = hotpCounter;
    }
    return $result;
  }
  OtpDeviceState._() : super();
  factory OtpDeviceState.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OtpDeviceState.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OtpDeviceState', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<$1.ReplicaId>(1, _omitFieldNames ? '' : 'deviceId', subBuilder: $1.ReplicaId.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'timeStepSec', $pb.PbFieldType.O3)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'hotpCounter', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OtpDeviceState clone() => OtpDeviceState()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OtpDeviceState copyWith(void Function(OtpDeviceState) updates) => super.copyWith((message) => updates(message as OtpDeviceState)) as OtpDeviceState;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OtpDeviceState create() => OtpDeviceState._();
  OtpDeviceState createEmptyInstance() => create();
  static $pb.PbList<OtpDeviceState> createRepeated() => $pb.PbList<OtpDeviceState>();
  @$core.pragma('dart2js:noInline')
  static OtpDeviceState getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OtpDeviceState>(create);
  static OtpDeviceState? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReplicaId get deviceId => $_getN(0);
  @$pb.TagNumber(1)
  set deviceId($1.ReplicaId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeviceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeviceId() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReplicaId ensureDeviceId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get timeStepSec => $_getIZ(1);
  @$pb.TagNumber(2)
  set timeStepSec($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimeStepSec() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimeStepSec() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get hotpCounter => $_getI64(2);
  @$pb.TagNumber(3)
  set hotpCounter($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHotpCounter() => $_has(2);
  @$pb.TagNumber(3)
  void clearHotpCounter() => clearField(3);
}

/// M1.4 — One append-only audit record (hash-chained locally).
class AuditLogEntry extends $pb.GeneratedMessage {
  factory AuditLogEntry({
    $fixnum.Int64? sequence,
    AuthEventType? eventType,
    $1.ReplicaId? actorDeviceId,
    $1.TimestampRfc3339? occurredAt,
    $1.Sha256Digest? prevHash,
    $1.Sha256Digest? entryHash,
    $core.List<$core.int>? payload,
  }) {
    final $result = create();
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (eventType != null) {
      $result.eventType = eventType;
    }
    if (actorDeviceId != null) {
      $result.actorDeviceId = actorDeviceId;
    }
    if (occurredAt != null) {
      $result.occurredAt = occurredAt;
    }
    if (prevHash != null) {
      $result.prevHash = prevHash;
    }
    if (entryHash != null) {
      $result.entryHash = entryHash;
    }
    if (payload != null) {
      $result.payload = payload;
    }
    return $result;
  }
  AuditLogEntry._() : super();
  factory AuditLogEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AuditLogEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AuditLogEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..e<AuthEventType>(2, _omitFieldNames ? '' : 'eventType', $pb.PbFieldType.OE, defaultOrMaker: AuthEventType.AUTH_EVENT_TYPE_UNSPECIFIED, valueOf: AuthEventType.valueOf, enumValues: AuthEventType.values)
    ..aOM<$1.ReplicaId>(3, _omitFieldNames ? '' : 'actorDeviceId', subBuilder: $1.ReplicaId.create)
    ..aOM<$1.TimestampRfc3339>(4, _omitFieldNames ? '' : 'occurredAt', subBuilder: $1.TimestampRfc3339.create)
    ..aOM<$1.Sha256Digest>(5, _omitFieldNames ? '' : 'prevHash', subBuilder: $1.Sha256Digest.create)
    ..aOM<$1.Sha256Digest>(6, _omitFieldNames ? '' : 'entryHash', subBuilder: $1.Sha256Digest.create)
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'payload', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AuditLogEntry clone() => AuditLogEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AuditLogEntry copyWith(void Function(AuditLogEntry) updates) => super.copyWith((message) => updates(message as AuditLogEntry)) as AuditLogEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AuditLogEntry create() => AuditLogEntry._();
  AuditLogEntry createEmptyInstance() => create();
  static $pb.PbList<AuditLogEntry> createRepeated() => $pb.PbList<AuditLogEntry>();
  @$core.pragma('dart2js:noInline')
  static AuditLogEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AuditLogEntry>(create);
  static AuditLogEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sequence => $_getI64(0);
  @$pb.TagNumber(1)
  set sequence($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequence() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequence() => clearField(1);

  @$pb.TagNumber(2)
  AuthEventType get eventType => $_getN(1);
  @$pb.TagNumber(2)
  set eventType(AuthEventType v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasEventType() => $_has(1);
  @$pb.TagNumber(2)
  void clearEventType() => clearField(2);

  @$pb.TagNumber(3)
  $1.ReplicaId get actorDeviceId => $_getN(2);
  @$pb.TagNumber(3)
  set actorDeviceId($1.ReplicaId v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasActorDeviceId() => $_has(2);
  @$pb.TagNumber(3)
  void clearActorDeviceId() => clearField(3);
  @$pb.TagNumber(3)
  $1.ReplicaId ensureActorDeviceId() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.TimestampRfc3339 get occurredAt => $_getN(3);
  @$pb.TagNumber(4)
  set occurredAt($1.TimestampRfc3339 v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasOccurredAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearOccurredAt() => clearField(4);
  @$pb.TagNumber(4)
  $1.TimestampRfc3339 ensureOccurredAt() => $_ensure(3);

  /// Hash of previous entry; genesis uses zero digest or fixed constant.
  @$pb.TagNumber(5)
  $1.Sha256Digest get prevHash => $_getN(4);
  @$pb.TagNumber(5)
  set prevHash($1.Sha256Digest v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrevHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevHash() => clearField(5);
  @$pb.TagNumber(5)
  $1.Sha256Digest ensurePrevHash() => $_ensure(4);

  /// Hash of canonical serialized payload of this entry (excluding this field).
  @$pb.TagNumber(6)
  $1.Sha256Digest get entryHash => $_getN(5);
  @$pb.TagNumber(6)
  set entryHash($1.Sha256Digest v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasEntryHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearEntryHash() => clearField(6);
  @$pb.TagNumber(6)
  $1.Sha256Digest ensureEntryHash() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.List<$core.int> get payload => $_getN(6);
  @$pb.TagNumber(7)
  set payload($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasPayload() => $_has(6);
  @$pb.TagNumber(7)
  void clearPayload() => clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
