import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:jobs_and_services/app/authenticate/register/register_page.dart';
import 'package:jobs_and_services/utils/authenticate_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'login_page.g.dart';


@JsonSerializable()
class FormData {
  String? phoneNumber;
  String? password;
  String? tempPassword;

  FormData({
    this.phoneNumber,
    this.password,
    this.tempPassword,
  });

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {

  FormData formData = FormData();
  var _countryPhoneCode = "+995";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.login),
      ),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: CountryCodePicker(
                          onChanged: (value) {
                            _countryPhoneCode = value.dialCode!;
                          },
                          initialSelection: 'GE',
                          showCountryOnly: false,
                          showOnlyCountryWhenClosed: false,
                          alignLeft: false,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.phone,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            formData.phoneNumber = _countryPhoneCode + value;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.code,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            formData.tempPassword = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: ArgonTimerButton(
                          height: 50,
                          width: MediaQuery.of(context).size.width * 0.30,
                          minWidth: MediaQuery.of(context).size.width * 0.20,
                          highlightColor: Colors.transparent,
                          highlightElevation: 0,
                          roundLoadingShape: false,
                          onTap: (startTimer, btnState) async {
                            formData.phoneNumber ??= "";
                            if (formData.phoneNumber!.isEmpty) {
                              showAlertDialog.call(context, AppLocalizations.of(context)!.enter_mobile_number, AppLocalizations.of(context)!.notification);
                            } else {
                              if (btnState == ButtonState.Idle) {
                                startTimer(20);
                                await generateTemporaryCodeForLogin(context, formData.phoneNumber);
                              }
                            }
                          },
                          child: Text(
                            AppLocalizations.of(context)!.get_code,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15
                            ),
                          ),
                          loader: (timeLeft) {
                            return Text(
                              AppLocalizations.of(context)!.please_wait + " | $timeLeft",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15
                              ),
                            );
                          },
                          borderRadius: 18.0,
                          color: Colors.blueGrey,
                          elevation: 0,
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      //TODO : თარგმნე
                      labelText: "პაროლი",
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (value) {
                      formData.password = value;
                    },
                  ),
                  MaterialButton(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.black)
                    ),
                    child: Text(AppLocalizations.of(context)!.login),
                    onPressed: () async {
                      var data =formData;

                      data.phoneNumber ??= "";
                      data.password ??= "";
                      data.tempPassword ??= "";

                      if (data.phoneNumber!.isEmpty || data.password!.isEmpty || _countryPhoneCode.isEmpty) {
                        showAlertDialog.call(context, AppLocalizations.of(context)!.enter_data, AppLocalizations.of(context)!.notification);
                      } else if (data.phoneNumber!.isNotEmpty &&
                          data.password!.isNotEmpty &&
                          data.tempPassword!.isNotEmpty
                      ) {
                        var result = await authenticate(context, formData.phoneNumber, formData.password, formData.tempPassword);

                        if (result) {
                          //TODO : მოსაფიქრებელი შემდეგ რაიქნება
                          showAlertDialog.call(context, "tesli vaar", "");
                        } else {
                          showAlertDialog.call(context, AppLocalizations.of(context)!.enter_the_correct_data, "");
                        }
                      }
                    }
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "",
                      children: [
                        TextSpan(
                          //TODO : თარგმნე
                          text: "არ ხართ დარეგისტრირებული?",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent,),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const RegisterPage()),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ].expand(
                      (widget) => [
                    widget,
                    const SizedBox(
                      height: 25,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

