import 'package:flutter/material.dart';
import 'package:hall_e_mobile/components/logins/connexion.logins.dart';
import 'package:hall_e_mobile/components/logins/sign-in.logins.dart';

class LoginsWrapper extends StatefulWidget {
  @override
  _LoginsWrapperState createState() => _LoginsWrapperState();
}

class _LoginsWrapperState extends State<LoginsWrapper> {
  bool _isConnexion = true;

  void getStateProfile() {
    setState(() {
      _isConnexion = !_isConnexion;  
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: _isConnexion
            ? Connexion(getStateProfile: getStateProfile)
            : SignIn(getStateProfile: getStateProfile));
  }
}
