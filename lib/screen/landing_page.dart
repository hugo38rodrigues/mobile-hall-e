import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/services/location_service.services.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';

import 'home_wrapper.screen.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _blinkController;

  // Logo : fondu + léger zoom
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    // Contrôleur de l'entrée en cascade
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Logo : de 0 à 0.4 du timeline
    _logoOpacity = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );

    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // Contrôleur du clignotement (boucle)
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: 1.0,
    );

    // Lance l'entrée, puis démarre le clignotement à la fin
    _entryController.forward().then((_) {
      _blinkController.repeat(reverse: true);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AccountNotifier provider = ref.read(accountProvider.notifier);
      LocationService location = LocationService();
      location.getLocation(context, provider);
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.shortestSide >= 600;

    return Scaffold(
      backgroundColor: background,
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
              horizontal: isTablet ? screenSize.width * 0.2 : 20.0,
              vertical: isTablet ? screenSize.height * 0.1 : 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Logo
                FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/logo_hall_e.png',
                            width: 320,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: isTablet ? 40 : 28),
                          FadeTransition(
                            opacity: _blinkController,
                            child: Text(
                              "Appuyer pour voir les matchs",
                              style: TextStyle(
                                color: textWhite,
                                fontSize: isTablet ? 32 : 23,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
