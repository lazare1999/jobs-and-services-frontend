import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../globals.dart';
import 'authenticate/authenticate_utils.dart';
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
        //TODO : თარგმნე
        content: const Text("ნამდვილად გინდა გასვლა?"),
        actions: <Widget>[
          OutlinedButton(
            child: Text(AppLocalizations.of(context)!.yes),
            onPressed: () async {
              await logout(context);
            }, //exit the app
          ),
          OutlinedButton(
            //TODO : თარგმნე
            child: const Text("ara"),
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
                          children: const <Widget>[
                            Icon(Icons.facebook_outlined, color: Colors.blue),
                            Flexible(
                                child: Padding(
                                  padding: EdgeInsets.only(left: 8.0),
                                  //TODO : თარგმნე
                                  child: Text("ჩვენი გვერდი"),
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
          ],
        ),
      )
    );
  }

}