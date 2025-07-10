import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/my-app-bar.component.dart';
import 'package:hall_e_mobile/components/password/get-email.component.dart';
import 'package:hall_e_mobile/components/password/reset-password.component.dart';
import 'package:hall_e_mobile/components/password/send-code.component.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int state = 0;
  String? idUser = '';
  String newToken = '';

  void getState(int choice) {
    setState(() {
      state = choice;
    });
  }

  void getIdUser(String? id) {
    setState(() {
      idUser = id;
    });
  }

  void getToken(String token) {
    setState(() {
      newToken = token;
    });
  }

  Widget selectedComponent(int choice) {
    switch (choice) {
      case 1:
        return SendCode(getState: getState, idUser: idUser);
      case 2:
        return ResetPassword(idUser: idUser);
      default:
        return GetEmail(getState: getState, getIdUser: getIdUser);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: MyAppBar(),
      body: SingleChildScrollView(
          padding: EdgeInsets.all(50),
          child: Column(
            children: [selectedComponent(state)],
          )),
    );
  }
}
