//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/supply.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'supply.pbenum.dart';

export 'supply.pbenum.dart';

class CargoSla extends $pb.GeneratedMessage {
  factory CargoSla({
    CargoPriority? priority,
    $core.double? maxHours,
  }) {
    final $result = create();
    if (priority != null) {
      $result.priority = priority;
    }
    if (maxHours != null) {
      $result.maxHours = maxHours;
    }
    return $result;
  }
  CargoSla._() : super();
  factory CargoSla.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CargoSla.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CargoSla', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..e<CargoPriority>(1, _omitFieldNames ? '' : 'priority', $pb.PbFieldType.OE, defaultOrMaker: CargoPriority.CARGO_PRIORITY_UNSPECIFIED, valueOf: CargoPriority.valueOf, enumValues: CargoPriority.values)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'maxHours', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CargoSla clone() => CargoSla()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CargoSla copyWith(void Function(CargoSla) updates) => super.copyWith((message) => updates(message as CargoSla)) as CargoSla;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CargoSla create() => CargoSla._();
  CargoSla createEmptyInstance() => create();
  static $pb.PbList<CargoSla> createRepeated() => $pb.PbList<CargoSla>();
  @$core.pragma('dart2js:noInline')
  static CargoSla getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CargoSla>(create);
  static CargoSla? _defaultInstance;

