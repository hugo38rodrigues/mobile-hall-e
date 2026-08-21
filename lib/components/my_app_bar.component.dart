import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      iconTheme: const IconThemeData(color: textGold),
      title: Text(
        "Hall Esport",
        style: TextStyle(
          color: textGold,
          fontFamily: 'Lexend',
          fontWeight: FontWeight.w700,
          fontSize: 40,
        ),
      ),
      backgroundColor: background,
      
    );
  }
}
