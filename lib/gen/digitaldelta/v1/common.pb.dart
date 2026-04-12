//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

/// Logical replica identifier (device or process). Stable string, e.g. UUID.
class ReplicaId extends $pb.GeneratedMessage {
  factory ReplicaId({
    $core.String? value,
  }) {
    final $result = create();
    if (value != null) {
      $result.value = value;
    }
    return $result;
  }
  ReplicaId._() : super();
  factory ReplicaId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReplicaId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReplicaId', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'value')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReplicaId clone() => ReplicaId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReplicaId copyWith(void Function(ReplicaId) updates) => super.copyWith((message) => updates(message as ReplicaId)) as ReplicaId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReplicaId create() => ReplicaId._();
  ReplicaId createEmptyInstance() => create();
  static $pb.PbList<ReplicaId> createRepeated() => $pb.PbList<ReplicaId>();
  @$core.pragma('dart2js:noInline')
  static ReplicaId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReplicaId>(create);
  static ReplicaId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get value => $_getSZ(0);
  @$pb.TagNumber(1)
  set value($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => clearField(1);
}

/// One component of a vector clock (Lamport-style per-replica counter).
class VectorClockComponent extends $pb.GeneratedMessage {
  factory VectorClockComponent({
    $core.String? replicaId,
    $fixnum.Int64? counter,
  }) {
    final $result = create();
    if (replicaId != null) {
      $result.replicaId = replicaId;
    }
    if (counter != null) {
      $result.counter = counter;
    }
    return $result;
  }
  VectorClockComponent._() : super();
  factory VectorClockComponent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VectorClockComponent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VectorClockComponent', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'replicaId')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'counter', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VectorClockComponent clone() => VectorClockComponent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VectorClockComponent copyWith(void Function(VectorClockComponent) updates) => super.copyWith((message) => updates(message as VectorClockComponent)) as VectorClockComponent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VectorClockComponent create() => VectorClockComponent._();
  VectorClockComponent createEmptyInstance() => create();
  static $pb.PbList<VectorClockComponent> createRepeated() => $pb.PbList<VectorClockComponent>();
  @$core.pragma('dart2js:noInline')
  static VectorClockComponent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorClockComponent>(create);
  static VectorClockComponent? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get replicaId => $_getSZ(0);
  @$pb.TagNumber(1)
  set replicaId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReplicaId() => $_has(0);
  @$pb.TagNumber(1)
  void clearReplicaId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get counter => $_getI64(1);
  @$pb.TagNumber(2)
  set counter($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCounter() => $_has(1);
  @$pb.TagNumber(2)
  void clearCounter() => clearField(2);
}

/// Causal ordering for CRDT mutations and sync deltas (M2.2).
class VectorClock extends $pb.GeneratedMessage {
  factory VectorClock({
    $core.Iterable<VectorClockComponent>? components,
  }) {
    final $result = create();
    if (components != null) {
      $result.components.addAll(components);
    }
    return $result;
  }
  VectorClock._() : super();
  factory VectorClock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VectorClock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VectorClock', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..pc<VectorClockComponent>(1, _omitFieldNames ? '' : 'components', $pb.PbFieldType.PM, subBuilder: VectorClockComponent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VectorClock clone() => VectorClock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VectorClock copyWith(void Function(VectorClock) updates) => super.copyWith((message) => updates(message as VectorClock)) as VectorClock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VectorClock create() => VectorClock._();
  VectorClock createEmptyInstance() => create();
  static $pb.PbList<VectorClock> createRepeated() => $pb.PbList<VectorClock>();
  @$core.pragma('dart2js:noInline')
  static VectorClock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VectorClock>(create);
  static VectorClock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<VectorClockComponent> get components => $_getList(0);
}

/// SHA-256 digest (32 bytes) for payload hashes, chain links, Merkle nodes.
class Sha256Digest extends $pb.GeneratedMessage {
  factory Sha256Digest({
    $core.List<$core.int>? raw,
  }) {
    final $result = create();
    if (raw != null) {
      $result.raw = raw;
    }
    return $result;
  }
  Sha256Digest._() : super();
  factory Sha256Digest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Sha256Digest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Sha256Digest', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'raw', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Sha256Digest clone() => Sha256Digest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Sha256Digest copyWith(void Function(Sha256Digest) updates) => super.copyWith((message) => updates(message as Sha256Digest)) as Sha256Digest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Sha256Digest create() => Sha256Digest._();
  Sha256Digest createEmptyInstance() => create();
  static $pb.PbList<Sha256Digest> createRepeated() => $pb.PbList<Sha256Digest>();
  @$core.pragma('dart2js:noInline')
  static Sha256Digest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Sha256Digest>(create);
  static Sha256Digest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get raw => $_getN(0);
  @$pb.TagNumber(1)
  set raw($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRaw() => $_has(0);
  @$pb.TagNumber(1)
  void clearRaw() => clearField(1);
}

/// Opaque public key (SubjectPublicKeyInfo or raw 32-byte Ed25519, etc.).
class PublicKey extends $pb.GeneratedMessage {
  factory PublicKey({
    $core.List<$core.int>? raw,
  }) {
    final $result = create();
    if (raw != null) {
      $result.raw = raw;
    }
    return $result;
  }
  PublicKey._() : super();
  factory PublicKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PublicKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublicKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'raw', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PublicKey clone() => PublicKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PublicKey copyWith(void Function(PublicKey) updates) => super.copyWith((message) => updates(message as PublicKey)) as PublicKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublicKey create() => PublicKey._();
  PublicKey createEmptyInstance() => create();
  static $pb.PbList<PublicKey> createRepeated() => $pb.PbList<PublicKey>();
  @$core.pragma('dart2js:noInline')
  static PublicKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PublicKey>(create);
  static PublicKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get raw => $_getN(0);
  @$pb.TagNumber(1)
  set raw($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRaw() => $_has(0);
  @$pb.TagNumber(1)
  void clearRaw() => clearField(1);
}

/// Opaque private key handle — never sync; local storage only (placeholder for codegen).
class PrivateKeyRef extends $pb.GeneratedMessage {
  factory PrivateKeyRef({
    $core.String? keystoreAlias,
  }) {
    final $result = create();
    if (keystoreAlias != null) {
      $result.keystoreAlias = keystoreAlias;
    }
    return $result;
  }
  PrivateKeyRef._() : super();
  factory PrivateKeyRef.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PrivateKeyRef.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrivateKeyRef', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'keystoreAlias')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PrivateKeyRef clone() => PrivateKeyRef()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PrivateKeyRef copyWith(void Function(PrivateKeyRef) updates) => super.copyWith((message) => updates(message as PrivateKeyRef)) as PrivateKeyRef;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PrivateKeyRef create() => PrivateKeyRef._();
  PrivateKeyRef createEmptyInstance() => create();
  static $pb.PbList<PrivateKeyRef> createRepeated() => $pb.PbList<PrivateKeyRef>();
  @$core.pragma('dart2js:noInline')
  static PrivateKeyRef getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrivateKeyRef>(create);
  static PrivateKeyRef? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get keystoreAlias => $_getSZ(0);
  @$pb.TagNumber(1)
  set keystoreAlias($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasKeystoreAlias() => $_has(0);
  @$pb.TagNumber(1)
  void clearKeystoreAlias() => clearField(1);
}

/// Wall-clock time for SLAs, OTP windows, audit (use RFC 3339 string for simplicity in MVP).
class TimestampRfc3339 extends $pb.GeneratedMessage {
  factory TimestampRfc3339({
    $core.String? utc,
  }) {
    final $result = create();
    if (utc != null) {
      $result.utc = utc;
    }
    return $result;
  }
  TimestampRfc3339._() : super();
  factory TimestampRfc3339.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TimestampRfc3339.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampRfc3339', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'utc')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TimestampRfc3339 clone() => TimestampRfc3339()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TimestampRfc3339 copyWith(void Function(TimestampRfc3339) updates) => super.copyWith((message) => updates(message as TimestampRfc3339)) as TimestampRfc3339;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimestampRfc3339 create() => TimestampRfc3339._();
  TimestampRfc3339 createEmptyInstance() => create();
  static $pb.PbList<TimestampRfc3339> createRepeated() => $pb.PbList<TimestampRfc3339>();
  @$core.pragma('dart2js:noInline')
  static TimestampRfc3339 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimestampRfc3339>(create);
  static TimestampRfc3339? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get utc => $_getSZ(0);
  @$pb.TagNumber(1)
  set utc($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUtc() => $_has(0);
  @$pb.TagNumber(1)
  void clearUtc() => clearField(1);
}

/// Geographic point — aligns with map JSON "lat"/"lng".
class GeoPoint extends $pb.GeneratedMessage {
  factory GeoPoint({
    $core.double? latDeg,
    $core.double? lngDeg,
  }) {
    final $result = create();
    if (latDeg != null) {
      $result.latDeg = latDeg;
    }
    if (lngDeg != null) {
      $result.lngDeg = lngDeg;
    }
    return $result;
  }
  GeoPoint._() : super();
  factory GeoPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GeoPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GeoPoint', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'latDeg', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'lngDeg', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GeoPoint clone() => GeoPoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GeoPoint copyWith(void Function(GeoPoint) updates) => super.copyWith((message) => updates(message as GeoPoint)) as GeoPoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GeoPoint create() => GeoPoint._();
  GeoPoint createEmptyInstance() => create();
  static $pb.PbList<GeoPoint> createRepeated() => $pb.PbList<GeoPoint>();
  @$core.pragma('dart2js:noInline')
  static GeoPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GeoPoint>(create);
  static GeoPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get latDeg => $_getN(0);
  @$pb.TagNumber(1)
  set latDeg($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLatDeg() => $_has(0);
  @$pb.TagNumber(1)
  void clearLatDeg() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get lngDeg => $_getN(1);
  @$pb.TagNumber(2)
  set lngDeg($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLngDeg() => $_has(1);
  @$pb.TagNumber(2)
  void clearLngDeg() => clearField(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
