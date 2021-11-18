library my_prj.authenticate_utils;

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jobs_and_services/app/authenticate/models/authentication_response.dart';
import 'package:jobs_and_services/app/sqflite/services/profile_service.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../main.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../utils/lazo_utils.dart';


AuthenticationResponse auth = AuthenticationResponse();
var _profileService = ProfileService();

//ტოკენის მოპოვება
Future<String?> getJwtViaRefreshToken() async {
  try {
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'jwt_via_refresh_token',
      queryParameters: {
        "refreshToken": auth.refreshToken,
      },
    );

    if(res.statusCode !=200) {
      return null;
    }

    await updateRefreshTokenLocal(res.data);
    return res.data["jwt"];
  } catch (e) {
    return null;
  }
}

Future<String?> getJwtViaRefreshTokenFromSharedRefs() async {

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
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'jwt_via_refresh_token',
      queryParameters: {
        "refreshToken": refreshToken,
      },
    );

    if(res.statusCode !=200) {
      return null;
    }

    await updateRefreshTokenLocal(res.data);
    return res.data["jwt"];
  } catch (e) {
    return null;
  }
}

Future<String?> getAccessToken() async {

  if (auth.jwt !=null && DateTime.now().isBefore(auth.expiresAt!)) {
    return auth.jwt;
  }

  if (auth.refreshToken !=null && DateTime.now().isBefore(auth.refreshExpiresAt!)) {
    return await getJwtViaRefreshToken();
  }

  return await getJwtViaRefreshTokenFromSharedRefs();
}
//ტოკენის მოპოვება

//ავტორიზაცია
Future<bool> authenticate(context, String? countryPhoneCode, String? username, String? password, String? tempPassword) async {

  if (username ==null ||
      countryPhoneCode ==null ||
      password ==null ||
      tempPassword ==null ||
      username.isEmpty ||
      countryPhoneCode.isEmpty ||
      password.isEmpty ||
      tempPassword.isEmpty) {
    return false;
  }

  try {
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'authenticate',
      queryParameters: {
        "countryPhoneCode": countryPhoneCode,
        "username": username,
        "password": password,
        "tempPassword": tempPassword,
      },
    );

    if(res.statusCode ==200) {
      final SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString("phone", username);
      _prefs.setString("countryCode", countryPhoneCode);
      await updateRefreshTokenLocal(res.data);
      return true;
    }
  } catch (e) {
    return false;
  }

  return false;
}

Future<String> resetPasswordByPhone(context, String? countryPhoneCode, String? phoneNumber, String? newPassword, String? tempPassword) async {
  try {
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'reset_password_by_phone',
      queryParameters: {
        "countryPhoneCode": countryPhoneCode,
        "phoneNumber": phoneNumber,
        "newPassword": newPassword,
        "tempPassword": tempPassword,
      },
    );

    return res.data;
  } catch (e) {
    return e.toString();
  }
}


Future<String> resetPasswordByEmail(context, String? email, String? newPassword, String? tempPassword) async {
  try {
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'reset_password_by_email',
      queryParameters: {
        "email": email,
        "newPassword": newPassword,
        "tempPassword": tempPassword,
      },
    );

    return res.data;
  } catch (e) {
    return e.toString();
  }
}

Future<void> updateRefreshTokenLocal(res) async {
  auth.update(res);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("refresh_token", auth.refreshToken!);
  prefs.setInt("refresh_token_expires_in", auth.refreshExpiresIn!);

}
//ავტორიზაცია

//რეგისტრაცია
Future<String> register(context, String? phoneNumber, String? countryPhoneCode, String? firstName, String? lastName, String? nickname, String? code,
    String? password, String? email, String? address, String? personalNumber, String? passportNumber) async {
  try {
    final res = await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'register',
      queryParameters: {
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

    return res.data;
  } catch (e) {
    return e.toString();
  }
}

//დროებითი კოდები
Future<void> generateTemporaryCodeForLogin(context, String? username, String? countryCode) async {
  try {
    await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'generate_temp_code_for_login',
      queryParameters: {
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
    await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'generate_temp_code_for_register',
      queryParameters: {
        "username": username,
        "countryCode": countryCode,
      },
    );

  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}

Future<void> generateTempCodeForResetPasswordByPhone(context, String? countryCode, String? phoneNumber) async {
  try {
    await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'get_temp_code_for_reset_password_by_phone',
      queryParameters: {
        "countryCode": countryCode,
        "phoneNumber": phoneNumber,
      },
    );

  } catch (e) {
    showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
  }
}

Future<void> generateTempCodeForResetPasswordByEmail(context, String? email) async {
  try {
    await dioDefault.post(
      dotenv.env['JOBS_AND_SERVICES_API_BASE_URL']! + 'get_temp_code_for_reset_password_by_email',
      queryParameters: {
        "email": email,
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

    await jobsAndServicesClient.post('logout_from_system');

    await _restart(context);
  } catch (e) {
    if (e is DioError && e.response?.statusCode == 403) {
      await _restart(context);
    }
    return;
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
                            obscureText: true,
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
                            color: Colors.blueGrey,
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