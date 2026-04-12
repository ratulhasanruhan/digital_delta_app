//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/node.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
  '2': [
    {'1': 'client_version', '3': 1, '4': 1, '5': 9, '10': 'clientVersion'},
  ],
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdBIlCg5jbGllbnRfdmVyc2lvbhgBIAEoCVINY2xpZW50VmVyc2lvbg==');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'server_version', '3': 1, '4': 1, '5': 9, '10': 'serverVersion'},
    {'1': 'server_time_unix_ms', '3': 2, '4': 1, '5': 3, '10': 'serverTimeUnixMs'},
    {'1': 'authenticated_user_id', '3': 3, '4': 1, '5': 9, '10': 'authenticatedUserId'},
    {'1': 'authenticated_email', '3': 4, '4': 1, '5': 9, '10': 'authenticatedEmail'},
    {'1': 'role', '3': 5, '4': 1, '5': 9, '10': 'role'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USJQoOc2VydmVyX3ZlcnNpb24YASABKAlSDXNlcnZlclZlcnNpb24SLQ'
    'oTc2VydmVyX3RpbWVfdW5peF9tcxgCIAEoA1IQc2VydmVyVGltZVVuaXhNcxIyChVhdXRoZW50'
    'aWNhdGVkX3VzZXJfaWQYAyABKAlSE2F1dGhlbnRpY2F0ZWRVc2VySWQSLwoTYXV0aGVudGljYX'
    'RlZF9lbWFpbBgEIAEoCVISYXV0aGVudGljYXRlZEVtYWlsEhIKBHJvbGUYBSABKAlSBHJvbGU=');

@$core.Deprecated('Use healthRequestDescriptor instead')
const HealthRequest$json = {
  '1': 'HealthRequest',
};

/// Descriptor for `HealthRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthRequestDescriptor = $convert.base64Decode(
    'Cg1IZWFsdGhSZXF1ZXN0');

@$core.Deprecated('Use healthResponseDescriptor instead')
const HealthResponse$json = {
  '1': 'HealthResponse',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 9, '10': 'status'},
  ],
};

/// Descriptor for `HealthResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List healthResponseDescriptor = $convert.base64Decode(
    'Cg5IZWFsdGhSZXNwb25zZRIWCgZzdGF0dXMYASABKAlSBnN0YXR1cw==');

