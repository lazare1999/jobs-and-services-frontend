part of 'reset_password_page.dart';

FormData _$FormDataFromJson(Map<String, dynamic> json) {
  return FormData(
    phoneNumber: json['phoneNumber'] as String?,
    email: json['email'] as String?,
    password: json['password'] as String?,
    reEnterPassword: json['reEnterPassword'] as String?,
    tempPassword: json['tempPassword'] as String?,
  );
}

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
  'phoneNumber': instance.phoneNumber,
  'email': instance.email,
  'password': instance.password,
  'reEnterPassword': instance.reEnterPassword,
  'tempPassword': instance.tempPassword,
};