//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/identity.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use userRoleDescriptor instead')
const UserRole$json = {
  '1': 'UserRole',
  '2': [
    {'1': 'USER_ROLE_UNSPECIFIED', '2': 0},
    {'1': 'USER_ROLE_FIELD_VOLUNTEER', '2': 1},
    {'1': 'USER_ROLE_SUPPLY_MANAGER', '2': 2},
    {'1': 'USER_ROLE_DRONE_OPERATOR', '2': 3},
    {'1': 'USER_ROLE_CAMP_COMMANDER', '2': 4},
    {'1': 'USER_ROLE_SYNC_ADMIN', '2': 5},
  ],
};

/// Descriptor for `UserRole`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List userRoleDescriptor = $convert.base64Decode(
    'CghVc2VyUm9sZRIZChVVU0VSX1JPTEVfVU5TUEVDSUZJRUQQABIdChlVU0VSX1JPTEVfRklFTE'
    'RfVk9MVU5URUVSEAESHAoYVVNFUl9ST0xFX1NVUFBMWV9NQU5BR0VSEAISHAoYVVNFUl9ST0xF'
    'X0RST05FX09QRVJBVE9SEAMSHAoYVVNFUl9ST0xFX0NBTVBfQ09NTUFOREVSEAQSGAoUVVNFUl'
    '9ST0xFX1NZTkNfQURNSU4QBQ==');

@$core.Deprecated('Use authAlgorithmDescriptor instead')
const AuthAlgorithm$json = {
  '1': 'AuthAlgorithm',
  '2': [
    {'1': 'AUTH_ALGORITHM_UNSPECIFIED', '2': 0},
    {'1': 'AUTH_ALGORITHM_ED25519', '2': 1},
    {'1': 'AUTH_ALGORITHM_RSA_PSS_SHA256', '2': 2},
  ],
};

/// Descriptor for `AuthAlgorithm`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authAlgorithmDescriptor = $convert.base64Decode(
    'Cg1BdXRoQWxnb3JpdGhtEh4KGkFVVEhfQUxHT1JJVEhNX1VOU1BFQ0lGSUVEEAASGgoWQVVUSF'
    '9BTEdPUklUSE1fRUQyNTUxORABEiEKHUFVVEhfQUxHT1JJVEhNX1JTQV9QU1NfU0hBMjU2EAI=');

@$core.Deprecated('Use authEventTypeDescriptor instead')
const AuthEventType$json = {
  '1': 'AuthEventType',
  '2': [
    {'1': 'AUTH_EVENT_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'AUTH_EVENT_TYPE_LOGIN_SUCCESS', '2': 1},
    {'1': 'AUTH_EVENT_TYPE_LOGIN_FAILURE', '2': 2},
    {'1': 'AUTH_EVENT_TYPE_OTP_FAILURE', '2': 3},
    {'1': 'AUTH_EVENT_TYPE_KEY_ROTATION', '2': 4},
    {'1': 'AUTH_EVENT_TYPE_ROLE_CHANGE', '2': 5},
  ],
};

/// Descriptor for `AuthEventType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List authEventTypeDescriptor = $convert.base64Decode(
    'Cg1BdXRoRXZlbnRUeXBlEh8KG0FVVEhfRVZFTlRfVFlQRV9VTlNQRUNJRklFRBAAEiEKHUFVVE'
    'hfRVZFTlRfVFlQRV9MT0dJTl9TVUNDRVNTEAESIQodQVVUSF9FVkVOVF9UWVBFX0xPR0lOX0ZB'
    'SUxVUkUQAhIfChtBVVRIX0VWRU5UX1RZUEVfT1RQX0ZBSUxVUkUQAxIgChxBVVRIX0VWRU5UX1'
    'RZUEVfS0VZX1JPVEFUSU9OEAQSHwobQVVUSF9FVkVOVF9UWVBFX1JPTEVfQ0hBTkdFEAU=');

@$core.Deprecated('Use deviceIdentityDescriptor instead')
const DeviceIdentity$json = {
  '1': 'DeviceIdentity',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'deviceId'},
    {'1': 'public_key', '3': 2, '4': 1, '5': 11, '6': '.digitaldelta.v1.PublicKey', '10': 'publicKey'},
    {'1': 'algorithm', '3': 3, '4': 1, '5': 14, '6': '.digitaldelta.v1.AuthAlgorithm', '10': 'algorithm'},
    {'1': 'role', '3': 4, '4': 1, '5': 14, '6': '.digitaldelta.v1.UserRole', '10': 'role'},
    {'1': 'display_name', '3': 5, '4': 1, '5': 9, '10': 'displayName'},
  ],
};

