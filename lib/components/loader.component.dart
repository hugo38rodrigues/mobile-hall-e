import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.brown), // Couleur marron
            backgroundColor: Colors.brown.shade200, // Couleur beige clair
            strokeWidth: 4, // Épaisseur du cercle
          ),
          SizedBox(height: 16), // Espacement
          Text(
            "Chargement des matchs...",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
        ],
      ),
    );
  }
}
