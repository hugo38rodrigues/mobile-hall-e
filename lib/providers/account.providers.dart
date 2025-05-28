import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, User>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<User> {
  AccountNotifier() : super(_guestUser());

  static User _guestUser() {
    return User(id: '', email: '', role: 'guest', token: '');
  }

  void setAccount(User account) {
    state = account;
    _saveToPreferences(account);
  }

  void updateAccount(Map<String, dynamic> accountUpdate) {
    state = User(
        id: accountUpdate['id'] ?? state.id,
        email: accountUpdate['email'] ?? state.email,
        token: accountUpdate['token'] ?? state.token,
        role: accountUpdate['role'] ?? state.role,
        favorites: accountUpdate.containsKey('favorites')
            ? Favorites.fromMap(accountUpdate['favorites'], state.favorites!)
            : state.favorites,
        informations: accountUpdate.containsKey('informations')
            ? Informations.fromJson(accountUpdate['informations'])
            : state.informations,
        programations: accountUpdate.containsKey('programations')
            ? accountUpdate['programation']
                .map((match) => {Match.fromJson(accountUpdate['programation'])})
                .toList()
            : state.programations,
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
