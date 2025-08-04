import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/screen/bar.screen.dart';
import 'package:hall_e_mobile/screen/match.screen.dart';
import 'package:hall_e_mobile/screen/profile.screen.dart';

import '../components/my-app-bar.component.dart';
import '../styles/font-colors.dart';

class HomeWrapperScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<HomeWrapperScreen> createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends ConsumerState<HomeWrapperScreen> {
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

    // ✅ tailles adaptées mobile / tablette
    final double iconSize = isTablet ? 28 : 32;
    final double textSize = isTablet ? 14 : 13;
    final double capsulePaddingH = isTablet ? 16 : 12;
    final double capsulePaddingV = isTablet ? 10 : 8;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          alignment: Alignment.center,
          child: isSelected
              ? ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.33),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: capsulePaddingH, vertical: capsulePaddingV),
                    decoration: BoxDecoration(
                      color: secondaryColor,
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
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit
                              .scaleDown, // ✅ réduit le texte si nécessaire
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: textSize,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: textSize,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(accountProvider).role;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final double navBarHeight = isTablet ? 90 : 80;
    final String isNotBar = role != 'bar' ? "Bar" : "Ma programmation";

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
              bottom: false,
              child: Container(
                color: primaryColor,
                height: navBarHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavButton('calendar_unselected.png', "Matches", 0,
                        screenWidth, isTablet),
                    _buildNavButton('beer_unselected.png', isNotBar, 1,
                        screenWidth, isTablet),
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
