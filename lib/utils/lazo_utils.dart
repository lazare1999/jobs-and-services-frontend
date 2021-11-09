library my_prj.lazo_utils;

import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' show asin, cos, pow, sqrt;

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isInteger(num? value) =>
    value is int || value == value!.roundToDouble();

showAlertDialog(BuildContext context, String? alertText, String title) {

  bool showTitle = true;
  if(title.isEmpty) {
    showTitle = false;
  }

  AlertDialog alert;
  if(showTitle) {
    alert = AlertDialog(
      title: Text(
        title,
        textAlign: TextAlign.center,
      ),
      content: Text(
        alertText!,
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: Colors.black)
      ),
    );
  } else {
    alert = AlertDialog(
      content: Text(
        alertText!,
        textAlign: TextAlign.center,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: Colors.black)
      ),
    );
  }
  // set up the AlertDialog


  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Card generateCard(child, marginVertical) {
  return Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.symmetric(
      vertical: marginVertical ?? 10,
      horizontal: 25.0,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    color: Colors.white,
    child: Padding(
        padding: const EdgeInsets.only(
            left: 25.0, right: 25.0, top: 2.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
                child: child
            ),
          ],
        )),
  );
}

double coordinateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos as double Function(num?);
  var a = 0.5 -
      c((lat2 - lat1) * p) / 2 +
      c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}

double roundDouble(double value, int places){
  double mod = pow(10.0, places) as double;
  return ((value * mod).round().toDouble() / mod);
}

//თარიღისა და დროის ფანჯრები
Future<DateTime?> selectDate(BuildContext context, helpText) async {
  DateTime? date = await showDatePicker(
      helpText: helpText,
      cancelText: AppLocalizations.of(context)!.do_not_specify,
      confirmText: AppLocalizations.of(context)!.indicate,
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900, 8),
      lastDate: DateTime(2101)
  );
  if (date ==null) {
    return null;
  }

  TimeOfDay? time = await showTimePicker(
    context: context,
    cancelText: AppLocalizations.of(context)!.do_not_specify,
    confirmText: AppLocalizations.of(context)!.indicate,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },);

  return DateTime(date.year, date.month, date.day, time!.hour, time.minute);
}

bool validatePassword(String value) {
  String  pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regExp = RegExp(pattern);
  return regExp.hasMatch(value);
}

void navigateToLastPage(context) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastRoute = prefs.getString('last_route');
  if(lastRoute ==null) {
    return;
  }
  if (lastRoute.isNotEmpty && lastRoute != '/') {
    Navigator.of(context).pushNamed(lastRoute);
  }
}

//TODO : ნოტიფიკაცია
// Future<void> showNotification() async {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   const AndroidNotificationDetails androidPlatformChannelSpecifics =
//   AndroidNotificationDetails(
//       'your channel id', 'your channel name', 'your channel description',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false);
//
//   const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//       0, 'plain title', 'plain body', platformChannelSpecifics,
//       payload: 'item x');
// }
