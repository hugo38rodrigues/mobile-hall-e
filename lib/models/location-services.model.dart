import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

enum LocationStatus {
  success,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  error,
}

class LocationService {
  final WidgetRef ref;

  LocationService({required this.ref});
  

  Future<LocationStatus> requestAndFetchLocation() async {
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
      
      String role = ref.watch(accountProvider).role;
      
      if (role != 'bar') {
        ref.read(accountProvider.notifier).updateAccount({
          'userLocation': Location(
            isActivated: true,
            latitude: position.latitude,
            longitude: position.longitude,
          ),
        });
      }

      return LocationStatus.success;
    } catch (e) {
      return LocationStatus.error;
    }
  }
}
