import 'package:flutter/material.dart';
import 'package:hall_e_mobile/screen/bar.screen.dart';
import 'package:hall_e_mobile/screen/match.screen.dart';
import 'package:hall_e_mobile/screen/profile.screen.dart';

import '../components/my-app-bar.component.dart';
import '../styles/font-colors.dart';

class HomeWrapperScreen extends StatefulWidget {
  @override
  _HomeWrapperScreenState createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends State<HomeWrapperScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  Widget _buildNavButton(String iconPath, String label, int index,
      double screenWidth, bool isTablet) {
    final isSelected = _selectedIndex == index;

    final double iconSize = isTablet ? screenWidth * 0.04 : screenWidth * 0.07;
    final double textSize =
        isTablet ? screenWidth * 0.025 : screenWidth * 0.035;
    final double capsulePaddingH = isTablet ? 12 : 16;
    final double capsulePaddingV = isTablet ? 8 : 6;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        width: screenWidth * 0.25,
        alignment: Alignment.center,
        child: isSelected
            ? Container(
                padding: EdgeInsets.symmetric(
                    horizontal: capsulePaddingH, vertical: capsulePaddingV),
                decoration: BoxDecoration(
                  color: secondaryColor, // capsule color
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/$iconPath',
                      color: primaryColor,
                      width: iconSize,
                      height: iconSize,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: textSize,
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/$iconPath',
                    color: Colors.grey,
                    width: iconSize,
                    height: iconSize,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: textSize,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final double navBarHeight = isTablet ? 90 : 85;

    return Scaffold(
      appBar: MyAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  const double maxContentWidth = 600;

                  return PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                isWide ? maxContentWidth : double.infinity,
                          ),
                          child: MatchScreen(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                isWide ? maxContentWidth : double.infinity,
                          ),
                          child: BarScreen(),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                isWide ? maxContentWidth : double.infinity,
                          ),
                          child: ProfileScreen(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                color: primaryColor,
                height: navBarHeight,
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton('calendar_unselected.png', "Matches", 0,
                        screenWidth, isTablet),
                    _buildNavButton(
                        'beer_unselected.png', "Bar", 1, screenWidth, isTablet),
                    _buildNavButton('user_unselected.png', "Profile", 2,
                        screenWidth, isTablet),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
