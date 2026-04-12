//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/sync.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use syncHandshakeRequestDescriptor instead')
const SyncHandshakeRequest$json = {
  '1': 'SyncHandshakeRequest',
  '2': [
    {'1': 'peer_id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'peerId'},
    {'1': 'watermark', '3': 2, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'watermark'},
    {'1': 'public_key', '3': 3, '4': 1, '5': 11, '6': '.digitaldelta.v1.PublicKey', '10': 'publicKey'},
  ],
};

/// Descriptor for `SyncHandshakeRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncHandshakeRequestDescriptor = $convert.base64Decode(
    'ChRTeW5jSGFuZHNoYWtlUmVxdWVzdBIzCgdwZWVyX2lkGAEgASgLMhouZGlnaXRhbGRlbHRhLn'
    'YxLlJlcGxpY2FJZFIGcGVlcklkEjoKCXdhdGVybWFyaxgCIAEoCzIcLmRpZ2l0YWxkZWx0YS52'
    'MS5WZWN0b3JDbG9ja1IJd2F0ZXJtYXJrEjkKCnB1YmxpY19rZXkYAyABKAsyGi5kaWdpdGFsZG'
    'VsdGEudjEuUHVibGljS2V5UglwdWJsaWNLZXk=');

@$core.Deprecated('Use syncHandshakeResponseDescriptor instead')
const SyncHandshakeResponse$json = {
  '1': 'SyncHandshakeResponse',
  '2': [
    {'1': 'peer_id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'peerId'},
    {'1': 'watermark', '3': 2, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'watermark'},
    {'1': 'accepted', '3': 3, '4': 1, '5': 8, '10': 'accepted'},
    {'1': 'reject_reason', '3': 4, '4': 1, '5': 9, '10': 'rejectReason'},
  ],
};

/// Descriptor for `SyncHandshakeResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncHandshakeResponseDescriptor = $convert.base64Decode(
    'ChVTeW5jSGFuZHNoYWtlUmVzcG9uc2USMwoHcGVlcl9pZBgBIAEoCzIaLmRpZ2l0YWxkZWx0YS'
    '52MS5SZXBsaWNhSWRSBnBlZXJJZBI6Cgl3YXRlcm1hcmsYAiABKAsyHC5kaWdpdGFsZGVsdGEu'
    'djEuVmVjdG9yQ2xvY2tSCXdhdGVybWFyaxIaCghhY2NlcHRlZBgDIAEoCFIIYWNjZXB0ZWQSIw'
    'oNcmVqZWN0X3JlYXNvbhgEIAEoCVIMcmVqZWN0UmVhc29u');

@$core.Deprecated('Use syncDeltaChunkDescriptor instead')
const SyncDeltaChunk$json = {
  '1': 'SyncDeltaChunk',
  '2': [
    {'1': 'sequence', '3': 1, '4': 1, '5': 13, '10': 'sequence'},
    {'1': 'mutations', '3': 2, '4': 3, '5': 11, '6': '.digitaldelta.v1.CrdtMutationEnvelope', '10': 'mutations'},
    {'1': 'directory_updates', '3': 3, '4': 3, '5': 11, '6': '.digitaldelta.v1.DeviceIdentity', '10': 'directoryUpdates'},
  ],
};

/// Descriptor for `SyncDeltaChunk`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncDeltaChunkDescriptor = $convert.base64Decode(
    'Cg5TeW5jRGVsdGFDaHVuaxIaCghzZXF1ZW5jZRgBIAEoDVIIc2VxdWVuY2USQwoJbXV0YXRpb2'
    '5zGAIgAygLMiUuZGlnaXRhbGRlbHRhLnYxLkNyZHRNdXRhdGlvbkVudmVsb3BlUgltdXRhdGlv'
    'bnMSTAoRZGlyZWN0b3J5X3VwZGF0ZXMYAyADKAsyHy5kaWdpdGFsZGVsdGEudjEuRGV2aWNlSW'
    'RlbnRpdHlSEGRpcmVjdG9yeVVwZGF0ZXM=');

@$core.Deprecated('Use syncAckDescriptor instead')
const SyncAck$json = {
  '1': 'SyncAck',
  '2': [
    {'1': 'new_watermark', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'newWatermark'},
    {'1': 'last_sequence', '3': 2, '4': 1, '5': 13, '10': 'lastSequence'},
    {'1': 'conflicts', '3': 3, '4': 3, '5': 11, '6': '.digitaldelta.v1.ConflictRecord', '10': 'conflicts'},
  ],
};

/// Descriptor for `SyncAck`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncAckDescriptor = $convert.base64Decode(
    'CgdTeW5jQWNrEkEKDW5ld193YXRlcm1hcmsYASABKAsyHC5kaWdpdGFsZGVsdGEudjEuVmVjdG'
    '9yQ2xvY2tSDG5ld1dhdGVybWFyaxIjCg1sYXN0X3NlcXVlbmNlGAIgASgNUgxsYXN0U2VxdWVu'
    'Y2USPQoJY29uZmxpY3RzGAMgAygLMh8uZGlnaXRhbGRlbHRhLnYxLkNvbmZsaWN0UmVjb3JkUg'
    'ljb25mbGljdHM=');

@$core.Deprecated('Use syncCursorDescriptor instead')
const SyncCursor$json = {
  '1': 'SyncCursor',
  '2': [
    {'1': 'since', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'since'},
  ],
};

/// Descriptor for `SyncCursor`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List syncCursorDescriptor = $convert.base64Decode(
    'CgpTeW5jQ3Vyc29yEjIKBXNpbmNlGAEgASgLMhwuZGlnaXRhbGRlbHRhLnYxLlZlY3RvckNsb2'
    'NrUgVzaW5jZQ==');

@$core.Deprecated('Use pingRequestDescriptor instead')
const PingRequest$json = {
  '1': 'PingRequest',
};

/// Descriptor for `PingRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingRequestDescriptor = $convert.base64Decode(
    'CgtQaW5nUmVxdWVzdA==');

@$core.Deprecated('Use pingResponseDescriptor instead')
const PingResponse$json = {
  '1': 'PingResponse',
  '2': [
    {'1': 'server_id', '3': 1, '4': 1, '5': 9, '10': 'serverId'},
  ],
};

/// Descriptor for `PingResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pingResponseDescriptor = $convert.base64Decode(
    'CgxQaW5nUmVzcG9uc2USGwoJc2VydmVyX2lkGAEgASgJUghzZXJ2ZXJJZA==');

