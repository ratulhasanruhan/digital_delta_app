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

import 'package:protobuf/protobuf.dart' as $pb;

/// M6.1 — Priority tiers with SLA hours from problem statement.
class CargoPriority extends $pb.ProtobufEnum {
  static const CargoPriority CARGO_PRIORITY_UNSPECIFIED = CargoPriority._(0, _omitEnumNames ? '' : 'CARGO_PRIORITY_UNSPECIFIED');
  static const CargoPriority CARGO_PRIORITY_P0_CRITICAL_MEDICAL = CargoPriority._(1, _omitEnumNames ? '' : 'CARGO_PRIORITY_P0_CRITICAL_MEDICAL');
  static const CargoPriority CARGO_PRIORITY_P1_HIGH = CargoPriority._(2, _omitEnumNames ? '' : 'CARGO_PRIORITY_P1_HIGH');
  static const CargoPriority CARGO_PRIORITY_P2_STANDARD = CargoPriority._(3, _omitEnumNames ? '' : 'CARGO_PRIORITY_P2_STANDARD');
  static const CargoPriority CARGO_PRIORITY_P3_LOW = CargoPriority._(4, _omitEnumNames ? '' : 'CARGO_PRIORITY_P3_LOW');

  static const $core.List<CargoPriority> values = <CargoPriority> [
    CARGO_PRIORITY_UNSPECIFIED,
    CARGO_PRIORITY_P0_CRITICAL_MEDICAL,
    CARGO_PRIORITY_P1_HIGH,
    CARGO_PRIORITY_P2_STANDARD,
    CARGO_PRIORITY_P3_LOW,
  ];

  static final $core.Map<$core.int, CargoPriority> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CargoPriority? valueOf($core.int value) => _byValue[value];

  const CargoPriority._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
