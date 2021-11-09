import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/animation_controller_class.dart';
import 'package:jobs_and_services/app/commons/star_rating.dart';
import 'package:jobs_and_services/app/craftsman/mini_menu/profile/profile_edit_page.dart';
import 'package:jobs_and_services/app/sqflite/models/profile_model.dart';
import 'package:jobs_and_services/app/sqflite/services/profile_service.dart';
import 'package:jobs_and_services/custom/custom_icons_icons.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePage createState() => _ProfilePage();
}

class _ProfilePage extends State<ProfilePage> {
  final ProfileModel _pModel = ProfileModel();
  final ProfileService _profileService = ProfileService();
  var firstLastName = "";

  //სერვერიდან მოაქვს user-ის მონაცემები
  Future<void> _updateProfileModelFromServer() async {

    try {

      final res = await jobsAndServicesClient.post('craftsman/get_profile_data');

      if(res.statusCode ==200) {
        var _profileModel = ProfileModel();
        _profileModel.updateProfile(res.data);

        if (!kIsWeb) {
          await _profileService.deleteAll();
          await _profileService.insert(_profileModel);
          var profileData = await _profileService.getProfileData();
          await _setProfileModel(profileData);
        } else {
          List<ProfileModel> newData = List<ProfileModel>.empty(growable: true);
          newData.add(_profileModel);
          await _setProfileModel(newData);
        }
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 403) {
        reloadApp(context);
      } else {
        showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
      }
      return;
    }
  }

  //სერვერიდან მოაქვს user-ის შეფასება
  Future<void> _updateRatingFromServer() async {
    try {

      final res = await jobsAndServicesClient.post('craftsman/get_rating');

      if(res.statusCode ==200) {
        if (res.data == null) {
          return;
        }
        _pModel.rating = res.data.toString();
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 403) {
        reloadApp(context);
      } else {
        showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
      }
      return;
    }
  }

  //ჩასეტავს მონაცემებს pModel-ში
  Future<void> _setProfileModel(List<ProfileModel> pData) async {
    var pData0 = pData.isNotEmpty ? pData[0] : ProfileModel();
    _pModel.firstName = pData0.firstName;
    _pModel.lastName = pData0.lastName;
    _pModel.nickname = pData0.nickname;
    _pModel.email = pData0.email;
    _pModel.phoneNumber = pData0.phoneNumber;
    _pModel.rating = pData0.rating;
    firstLastName = (_pModel.firstName ?? "")+ " " + (_pModel.lastName ==null ? "" : _pModel.lastName!);
  }

  Future<bool> _updateProfile() async {
    List<ProfileModel>? profileDataList;

    if (!kIsWeb) {
      profileDataList = await _profileService.getProfileData();
    }

    if(profileDataList == null || profileDataList.isEmpty) {
      await _updateProfileModelFromServer();
    } else {
      await _updateRatingFromServer();
      await _setProfileModel(profileDataList);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _updateProfile(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.profile),
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
                      child: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfileEditPage(profileData: _pModel)),
                        );
                      },
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.white70,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(
                        height: 20.0,
                      ),

                      generateCard(
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextFormField(
                                readOnly: true,
                                initialValue: firstLastName,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  hintText: AppLocalizations.of(context)!.full_name,
                                ),
                              )
                          ), 10.0
                      ),
                      generateCard(
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextFormField(
                                readOnly: true,
                                initialValue: _pModel.email,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.email),
                              )
                          ), 10.0
                      ),
                      generateCard(
                          Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: TextFormField(
                                readOnly: true,
                                initialValue: _pModel.phoneNumber,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(hintText: AppLocalizations.of(context)!.tel_number),
                              )
                          ), 10.0
                      ),
                      generateCard(ListTile(
                        title: StarRating(rating: _pModel.rating !=null ? double.parse(_pModel.rating!) : 0),
                        onTap: () {
                          showAlertDialog(context, AppLocalizations.of(context)!.my_rating, "");
                        } ,
                      ), 10.0),
                    ],
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