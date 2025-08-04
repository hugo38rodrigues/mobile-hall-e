import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/identification/connexion.logins.dart';
import 'package:hall_e_mobile/components/identification/sign-up/sign-up-wrapper.component.dart';

class IdendtificationWrapper extends StatefulWidget {
  @override
  _IdendtificationWrapperState createState() => _IdendtificationWrapperState();
}

class _IdendtificationWrapperState extends State<IdendtificationWrapper> {
  bool _IsConnectionUser = true;

  void getStateProfile() {
    setState(() {
      _IsConnectionUser = !_IsConnectionUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _IsConnectionUser
            ? Connexion(getStateProfile: getStateProfile)
            : SignUp(getStateProfile: getStateProfile));
  }
}
