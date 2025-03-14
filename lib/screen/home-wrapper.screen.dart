import 'package:flutter/material.dart';
import 'package:hall_e_mobile/screen/bar.screen.dart';
import 'package:hall_e_mobile/screen/match.screen.dart';
import 'package:hall_e_mobile/screen/profile.screen.dart';

import '../components/my-app-bar.component.dart';
import '../styles/font-colors.dart';

class HomeWrapperScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomeWrapperScreenState createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends State<HomeWrapperScreen> {
  int _selectedIndex = 0;

  // 📍 Positions dynamiques des onglets
  final List<double> _positions = [20, 145, 270];
  final PageController _pageController = PageController();

  /// 🔵 Bouton dans la capsule sélectionnée
  Widget _buildNavItem(int index) {
    List<String> iconPaths = [
      'assets/icons/calendar_selected.png',
      'assets/icons/beer_selected.png',
      'assets/icons/user_selected.png'
    ];
    List<String> labels = ["Matches", "Bars", "Profile"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(iconPaths[index],
            color: primaryColor,
            width: 28,
            height: 28), // Utilisation de l'icône PNG
        SizedBox(width: 8),
        Text(labels[index],
            style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold)), // 🎨 Texte en primaryColor
      ],
    );
  }

  /// ⚪️ Icônes grises quand non sélectionnées
  Widget _buildNavButton(String iconPath, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: 100,
        height: 50,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/icons/$iconPath',
          color: _selectedIndex == index
              ? Colors.transparent
              : Colors.grey, // Icône avec opacité
          width: 28,
          height: 28,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: PageView(
        controller: _pageController, // Contrôle la navigation entre pages
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          // Les différentes pages
          Center(child: MatchScreen()),
          Center(child: BarScreen()),
          Center(child: ProfileScreen())
        ],
      ),
      bottomNavigationBar: Container(
        color: primaryColor,
        height: 70,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Stack(
          children: [
            // 🎯 Capsule animée avec primaryColor
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: _positions[_selectedIndex],
              top: 5,
              child: IntrinsicWidth(
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: secondaryColor, // 🎨 Couleur de fond de la capsule
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor,
                        blurRadius: 10,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Center(
                    child: _buildNavItem(
                        _selectedIndex), // Récupère l'élément sélectionné
                  ),
                ),
              ),
            ),

            // 🏡 Barre de navigation avec icônes et labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavButton('calendar_unselected.png', "Matches", 0),
                _buildNavButton('beer_unselected.png', "Bar", 1),
                _buildNavButton('user_unselected.png', "Profile", 2),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
