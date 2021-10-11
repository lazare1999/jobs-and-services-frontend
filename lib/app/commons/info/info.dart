import 'package:flutter/material.dart';
class Info extends StatelessWidget {

  final Widget? safeAreaChild;
  final String? title;

  const Info({Key? key, required this.safeAreaChild, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //TODO : თარგმნე
        title: Text(title != null ? title! : "ინფო"),
        leading: Container()
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: safeAreaChild!,
      ),
    );

  }

}