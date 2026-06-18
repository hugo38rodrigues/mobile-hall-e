import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/services/location_service.services.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, User>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<User> {
  AccountNotifier()
      : super(
          GuestUser.fromLocation(
            Location(latitude: 0.0, longitude: 0.0, isActivated: false),
          ),
        );

  void setAccount(User account) {
    state = account;
    _saveToPreferences(account);
  }

  void updateAccount(Map<String, dynamic> accountUpdate) {
    final currentJson = state.toJson();
    final mergedMap = {
      ...currentJson,
      ...accountUpdate,
    };
    state = User.fromMap(mergedMap);
    _saveToPreferences(state);
  }

  Future<void> _saveToPreferences(User account) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(account.toJson()));
  }

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('user');
    if (raw != null) {
      state = User.fromMap(json.decode(raw));
    } else {
      state = GuestUser.fromLocation(null);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');

    final locationService = LocationService();
    final result = await locationService.requestAndFetchLocation();

    Location? location;
    if (result is Map) {
      final status = result['status'] as LocationStatus;
      if (status == LocationStatus.success) {
        location = Location(
          latitude: result['latitude'] as double,
          longitude: result['longitude'] as double,
          isActivated: true,
        );
      }
    }

    state = GuestUser.fromLocation(location);
    _saveToPreferences(state);
  }
}
