import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/language_change_list_view.dart';
import 'package:jobs_and_services/app/craftsman/mini_menu/profile/profile_page.dart';
import 'package:jobs_and_services/custom/custom_icons_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_us/contact_page.dart';
import 'my_account/account_page.dart';

class MiniMenu extends StatelessWidget {
  const MiniMenu({Key? key}) : super(key: key);


  Widget _createFooterItem({IconData? icon, required String text, GestureTapCallback? onTap}){
    return ListTile(
      title: Row(
        children: <Widget>[
          Icon(icon),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(text),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                _createFooterItem(
                    icon: Icons.account_balance,
                    text: AppLocalizations.of(context)!.my_account,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountPage()),
                      );
                    }),
                _createFooterItem(
                    icon: Icons.account_box,
                    text: AppLocalizations.of(context)!.profile,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    }),
                _createFooterItem(
                    icon: Icons.language,
                    text: AppLocalizations.of(context)!.language,
                    onTap: () {
                      showModalBottomSheet<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return languageChangeListView(context);
                        },
                      );
                    }),
              ],
            ),
            Expanded(child: Container()), // Add this to force the bottom items to the lowest point
            Column(
              children: <Widget>[
                _createFooterItem(
                    icon: CustomIcons.fbMessenger,
                    text: AppLocalizations.of(context)!.message_us,
                    onTap: () {
                      launch("http://" + dotenv.env['MESSENGER']!);
                    }),
                _createFooterItem(
                    icon: Icons.email,
                    text: AppLocalizations.of(context)!.contact,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ContactPage()),
                      );
                    }),
                _createFooterItem(
                    icon: Icons.arrow_back,
                    //TODO : თარგმნე
                    text: "უკან",
                    onTap: () {
                      Navigator.of(context).pushNamed('/main_menu');
                    }),
                _createFooterItem(
                    icon: Icons.logout,
                    text: AppLocalizations.of(context)!.exit,
                    onTap: () async {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text(' '),
                            content: Text(AppLocalizations.of(context)!.are_you_sure_want_to_exit),
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
                          )
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );

  }

}