  @$pb.TagNumber(1)
  CargoPriority get priority => $_getN(0);
  @$pb.TagNumber(1)
  set priority(CargoPriority v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPriority() => $_has(0);
  @$pb.TagNumber(1)
  void clearPriority() => clearField(1);

  @$pb.TagNumber(2)
  $core.double get maxHours => $_getN(1);
  @$pb.TagNumber(2)
  set maxHours($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxHours() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxHours() => clearField(2);
}

/// Single supply line item in OR-Set with LWW metadata on quantity field via separate messages.
class SupplyItemId extends $pb.GeneratedMessage {
  factory SupplyItemId({
    $core.String? uuid,
  }) {
    final $result = create();
    if (uuid != null) {
      $result.uuid = uuid;
    }
    return $result;
  }
  SupplyItemId._() : super();
  factory SupplyItemId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplyItemId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplyItemId', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'uuid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplyItemId clone() => SupplyItemId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplyItemId copyWith(void Function(SupplyItemId) updates) => super.copyWith((message) => updates(message as SupplyItemId)) as SupplyItemId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplyItemId create() => SupplyItemId._();
  SupplyItemId createEmptyInstance() => create();
  static $pb.PbList<SupplyItemId> createRepeated() => $pb.PbList<SupplyItemId>();
  @$core.pragma('dart2js:noInline')
  static SupplyItemId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplyItemId>(create);
  static SupplyItemId? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get uuid => $_getSZ(0);
  @$pb.TagNumber(1)
  set uuid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUuid() => $_has(0);
  @$pb.TagNumber(1)
  void clearUuid() => clearField(1);
}

class SupplyItem extends $pb.GeneratedMessage {
  factory SupplyItem({
    SupplyItemId? id,
    $core.String? skuCode,
    $core.String? description,
    $fixnum.Int64? quantity,
    CargoSla? sla,
    $core.String? currentLocationNodeId,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (skuCode != null) {
      $result.skuCode = skuCode;
    }
    if (description != null) {
      $result.description = description;
    }
    if (quantity != null) {
      $result.quantity = quantity;
    }
    if (sla != null) {
      $result.sla = sla;
    }
    if (currentLocationNodeId != null) {
      $result.currentLocationNodeId = currentLocationNodeId;
    }
    return $result;
  }
  SupplyItem._() : super();
  factory SupplyItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SupplyItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SupplyItem', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<SupplyItemId>(1, _omitFieldNames ? '' : 'id', subBuilder: SupplyItemId.create)
    ..aOS(2, _omitFieldNames ? '' : 'skuCode')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'quantity', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<CargoSla>(5, _omitFieldNames ? '' : 'sla', subBuilder: CargoSla.create)
    ..aOS(6, _omitFieldNames ? '' : 'currentLocationNodeId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SupplyItem clone() => SupplyItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SupplyItem copyWith(void Function(SupplyItem) updates) => super.copyWith((message) => updates(message as SupplyItem)) as SupplyItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SupplyItem create() => SupplyItem._();
  SupplyItem createEmptyInstance() => create();
  static $pb.PbList<SupplyItem> createRepeated() => $pb.PbList<SupplyItem>();
  @$core.pragma('dart2js:noInline')
  static SupplyItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SupplyItem>(create);
  static SupplyItem? _defaultInstance;

  @$pb.TagNumber(1)
  SupplyItemId get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(SupplyItemId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  SupplyItemId ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get skuCode => $_getSZ(1);
  @$pb.TagNumber(2)
  set skuCode($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSkuCode() => $_has(1);
  @$pb.TagNumber(2)
  void clearSkuCode() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get quantity => $_getI64(3);
  @$pb.TagNumber(4)
  set quantity($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasQuantity() => $_has(3);
  @$pb.TagNumber(4)
  void clearQuantity() => clearField(4);

  @$pb.TagNumber(5)
  CargoSla get sla => $_getN(4);
  @$pb.TagNumber(5)
  set sla(CargoSla v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasSla() => $_has(4);
  @$pb.TagNumber(5)
  void clearSla() => clearField(5);
  @$pb.TagNumber(5)
  CargoSla ensureSla() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get currentLocationNodeId => $_getSZ(5);
  @$pb.TagNumber(6)
  set currentLocationNodeId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCurrentLocationNodeId() => $_has(5);
  @$pb.TagNumber(6)
  void clearCurrentLocationNodeId() => clearField(6);
}

/// OR-Set: add/remove tombstones with unique tags.
class OrSetSupplyAdd extends $pb.GeneratedMessage {
  factory OrSetSupplyAdd({
    SupplyItem? item,
    $core.String? uniqueTag,
  }) {
    final $result = create();
    if (item != null) {
      $result.item = item;
    }
    if (uniqueTag != null) {
      $result.uniqueTag = uniqueTag;
    }
    return $result;
  }
  OrSetSupplyAdd._() : super();
  factory OrSetSupplyAdd.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrSetSupplyAdd.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrSetSupplyAdd', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<SupplyItem>(1, _omitFieldNames ? '' : 'item', subBuilder: SupplyItem.create)
    ..aOS(2, _omitFieldNames ? '' : 'uniqueTag')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrSetSupplyAdd clone() => OrSetSupplyAdd()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrSetSupplyAdd copyWith(void Function(OrSetSupplyAdd) updates) => super.copyWith((message) => updates(message as OrSetSupplyAdd)) as OrSetSupplyAdd;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrSetSupplyAdd create() => OrSetSupplyAdd._();
  OrSetSupplyAdd createEmptyInstance() => create();
  static $pb.PbList<OrSetSupplyAdd> createRepeated() => $pb.PbList<OrSetSupplyAdd>();
  @$core.pragma('dart2js:noInline')
  static OrSetSupplyAdd getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrSetSupplyAdd>(create);
  static OrSetSupplyAdd? _defaultInstance;

  @$pb.TagNumber(1)
  SupplyItem get item => $_getN(0);
  @$pb.TagNumber(1)
  set item(SupplyItem v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasItem() => $_has(0);
  @$pb.TagNumber(1)
  void clearItem() => clearField(1);
  @$pb.TagNumber(1)
  SupplyItem ensureItem() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get uniqueTag => $_getSZ(1);
  @$pb.TagNumber(2)
  set uniqueTag($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUniqueTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearUniqueTag() => clearField(2);
}

class OrSetSupplyRemove extends $pb.GeneratedMessage {
  factory OrSetSupplyRemove({
    SupplyItemId? id,
    $core.String? uniqueTag,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (uniqueTag != null) {
      $result.uniqueTag = uniqueTag;
    }
    return $result;
  }
  OrSetSupplyRemove._() : super();
  factory OrSetSupplyRemove.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrSetSupplyRemove.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrSetSupplyRemove', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..aOM<SupplyItemId>(1, _omitFieldNames ? '' : 'id', subBuilder: SupplyItemId.create)
    ..aOS(2, _omitFieldNames ? '' : 'uniqueTag')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrSetSupplyRemove clone() => OrSetSupplyRemove()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrSetSupplyRemove copyWith(void Function(OrSetSupplyRemove) updates) => super.copyWith((message) => updates(message as OrSetSupplyRemove)) as OrSetSupplyRemove;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrSetSupplyRemove create() => OrSetSupplyRemove._();
  OrSetSupplyRemove createEmptyInstance() => create();
  static $pb.PbList<OrSetSupplyRemove> createRepeated() => $pb.PbList<OrSetSupplyRemove>();
  @$core.pragma('dart2js:noInline')
  static OrSetSupplyRemove getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrSetSupplyRemove>(create);
  static OrSetSupplyRemove? _defaultInstance;

  @$pb.TagNumber(1)
  SupplyItemId get id => $_getN(0);
  @$pb.TagNumber(1)
  set id(SupplyItemId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
  @$pb.TagNumber(1)
  SupplyItemId ensureId() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get uniqueTag => $_getSZ(1);
  @$pb.TagNumber(2)
  set uniqueTag($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasUniqueTag() => $_has(1);
  @$pb.TagNumber(2)
  void clearUniqueTag() => clearField(2);
}

enum OrSetSupplyOperation_Op {
  add, 
  remove, 
  notSet
}

class OrSetSupplyOperation extends $pb.GeneratedMessage {
  factory OrSetSupplyOperation({
    OrSetSupplyAdd? add,
    OrSetSupplyRemove? remove,
  }) {
    final $result = create();
    if (add != null) {
      $result.add = add;
    }
    if (remove != null) {
      $result.remove = remove;
    }
    return $result;
  }
  OrSetSupplyOperation._() : super();
  factory OrSetSupplyOperation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OrSetSupplyOperation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, OrSetSupplyOperation_Op> _OrSetSupplyOperation_OpByTag = {
    1 : OrSetSupplyOperation_Op.add,
    2 : OrSetSupplyOperation_Op.remove,
    0 : OrSetSupplyOperation_Op.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OrSetSupplyOperation', package: const $pb.PackageName(_omitMessageNames ? '' : 'digitaldelta.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<OrSetSupplyAdd>(1, _omitFieldNames ? '' : 'add', subBuilder: OrSetSupplyAdd.create)
    ..aOM<OrSetSupplyRemove>(2, _omitFieldNames ? '' : 'remove', subBuilder: OrSetSupplyRemove.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OrSetSupplyOperation clone() => OrSetSupplyOperation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OrSetSupplyOperation copyWith(void Function(OrSetSupplyOperation) updates) => super.copyWith((message) => updates(message as OrSetSupplyOperation)) as OrSetSupplyOperation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OrSetSupplyOperation create() => OrSetSupplyOperation._();
  OrSetSupplyOperation createEmptyInstance() => create();
  static $pb.PbList<OrSetSupplyOperation> createRepeated() => $pb.PbList<OrSetSupplyOperation>();
  @$core.pragma('dart2js:noInline')
  static OrSetSupplyOperation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OrSetSupplyOperation>(create);
  static OrSetSupplyOperation? _defaultInstance;

  OrSetSupplyOperation_Op whichOp() => _OrSetSupplyOperation_OpByTag[$_whichOneof(0)]!;
  void clearOp() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  OrSetSupplyAdd get add => $_getN(0);
  @$pb.TagNumber(1)
  set add(OrSetSupplyAdd v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasAdd() => $_has(0);
  @$pb.TagNumber(1)
  void clearAdd() => clearField(1);
  @$pb.TagNumber(1)
  OrSetSupplyAdd ensureAdd() => $_ensure(0);

  @$pb.TagNumber(2)
  OrSetSupplyRemove get remove => $_getN(1);
  @$pb.TagNumber(2)
  set remove(OrSetSupplyRemove v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemove() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemove() => clearField(2);
  @$pb.TagNumber(2)
  OrSetSupplyRemove ensureRemove() => $_ensure(1);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
