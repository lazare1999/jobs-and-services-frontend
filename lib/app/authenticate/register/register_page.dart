import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jobs_and_services/app/authenticate/privacy_and_policy/terms_of_use.dart';
import 'package:jobs_and_services/app/authenticate/authenticate_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';

part 'register_page.g.dart';


@JsonSerializable()
class FormData {
  String? firstName;
  String? lastName;
  String? nickname;
  String? phoneNumber;
  String? password;
  String? tempPassword;

  FormData({
    this.firstName,
    this.lastName,
    this.nickname,
    this.phoneNumber,
    this.password,
    this.tempPassword,
  });

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}


class RegisterPage extends StatefulWidget {
  final http.Client? httpClient;

  const RegisterPage({Key? key,
    this.httpClient,
  }) : super(key: key);

  @override
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {

  FormData formData = FormData();
  var _countryPhoneCode = "+995";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.register),
      ),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.first_name,
                      ),
                      onChanged: (value) {
                        formData.firstName = value;
                      }
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.last_name,
                      ),
                      onChanged: (value) {
                        formData.lastName = value;
                      }
                  ),
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
                    child: Text(AppLocalizations.of(context)!.register),
                    onPressed: () async {

                      var data =formData;

                      data.phoneNumber ??= "";
                      data.firstName ??= "";
                      data.lastName ??= "";
                      data.nickname ??= "";
                      data.password ??= "";

                      if (data.phoneNumber!.isEmpty || data.password!.isEmpty) {
                        showAlertDialog.call(context, AppLocalizations.of(context)!.enter_data, AppLocalizations.of(context)!.notification);
                      } else if (data.phoneNumber!.isNotEmpty && data.password!.isNotEmpty) {
                        var result = await register(context, formData.phoneNumber, formData.firstName, formData.lastName, formData.nickname, formData.password);

                        _success() {
                          Navigator.pop(context,false);
                          //TODO : თარგმნე
                          showAlertDialog.call(context, "თქვენ წარმატებით გაიარეთ რეგისტრაცია", "");
                        }

                        switch (result) {
                          case "temporary_code_empty" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_empty, ""); break;
                          case "phone_number_empty" : showAlertDialog.call(context, AppLocalizations.of(context)!.phone_number_empty, ""); break;
                          case "temporary_code_not_exists" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_not_exists, ""); break;
                          case "user_already_defined" : showAlertDialog.call(context, AppLocalizations.of(context)!.user_already_defined, ""); break;
                          case "temporary_code_incorrect" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_incorrect, ""); break;
                          case "success" : _success() ; break;
                          default : showAlertDialog.call(context, AppLocalizations.of(context)!.an_error_occurred, "");
                        }



                      }

                    },
                  ),
                  const TermsOfUse(),
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

