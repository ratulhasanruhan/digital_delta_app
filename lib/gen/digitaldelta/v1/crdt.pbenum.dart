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

class CrdtKind extends $pb.ProtobufEnum {
  static const CrdtKind CRDT_KIND_UNSPECIFIED = CrdtKind._(0, _omitEnumNames ? '' : 'CRDT_KIND_UNSPECIFIED');
  static const CrdtKind CRDT_KIND_G_COUNTER = CrdtKind._(1, _omitEnumNames ? '' : 'CRDT_KIND_G_COUNTER');
  static const CrdtKind CRDT_KIND_OR_SET = CrdtKind._(2, _omitEnumNames ? '' : 'CRDT_KIND_OR_SET');
  static const CrdtKind CRDT_KIND_LWW_REGISTER = CrdtKind._(3, _omitEnumNames ? '' : 'CRDT_KIND_LWW_REGISTER');
  static const CrdtKind CRDT_KIND_RGA = CrdtKind._(4, _omitEnumNames ? '' : 'CRDT_KIND_RGA');

  static const $core.List<CrdtKind> values = <CrdtKind> [
    CRDT_KIND_UNSPECIFIED,
    CRDT_KIND_G_COUNTER,
    CRDT_KIND_OR_SET,
    CRDT_KIND_LWW_REGISTER,
    CRDT_KIND_RGA,
  ];

  static final $core.Map<$core.int, CrdtKind> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CrdtKind? valueOf($core.int value) => _byValue[value];

  const CrdtKind._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
