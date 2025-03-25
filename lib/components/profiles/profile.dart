import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/profiles/favorites-profile.component.dart';
import 'package:hall_e_mobile/components/profiles/informations-profile.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class Profile extends ConsumerWidget {
  final List<String> items =
      List.generate(1, (index) => "Élément ${index + 1}");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
        child: Column(children: [
      InformationsProfile(),
      FavoritesProfile(),
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
