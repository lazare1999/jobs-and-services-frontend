import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'contactus.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPage createState() => _ContactPage();
}

class _ContactPage extends State<ContactPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.contact),
      ),
      backgroundColor: Colors.white70,
      body: ContactUs(
        cardColor: Colors.white,
        email: dotenv.env['EMAIL']!,
        companyName: "",
        companyColor: Colors.black,
        phoneNumber: dotenv.env['PHONE_NUMBER']!,
        facebookHandle: dotenv.env['FACEBOOK']!,
        message: dotenv.env['MESSENGER']!,
      ),
    );
  }

}