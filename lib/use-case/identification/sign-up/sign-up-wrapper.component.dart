import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/use-case/identification/sign-up/credentiels-sign-up.component.dart';
import 'package:hall_e_mobile/use-case/identification/sign-up/informations-sign-up.component.dart';

class SignUp extends StatefulWidget {
  final Function() getStateSession;
  SignUp({required this.getStateSession});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late UserCredentiels newCredentiels =
      UserCredentiels(email: '', password: '', role: '');
  int state = 0;

  void getCredentiels(credentiels) {
    setState(() {
      newCredentiels = credentiels;
    });
  }

  void manageState(newState) {
    setState(() {
      state = newState;
    });
  }

  Widget signUpStep(int choice) {
    switch (choice) {
      case 1:
        return InformationsSignUp(
            goBack: manageState,
            credentiels: newCredentiels,
            getStateSession: widget.getStateSession);
      default:
        return CredentielsSignUp(
            getCredentiels: getCredentiels,
            goNext: manageState,
            profile: newCredentiels);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        signUpStep(state),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 14, color: textGold),
            children: [
              const TextSpan(text: "Vous avez déjà un compte ? "),
              TextSpan(
                text: "Connexion",
                style: const TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                    color: textGold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.getStateSession();
                  },
              ),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }
}
