import 'dart:collection';

import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
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
  String? email;
  String? address;
  String? phoneNumber;
  String? password;
  String? reEnterPassword;
  String? tempPassword;

  FormData({
    this.firstName,
    this.lastName,
    this.nickname,
    this.email,
    this.address,
    this.phoneNumber,
    this.password,
    this.reEnterPassword,
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

  final _textFirstName = TextEditingController();
  bool _validateFirstName = true;

  final _textLastName = TextEditingController();
  bool _validateLastName = true;

  final _textEmail = TextEditingController();
  bool _validateEmail = false;

  final _textAddress = TextEditingController();
  bool _validateAddress = true;

  final _textPhone = TextEditingController();
  bool _validatePhone = true;

  final _textTempPassword = TextEditingController();
  bool _validateTempPassword = false;

  final _textPasswordStrengthOrPasswordIsEmpty = TextEditingController();
  bool _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty = true;
  String _passwordErrorText = "";
  //TODO : თარგმნე
  final Map<int, String> _passwordErrorTextMap = {
    0: "შეიყვანეთ პაროლი",
    1: "პაროლი სუსტია",
  };

  final _textReEnterPassword = TextEditingController();
  bool _validateReEnterPassword = true;
  String _reEnterPasswordErrorText = "";
  //TODO : თარგმნე
  final Map<int, String> _reEnterPasswordErrorTextMap = {
    0: "დაადასტურეთ პაროლი",
    1: "პაროლები არ ემთხვევა",
  };

  bool _showReEnterPassword = false;

  bool _obscureTextPassword = true;
  bool _obscureTextTempPassword = true;

  //TODO : თარგმნე
  final Map<int, String> _userIdentifyChoice = {
    0: "პირადობის ნომერი",
    1: "პასპორტის ნომერი"
  };

  int userChoice = -1;

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

                  TextField(
                      controller: _textFirstName,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.first_name,
                        //TODO : თარგმნე
                        errorText: _validateFirstName ? "შეიყვანეთ სახელი" : null,
                      ),
                      onChanged: (value) {
                        formData.firstName = value;
                        if (value.isNotEmpty) {
                          setState(() {
                            _validateFirstName = false;
                          });
                        }
                      }
                  ),
                  TextField(
                      controller: _textLastName,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.last_name,
                        //TODO : თარგმნე
                        errorText: _validateLastName ? "შეიყვანეთ გვარი" : null,
                      ),
                      onChanged: (value) {
                        formData.lastName = value;
                        if (value.isNotEmpty) {
                          setState(() {
                            _validateLastName = false;
                          });
                        }
                      }
                  ),
                  TextFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        //TODO : თარგმნე
                        labelText: "ზედმეტსახელი",
                      ),
                      onChanged: (value) {
                        formData.nickname = value;
                      }
                  ),
                  TextField(
                      controller: _textEmail,
                      decoration: InputDecoration(
                        filled: true,
                        //TODO : თარგმნე
                        labelText: "email",
                        errorText: _validateEmail ? "მეილი არასწორია" : null,
                      ),
                      onChanged: (value) {
                        if(value.isNotEmpty && !EmailValidator.validate(value)) {
                          setState(() {
                            _validateEmail = true;
                          });
                        } else {
                          setState(() {
                            _validateEmail = false;
                          });
                        }
                      }
                  ),
                  TextField(
                      controller: _textAddress,
                      decoration: InputDecoration(
                        filled: true,
                        //TODO : თარგმნე
                        labelText: "მისამართი",
                        errorText: _validateAddress ? "შეიყვანეთ მისამართი" : null,
                      ),
                      onChanged: (value) {
                        formData.address = value;
                        if (value.isNotEmpty) {
                          setState(() {
                            _validateAddress = false;
                          });
                        }
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
                        child: TextField(
                          controller: _textPhone,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.phone,
                            //TODO : თარგმნე
                            errorText: _validatePhone ? "შეიყვანეთ ტელეფონი" : null,
                          ),
                          onChanged: (value) {
                            formData.phoneNumber = value;
                            if (value.isNotEmpty) {
                              setState(() {
                                _validatePhone = false;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textTempPassword,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.code,
                            //TODO : თარგმნე
                            errorText: _validateTempPassword ? "შეიყვანეთ კოდი" : null,
                          ),
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            formData.tempPassword = value;
                            if (value.isNotEmpty) {
                              setState(() {
                                _validateTempPassword = false;
                              });
                            }
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
                              setState(() {
                                _validateTempPassword = true;
                              });
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: MaterialButton(
                          child: const Icon(Icons.info_outline_rounded),
                          //TODO : თარგმნე
                          onPressed: () => showAlertDialog(context, "პაროლი უნდა შეიცავდეს სავალდებულო პარამეტრებს", ""),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _textPasswordStrengthOrPasswordIsEmpty,
                          decoration: InputDecoration(
                            filled: true,
                            //TODO : თარგმნე
                            labelText: "პაროლი",
                            errorText: _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty ? _passwordErrorText.isEmpty ? _passwordErrorTextMap[0]! : _passwordErrorText : null,
                          ),
                          obscureText: _obscureTextPassword,
                          enableSuggestions: false,
                          autocorrect: false,
                          onChanged: (value) {
                            formData.password = value;
                            if (value.isNotEmpty) {

                              if(!validatePassword(value)) {
                                setState(() {
                                  _passwordErrorText = _passwordErrorTextMap[1]!;
                                  _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty = true;
                                });
                                return;
                              } else {
                                setState(() {
                                  _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty = false;
                                  _showReEnterPassword = true;
                                });
                              }

                            } else {
                              setState(() {
                                _passwordErrorText = _passwordErrorTextMap[0]!;
                                _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty = true;
                                _showReEnterPassword = false;
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: MaterialButton(
                          child: const Icon(Icons.remove_red_eye_outlined),
                          onPressed: () {

                            setState(() {
                              _obscureTextPassword = !_obscureTextPassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                      visible: _showReEnterPassword,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: 6,
                            child:TextField(
                              controller: _textReEnterPassword,
                              decoration: InputDecoration(
                                filled: true,
                                //TODO : თარგმნე
                                labelText: "დაადასტურეთ პაროლი",
                                errorText: _validateReEnterPassword ? _reEnterPasswordErrorText.isEmpty ? _reEnterPasswordErrorTextMap[0]! : _reEnterPasswordErrorText : null,
                              ),
                              obscureText: _obscureTextTempPassword,
                              enableSuggestions: false,
                              autocorrect: false,
                              onChanged: (value) {
                                formData.reEnterPassword = value;
                                if (value.isNotEmpty && formData.reEnterPassword != formData.password) {
                                  setState(() {
                                    _reEnterPasswordErrorText = _reEnterPasswordErrorTextMap[1]!;
                                    _validateReEnterPassword = true;
                                  });
                                } else if (formData.reEnterPassword == formData.password) {
                                  setState(() {
                                    _validateReEnterPassword = false;
                                  });
                                } else {
                                  setState(() {
                                    _reEnterPasswordErrorText = _reEnterPasswordErrorTextMap[0]!;
                                  });
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: MaterialButton(
                              child: const Icon(Icons.remove_red_eye_outlined),
                              onPressed: () {

                                setState(() {
                                  _obscureTextTempPassword = !_obscureTextTempPassword;
                                });
                              },
                            ),
                          ),
                        ],
                      )
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
                      data.email ??= "";
                      data.address ??= "";
                      data.nickname ??= "";
                      data.password ??= "";
                      data.reEnterPassword ??= "";
                      data.tempPassword ??= "";

                      setState(() {
                        _textFirstName.text.isEmpty ? _validateFirstName = true : _validateFirstName = false;
                      });
                      if (data.firstName!.isEmpty) {
                        return;
                      }

                      setState(() {
                        _textLastName.text.isEmpty ? _validateLastName = true : _validateLastName = false;
                      });
                      if (data.lastName!.isEmpty) {
                        return;
                      }

                      if(data.email!.isNotEmpty && !EmailValidator.validate(data.email!)) {
                        return;
                      }

                      setState(() {
                        _textAddress.text.isEmpty ? _validateAddress = true : _validateAddress = false;
                      });
                      if (data.address!.isEmpty) {
                        return;
                      }

                      setState(() {
                        _textPhone.text.isEmpty ? _validatePhone = true : _validatePhone = false;
                      });
                      if (data.phoneNumber!.isEmpty) {
                        return;
                      }

                      setState(() {
                        _textTempPassword.text.isEmpty ? _validateTempPassword = true : _validateTempPassword = false;
                      });
                      if (data.tempPassword!.isEmpty) {
                        return;
                      }


                      if (data.password!.isEmpty) {
                        return;
                      }

                      if (data.reEnterPassword!.isEmpty) {
                        return;
                      }

                      if (formData.reEnterPassword != formData.password) {
                        return;
                      }

                      data.phoneNumber = _countryPhoneCode + data.phoneNumber!;

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

