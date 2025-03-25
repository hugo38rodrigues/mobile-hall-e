import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';


class FavoritesProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    bool favoritesClient = profile.informations is ClientInformationsModel;
    print(favoritesClient);
    return Column(children: [
      Text('Vos favoris'),
      Column(
        children: [
          Card(
            child: Column(children: [
              Text('Jeux'),
              
            ]),
          )
        ],
      )
    ]);
  }
}
