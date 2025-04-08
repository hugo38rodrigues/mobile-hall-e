import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'home-wrapper.screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool locationDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  // Récupérer la position actuelle de l'utilisateur
  Future<void> _fetchUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Mettre à jour l'état global avec Riverpod
       ref.read(accountProvider.notifier).updateAccount({
        'userLocation': Location(
          isActivated: true,
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      });
    } catch (e) {
      debugPrint("Erreur localisation : $e");
    }
  }

  // Afficher un message si la localisation est désactivée
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

  // Demander la permission et récupérer la position
  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDisabledDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showPermissionDeniedMessage();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showPermissionDeniedMessage();
      return;
    }
    _fetchUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // Simule une connexion et redirige vers HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeWrapperScreen()),
          );
        },
        child: Center(
          child: Text(
            "Toucher pour voir vos matches",
            style: TextStyle(color: secondaryColor),
          ),
        ),
      ),
    );
  }
}
