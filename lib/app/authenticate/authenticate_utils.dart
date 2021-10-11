library my_prj.authenticate_utils;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jobs_and_services/app/authenticate/models/authentication_response.dart';
import 'package:jobs_and_services/app/sqflite/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globals.dart';
import '../../main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/lazo_utils.dart';


AuthenticationResponse auth = AuthenticationResponse();
var _profileService = ProfileService();

//ტოკენის მოპოვება
Future<String?> getJwtViaRefreshToken(context) async {
  try {
    final res = await http.post(
      Uri.parse(commonUrl + 'jwt_via_refresh_token'),
      body: {
        "refreshToken": auth.refreshToken,
      },
    );

    final String resString = res.body;

    if(res.statusCode !=200) {
      return null;
    }

    await updateRefreshTokenLocal(resString);
    var body = json.decode(resString);
    return body["jwt"];
  } catch (e) {
    return null;
  }
}

Future<String?> getJwtViaRefreshTokenFromSharedRefs(context) async {

  final SharedPreferences prefs = await SharedPreferences.getInstance();

  var refreshToken = prefs.get("refresh_token");
  int? refreshTokenExpiresIn = prefs.get("refresh_token_expires_in") as int?;

  if (refreshToken ==null || refreshTokenExpiresIn ==null) {
    return null;
  }

  var expiresAt = DateTime.fromMillisecondsSinceEpoch(refreshTokenExpiresIn);
  if (DateTime.now().isAfter(expiresAt)) {
    return null;
  }

  try {
    final res = await http.post(
      Uri.parse(commonUrl + 'jwt_via_refresh_token'),
      body: {
        "refreshToken": refreshToken,
      },
    );

    final String resString = res.body;

    if(res.statusCode !=200) {
      return null;
    }

    await updateRefreshTokenLocal(resString);
    var body = json.decode(resString);
    return body["jwt"];
  } catch (e) {
    return null;
  }
}

Future<String?> getAccessToken(context) async {

  if (auth.jwt !=null && DateTime.now().isBefore(auth.expiresAt!)) {
    return auth.jwt;
  }

  if (auth.refreshToken !=null && DateTime.now().isBefore(auth.refreshExpiresAt!)) {
    return await getJwtViaRefreshToken(context);
  }

  return await getJwtViaRefreshTokenFromSharedRefs(context);
}
//ტოკენის მოპოვება

//ავტორიზაცია
Future<bool> authenticate(context, String? countryPhoneCode, String? username, String? password, String? tempPassword) async {

  try {
    final res = await http.post(
      Uri.parse(commonUrl + 'authenticate'),
      body: {
        "countryPhoneCode": countryPhoneCode,
        "username": username,
        "password": password,
        "tempPassword": tempPassword,
      },
    );

    if(res.statusCode ==200) {
      final String resString = res.body;
      await updateRefreshTokenLocal(resString);
      return true;
    }
  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
    return false;
  }

  return false;
}

Future<void> updateRefreshTokenLocal(resString) async {
  auth.update(resString);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("refresh_token", auth.refreshToken!);
  prefs.setInt("refresh_token_expires_in", auth.refreshExpiresIn!);

}
//ავტორიზაცია

//რეგისტრაცია
Future<String> register(context, String? phoneNumber, String? countryPhoneCode, String? firstName, String? lastName, String? nickname, String? code,
    String? password, String? email, String? address, String? personalNumber, String? passportNumber) async {
  try {
    final res = await http.post(
      Uri.parse(commonUrl + 'register'),
      body: {
        "phoneNumber": phoneNumber,
        "countryPhoneCode": countryPhoneCode,
        "firstName": firstName,
        "lastName": lastName,
        "nickname": nickname,
        "code": code,
        "password": password,
        "email": email,
        "address": address,
        "personalNumber": personalNumber,
        "passportNumber": passportNumber,
      },
    );

    return res.body;
  } catch (e) {
    return e.toString();
  }
}

//დროებითი კოდები
Future<void> generateTemporaryCodeForLogin(context, String? username, String? countryCode) async {
  try {
    await http.post(
      Uri.parse(commonUrl + 'generate_temp_code_for_login'),
      body: {
        "username": username,
        "countryCode": countryCode,
      },
    );

  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}

Future<void> generateTemporaryCodeForRegister(context, String? username, String? countryCode) async {
  try {
    await http.post(
      Uri.parse(commonUrl + 'generate_temp_code_for_register'),
      body: {
        "username": username,
        "countryCode": countryCode,
      },
    );

  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}
//დროებითი კოდები

Future<void> logout(context) async {

  try {
    var token = await getAccessToken(context);

    if(token ==null) {
      await reloadApp(context);
      return;
    }

    await http.post(
      Uri.parse(commonUrl + 'logout_from_system'),
      headers: {
        HttpHeaders.authorizationHeader : "Bearer " + token
      },
    );
    await reloadApp(context);
  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}

Future<void> reloadApp(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  if (!kIsWeb) {
    await _profileService.deleteAll();
  }

  RestartWidget.restartApp(context);
}
