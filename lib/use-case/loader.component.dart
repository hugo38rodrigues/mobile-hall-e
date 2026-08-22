import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class CustomLoader extends StatefulWidget {
  final String text;
  CustomLoader({required this.text});

  @override
  _CustomLoaderState createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(textGold), // Couleur marron
            backgroundColor: textWhite, // Couleur beige clair
            strokeWidth: 4, // Épaisseur du cercle
          ),
          SizedBox(height: 16), // Espacement
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textGold,
            ),
          ),
        ],
      ),
    );
  }
}
