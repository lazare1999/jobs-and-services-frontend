part of 'register_page.dart';

FormData _$FormDataFromJson(Map<String, dynamic> json) {

  return FormData(
    personalNumber: json['personalNumber'] as String?,
    passportNumber: json['passportNumber'] as String?,
    firstName: json['firstName'] as String?,
    lastName: json['lastName'] as String?,
    nickname: json['nickname'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    countryPhoneCode: json['countryPhoneCode'] as String?,
    password: json['password'] as String?,
    reEnterPassword: json['reEnterPassword'] as String?,
    tempPassword: json['tempPassword'] as String?,
  );
}

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
  'personalNumber': instance.personalNumber,
  'passportNumber': instance.passportNumber,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'nickname': instance.nickname,
  'email': instance.email,
  'address': instance.address,
  'phoneNumber': instance.phoneNumber,
  'countryPhoneCode': instance.countryPhoneCode,
  'password': instance.password,
  'reEnterPassword': instance.reEnterPassword,
  'tempPassword': instance.tempPassword,
};