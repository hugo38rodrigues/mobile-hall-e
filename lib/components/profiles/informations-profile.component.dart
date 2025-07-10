import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';

class InformationsProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(accountProvider);
    print(profile.informations.toJson());

    return Card(
      elevation: 4,
      shape: Border(),
      borderOnForeground: true,
      child: Column(children: [
        Informations()
        Favorites()
        Text('Email: ${profile.email}'),
        Text('Role: ${profile.role}'),
        // Vérification du type pour accéder aux informations client
        (profile.role == 'client'
            ? Column(
                children: [
                  Text(
                      'Nom: ${(profile.informations as ClientInformationsModel).firstName}'),
                  Text(
                      'Prénom: ${(profile.informations as ClientInformationsModel).lastName}'),
                  Text(
                      'Game Favorites: ${profile.favorites.gameName.join(', ')}'),
                  Text(
                      'League Favorites: ${profile.favorites.leagueName.join(', ')}'),
                  // Affichage des équipes si nécessaire
                  Text(
                      'Teams: ${profile.favorites.teams.map((team) => team.name).join(', ')}'),
                ],
              )
            : // Vérification du type pour accéder aux informations bar
            Column(
                children: [
                  Text(
                      'Nom du bar: ${(profile.informations as BarInformationsModel).name}'),
                  Text(
                      'Adresse: ${(profile.informations as BarInformationsModel).address}'),
                  Text(
                      'Description: ${(profile.informations as BarInformationsModel).description}'),
                  Text(
                      'Image: ${(profile.informations as BarInformationsModel).pictures}'),
                ],
              )),
      ]),
    );
  }
}
