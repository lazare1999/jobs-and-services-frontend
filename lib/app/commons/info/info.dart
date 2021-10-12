import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Info extends StatelessWidget {

  final Widget? safeAreaChild;
  final String? title;

  const Info({Key? key, required this.safeAreaChild, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title != null ? title! : AppLocalizations.of(context)!.info),
        leading: Container()
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: safeAreaChild!,
      ),
    );

  }

}