import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'home-wrapper.screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          // Simule une connexion et redirige vers HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeWrapperScreen()),
          )
        },
        child: Center(
          child: Text(
            "Toucher pour voir vos matches",
            style: TextStyle(color: secondaryColor),
          ),
        ),
      ),
    );
  }
}
