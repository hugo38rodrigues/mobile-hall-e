import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

class FavoritesComponent extends ConsumerStatefulWidget {
  final User profile;
  FavoritesComponent({super.key, required this.profile});

  @override
  FavoritesComponentState createState() => FavoritesComponentState();
}

class FavoritesComponentState extends ConsumerState<FavoritesComponent> {

  Future<void> toggleFavorite(
      {required String type, String? name, String? id}) async {

    // ✅ Appelle l'API correspondante
    try {
      switch (type) {
        case 'gameName':
        case 'leagueName':
          await deleteFavorite(type, name: name);
          break;
        case 'barName':
        case 'teams':
          await deleteFavorite(type, id: id);
          break;
      }
    } catch (_) {}
  }

  Future<void> deleteFavorite(String type, {String? name, String? id}) async =>
      await _sendFavoriteRequest(type, 'DELETE', name: name, id: id);

  Future<void> _sendFavoriteRequest(String type, String method,
      {String? name, String? id}) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    final path = '$apiUrl/favoris';
    final data = {
      "type": type,
      "idUser": widget.profile.id,
      if (name != null) "data": name,
      if (id != null) "data": id,
    };

    try {
      Response response = await (dio.delete(path,
              data: data, options: _options(widget.profile.token)))
          .timeout(Duration(seconds: 10), onTimeout: () {
        throw DioException(
            requestOptions: RequestOptions(path: path),
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout');
      });

      if (response.statusCode == 200) {
        ref
            .read(accountProvider.notifier)
            .updateAccount({'favorites': response.data});
      }
    } catch (e) {
      if (e is DioException && mounted) await handleError(e, context);
    }
  }

  Options _options(String token) => Options(headers: {
        "Content-Type": "application/json",
        'Authorization': 'Bearer $token',
      });

  @override
  Widget build(BuildContext context) {
    bool isClient = widget.profile.role == 'client';
    List<String> gamesFavorites = widget.profile.favorites != null
        ? widget.profile.favorites!.gameName
        : [];
    List<String> leaguesFavorites = widget.profile.favorites != null
        ? widget.profile.favorites!.leagueName
        : [];
    List<Team> teamsFavorites =
        widget.profile.favorites != null ? widget.profile.favorites!.teams : [];
    List<Map<String, dynamic>> barsNameFavorites =
        widget.profile.favorites != null
            ? widget.profile.favorites!.barName
            : [];

    bool hasEmptyTeamsFavoris = teamsFavorites.isEmpty;
    bool hasEmptyLeaguesFavoris = leaguesFavorites.isEmpty;
    bool hasEmptyGamesFavoris = gamesFavorites.isEmpty;
    bool hasEmptyBarNameFavoris = barsNameFavorites.isEmpty;

    bool hasNotFavorites =
        hasEmptyTeamsFavoris && hasEmptyGamesFavoris && hasEmptyLeaguesFavoris;

    return Card(
      color: primaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
          side: BorderSide(color: secondaryColor)),
      borderOnForeground: true,
      child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Vos favoris',
                    style: TextStyle(color: secondaryColor, fontSize: 20),
                  ),
                ],
              ),
              SizedBox(height: 10),
              !hasNotFavorites
                  ? Column(
                      children: [
                        Column(
                          children: [
                            Text(
                              'Jeux',
                              style: TextStyle(
                                  color: secondaryColor, fontSize: 16),
                            ),
                            !hasEmptyGamesFavoris
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: gamesFavorites.map((game) {
                                      return Chip(
                                        backgroundColor: primaryColor,
                                        label: Text(game),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: secondaryColor,
                                        ),
                                        onDeleted: () => toggleFavorite(
                                            name: game, type: 'gameName'),
                                        padding: EdgeInsets.only(left: 8),
                                      );
                                    }).toList(),
                                  )
                                : Text(
                                    "Vous n'avez pas ajouté de jeu en favoris",
                                    style: TextStyle(color: secondaryColor),
                                  ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Text(
                              'Compétitons',
                              style: TextStyle(
                                  color: secondaryColor, fontSize: 16),
                            ),
                            !hasEmptyLeaguesFavoris
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: leaguesFavorites.map((league) {
                                      return Chip(
                                        backgroundColor: primaryColor,
                                        label: Text(league),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: secondaryColor,
                                        ),
                                        onDeleted: () => toggleFavorite(
                                            name: league, type: 'leagueName'),
                                        padding: EdgeInsets.only(left: 8),
                                      );
                                    }).toList(),
                                  )
                                : Text(
                                    "Vous n'avez pas ajouté de compétitons en favoris",
                                    style: TextStyle(color: secondaryColor),
                                  ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: [
                            Text(
                              'Équipes',
                              style: TextStyle(
                                  color: secondaryColor, fontSize: 16),
                            ),
                            !hasEmptyTeamsFavoris
                                ? Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: teamsFavorites.map((team) {
                                      return Chip(
                                        backgroundColor: primaryColor,
                                        label: Text(team.name),
                                        deleteIcon: Icon(
                                          Icons.close,
                                          size: 18,
                                          color: secondaryColor,
                                        ),
                                        onDeleted: () => {
                                          print(team.toJson()),
                                          toggleFavorite(
                                            type: 'teams', id: team.id)},
                                        padding: EdgeInsets.only(left: 8),
                                      );
                                    }).toList(),
                                  )
                                : Text(
                                    "Vous n'avez pas ajouté d'équipe en favoris",
                                    style: TextStyle(color: secondaryColor),
                                  ),
                          ],
                        ),
                        if (isClient)
                          Column(
                            children: [
                              SizedBox(height: 10),
                              Text(
                                'Bars',
                                style: TextStyle(
                                    color: secondaryColor, fontSize: 16),
                              ),
                              !hasEmptyBarNameFavoris
                                  ? Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: barsNameFavorites.map((bar) {
                                        return Chip(
                                          backgroundColor: primaryColor,
                                          label: Text(bar["name"]),
                                          deleteIcon: Icon(
                                            Icons.close,
                                            size: 18,
                                            color: secondaryColor,
                                          ),
                                          onDeleted: () =>
                                              toggleFavorite(type: 'barName', id: bar['_id']),
                                          padding: EdgeInsets.only(left: 8),
                                        );
                                      }).toList(),
                                    )
                                  : Text(
                                      "Vous n'avez pas ajouté de bar en favoris",
                                      style: TextStyle(color: secondaryColor),
                                    ),
                            ],
                          ),
                      ],
                    )
                  : Text(
                      "Vous n'avez pas encore ajouté de favoris",
                      style: TextStyle(color: secondaryColor),
                    )
            ],
          )),
    );
  }
}
