import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/profiles/informations-profile.component.dart';
import 'package:hall_e_mobile/models/location-services.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class Profile extends ConsumerStatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends ConsumerState<Profile> {
  bool locationDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      location();
    });
  }

  void location() async {
    final locationService = LocationService(ref: ref);
    final status = await locationService.requestAndFetchLocation();
    switch (status) {
      case LocationStatus.success:
        // OK
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

  final List<String> items =
      List.generate(1, (index) => "Élément ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(children: [
      InformationsProfile(),
      ElevatedButton(
        onPressed: () async {
          // Déconnecter l'utilisateur
          await ref.read(accountProvider.notifier).clearAccount();
        },
        child: Text('Se déconnecter'),
      )
    ]));
  }
}
