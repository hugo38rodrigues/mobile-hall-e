import 'package:flutter/material.dart';
import 'home.screen.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Connexion")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simule une connexion et redirige vers HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Text("Se connecter"),
        ),
      ),
    );
  }
}
