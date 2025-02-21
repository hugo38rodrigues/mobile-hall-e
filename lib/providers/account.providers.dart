import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account.providers.g.dart'; // Généré automatiquement

@riverpod
class Account extends _$Account {
  @override
  Map<String, dynamic> build() => {'role': 'invité'}; // Valeur initiale

  void setAccount(Map<String, dynamic> account) {
    state = account; // Mise à jour de l'état
  }

  void setUpdateAccount(Map<String, dynamic> accountUpdate) {
      state = {
        ...state, // Conserve l'état actuel
        ...accountUpdate, // Ajoute ou remplace les valeurs avec celles de accountUpdate
      };
  }
}
