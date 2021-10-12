import 'package:argon_buttons_flutter/argon_buttons_flutter.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:jobs_and_services/app/authenticate/register/privacy_and_policy/terms_of_use.dart';
import 'package:jobs_and_services/app/authenticate/utils/authenticate_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/utils/lazo_utils.dart';

part 'register_page.g.dart';


@JsonSerializable()
class FormData {
  String? personalNumber;
  String? passportNumber;
  String? firstName;
  String? lastName;
  String? nickname;
  String? email;
  String? address;
  String? phoneNumber;
  String? countryPhoneCode;
  String? password;
  String? reEnterPassword;
  String? tempPassword;

  FormData({
    this.personalNumber,
    this.passportNumber,
    this.firstName,
    this.lastName,
    this.nickname,
    this.email,
    this.address,
    this.phoneNumber,
    this.countryPhoneCode = "+995",
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

  final _textReEnterPassword = TextEditingController();
  bool _validateReEnterPassword = true;
  String _reEnterPasswordErrorText = "";

  bool _showReEnterPassword = false;

  bool _obscureTextPassword = true;
  bool _obscureTextTempPassword = true;

  int _userChoice = -1;

  final _textUserIdentifyChoice = TextEditingController();
  bool _validateUserIdentifyChoice = true;

  bool _userIdentityApproved = false;

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

    final Map<int, String> _userIdentifyChoice = {
      0: AppLocalizations.of(context)!.personal_number,
      1: AppLocalizations.of(context)!.passport_number,
    };

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
                  DropdownButton(
                      hint: Text(AppLocalizations.of(context)!.identifiable),
                      value: _userChoice !=-1 ? _userChoice: null,
                      items: {
                        0: AppLocalizations.of(context)!.personal_number,
                        1: AppLocalizations.of(context)!.passport_number,
                      }.map((value, description) {
                        return MapEntry(
                            value,
                            DropdownMenuItem<int>(
                              value: value,
                              child: Text(description),
                            ));
                      }).values.toList(),
                      onChanged: (dynamic newValue) {
                        setState(() {
                          _userChoice = newValue;
                          _textUserIdentifyChoice.text = "";
                          _userIdentityApproved = false;
                        });
                      }
                  ),
                  Visibility(
                      visible: _userChoice !=-1,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child:TextField(
                              controller: _textUserIdentifyChoice,
                              decoration: InputDecoration(
                                filled: true,
                                labelText: _userIdentifyChoice[_userChoice],
                                errorText: _validateUserIdentifyChoice ? AppLocalizations.of(context)!.enter_data : null,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (_userChoice ==0) {
                                    formData.personalNumber =value;
                                  } else if (_userChoice ==1) {
                                    formData.passportNumber =value;
                                  }
                                  setState(() {
                                    _validateUserIdentifyChoice = false;
                                  });
                                } else {
                                  setState(() {
                                    _validateUserIdentifyChoice = true;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 5,),
                          Expanded(
                            flex: 2,
                            child: ArgonTimerButton(
                              height: 50,
                              width: MediaQuery.of(context).size.width * 0.30,
                              minWidth: MediaQuery.of(context).size.width * 0.20,
                              highlightColor: Colors.transparent,
                              highlightElevation: 0,
                              roundLoadingShape: false,
                              onTap: (startTimer, btnState) async {
                                if (_userChoice ==0 && formData.personalNumber!.isEmpty) {
                                  setState(() {
                                    _validateUserIdentifyChoice = true;
                                  });
                                } else if (_userChoice ==1 && formData.passportNumber!.isEmpty) {
                                  setState(() {
                                    _validateUserIdentifyChoice = true;
                                  });
                                } else if (btnState == ButtonState.Idle) {
                                  //TODO : გასაკეთებელია პირადი ნომრის და პასპორტის ნომრის გადამოწმება
                                  startTimer(20);
                                  _userIdentityApproved = true;
                                }
                              },
                              child: Text(
                                AppLocalizations.of(context)!.verification,
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
                      )
                  ),
                  TextField(
                      controller: _textFirstName,
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.first_name,
                        errorText: _validateFirstName ? AppLocalizations.of(context)!.enter_first_name : null,
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
                        errorText: _validateLastName ? AppLocalizations.of(context)!.enter_last_name : null,
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
                  TextField(
                      decoration: InputDecoration(
                        filled: true,
                        labelText: AppLocalizations.of(context)!.nickname,
                      ),
                      onChanged: (value) {
                        formData.nickname = value;
                      }
                  ),
                  TextField(
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
                        labelText: AppLocalizations.of(context)!.address,
                        errorText: _validateAddress ? AppLocalizations.of(context)!.enter_address : null,
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
                            formData.countryPhoneCode = value.dialCode!;
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
                            errorText: _validatePhone ? AppLocalizations.of(context)!.enter_phone : null,
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
                            if (formData.phoneNumber!.isEmpty) {
                              showAlertDialog.call(context, AppLocalizations.of(context)!.enter_mobile_number, "");
                            } else {
                              setState(() {
                                _validateTempPassword = true;
                                _textTempPassword.text = "";
                              });
                              if (btnState == ButtonState.Idle) {
                                startTimer(20);
                                await generateTemporaryCodeForRegister(context, formData.phoneNumber!, formData.countryPhoneCode);
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
                            labelText: AppLocalizations.of(context)!.password,
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
                    child: Text(AppLocalizations.of(context)!.register),
                    onPressed: () async {
                      
                      if (!_userIdentityApproved) {
                        return;
                      }

                      var data =formData;
                      data.personalNumber ??= "";
                      data.passportNumber ??= "";
                      data.phoneNumber ??= "";
                      data.firstName ??= "";
                      data.lastName ??= "";
                      data.nickname ??= "";
                      data.email ??= "";
                      data.address ??= "";
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

                      var result = await register(context,
                          formData.phoneNumber,
                          formData.countryPhoneCode,
                          formData.firstName,
                          formData.lastName,
                          formData.nickname,
                          formData.tempPassword,
                          formData.password,
                          formData.email,
                          formData.address,
                          formData.personalNumber,
                          formData.passportNumber
                      );

                      _success() {
                        Navigator.pop(context,false);
                        showAlertDialog.call(context, AppLocalizations.of(context)!.you_have_successfully_registered, "");
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