/// Descriptor for `DeviceIdentity`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deviceIdentityDescriptor = $convert.base64Decode(
    'Cg5EZXZpY2VJZGVudGl0eRI3CglkZXZpY2VfaWQYASABKAsyGi5kaWdpdGFsZGVsdGEudjEuUm'
    'VwbGljYUlkUghkZXZpY2VJZBI5CgpwdWJsaWNfa2V5GAIgASgLMhouZGlnaXRhbGRlbHRhLnYx'
    'LlB1YmxpY0tleVIJcHVibGljS2V5EjwKCWFsZ29yaXRobRgDIAEoDjIeLmRpZ2l0YWxkZWx0YS'
    '52MS5BdXRoQWxnb3JpdGhtUglhbGdvcml0aG0SLQoEcm9sZRgEIAEoDjIZLmRpZ2l0YWxkZWx0'
    'YS52MS5Vc2VyUm9sZVIEcm9sZRIhCgxkaXNwbGF5X25hbWUYBSABKAlSC2Rpc3BsYXlOYW1l');

@$core.Deprecated('Use otpDeviceStateDescriptor instead')
const OtpDeviceState$json = {
  '1': 'OtpDeviceState',
  '2': [
    {'1': 'device_id', '3': 1, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'deviceId'},
    {'1': 'time_step_sec', '3': 2, '4': 1, '5': 5, '10': 'timeStepSec'},
    {'1': 'hotp_counter', '3': 3, '4': 1, '5': 4, '10': 'hotpCounter'},
  ],
};

/// Descriptor for `OtpDeviceState`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List otpDeviceStateDescriptor = $convert.base64Decode(
    'Cg5PdHBEZXZpY2VTdGF0ZRI3CglkZXZpY2VfaWQYASABKAsyGi5kaWdpdGFsZGVsdGEudjEuUm'
    'VwbGljYUlkUghkZXZpY2VJZBIiCg10aW1lX3N0ZXBfc2VjGAIgASgFUgt0aW1lU3RlcFNlYxIh'
    'Cgxob3RwX2NvdW50ZXIYAyABKARSC2hvdHBDb3VudGVy');

@$core.Deprecated('Use auditLogEntryDescriptor instead')
const AuditLogEntry$json = {
  '1': 'AuditLogEntry',
  '2': [
    {'1': 'sequence', '3': 1, '4': 1, '5': 4, '10': 'sequence'},
    {'1': 'event_type', '3': 2, '4': 1, '5': 14, '6': '.digitaldelta.v1.AuthEventType', '10': 'eventType'},
    {'1': 'actor_device_id', '3': 3, '4': 1, '5': 11, '6': '.digitaldelta.v1.ReplicaId', '10': 'actorDeviceId'},
    {'1': 'occurred_at', '3': 4, '4': 1, '5': 11, '6': '.digitaldelta.v1.TimestampRfc3339', '10': 'occurredAt'},
    {'1': 'prev_hash', '3': 5, '4': 1, '5': 11, '6': '.digitaldelta.v1.Sha256Digest', '10': 'prevHash'},
    {'1': 'entry_hash', '3': 6, '4': 1, '5': 11, '6': '.digitaldelta.v1.Sha256Digest', '10': 'entryHash'},
    {'1': 'payload', '3': 7, '4': 1, '5': 12, '10': 'payload'},
  ],
};

/// Descriptor for `AuditLogEntry`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List auditLogEntryDescriptor = $convert.base64Decode(
    'Cg1BdWRpdExvZ0VudHJ5EhoKCHNlcXVlbmNlGAEgASgEUghzZXF1ZW5jZRI9CgpldmVudF90eX'
    'BlGAIgASgOMh4uZGlnaXRhbGRlbHRhLnYxLkF1dGhFdmVudFR5cGVSCWV2ZW50VHlwZRJCCg9h'
    'Y3Rvcl9kZXZpY2VfaWQYAyABKAsyGi5kaWdpdGFsZGVsdGEudjEuUmVwbGljYUlkUg1hY3Rvck'
    'RldmljZUlkEkIKC29jY3VycmVkX2F0GAQgASgLMiEuZGlnaXRhbGRlbHRhLnYxLlRpbWVzdGFt'
    'cFJmYzMzMzlSCm9jY3VycmVkQXQSOgoJcHJldl9oYXNoGAUgASgLMh0uZGlnaXRhbGRlbHRhLn'
    'YxLlNoYTI1NkRpZ2VzdFIIcHJldkhhc2gSPAoKZW50cnlfaGFzaBgGIAEoCzIdLmRpZ2l0YWxk'
    'ZWx0YS52MS5TaGEyNTZEaWdlc3RSCWVudHJ5SGFzaBIYCgdwYXlsb2FkGAcgASgMUgdwYXlsb2'
    'Fk');

