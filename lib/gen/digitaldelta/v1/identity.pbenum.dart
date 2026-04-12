//
//  Generated code. Do not modify.
//  source: digitaldelta/v1/identity.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class UserRole extends $pb.ProtobufEnum {
  static const UserRole USER_ROLE_UNSPECIFIED = UserRole._(0, _omitEnumNames ? '' : 'USER_ROLE_UNSPECIFIED');
  static const UserRole USER_ROLE_FIELD_VOLUNTEER = UserRole._(1, _omitEnumNames ? '' : 'USER_ROLE_FIELD_VOLUNTEER');
  static const UserRole USER_ROLE_SUPPLY_MANAGER = UserRole._(2, _omitEnumNames ? '' : 'USER_ROLE_SUPPLY_MANAGER');
  static const UserRole USER_ROLE_DRONE_OPERATOR = UserRole._(3, _omitEnumNames ? '' : 'USER_ROLE_DRONE_OPERATOR');
  static const UserRole USER_ROLE_CAMP_COMMANDER = UserRole._(4, _omitEnumNames ? '' : 'USER_ROLE_CAMP_COMMANDER');
  static const UserRole USER_ROLE_SYNC_ADMIN = UserRole._(5, _omitEnumNames ? '' : 'USER_ROLE_SYNC_ADMIN');

  static const $core.List<UserRole> values = <UserRole> [
    USER_ROLE_UNSPECIFIED,
    USER_ROLE_FIELD_VOLUNTEER,
    USER_ROLE_SUPPLY_MANAGER,
    USER_ROLE_DRONE_OPERATOR,
    USER_ROLE_CAMP_COMMANDER,
    USER_ROLE_SYNC_ADMIN,
  ];

  static final $core.Map<$core.int, UserRole> _byValue = $pb.ProtobufEnum.initByValue(values);
  static UserRole? valueOf($core.int value) => _byValue[value];

  const UserRole._($core.int v, $core.String n) : super(v, n);
}

class AuthAlgorithm extends $pb.ProtobufEnum {
  static const AuthAlgorithm AUTH_ALGORITHM_UNSPECIFIED = AuthAlgorithm._(0, _omitEnumNames ? '' : 'AUTH_ALGORITHM_UNSPECIFIED');
  static const AuthAlgorithm AUTH_ALGORITHM_ED25519 = AuthAlgorithm._(1, _omitEnumNames ? '' : 'AUTH_ALGORITHM_ED25519');
  static const AuthAlgorithm AUTH_ALGORITHM_RSA_PSS_SHA256 = AuthAlgorithm._(2, _omitEnumNames ? '' : 'AUTH_ALGORITHM_RSA_PSS_SHA256');

  static const $core.List<AuthAlgorithm> values = <AuthAlgorithm> [
    AUTH_ALGORITHM_UNSPECIFIED,
    AUTH_ALGORITHM_ED25519,
    AUTH_ALGORITHM_RSA_PSS_SHA256,
  ];

  static final $core.Map<$core.int, AuthAlgorithm> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AuthAlgorithm? valueOf($core.int value) => _byValue[value];

  const AuthAlgorithm._($core.int v, $core.String n) : super(v, n);
}

class AuthEventType extends $pb.ProtobufEnum {
  static const AuthEventType AUTH_EVENT_TYPE_UNSPECIFIED = AuthEventType._(0, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_UNSPECIFIED');
  static const AuthEventType AUTH_EVENT_TYPE_LOGIN_SUCCESS = AuthEventType._(1, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_LOGIN_SUCCESS');
  static const AuthEventType AUTH_EVENT_TYPE_LOGIN_FAILURE = AuthEventType._(2, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_LOGIN_FAILURE');
  static const AuthEventType AUTH_EVENT_TYPE_OTP_FAILURE = AuthEventType._(3, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_OTP_FAILURE');
  static const AuthEventType AUTH_EVENT_TYPE_KEY_ROTATION = AuthEventType._(4, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_KEY_ROTATION');
  static const AuthEventType AUTH_EVENT_TYPE_ROLE_CHANGE = AuthEventType._(5, _omitEnumNames ? '' : 'AUTH_EVENT_TYPE_ROLE_CHANGE');

  static const $core.List<AuthEventType> values = <AuthEventType> [
    AUTH_EVENT_TYPE_UNSPECIFIED,
    AUTH_EVENT_TYPE_LOGIN_SUCCESS,
    AUTH_EVENT_TYPE_LOGIN_FAILURE,
    AUTH_EVENT_TYPE_OTP_FAILURE,
    AUTH_EVENT_TYPE_KEY_ROTATION,
    AUTH_EVENT_TYPE_ROLE_CHANGE,
  ];

  static final $core.Map<$core.int, AuthEventType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AuthEventType? valueOf($core.int value) => _byValue[value];

  const AuthEventType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
