import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/user.models.dart';
import 'package:shared_preferences/shared_preferences.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, User>((ref) {
  return AccountNotifier();
});

class AccountNotifier extends StateNotifier<User> {
  AccountNotifier()
      : super(User(
            id: '', email: '', role: 'invité', token: '', informations: {}));

  void setAccount(User account) {
    state = account;
    _saveToPreferences(account);
  }

  void updateAccount(Map<String, String> accountUpdate) {
    state = User(
      id: accountUpdate['id'] ?? state.id,
      email: accountUpdate['email'] ?? state.email,
      role: accountUpdate['role'] ?? state.role,
      token: accountUpdate['token'] ?? state.token,
      informations: accountUpdate['informations'] != null
          ? accountUpdate['informations'] as Map<String, dynamic>
          : state.informations,
    );
    _saveToPreferences(state);
  }

  Future<void> _saveToPreferences(User account) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'user', json.encode(account.toMap())); // Enregistrer en JSON
  }

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString('user');

    if (userString != null) {
      final userMap = json.decode(userString);
      state = User.fromMap(userMap); // Charger depuis SharedPreferences
    }
  }

  // Supprimer les données de l'utilisateur lors de la déconnexion
  Future<void> clearAccount() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    state =
        User(id: '', email: '', role: 'invité', token: '', informations: {});
  }
}
