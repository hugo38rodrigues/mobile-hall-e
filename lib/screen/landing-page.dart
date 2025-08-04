import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/services/location-service.services.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

import 'home-wrapper.screen.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccountNotifier provider = ref.watch(accountProvider.notifier);
      LocationService location = LocationService(); 
      location.getLocation(context, provider);
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeWrapperScreen()),
          );
        },
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? screenSize.width * 0.2 : 16.0,
              vertical: isTablet ? screenSize.height * 0.1 : 16.0,
            ),
            child: Text(
              "Toucher pour voir vos matches",
              style: TextStyle(
                color: secondaryColor,
                fontSize: isTablet ? 32 : 20,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
