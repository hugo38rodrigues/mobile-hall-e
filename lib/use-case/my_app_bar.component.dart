import 'package:flutter/material.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    // Y a-t-il un écran précédent vers lequel revenir ?
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: background,
      automaticallyImplyLeading: false, // on gère la flèche nous-mêmes
      flexibleSpace: SafeArea(
        child: Row(
          children: [
            // Flèche retour (seulement s'il y a une page précédente)
            if (canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back, color: textGold),
                onPressed: () => Navigator.of(context).pop(),
              )
            else
              const SizedBox(
                  width: 35), // garde l'alignement quand pas de flèche

            // Logo
            ClipOval(
              child: Container(
                width: 84,
                height: 72,
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/logo_hall_e.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Titre centré dans le reste
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: const Text(
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
              ),
            ),

            const SizedBox(width: 45),
          ],
        ),
      ),
    );
  }
}
