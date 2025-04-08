import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

import '../loader.component.dart';
import 'match-card.component.dart';

class MatchList extends StatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<dynamic>> filtersList;
  // final List<String> favoriteList;

  MatchList({required this.selectedDate, required this.filtersList});

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  List<Map<String, dynamic>> matches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  Future<void> fetchMatches() async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();

    try {
      Response response = await dio.get('$apiUrl/commun').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/commun'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        // Extraire la liste des matchs depuis "data"
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(response.data["data"]);
        setState(() {
          matches = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        // Appelle la fonction de gestion des erreurs
        handleError(e, context);
      }
    }
  }

  /// Vérifie le nombre de manches (Bo) et retourne un ajustement d'heure
  int filterMatchByBo(Map<String, dynamic> match) {
    String numberOfGames = match["numberOfGame"];

    if (numberOfGames == '1') {
      return 1;
    } else if (numberOfGames == '3') {
      return 3;
    } else {
      return 4;
    }
  }

  /// Vérifie si la date du match correspond à la date sélectionnée
  bool isSameDay(DateTime matchDate, DateTime targetDate) {
    return matchDate.year == targetDate.year &&
        matchDate.month == targetDate.month &&
        matchDate.day == targetDate.day;
  }

  /// Filtre les matchs du jour sélectionné
  bool filterByDate(Map<String, dynamic> match, DateTime targetDate) {
    DateTime matchDate = DateTime.parse(match["date"]);

    // Si c'est aujourd'hui, appliquer filterMatchByBo
    if (isSameDay(matchDate, DateTime.now())) {
      int adjustedHour = matchDate.hour + filterMatchByBo(match);
      if (adjustedHour <= DateTime.now().hour) {
        return false;
      }
    }

    return isSameDay(matchDate, targetDate);
  }

  /// Filtre par équipes sélectionnées (peut en avoir plusieurs)
  bool filterByTeams(Map<String, dynamic> match, List<dynamic>? selectedTeams) {
    if (selectedTeams == null || selectedTeams.isEmpty) return true;

    bool isTeam1Selected = selectedTeams.contains(match['team1']["name"]);
    bool isTeam2Selected = selectedTeams.contains(match['team2']["name"]);
    return isTeam1Selected || isTeam2Selected;
  }

  /// Filtre par jeux sélectionnés (peut en avoir plusieurs)
  bool filterByGames(Map<String, dynamic> match, List<dynamic>? selectedGames) {
    if (selectedGames == null || selectedGames.isEmpty) return true;

    return selectedGames.contains(match["gameName"]);
  }

  /// Filtre par ligues sélectionnées (peut en avoir plusieurs)
  bool filterByLeagues(
      Map<String, dynamic> match, List<dynamic>? selectedLeagues) {
    if (selectedLeagues == null || selectedLeagues.isEmpty) return true;

    return selectedLeagues.contains(match["leagueName"]);
  }

  /// Filtre par favoris (équipes, ligues ou jeux)
  bool filterByFavorites(Map<String, dynamic> match,
      List<String>? favoriteNames, bool isFavoritesActive) {
    // Le filtre favoris ne s'active que si le bouton est sélectionné
    if (!isFavoritesActive) return true;

    bool isFavoriteTeam = favoriteNames?.contains(match['team1']["name"]) ??
        false || favoriteNames!.contains(match["team2"]["name"]);
    bool isFavoriteLeague =
        favoriteNames?.contains(match["leagueName"]) ?? false;
    bool isFavoriteGame = favoriteNames?.contains(match["gameName"]) ?? false;

    return isFavoriteTeam || isFavoriteLeague || isFavoriteGame;
  }

  /// Fonction principale de filtrage
  List<Map<String, dynamic>> filterMatchesByDay(
    DateTime targetDate,
    List<dynamic>? selectedTeams,
    List<dynamic>? selectedGames,
    List<dynamic>? selectedLeagues,
    // List<String>? favoriteNames,
    // {bool isFavoritesActive = false}
  ) {
    return matches.where((match) {
      return filterByDate(match, targetDate) &&
          (filterByTeams(match, selectedTeams) &&
              filterByGames(match, selectedGames) &&
              filterByLeagues(match, selectedLeagues)); //&&
      // filterByFavorites(match, favoriteNames, isFavoritesActive);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    List? selectedGames = widget.filtersList['games'];
    List? selectedLeagues = widget.filtersList['leagues'];
    List? selectedTeams = widget.filtersList['teams'];
    List<Map<String, dynamic>> filteredMatches = filterMatchesByDay(
        widget.selectedDate, selectedTeams, selectedGames, selectedLeagues);

    filteredMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']);
      DateTime dateB = DateTime.parse(b['date']);
      return dateA.compareTo(dateB);
    });

    return isLoading
        ? CustomLoader(
            text: loadMatchText,
          )
        : filteredMatches.isEmpty
            ? Center(
                child: Text(
                  "Aucun match programé pour ce jour".toUpperCase(),
                  selectionColor: secondaryColor,
                ),
              )
            : Column(
                children: filteredMatches.map(
                (match) {
                  return MatchCard(
                    programmed: match['programmed'],
                    leagueName: match['leagueName'],
                    gameName: match['gameName'],
                    idMatch: match['idMatch'],
                    date: match['date'],
                    team1Acronym: match['team1']['acronym'],
                    team1Logo: match['team1']['logoUrl'],
                    team1Name: match['team1']['name'],
                    team2Acronym: match['team2']['acronym'],
                    team2Logo: match['team2']['logoUrl'],
                    team2Name: match['team2']['name'],
                  );
                },
              ).toList(),);
  }
}
