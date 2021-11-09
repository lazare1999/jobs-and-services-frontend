import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:jobs_and_services/app/commons/info/info.dart';

import '../main_menu.dart';
import 'mini_menu/mini_menu.dart';

class CraftsmanMainPage extends StatefulWidget {

  const CraftsmanMainPage({Key? key}) : super(key: key);

  @override
  _CraftsmanMainPage createState() => _CraftsmanMainPage();
}

class _CraftsmanMainPage extends State<CraftsmanMainPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  Future<bool> _onBackPressed() {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MainMenu()),
    ).then((x) => x ?? false);
  }

  @override
  Widget build(BuildContext context) {
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
            body: const Center(
                child: SizedBox(
                  width: 200.0,
                  height: 200.0,
                  child: Text("აქ იქნება მოხელეზე ინფო \n"
                      "ვინ არი, რა შეუძლია, რა კვალიფიკაცია აქ, რა რეიტინგი..."),
                )
            ),
        )
    );
  }

}