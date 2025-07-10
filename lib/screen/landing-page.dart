import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/location-services.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';

import 'home-wrapper.screen.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  bool locationDenied = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      String role = ref.watch(accountProvider).role;
      if (role != 'bar') {
        location();
      }
    });
  }

  void location() async {
    final locationService = LocationService(ref: ref);
    final status = await locationService.requestAndFetchLocation();
    switch (status) {
      case LocationStatus.success:
        break;
      case LocationStatus.serviceDisabled:
        _showLocationDisabledDialog();
        break;
      case LocationStatus.permissionDenied:
      case LocationStatus.permissionDeniedForever:
        showPermissionDeniedMessage();
        break;
      case LocationStatus.error:
        _showErrorSnackbar();
        break;
    }
  }

  void _showLocationDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Localisation désactivée"),
        content: const Text(
            "Veuillez activer la localisation pour afficher votre position sur la carte."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Erreur"),
        content: const Text("Une erreur est survenue veuillez réessayer"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void showPermissionDeniedMessage() {
    setState(() {
      locationDenied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Permission de localisation refusée"),
        backgroundColor: Colors.red,
      ),
    );
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
