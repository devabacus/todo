/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'configuration.dart' as _i2;
import 'configuration_sync_event.dart' as _i3;
import 'greeting.dart' as _i4;
import 'storage/upload_request.dart' as _i5;
import 'storage/upload_status.dart' as _i6;
import 'storage/uploaded_file.dart' as _i7;
import 'sync_event_type.dart' as _i8;
import 'test_data.dart' as _i9;
import 'user/customer.dart' as _i10;
import 'user/customer_user.dart' as _i11;
import 'user/permission.dart' as _i12;
import 'user/role.dart' as _i13;
import 'user/role_details.dart' as _i14;
import 'user/role_permission.dart' as _i15;
import 'user/super_admin_dashboard.dart' as _i16;
import 'user/super_user_details.dart' as _i17;
import 'user/user_details.dart' as _i18;
import 'user/user_session_data.dart' as _i19;
import 'package:serverpod_auth_client/serverpod_auth_client.dart' as _i20;
import 'package:todo_client/src/protocol/user/user_details.dart' as _i21;
import 'package:todo_client/src/protocol/user/role.dart' as _i22;
import 'package:todo_client/src/protocol/user/permission.dart' as _i23;
import 'package:todo_client/src/protocol/configuration.dart' as _i24;
import 'package:todo_client/src/protocol/storage/uploaded_file.dart' as _i25;
import 'package:todo_client/src/protocol/user/customer.dart' as _i26;
import 'package:todo_client/src/protocol/user/super_user_details.dart' as _i27;
import 'package:todo_client/src/protocol/test_data.dart' as _i28;
export 'configuration.dart';
export 'configuration_sync_event.dart';
export 'greeting.dart';
export 'storage/upload_request.dart';
export 'storage/upload_status.dart';
export 'storage/uploaded_file.dart';
export 'sync_event_type.dart';
export 'test_data.dart';
export 'user/customer.dart';
export 'user/customer_user.dart';
export 'user/permission.dart';
export 'user/role.dart';
export 'user/role_details.dart';
export 'user/role_permission.dart';
export 'user/super_admin_dashboard.dart';
export 'user/super_user_details.dart';
export 'user/user_details.dart';
export 'user/user_session_data.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != t.toString()) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.Configuration) {
      return _i2.Configuration.fromJson(data) as T;
    }
    if (t == _i3.ConfigurationSyncEvent) {
      return _i3.ConfigurationSyncEvent.fromJson(data) as T;
    }
    if (t == _i4.Greeting) {
      return _i4.Greeting.fromJson(data) as T;
    }
    if (t == _i5.UploadRequest) {
      return _i5.UploadRequest.fromJson(data) as T;
    }
    if (t == _i6.UploadStatus) {
      return _i6.UploadStatus.fromJson(data) as T;
    }
    if (t == _i7.UploadedFile) {
      return _i7.UploadedFile.fromJson(data) as T;
    }
    if (t == _i8.SyncEventType) {
      return _i8.SyncEventType.fromJson(data) as T;
    }
    if (t == _i9.TestData) {
      return _i9.TestData.fromJson(data) as T;
    }
    if (t == _i10.Customer) {
      return _i10.Customer.fromJson(data) as T;
    }
    if (t == _i11.CustomerUser) {
      return _i11.CustomerUser.fromJson(data) as T;
    }
    if (t == _i12.Permission) {
      return _i12.Permission.fromJson(data) as T;
    }
    if (t == _i13.Role) {
      return _i13.Role.fromJson(data) as T;
    }
    if (t == _i14.RoleDetails) {
      return _i14.RoleDetails.fromJson(data) as T;
    }
    if (t == _i15.RolePermission) {
      return _i15.RolePermission.fromJson(data) as T;
    }
    if (t == _i16.SuperAdminDashboard) {
      return _i16.SuperAdminDashboard.fromJson(data) as T;
    }
    if (t == _i17.SuperUserDetails) {
      return _i17.SuperUserDetails.fromJson(data) as T;
    }
    if (t == _i18.UserDetails) {
      return _i18.UserDetails.fromJson(data) as T;
    }
    if (t == _i19.UserSessionData) {
      return _i19.UserSessionData.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Configuration?>()) {
      return (data != null ? _i2.Configuration.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ConfigurationSyncEvent?>()) {
      return (data != null ? _i3.ConfigurationSyncEvent.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.Greeting?>()) {
      return (data != null ? _i4.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.UploadRequest?>()) {
      return (data != null ? _i5.UploadRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.UploadStatus?>()) {
      return (data != null ? _i6.UploadStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.UploadedFile?>()) {
      return (data != null ? _i7.UploadedFile.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.SyncEventType?>()) {
      return (data != null ? _i8.SyncEventType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.TestData?>()) {
      return (data != null ? _i9.TestData.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Customer?>()) {
      return (data != null ? _i10.Customer.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.CustomerUser?>()) {
      return (data != null ? _i11.CustomerUser.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.Permission?>()) {
      return (data != null ? _i12.Permission.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.Role?>()) {
      return (data != null ? _i13.Role.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.RoleDetails?>()) {
      return (data != null ? _i14.RoleDetails.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.RolePermission?>()) {
      return (data != null ? _i15.RolePermission.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.SuperAdminDashboard?>()) {
      return (data != null ? _i16.SuperAdminDashboard.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i17.SuperUserDetails?>()) {
      return (data != null ? _i17.SuperUserDetails.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i18.UserDetails?>()) {
      return (data != null ? _i18.UserDetails.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i19.UserSessionData?>()) {
      return (data != null ? _i19.UserSessionData.fromJson(data) : null) as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i20.UserInfo>) {
      return (data as List).map((e) => deserialize<_i20.UserInfo>(e)).toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i21.UserDetails>) {
      return (data as List)
              .map((e) => deserialize<_i21.UserDetails>(e))
              .toList()
          as T;
    }
    if (t == List<_i22.Role>) {
      return (data as List).map((e) => deserialize<_i22.Role>(e)).toList() as T;
    }
    if (t == List<_i23.Permission>) {
      return (data as List).map((e) => deserialize<_i23.Permission>(e)).toList()
          as T;
    }
    if (t == List<_i1.UuidValue>) {
      return (data as List).map((e) => deserialize<_i1.UuidValue>(e)).toList()
          as T;
    }
    if (t == List<_i24.Configuration>) {
      return (data as List)
              .map((e) => deserialize<_i24.Configuration>(e))
              .toList()
          as T;
    }
    if (t == List<_i25.UploadedFile>) {
      return (data as List)
              .map((e) => deserialize<_i25.UploadedFile>(e))
              .toList()
          as T;
    }
    if (t == List<_i26.Customer>) {
      return (data as List).map((e) => deserialize<_i26.Customer>(e)).toList()
          as T;
    }
    if (t == List<_i27.SuperUserDetails>) {
      return (data as List)
              .map((e) => deserialize<_i27.SuperUserDetails>(e))
              .toList()
          as T;
    }
    if (t == List<_i28.TestData>) {
      return (data as List).map((e) => deserialize<_i28.TestData>(e)).toList()
          as T;
    }
    try {
      return _i20.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('todo.', '');
    }

    switch (data) {
      case _i2.Configuration():
        return 'Configuration';
      case _i3.ConfigurationSyncEvent():
        return 'ConfigurationSyncEvent';
      case _i4.Greeting():
        return 'Greeting';
      case _i5.UploadRequest():
        return 'UploadRequest';
      case _i6.UploadStatus():
        return 'UploadStatus';
      case _i7.UploadedFile():
        return 'UploadedFile';
      case _i8.SyncEventType():
        return 'SyncEventType';
      case _i9.TestData():
        return 'TestData';
      case _i10.Customer():
        return 'Customer';
      case _i11.CustomerUser():
        return 'CustomerUser';
      case _i12.Permission():
        return 'Permission';
      case _i13.Role():
        return 'Role';
      case _i14.RoleDetails():
        return 'RoleDetails';
      case _i15.RolePermission():
        return 'RolePermission';
      case _i16.SuperAdminDashboard():
        return 'SuperAdminDashboard';
      case _i17.SuperUserDetails():
        return 'SuperUserDetails';
      case _i18.UserDetails():
        return 'UserDetails';
      case _i19.UserSessionData():
        return 'UserSessionData';
    }
    className = _i20.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Configuration') {
      return deserialize<_i2.Configuration>(data['data']);
    }
    if (dataClassName == 'ConfigurationSyncEvent') {
      return deserialize<_i3.ConfigurationSyncEvent>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i4.Greeting>(data['data']);
    }
    if (dataClassName == 'UploadRequest') {
      return deserialize<_i5.UploadRequest>(data['data']);
    }
    if (dataClassName == 'UploadStatus') {
      return deserialize<_i6.UploadStatus>(data['data']);
    }
    if (dataClassName == 'UploadedFile') {
      return deserialize<_i7.UploadedFile>(data['data']);
    }
    if (dataClassName == 'SyncEventType') {
      return deserialize<_i8.SyncEventType>(data['data']);
    }
    if (dataClassName == 'TestData') {
      return deserialize<_i9.TestData>(data['data']);
    }
    if (dataClassName == 'Customer') {
      return deserialize<_i10.Customer>(data['data']);
    }
    if (dataClassName == 'CustomerUser') {
      return deserialize<_i11.CustomerUser>(data['data']);
    }
    if (dataClassName == 'Permission') {
      return deserialize<_i12.Permission>(data['data']);
    }
    if (dataClassName == 'Role') {
      return deserialize<_i13.Role>(data['data']);
    }
    if (dataClassName == 'RoleDetails') {
      return deserialize<_i14.RoleDetails>(data['data']);
    }
    if (dataClassName == 'RolePermission') {
      return deserialize<_i15.RolePermission>(data['data']);
    }
    if (dataClassName == 'SuperAdminDashboard') {
      return deserialize<_i16.SuperAdminDashboard>(data['data']);
    }
    if (dataClassName == 'SuperUserDetails') {
      return deserialize<_i17.SuperUserDetails>(data['data']);
    }
    if (dataClassName == 'UserDetails') {
      return deserialize<_i18.UserDetails>(data['data']);
    }
    if (dataClassName == 'UserSessionData') {
      return deserialize<_i19.UserSessionData>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth.')) {
      data['className'] = dataClassName.substring(15);
      return _i20.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
