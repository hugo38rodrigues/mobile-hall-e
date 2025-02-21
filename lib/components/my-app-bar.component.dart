import 'package:flutter/material.dart';
import '../styles/fontColors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(50);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("EZONE", style: TextStyle(color: secondaryColor, fontSize: 40)),
      backgroundColor: primaryColor,
    );
  }
}
