import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Centre le titre sur toutes les plateformes.
      // Sans ça, Android l'aligne à gauche (défaut Material) alors qu'iOS le centre.
      centerTitle: true,
      iconTheme: const IconThemeData(color: textGold),
      title: const FittedBox(
        // Réduit le titre automatiquement s'il manque de place,
        // au lieu de le tronquer (utile avec fontSize: 40 sur écran étroit).
        fit: BoxFit.scaleDown,
        child: Text(
          "Hall Esport",
          maxLines: 1,
          style: TextStyle(
            color: textGold,
            fontFamily: 'Lexend',
            fontWeight: FontWeight.w700,
            fontSize: 40,
          ),
        ),
      ),
      backgroundColor: background,
    );
  }
}
