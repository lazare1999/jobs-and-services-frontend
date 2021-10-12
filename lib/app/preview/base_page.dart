import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jobs_and_services/app/authenticate/login/login_page.dart';
import 'package:jobs_and_services/app/commons/animation_controller_class.dart';
import 'package:jobs_and_services/app/commons/language_change_list_view.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../main.dart';

class BasePage extends StatefulWidget {
  const BasePage({Key? key}) : super(key: key);

  @override
  _BasePage createState() => _BasePage();
}

class _BasePage extends State<BasePage> {

  @override
  void initState() {
    super.initState();
    navigateToLastPage(context);
    _updateLocale();
  }

  Future<void> _updateLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.get("locale") !=null) {
      MyApp.of(context)!.setLocale(Locale.fromSubtags(languageCode: prefs.get("locale") as String));
    }
  }

  Future<bool> basePageLoad() async {


    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> myTabs = <Tab>[
      Tab(text: AppLocalizations.of(context)!.about_us,),
      Tab(text: AppLocalizations.of(context)!.contact),
    ];

    return FutureBuilder<bool>(
        future: basePageLoad(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {

            return DefaultTabController(
              length: myTabs.length,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(kToolbarHeight),
                  child: SafeArea(
                    child: Column(
                      children: <Widget>[
                        Expanded(child: Container()),
                        TabBar(
                          labelColor: Colors.blueGrey,
                          tabs: myTabs,
                        ),
                      ],
                    ),
                  ),
                ),
                body: const TabBarView(
                  children: [
                    Center(
                      child: Text("ჩვენს შესახებ"),
                    ),
                    Center(
                      child: Text("კონტაქტი"),
                    ),
                  ]
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
                        child: const Icon(Icons.language),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            builder: (BuildContext context) {
                              return languageChangeListView(context);
                            },
                          );
                        },
                      ),
                      FloatingActionButton(
                        child: const Icon(Icons.login_outlined),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        },
                      ),
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