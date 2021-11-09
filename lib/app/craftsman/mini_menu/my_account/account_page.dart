import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:jobs_and_services/app/commons/animation_controller_class.dart';
import 'package:jobs_and_services/custom/custom_icons_icons.dart';
import 'package:jobs_and_services/globals.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';


class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPage createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  var _rating = '0.0';

  //სერვერიდან მოაქვს user-ის შეფასება
  Future<bool> updateRatingFromServerAccountPage() async {

    try {

      final res = await jobsAndServicesClient.post('craftsman/get_rating');

      if(res.statusCode ==200) {
        if (res.data == null) {
          return false;
        }
        _rating = res.data.toString();
      }
    } catch (e) {
      if (e is DioError && e.response?.statusCode == 403) {
        reloadApp(context);
      } else {
        showAlertDialog(context, e.toString(), AppLocalizations.of(context)!.the_connection_to_the_server_was_lost);
      }
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: updateRatingFromServerAccountPage(),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              appBar: AppBar(
                title: Text(AppLocalizations.of(context)!.my_account),
              ),
              backgroundColor: Colors.white70,
              floatingActionButton: FloatingActionButton(
                heroTag: "btn1",
                child: const Icon(CustomIcons.fbMessenger),
                onPressed: () {
                  launch("http://" + dotenv.env['MESSENGER']!);
                },
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[

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
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('_rating', _rating));
  }

}