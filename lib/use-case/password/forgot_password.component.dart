import 'package:flutter/material.dart';
import 'package:hall_e_mobile/use-case/my_app_bar.component.dart';
import 'package:hall_e_mobile/use-case/password/get_email.component.dart';
import 'package:hall_e_mobile/use-case/password/reset_password.component.dart';
import 'package:hall_e_mobile/use-case/password/send_code.component.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  int state = 0;
  String? userId = '';
  String newToken = '';

  void getState(int choice) {
    setState(() {
      state = choice;
    });
  }

  void getUserId(String? id,) {
    setState(() {
      userId = id;
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
        return SendCode(getState: getState, userId: userId, token: newToken);
      case 2:
        return ResetPassword(userId: userId, token: newToken);
      default:
        return GetEmail(getState: getState, getIdUser: getUserId, getToken: getToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;
    final double contentWidth = isTablet ? 400 : 320;

    return Scaffold(
      backgroundColor: background,
      appBar: MyAppBar(),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: selectedComponent(state),
            ),
          ),
        ),
      ),
    );
  }
}
