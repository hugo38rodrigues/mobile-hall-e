import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/programmationMatch.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:shared_preferences/shared_preferences.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, User>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<User> {
  AccountNotifier() : super(_guestUser());

  static User _guestUser() {
    return User(
        id: '',
        email: '',
        role: 'guest',
        informations: ClientInformationsModel(firstName: '', lastName: ''),
        favorites:
            Favorites(gameName: [], leagueName: [], teams: [], barName: []),
        programmations: [],
        userLocation:
            Location(isActivated: false, latitude: null, longitude: null));
  }

  void setAccount(User account) {
    state = account;
    _saveToPreferences(account);
  }

  void updateAccount(Map<String, dynamic> accountUpdate) {
    state = User(
        id: accountUpdate['id'] ?? state.id,
        email: accountUpdate['email'] ?? state.email,
        role: accountUpdate['role'] ?? state.role,
        favorites: accountUpdate.containsKey('favorites')
            ? Favorites.fromMap(accountUpdate['favorites'], state.favorites)
            : state.favorites,
        informations: accountUpdate.containsKey('informations')
            ? Informations.fromJson(
                accountUpdate['informations'], accountUpdate['role'])
            : state.informations,
        programmations: accountUpdate.containsKey('programmations') &&
                accountUpdate['programmations'] is List
            ? List<ProgrammationMatch>.from(
                (accountUpdate['programmations'] as List)
                    .map((e) => ProgrammationMatch.fromJson(e)))
            : state.programmations,
        userLocation: accountUpdate['userLocation'] ?? state.userLocation);
    _saveToPreferences(state);
  }

  Future<void> _saveToPreferences(User account) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user', json.encode(account.toJson()));
  }

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userMap = json.decode(userString);
      state = User.fromMap(userMap);
    }
  }

  Future<void> clearAccount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    state = _guestUser();
  }
}
