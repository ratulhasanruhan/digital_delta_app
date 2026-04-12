//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use replicaIdDescriptor instead')
const ReplicaId$json = {
  '1': 'ReplicaId',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 9, '10': 'value'},
  ],
};

/// Descriptor for `ReplicaId`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List replicaIdDescriptor = $convert.base64Decode(
    'CglSZXBsaWNhSWQSFAoFdmFsdWUYASABKAlSBXZhbHVl');

@$core.Deprecated('Use vectorClockComponentDescriptor instead')
const VectorClockComponent$json = {
  '1': 'VectorClockComponent',
  '2': [
    {'1': 'replica_id', '3': 1, '4': 1, '5': 9, '10': 'replicaId'},
    {'1': 'counter', '3': 2, '4': 1, '5': 4, '10': 'counter'},
  ],
};

/// Descriptor for `VectorClockComponent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorClockComponentDescriptor = $convert.base64Decode(
    'ChRWZWN0b3JDbG9ja0NvbXBvbmVudBIdCgpyZXBsaWNhX2lkGAEgASgJUglyZXBsaWNhSWQSGA'
    'oHY291bnRlchgCIAEoBFIHY291bnRlcg==');

@$core.Deprecated('Use vectorClockDescriptor instead')
const VectorClock$json = {
  '1': 'VectorClock',
  '2': [
    {'1': 'components', '3': 1, '4': 3, '5': 11, '6': '.digitaldelta.v1.VectorClockComponent', '10': 'components'},
  ],
};

/// Descriptor for `VectorClock`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List vectorClockDescriptor = $convert.base64Decode(
    'CgtWZWN0b3JDbG9jaxJFCgpjb21wb25lbnRzGAEgAygLMiUuZGlnaXRhbGRlbHRhLnYxLlZlY3'
    'RvckNsb2NrQ29tcG9uZW50Ugpjb21wb25lbnRz');

@$core.Deprecated('Use sha256DigestDescriptor instead')
const Sha256Digest$json = {
  '1': 'Sha256Digest',
  '2': [
    {'1': 'raw', '3': 1, '4': 1, '5': 12, '10': 'raw'},
  ],
};

/// Descriptor for `Sha256Digest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List sha256DigestDescriptor = $convert.base64Decode(
    'CgxTaGEyNTZEaWdlc3QSEAoDcmF3GAEgASgMUgNyYXc=');

@$core.Deprecated('Use publicKeyDescriptor instead')
const PublicKey$json = {
  '1': 'PublicKey',
  '2': [
    {'1': 'raw', '3': 1, '4': 1, '5': 12, '10': 'raw'},
  ],
};

/// Descriptor for `PublicKey`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List publicKeyDescriptor = $convert.base64Decode(
    'CglQdWJsaWNLZXkSEAoDcmF3GAEgASgMUgNyYXc=');

@$core.Deprecated('Use privateKeyRefDescriptor instead')
const PrivateKeyRef$json = {
  '1': 'PrivateKeyRef',
  '2': [
    {'1': 'keystore_alias', '3': 1, '4': 1, '5': 9, '10': 'keystoreAlias'},
  ],
};

/// Descriptor for `PrivateKeyRef`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List privateKeyRefDescriptor = $convert.base64Decode(
    'Cg1Qcml2YXRlS2V5UmVmEiUKDmtleXN0b3JlX2FsaWFzGAEgASgJUg1rZXlzdG9yZUFsaWFz');

@$core.Deprecated('Use timestampRfc3339Descriptor instead')
const TimestampRfc3339$json = {
  '1': 'TimestampRfc3339',
  '2': [
    {'1': 'utc', '3': 1, '4': 1, '5': 9, '10': 'utc'},
  ],
};

/// Descriptor for `TimestampRfc3339`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampRfc3339Descriptor = $convert.base64Decode(
    'ChBUaW1lc3RhbXBSZmMzMzM5EhAKA3V0YxgBIAEoCVIDdXRj');

@$core.Deprecated('Use geoPointDescriptor instead')
const GeoPoint$json = {
  '1': 'GeoPoint',
  '2': [
    {'1': 'lat_deg', '3': 1, '4': 1, '5': 1, '10': 'latDeg'},
    {'1': 'lng_deg', '3': 2, '4': 1, '5': 1, '10': 'lngDeg'},
  ],
};

/// Descriptor for `GeoPoint`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List geoPointDescriptor = $convert.base64Decode(
    'CghHZW9Qb2ludBIXCgdsYXRfZGVnGAEgASgBUgZsYXREZWcSFwoHbG5nX2RlZxgCIAEoAVIGbG'
    '5nRGVn');

