import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/services/location-service.services.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/user-factory.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider Riverpod pour l'utilisateur connecté
final accountProvider = StateNotifierProvider<AccountNotifier, User>((ref) {
  return AccountNotifier();
});

/// Notifier qui gère l'état utilisateur (login, logout, mise à jour, etc.)
class AccountNotifier extends StateNotifier<User> {
  AccountNotifier()
      : super(
          UserFactory.createGuest(
            location:
                Location(latitude: 0.0, longitude: 0.0, isActivated: false),
          ),
        );

  void setAccount(User account) {
    state = account;
    _saveToPreferences(account);
  }

  void updateAccount(Map<String, dynamic> accountUpdate) {
    // Fusionne la map avec l'état existant, puis recrée l'utilisateur via la factory
    final updatedMap = {
      'id': accountUpdate['id'] ?? state.id,
      'token': accountUpdate['token'] ?? state.token,
      'email': accountUpdate['email'] ?? state.email,
      'role': accountUpdate['role'] ?? state.role,
      'favorites': accountUpdate['favorites'] ?? state.favorites?.toJson(),
      'informations':
          accountUpdate['informations'] ?? state.informations.toJson(),
      'programmedMatches': accountUpdate['programations'] ??
          state.programations?.map((p) => p.toJson()).toList(),
      'userLocation':
          accountUpdate['userLocation'] ?? state.userLocation.toJson(),
    };

    state = UserFactory.createFromMap(updatedMap);
    _saveToPreferences(state);
  }

  Future<void> _saveToPreferences(User account) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(account.toJson()));
  }

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserFactory.createGuest(); // ou UserFactory.createGuest()
    prefs.setString('user', json.encode(state));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    final locationService = LocationService();
    final result = await locationService.requestAndFetchLocation();

    if (result is Map) {
      final status = result['status'] as LocationStatus;
      if (status == LocationStatus.success) {
        final latitude = result['latitude'] as double;
        final longitude = result['longitude'] as double;
        User guest = UserFactory.createGuest(
            location: Location(
                latitude: latitude, longitude: longitude, isActivated: true));
        _saveToPreferences(guest);
        state = guest;
      }
    }
  }
}
