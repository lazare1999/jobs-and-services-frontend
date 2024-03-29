import 'package:animations/animations.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:jobs_and_services/app/authenticate/register/privacy_and_policy/policy_dialog.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          text: AppLocalizations.of(context)!.terms_and_conditions_warning,
          style: Theme.of(context).textTheme.bodyText1,
          children: [
            TextSpan(
              text: AppLocalizations.of(context)!.terms_and_conditions,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent,),
              recognizer: TapGestureRecognizer()..onTap = () {
                  showModal(
                    context: context,
                    configuration: const FadeScaleTransitionConfiguration(),
                    builder: (context) {
                      return PolicyDialog(
                        mdFileName: AppLocalizations.of(context)!.terms_and_conditions_file,
                      );
                    },
                  );
                },
            )
          ],
        ),
      ),
    );
  }
}