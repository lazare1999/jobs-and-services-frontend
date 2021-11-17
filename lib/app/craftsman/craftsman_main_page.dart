import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/animation_controller_class.dart';

import 'package:jobs_and_services/app/commons/info/info.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main_menu.dart';
import 'mini_menu/mini_menu.dart';

class CraftsmanMainPage extends StatefulWidget {

  const CraftsmanMainPage({Key? key}) : super(key: key);

  @override
  _CraftsmanMainPage createState() => _CraftsmanMainPage();
}

class _CraftsmanMainPage extends State<CraftsmanMainPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isToggled = false;

  Future<bool> _onBackPressed() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainMenu()),
    ).then((x) => x ?? false);
  }


  Future<bool> _craftsmanMainPageLoad() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    var _sharedVisibleVar = _prefs.getBool("userIsVisible");
    if (_sharedVisibleVar !=null) {
      _isToggled = _sharedVisibleVar;
    } else {
      try {

        final res = await jobsAndServicesClient.post("craftsman/get_visibility_status");

        if(res.statusCode ==200) {
          _isToggled = res.data;
        }
      } catch (e) {
        if (e is DioError && e.response?.statusCode == 403) {
          reloadApp(context);
        } else {
          showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
        }
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
        future: _craftsmanMainPageLoad(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return WillPopScope(
                onWillPop: _onBackPressed,
                child: Scaffold(
                  key: _scaffoldKey,
                  resizeToAvoidBottomInset: false,
                  appBar: AppBar(
                    actions: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                        ),
                        onPressed: () {
                          _scaffoldKey.currentState!.openEndDrawer();
                        },
                      )
                    ],
                  ),
                  drawer: const Drawer(
                      child: MiniMenu()
                  ),
                  endDrawer: Drawer(
                      child: Info(
                        //TODO : თარგმნე
                        title: "ჩემი კვალიფიკაცია",
                        safeAreaChild: ListView(
                          children: <Widget>[
                            ListTile(
                              title: Row(
                                children: const <Widget>[
                                  Icon(Icons.menu, color: Colors.blueGrey),
                                  Flexible(
                                      child: Padding(
                                        padding: EdgeInsets.only(left: 8.0),
                                        //TODO : თარგმნე
                                        child: Text("მცირე მენიუ"),
                                      )
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                  ),
                  body: Form(
                    child: Scrollbar(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ...[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: TextFormField(
                                        readOnly: true,
                                        initialValue: "lazooo",
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          hintText: AppLocalizations.of(context)!.full_name,
                                        ),
                                      )
                                  ),
                                  FlutterSwitch(
                                    height: 20.0,
                                    width: 40.0,
                                    padding: 4.0,
                                    toggleSize: 15.0,
                                    borderRadius: 10.0,
                                    activeColor: Colors.green,
                                    value: _isToggled,
                                    onToggle: (value) async {
                                      final SharedPreferences _prefs = await SharedPreferences.getInstance();
                                      String path = 'craftsman/unmake_visible';
                                      if(value) {
                                        path = 'craftsman/make_visible';
                                      }

                                      try {

                                        final res = await jobsAndServicesClient.post(path);

                                        if(res.statusCode ==200) {
                                          setState(() {
                                            _isToggled = value;
                                            _prefs.setBool("userIsVisible", value);
                                          });
                                        }
                                      } catch (e) {
                                        if (e is DioError && e.response?.statusCode == 403) {
                                          reloadApp(context);
                                        } else {
                                          showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
                                        }
                                      }
                                    },
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
                )
            );
          } else {
            return const AnimationControllerClass();
          }
        }
    );
  }

}