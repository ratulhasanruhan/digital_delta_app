//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/crdt.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use crdtKindDescriptor instead')
const CrdtKind$json = {
  '1': 'CrdtKind',
  '2': [
    {'1': 'CRDT_KIND_UNSPECIFIED', '2': 0},
    {'1': 'CRDT_KIND_G_COUNTER', '2': 1},
    {'1': 'CRDT_KIND_OR_SET', '2': 2},
    {'1': 'CRDT_KIND_LWW_REGISTER', '2': 3},
    {'1': 'CRDT_KIND_RGA', '2': 4},
  ],
};

/// Descriptor for `CrdtKind`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List crdtKindDescriptor = $convert.base64Decode(
    'CghDcmR0S2luZBIZChVDUkRUX0tJTkRfVU5TUEVDSUZJRUQQABIXChNDUkRUX0tJTkRfR19DT1'
    'VOVEVSEAESFAoQQ1JEVF9LSU5EX09SX1NFVBACEhoKFkNSRFRfS0lORF9MV1dfUkVHSVNURVIQ'
    'AxIRCg1DUkRUX0tJTkRfUkdBEAQ=');

@$core.Deprecated('Use conflictRecordDescriptor instead')
const ConflictRecord$json = {
  '1': 'ConflictRecord',
  '2': [
    {'1': 'field_key', '3': 1, '4': 1, '5': 9, '10': 'fieldKey'},
    {'1': 'value_a', '3': 2, '4': 1, '5': 12, '10': 'valueA'},
    {'1': 'value_b', '3': 3, '4': 1, '5': 12, '10': 'valueB'},
    {'1': 'clock_a', '3': 4, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'clockA'},
    {'1': 'clock_b', '3': 5, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'clockB'},
    {'1': 'resolved', '3': 6, '4': 1, '5': 8, '10': 'resolved'},
    {'1': 'resolved_value', '3': 7, '4': 1, '5': 12, '10': 'resolvedValue'},
    {'1': 'resolved_by', '3': 8, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'resolvedBy'},
  ],
};

/// Descriptor for `ConflictRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conflictRecordDescriptor = $convert.base64Decode(
    'Cg5Db25mbGljdFJlY29yZBIbCglmaWVsZF9rZXkYASABKAlSCGZpZWxkS2V5EhcKB3ZhbHVlX2'
    'EYAiABKAxSBnZhbHVlQRIXCgd2YWx1ZV9iGAMgASgMUgZ2YWx1ZUISNQoHY2xvY2tfYRgEIAEo'
    'CzIcLmRpZ2l0YWxkZWx0YS52MS5WZWN0b3JDbG9ja1IGY2xvY2tBEjUKB2Nsb2NrX2IYBSABKA'
    'syHC5kaWdpdGFsZGVsdGEudjEuVmVjdG9yQ2xvY2tSBmNsb2NrQhIaCghyZXNvbHZlZBgGIAEo'
    'CFIIcmVzb2x2ZWQSJQoOcmVzb2x2ZWRfdmFsdWUYByABKAxSDXJlc29sdmVkVmFsdWUSOwoLcm'
    'Vzb2x2ZWRfYnkYCCABKAsyGi5kaWdpdGFsZGVsdGEudjEuUmVwbGljYUlkUgpyZXNvbHZlZEJ5');

@$core.Deprecated('Use crdtMutationEnvelopeDescriptor instead')
const CrdtMutationEnvelope$json = {
  '1': 'CrdtMutationEnvelope',
  '2': [
    {'1': 'collection_id', '3': 1, '4': 1, '5': 9, '10': 'collectionId'},
    {'1': 'kind', '3': 2, '4': 1, '5': 14, '6': '.digitaldelta.v1.CrdtKind', '10': 'kind'},
    {'1': 'origin', '3': 3, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'origin'},
    {'1': 'vector_clock', '3': 4, '4': 1, '5': 11, '6': '.digitaldelta.v1.VectorClock', '10': 'vectorClock'},
    {'1': 'payload', '3': 5, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `CrdtMutationEnvelope`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List crdtMutationEnvelopeDescriptor = $convert.base64Decode(
    'ChRDcmR0TXV0YXRpb25FbnZlbG9wZRIjCg1jb2xsZWN0aW9uX2lkGAEgASgJUgxjb2xsZWN0aW'
    '9uSWQSLQoEa2luZBgCIAEoDjIZLmRpZ2l0YWxkZWx0YS52MS5DcmR0S2luZFIEa2luZBIyCgZv'
    'cmlnaW4YAyABKAsyGi5kaWdpdGFsZGVsdGEudjEuUmVwbGljYUlkUgZvcmlnaW4SPwoMdmVjdG'
    '9yX2Nsb2NrGAQgASgLMhwuZGlnaXRhbGRlbHRhLnYxLlZlY3RvckNsb2NrUgt2ZWN0b3JDbG9j'
    'axIYCgdwYXlsb2FkGAUgASgMUgdwYXlsb2Fk');

