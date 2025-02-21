import 'package:flutter/material.dart';
import '../screen/home.screen.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Simule une connexion et redirige vers HomeScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Text("S'inscrire"),
        ),
      ),
    );
  }
}
