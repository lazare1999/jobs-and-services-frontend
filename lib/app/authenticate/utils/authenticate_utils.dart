library my_prj.authenticate_utils;

import 'dart:convert';
import 'dart:io';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:jobs_and_services/app/authenticate/models/authentication_response.dart';
import 'package:jobs_and_services/app/sqflite/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globals.dart';
import '../../../main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/lazo_utils.dart';


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

  if (username ==null || password ==null || tempPassword ==null || password.isEmpty || tempPassword.isEmpty) {
    return false;
  }

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
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString("phone", username!);
      _prefs.setString("countryCode", countryPhoneCode!);
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


Future<void> _restart(context) async {
  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  _prefs.clear();
  if (!kIsWeb) {
    await _profileService.deleteAll();
  }

  RestartWidget.restartApp(context);
}

Future<void> logout(context) async {

  try {
    var token = await getAccessToken(context);

    if(token ==null) {
      await _restart(context);
      return;
    }

    await http.post(
      Uri.parse(commonUrl + 'logout_from_system'),
      headers: {
        HttpHeaders.authorizationHeader : "Bearer " + token
      },
    );
    await _restart(context);
  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}

Future<void> reloadApp(context) async {

  final SharedPreferences _prefs = await SharedPreferences.getInstance();
  var _phone = _prefs.getString("phone");
  var _countryCode = _prefs.getString("countryCode");
  String _tempPassword = "";
  String _password = "";

  if (_phone == null || _phone.isEmpty || _countryCode ==null || _countryCode.isEmpty) {
    await _restart(context);
    return;
  }

  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        //TODO : თარგმნე
        title: const Text("სესიის დრო ამოიწურა"),
        content: Form(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...[
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 5,
                          child: TextField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.password,
                            ),
                            enableSuggestions: false,
                            autocorrect: false,
                            onChanged: (value) {
                              _password = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.code,
                            ),
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _tempPassword = value;
                            },
                          ),
                        ),
                        const SizedBox(width: 5,),
                        Expanded(
                          child: ArgonTimerButton(
                            height: 50,
                            width: MediaQuery.of(context).size.width * 0.30,
                            minWidth: MediaQuery.of(context).size.width * 0.20,
                            highlightColor: Colors.transparent,
                            highlightElevation: 0,
                            roundLoadingShape: false,
                            onTap: (startTimer, btnState) async {
                              _phone ??= "";
                              if (_phone!.isEmpty) {
                                showAlertDialog.call(context, AppLocalizations.of(context)!.enter_mobile_number, AppLocalizations.of(context)!.notification);
                              } else {
                                if (btnState == ButtonState.Idle) {
                                  startTimer(20);
                                  await generateTemporaryCodeForLogin(context, _phone, _countryCode);
                                }
                              }
                            },
                            child: Text(
                              AppLocalizations.of(context)!.get_code,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            ),
                            loader: (timeLeft) {
                              return Text(
                                AppLocalizations.of(context)!.please_wait + " | $timeLeft",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15
                                ),
                              );
                            },
                            borderRadius: 18.0,
                            color: Colors.deepOrange,
                            elevation: 0,
                          ),
                        )
                      ],
                    ),
                  ].expand(
                        (widget) => [
                      widget,
                      const SizedBox(
                        height: 25,
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        actions: <Widget>[
          OutlinedButton(
            //TODO : თარგმნე
            child: const Text("ხელახლა შესვლა"),
            onPressed: () async {
              if(!await authenticate(context, _countryCode, _phone, _password, _tempPassword)) {
                await reloadApp(context);
              } else {
                navigateToLastPage(context);
              }
              Navigator.pop(context,false);
            }, //exit the app
          ),
          OutlinedButton(
            //TODO : თარგმნე
            child: const Text("გასვლა"),
            onPressed: () async {
              await _restart(context);
            },
          )
        ],
      )
  );

}