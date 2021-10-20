import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

part 'reset_password_page.g.dart';


@JsonSerializable()
class FormData {
  String? phoneNumber;
  String? email;
  String? password;
  String? reEnterPassword;
  String? tempPassword;

  FormData({
    this.phoneNumber,
    this.email,
    this.password,
    this.reEnterPassword,
    this.tempPassword,
  });

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}


class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  _ResetPasswordPage createState() => _ResetPasswordPage();
}

class _ResetPasswordPage extends State<ResetPasswordPage> {

  FormData formData = FormData();
  var _countryPhoneCode = "+995";

  bool _validateByPhone = true;
  bool _validateByEmail = false;

  final _textTempPassword = TextEditingController();
  bool _validateTempPassword = false;

  final _textEmail = TextEditingController();
  bool _validateEmail = false;

  final _textPasswordStrengthOrPasswordIsEmpty = TextEditingController();
  bool _validateThatPasswordContainsAllCharactersOrPasswordIsEmpty = true;
  String _passwordErrorText = "";

  final _textReEnterPassword = TextEditingController();
  bool _validateReEnterPassword = true;
  String _reEnterPasswordErrorText = "";

  bool _obscureTextPassword = true;
  bool _obscureTextTempPassword = true;

  bool _showReEnterPassword = false;


  @override
  Widget build(BuildContext context) {

    final Map<int, String> _passwordErrorTextMap = {
      0: AppLocalizations.of(context)!.enter_password,
      1: AppLocalizations.of(context)!.password_is_weak,
    };

    final Map<int, String> _reEnterPasswordErrorTextMap = {
      0: AppLocalizations.of(context)!.confirm_password,
      1: AppLocalizations.of(context)!.passwords_does_not_match,
    };

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
                        child: MaterialButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.blueGrey)
                          ),
                          child: Text(AppLocalizations.of(context)!.phone),
                          onPressed: () {
                            setState(() {
                              _validateByPhone = true;
                              _validateByEmail = false;
                            });
                          },
                        )
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        child: MaterialButton(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.0),
                              side: const BorderSide(color: Colors.blueGrey)
                          ),
                          child: Text(AppLocalizations.of(context)!.email),
                          onPressed: () {
                            setState(() {
                              _validateByPhone = false;
                              _validateByEmail = true;
                            });
                          },
                        )
                      ),
                    ],
                  ),
                  Visibility(
                    visible: _validateByPhone,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: CountryCodePicker(
                            onChanged: (value) {
                              formData.phoneNumber = formData.phoneNumber!.substring(_countryPhoneCode.length);
                              _countryPhoneCode = value.dialCode!;
                              formData.phoneNumber = _countryPhoneCode + formData.phoneNumber!;
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
                              formData.phoneNumber = value;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _validateByEmail,
                    child: TextField(
                        controller: _textEmail,
                        decoration: InputDecoration(
                          filled: true,
                          labelText: AppLocalizations.of(context)!.email,
                          errorText: _validateEmail ? AppLocalizations.of(context)!.email_is_invalid : null,
                        ),
                        onChanged: (value) {
                          if(value.isNotEmpty && !EmailValidator.validate(value)) {
                            setState(() {
                              _validateEmail = true;
                            });
                          } else {
                            formData.email = value;
                            setState(() {
                              _validateEmail = false;
                            });
                          }
                        }
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: TextField(
                          controller: _textTempPassword,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.code,
                            errorText: _validateTempPassword ? AppLocalizations.of(context)!.enter_code : null,
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
                            formData.email ??= "";
                            if (_validateByPhone && formData.phoneNumber!.isEmpty) {
                              showAlertDialog.call(context, AppLocalizations.of(context)!.enter_mobile_number, AppLocalizations.of(context)!.notification);
                              return;
                            }

                            if (_validateByEmail && formData.email!.isEmpty) {
                              //TODO : თარგმნე
                              showAlertDialog.call(context, "შეიყვანეთ ელ. ფოსტა", AppLocalizations.of(context)!.notification);
                              return;
                            }

                            setState(() {
                              _validateTempPassword = true;
                              _textTempPassword.text = "";
                            });
                            if (btnState == ButtonState.Idle) {
                              startTimer(20);
                              if (_validateByPhone) {
                                await generateTempCodeForResetPasswordByPhone(context, _countryPhoneCode, formData.phoneNumber);
                              } else if (_validateByEmail) {
                                await generateTempCodeForResetPasswordByEmail(context, formData.email);
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
                          onPressed: () => showAlertDialog(context, AppLocalizations.of(context)!.password_strength_criteria, ""),
                        ),
                      ),
                      const SizedBox(width: 5,),
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _textPasswordStrengthOrPasswordIsEmpty,
                          decoration: InputDecoration(
                            filled: true,
                            labelText: AppLocalizations.of(context)!.new_password,
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
                                labelText: AppLocalizations.of(context)!.confirm_password,
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
                      child: Text(AppLocalizations.of(context)!.update),
                      onPressed: () async {

                        var data =formData;
                        data.phoneNumber ??= "";
                        data.email ??= "";
                        data.password ??= "";
                        data.reEnterPassword ??= "";
                        data.tempPassword ??= "";

                        if(data.email!.isNotEmpty && !EmailValidator.validate(data.email!)) {
                          return;
                        }

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

                        var _result = "";

                        if (_validateByPhone) {
                          _result = await resetPasswordByPhone(context, _countryPhoneCode, formData.phoneNumber, formData.password, formData.tempPassword);
                        } else if (_validateByEmail) {
                          _result = await resetPasswordByEmail(context, formData.email, formData.password, formData.tempPassword);
                        }

                        _success() {
                          Navigator.pop(context,false);
                          showAlertDialog.call(context, "პაროლი წარმატებით განახლდა", "");
                        }

                        switch (_result) {
                          case "temporary_code_empty" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_empty, ""); break;
                          case "phone_number_empty" : showAlertDialog.call(context, AppLocalizations.of(context)!.phone_number_empty, ""); break;
                          case "email_empty" : showAlertDialog.call(context, AppLocalizations.of(context)!.email_empty, ""); break;
                          case "temporary_code_not_exists" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_not_exists, ""); break;
                          case "temporary_code_incorrect" : showAlertDialog.call(context, AppLocalizations.of(context)!.temporary_code_incorrect, ""); break;
                          case "success" : _success() ; break;
                          default : showAlertDialog.call(context, AppLocalizations.of(context)!.an_error_occurred, "");
                        }

                      }
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

