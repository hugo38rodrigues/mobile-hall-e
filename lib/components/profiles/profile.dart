import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/components/profiles/informations-profile.component.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class Profile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);

    print('information ${profile.informations["lastName"]}');
    print('role ${profile.role}');
    return Center(
        child: Column(children: [
      InformationsProfile(),
      ElevatedButton(
        onPressed: () async {
          // Déconnecter l'utilisateur
          await ref.read(accountProvider.notifier).clearAccount();
        },
        child: Text('Se déconnecter'),
      ),
    ]));
  }
}
