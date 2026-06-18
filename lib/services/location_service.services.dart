import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationService {
  LocationService();

  Future<Object> requestAndFetchLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationStatus.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.permissionDenied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.permissionDeniedForever;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return {
        'status': LocationStatus.success,
        'latitude': position.latitude,
        'longitude': position.longitude
      };
    } catch (e) {
      return LocationStatus.error;
    }
  }

  void getLocation(context, AccountNotifier provider) async {
    final result = await requestAndFetchLocation();

    if (result is Map) {
      final status = result['status'] as LocationStatus;
      if (status == LocationStatus.success) {
        final latitude = result['latitude'] as double;
        final longitude = result['longitude'] as double;

        provider.updateAccount({
          'userLocation': {
            'latitude': latitude,
            'longitude': longitude,
            'isActivated': true,
          },
        });
      }
    } else if (result is LocationStatus) {
      switch (result) {
        case LocationStatus.serviceDisabled:
          _showLocationDisabledDialog(context);
          break;
        case LocationStatus.permissionDenied:
        case LocationStatus.permissionDeniedForever:
          showPermissionDeniedMessage(context);
          break;
        case LocationStatus.error:
          _showErrorSnackbar(context);
          break;
        default:
          break;
      }
    }
  }

  void _showLocationDisabledDialog(context) {
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

  void _showErrorSnackbar(context) {
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

  void showPermissionDeniedMessage(context) {
    showErrorSnackBar(context, "Permission de localisation refusée" );
  }

  
}
