import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class FavoritesComponent extends ConsumerStatefulWidget {
  final User profile;
  const FavoritesComponent({super.key, required this.profile});

  @override
  ConsumerState<FavoritesComponent> createState() => FavoritesComponentState();
}

class FavoritesComponentState extends ConsumerState<FavoritesComponent> {
  Future<void> _deleteFavorite(String type, String id) async {
    final profile = ref.read(accountProvider);
    final currentFav = profile.favorites ?? Favorites.empty();

    setState(() {});
    final updatedFav = switch (type) {
      'game' => currentFav.copyWith(
          games: currentFav.games.where((g) => g.id != id).toList()),
      'league' => currentFav.copyWith(
          leagues: currentFav.leagues.where((l) => l.id != id).toList()),
      'team' => currentFav.copyWith(
          teams: currentFav.teams.where((t) => t.id != id).toList()),
      'barName' => currentFav.copyWith(
          barName: currentFav.barName.where((b) => b['id'] != id).toList()),
      _ => currentFav,
    };

    ref
        .read(accountProvider.notifier)
        .updateAccount({'favorites': updatedFav.toJson()});

    try {
      await request('${dotenv.env['API_URL']}/favoris', 'DELETE',
              data: {'type': type, 'userId': profile.id, 'id': id},
              token: profile.token)
          .timeout(const Duration(seconds: 10));
    } on DioException catch (e) {
      ref
          .read(accountProvider.notifier)
          .updateAccount({'favorites': currentFav.toJson()});
      if (mounted) await handleError(e, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(accountProvider);
    final fav = profile.favorites ?? Favorites.empty();
    final isClient = profile.role == 'client';

    final hasNoFavorites =
        fav.games.isEmpty && fav.leagues.isEmpty && fav.teams.isEmpty;

    return Card(
      color: background,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: textGold),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Vos favoris',
                style: TextStyle(color: textGold, fontSize: 20)),
            const SizedBox(height: 10),
            if (hasNoFavorites)
              const Text("Vous n'avez pas encore ajouté de favoris",
                  style: TextStyle(color: textGold))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                      'Jeux',
                      fav.games.isEmpty,
                      fav.games.map(
                        (g) => _buildChip(
                            g.name, () => _deleteFavorite('game', g.id)),
                      )),
                  const SizedBox(height: 10),
                  _buildSection(
                      'Compétitions',
                      fav.leagues.isEmpty,
                      fav.leagues.map(
                        (l) => _buildChip(
                            l.name, () => _deleteFavorite('league', l.id)),
                      )),
                  const SizedBox(height: 10),
                  _buildSection(
                      'Équipes',
                      fav.teams.isEmpty,
                      fav.teams.map(
                        (t) => _buildChip(
                            t.name, () => _deleteFavorite('team', t.id)),
                      )),
                  if (isClient) ...[
                    const SizedBox(height: 10),
                    _buildSection(
                        'Bars',
                        fav.barName.isEmpty,
                        fav.barName.map(
                          (b) => _buildChip(b['name'],
                              () => _deleteFavorite('barName', b['id'])),
                        )),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, bool isEmpty, Iterable<Widget> chips) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: textGold, fontSize: 16)),
        if (isEmpty)
          Text("Vous n'avez pas ajouté de $title en favoris",
              style: const TextStyle(color: textGold))
        else
          Wrap(spacing: 8, runSpacing: 8, children: chips.toList()),
      ],
    );
  }

  Widget _buildChip(String label, VoidCallback onDelete) {
    return Chip(
      backgroundColor: background,
      label: Text(label, style: const TextStyle(color: textGold)),
      deleteIcon: const Icon(Icons.close, size: 18, color: textGold),
      onDeleted: onDelete,
      padding: const EdgeInsets.only(left: 8),
    );
  }
}
