//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/supply.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use cargoPriorityDescriptor instead')
const CargoPriority$json = {
  '1': 'CargoPriority',
  '2': [
    {'1': 'CARGO_PRIORITY_UNSPECIFIED', '2': 0},
    {'1': 'CARGO_PRIORITY_P0_CRITICAL_MEDICAL', '2': 1},
    {'1': 'CARGO_PRIORITY_P1_HIGH', '2': 2},
    {'1': 'CARGO_PRIORITY_P2_STANDARD', '2': 3},
    {'1': 'CARGO_PRIORITY_P3_LOW', '2': 4},
  ],
};

/// Descriptor for `CargoPriority`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List cargoPriorityDescriptor = $convert.base64Decode(
    'Cg1DYXJnb1ByaW9yaXR5Eh4KGkNBUkdPX1BSSU9SSVRZX1VOU1BFQ0lGSUVEEAASJgoiQ0FSR0'
    '9fUFJJT1JJVFlfUDBfQ1JJVElDQUxfTUVESUNBTBABEhoKFkNBUkdPX1BSSU9SSVRZX1AxX0hJ'
    'R0gQAhIeChpDQVJHT19QUklPUklUWV9QMl9TVEFOREFSRBADEhkKFUNBUkdPX1BSSU9SSVRZX1'
    'AzX0xPVxAE');

@$core.Deprecated('Use cargoSlaDescriptor instead')
const CargoSla$json = {
  '1': 'CargoSla',
  '2': [
    {'1': 'priority', '3': 1, '4': 1, '5': 14, '6': '.digitaldelta.v1.CargoPriority', '10': 'priority'},
    {'1': 'max_hours', '3': 2, '4': 1, '5': 1, '10': 'maxHours'},
  ],
};

/// Descriptor for `CargoSla`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List cargoSlaDescriptor = $convert.base64Decode(
    'CghDYXJnb1NsYRI6Cghwcmlvcml0eRgBIAEoDjIeLmRpZ2l0YWxkZWx0YS52MS5DYXJnb1ByaW'
    '9yaXR5Ughwcmlvcml0eRIbCgltYXhfaG91cnMYAiABKAFSCG1heEhvdXJz');

@$core.Deprecated('Use supplyItemIdDescriptor instead')
const SupplyItemId$json = {
  '1': 'SupplyItemId',
  '2': [
    {'1': 'uuid', '3': 1, '4': 1, '5': 9, '10': 'uuid'},
  ],
};

/// Descriptor for `SupplyItemId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplyItemIdDescriptor = $convert.base64Decode(
    'CgxTdXBwbHlJdGVtSWQSEgoEdXVpZBgBIAEoCVIEdXVpZA==');

@$core.Deprecated('Use supplyItemDescriptor instead')
const SupplyItem$json = {
  '1': 'SupplyItem',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.SupplyItemId', '10': 'id'},
    {'1': 'sku_code', '3': 2, '4': 1, '5': 9, '10': 'skuCode'},
    {'1': 'description', '3': 3, '4': 1, '5': 9, '10': 'description'},
    {'1': 'quantity', '3': 4, '4': 1, '5': 4, '10': 'quantity'},
    {'1': 'sla', '3': 5, '4': 1, '5': 11, '6': '.digitaldelta.v1.CargoSla', '10': 'sla'},
    {'1': 'current_location_node_id', '3': 6, '4': 1, '5': 9, '10': 'currentLocationNodeId'},
  ],
};

/// Descriptor for `SupplyItem`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List supplyItemDescriptor = $convert.base64Decode(
    'CgpTdXBwbHlJdGVtEi0KAmlkGAEgASgLMh0uZGlnaXRhbGRlbHRhLnYxLlN1cHBseUl0ZW1JZF'
    'ICaWQSGQoIc2t1X2NvZGUYAiABKAlSB3NrdUNvZGUSIAoLZGVzY3JpcHRpb24YAyABKAlSC2Rl'
    'c2NyaXB0aW9uEhoKCHF1YW50aXR5GAQgASgEUghxdWFudGl0eRIrCgNzbGEYBSABKAsyGS5kaW'
    'dpdGFsZGVsdGEudjEuQ2FyZ29TbGFSA3NsYRI3ChhjdXJyZW50X2xvY2F0aW9uX25vZGVfaWQY'
    'BiABKAlSFWN1cnJlbnRMb2NhdGlvbk5vZGVJZA==');

@$core.Deprecated('Use orSetSupplyAddDescriptor instead')
const OrSetSupplyAdd$json = {
  '1': 'OrSetSupplyAdd',
  '2': [
    {'1': 'item', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.SupplyItem', '10': 'item'},
    {'1': 'unique_tag', '3': 2, '4': 1, '5': 9, '10': 'uniqueTag'},
  ],
};

/// Descriptor for `OrSetSupplyAdd`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orSetSupplyAddDescriptor = $convert.base64Decode(
    'Cg5PclNldFN1cHBseUFkZBIvCgRpdGVtGAEgASgLMhsuZGlnaXRhbGRlbHRhLnYxLlN1cHBseU'
    'l0ZW1SBGl0ZW0SHQoKdW5pcXVlX3RhZxgCIAEoCVIJdW5pcXVlVGFn');

@$core.Deprecated('Use orSetSupplyRemoveDescriptor instead')
const OrSetSupplyRemove$json = {
  '1': 'OrSetSupplyRemove',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.SupplyItemId', '10': 'id'},
    {'1': 'unique_tag', '3': 2, '4': 1, '5': 9, '10': 'uniqueTag'},
  ],
};

/// Descriptor for `OrSetSupplyRemove`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orSetSupplyRemoveDescriptor = $convert.base64Decode(
    'ChFPclNldFN1cHBseVJlbW92ZRItCgJpZBgBIAEoCzIdLmRpZ2l0YWxkZWx0YS52MS5TdXBwbH'
    'lJdGVtSWRSAmlkEh0KCnVuaXF1ZV90YWcYAiABKAlSCXVuaXF1ZVRhZw==');

@$core.Deprecated('Use orSetSupplyOperationDescriptor instead')
const OrSetSupplyOperation$json = {
  '1': 'OrSetSupplyOperation',
  '2': [
    {'1': 'add', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.OrSetSupplyAdd', '9': 0, '10': 'add'},
    {'1': 'remove', '3': 2, '4': 1, '5': 11, '6': '.digitaldelta.v1.OrSetSupplyRemove', '9': 0, '10': 'remove'},
  ],
  '8': [
    {'1': 'op'},
  ],
};

/// Descriptor for `OrSetSupplyOperation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List orSetSupplyOperationDescriptor = $convert.base64Decode(
    'ChRPclNldFN1cHBseU9wZXJhdGlvbhIzCgNhZGQYASABKAsyHy5kaWdpdGFsZGVsdGEudjEuT3'
    'JTZXRTdXBwbHlBZGRIAFIDYWRkEjwKBnJlbW92ZRgCIAEoCzIiLmRpZ2l0YWxkZWx0YS52MS5P'
    'clNldFN1cHBseVJlbW92ZUgAUgZyZW1vdmVCBAoCb3A=');

