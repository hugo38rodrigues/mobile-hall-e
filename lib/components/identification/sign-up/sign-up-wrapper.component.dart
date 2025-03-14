import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/identification/sign-up/credentiels-sign-up.component.dart';
import 'package:hall_e_mobile/components/identification/sign-up/informations-sign-up.component.dart';
import 'package:hall_e_mobile/models/user-credentiels.model.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class SignUp extends StatefulWidget {
  final Function() getStateProfile;
  SignUp({required this.getStateProfile});
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late UserCredentiels newCredentiels = UserCredentiels(email: '', password: '', role: '');
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
          goBack: manageState, credentiels: newCredentiels, getStateProfile: widget.getStateProfile);
      default:
        return CredentielsSignUp(
            getCredentiels: getCredentiels,
            goNext: manageState,
            profile: newCredentiels);
    }
  }

  @override
  Widget build(BuildContext context) {
    print(newCredentiels);
    return Column(
      children: [
        signUpStep(state),
        Text.rich(
          TextSpan(
            text: "Vous avez déjà un compte ?",
            style: TextStyle(fontSize: 14, color: secondaryColor),
            children: [
              TextSpan(
                text: " Se connecter",
                style: TextStyle(
                  color: secondaryColor,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    widget.getStateProfile();
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
