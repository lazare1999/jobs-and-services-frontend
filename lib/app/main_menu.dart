import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/custom/custom_icons_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../globals.dart';
import 'authenticate/utils/authenticate_utils.dart';
import 'commons/info/info.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  _MainMenu createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<bool> _onBackPressed() async {
    return (await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(' '),
        content: Text(AppLocalizations.of(context)!.really_want_to_log_out),
        actions: <Widget>[
          OutlinedButton(
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () async {
              await logout(context);
            }, //exit the app
          ),
          OutlinedButton(
            child: Text(AppLocalizations.of(context)!.no),
            onPressed: ()=> Navigator.pop(context,false),
          )
        ],
      ),
    )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () { _onBackPressed(); },
              );
            },
          ),
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
        endDrawer: Drawer(
            child: Info(
              safeAreaChild: Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      ListTile(
                        title: Row(
                          children: <Widget>[
                            const Icon(Icons.facebook_outlined, color: Colors.blue),
                            Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(AppLocalizations.of(context)!.our_page),
                                )
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
        ),
        body: CircularMenu(
          alignment: Alignment.center,
          toggleButtonColor: Colors.blueGrey,
          startingAngleInRadian: 20.0,
          endingAngleInRadian: 20.0,
          toggleButtonBoxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 0,
            ),
          ],
          toggleButtonMargin: 50,
          toggleButtonSize: 90,
          items: [
            CircularMenuItem(
                icon: Icons.search_outlined,
                iconSize: 50,
                color: Colors.blueGrey,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                  ),
                ],
                onTap: () async {
                // TODO : მოძებნე მოხელე

                }),
            CircularMenuItem(
                icon: Icons.facebook_outlined,
                iconSize: 50,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                  ),
                ],
                color: Colors.blue,
                //ჩემი სეისგურგი
                onTap: () => launch('https://www.facebook.com/' + facebookHandle)
            ),
            CircularMenuItem(
                icon: CustomIcons.craftsman,
                iconSize: 50,
                color: Colors.blueGrey,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                  ),
                ],
                onTap: () async {
                  // TODO : მოხელე

                }),
            CircularMenuItem(
                icon: CustomIcons.fbMessenger,
                iconSize: 50,
                color: Colors.purple,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white,
                    blurRadius: 0,
                  ),
                ],
                onTap: () {
                  //მესენჯერი
                  launch("http://$messengerUrl");
                }),
          ],
        ),
      )
    );
  }

}