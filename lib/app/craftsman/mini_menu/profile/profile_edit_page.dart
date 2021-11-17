import 'dart:async';

import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/animation_controller_class.dart';
import 'package:jobs_and_services/app/commons/models/profile_model.dart';
import 'package:jobs_and_services/app/sqflite/services/profile_service.dart';
import 'package:jobs_and_services/custom/custom_icons_icons.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileEditPage extends StatelessWidget {

  final ProfileModel? profileData;

  ProfileEditPage({Key? key, required this.profileData}) : super(key: key);

  final ProfileModel _pEditModel = ProfileModel();
  final ProfileModel _pEditModelOld = ProfileModel();
  final ProfileService _profileService = ProfileService();

  Future<bool> updateProfileEdit() async {
    _pEditModel.id = profileData!.id ?? 0;
    _pEditModel.firstName = profileData!.firstName ?? "";
    _pEditModel.lastName = profileData!.lastName ?? "";
    _pEditModel.nickname = profileData!.nickname ?? "";
    _pEditModel.email = profileData!.email ?? "";
    _pEditModel.phoneNumber = profileData!.phoneNumber ?? "";
    _pEditModel.rating = profileData!.rating ?? "";

    _pEditModelOld.firstName = profileData!.firstName;
    _pEditModelOld.lastName = profileData!.lastName;
    _pEditModelOld.nickname = profileData!.nickname;
    _pEditModelOld.email = profileData!.email;
    _pEditModelOld.phoneNumber = profileData!.phoneNumber;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: updateProfileEdit(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.edit),
              ),
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              floatingActionButton: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "btn1",
                      child: const Icon(CustomIcons.fbMessenger),
                      onPressed: () {
                        launch("http://" + dotenv.env['MESSENGER']!);
                      },
                    ),
                    FloatingActionButton(
                      child: const Icon(Icons.upload_rounded),
                      onPressed: () async {

                        if (
                        _pEditModelOld.firstName == _pEditModel.firstName &&
                            _pEditModelOld.lastName == _pEditModel.lastName &&
                            _pEditModelOld.nickname == _pEditModel.nickname &&
                            _pEditModelOld.email == _pEditModel.email
                        ) {
                          showAlertDialog(context, AppLocalizations.of(context)!.same_data, "");
                          return;
                        }

                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(' '),
                              content: Text(AppLocalizations.of(context)!.are_you_sure_want_to_edit),
                              actions: <Widget>[
                                OutlinedButton(
                                  child: Text(AppLocalizations.of(context)!.yes),
                                  onPressed: () async {
                                    if(_pEditModel.email !=null && !EmailValidator.validate(_pEditModel.email!)) {
                                      showAlertDialog(context, AppLocalizations.of(context)!.mail_incorrect, "");
                                      return;
                                    }


                                    try {
                                      final res = await jobsAndServicesClient.post(
                                        'craftsman/update_profile',
                                        queryParameters: _pEditModel.toMap(),
                                      );

                                      if(res.statusCode !=200) {
                                        showAlertDialog(context, AppLocalizations.of(context)!.could_not_edit, "");
                                        return;
                                      }

                                      if (!kIsWeb) {
                                        await _profileService.deleteAll();
                                        await _profileService.insert(_pEditModel);
                                      }

                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                      String? lastRoute = prefs.getString('last_route');
                                      if(lastRoute ==null) {
                                        return;
                                      }
                                      if (lastRoute.isNotEmpty && lastRoute != '/') {
                                        Navigator.of(context).pushNamed(lastRoute);
                                      }

                                    } catch (e) {
                                      if (e is DioError && e.response?.statusCode == 403) {
                                        reloadApp(context);
                                      } else {
                                        showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
                                      }
                                      return;
                                    }
                                  },
                                ),
                                OutlinedButton(
                                  child: Text(AppLocalizations.of(context)!.no),
                                  onPressed: ()=> Navigator.pop(context,false),
                                )
                              ],
                            )
                        );
                      },
                    ),
                  ],
                ),
              ),
              body: Form(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ...[
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.first_name,
                            ),
                            initialValue: _pEditModel.firstName,
                            onChanged: (value) {
                              _pEditModel.firstName = value;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.last_name,
                            ),
                            initialValue: _pEditModel.lastName,
                            onChanged: (value) {
                              _pEditModel.lastName = value;
                            },
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              filled: true,
                              labelText: AppLocalizations.of(context)!.email,
                            ),
                            initialValue: _pEditModel.email,
                            onChanged: (value) {
                              _pEditModel.email = value;
                            },
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
            );
          } else {
            return const AnimationControllerClass();
          }
        }
    );
  }
}

