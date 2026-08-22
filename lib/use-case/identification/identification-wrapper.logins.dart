import 'package:flutter/material.dart';
import 'package:hall_e_mobile/use-case/identification/connexion.logins.dart';
import 'package:hall_e_mobile/use-case/identification/sign-up/sign-up-wrapper.component.dart';


class IdendtificationWrapper extends StatefulWidget {
  @override
  _IdendtificationWrapperState createState() => _IdendtificationWrapperState();
}

class _IdendtificationWrapperState extends State<IdendtificationWrapper> {
  bool _isConnectionUser = true;

  void getStateSession() {
    setState(() {
      _isConnectionUser = !_isConnectionUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _isConnectionUser
            ? Connexion(getStateSession: getStateSession)
            : SignUp(getStateSession: getStateSession));
  }
}
