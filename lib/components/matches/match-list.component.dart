import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font-colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';

import '../loader.component.dart';
import 'match-card.component.dart';

class MatchList extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<dynamic>> filtersList;
  final bool isFavoritesSelected;

  MatchList(
      {required this.selectedDate,
      required this.filtersList,
      required this.isFavoritesSelected});

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends ConsumerState<MatchList> {
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
      Response response = await dio.get('$apiUrl/').timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/'),
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
    // Parse la date du match en local (important si le backend envoie du UTC)
    DateTime matchDate = DateTime.parse(match["date"]).toLocal();

    // Définir les bornes du jour sélectionné (00:00 à 23:59:59.999)
    DateTime startOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    DateTime endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    // Ne garder que les matchs compris dans cette journée
    bool isInSelectedDay =
        matchDate.isAfter(startOfDay) && matchDate.isBefore(endOfDay);

    if (!isInSelectedDay) return false;

    // Si on est sur aujourd’hui, on exclut les matchs déjà passés dans la journée
    DateTime now = DateTime.now();
    if (isSameDay(targetDate, now)) {
      return matchDate.isAfter(now);
    }

    return true;
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
  bool filterByFavorites(Map<String, dynamic> match, Favorites favoris) {
    String role = ref.watch(accountProvider).role;
    bool isFavoriteBarName = false;

    List<String> arrayTeams =
        favoris.teams.map<String>((team) => team.name.toString()).toList();

    bool isFavoriteTeam = arrayTeams.contains(match['team1']["name"]) ||
        arrayTeams.contains(match['team2']['name']);

    bool isFavoriteLeague = favoris.leagueName.contains(match["leagueName"]);
    
    bool isFavoriteGame = favoris.gameName.contains(match["gameName"]);

    if (role == 'client') {
       // Créer une liste des noms de bars programmés
      List<String> programmedBarNames = match["programmed"]
          .map<String>((bar) => bar["name"].toString())
          .toList();

      // Vérifier si l'un des noms dans `favoris.barName` est dans `programmedBarNames`
      isFavoriteBarName = favoris.barName
          .any((barName) => programmedBarNames.contains(barName));
    }

    return isFavoriteTeam ||
        isFavoriteLeague ||
        isFavoriteGame ||
        isFavoriteBarName;
  }

  bool filterByBarName(
    Map<String, dynamic> match,
    List<dynamic>? selectedBarName,
  ) {
    if (selectedBarName == null || selectedBarName.isEmpty) return true;
    if (match["programmed"].isEmpty) {
      return false;
    }

    // On récupère tous les noms de bars qui ont programmé ce match
    List<String> programmedBarNames = match["programmed"]
        .map<String>((bar) => bar["name"].toString())
        .toList();

    // On vérifie s'il y a au moins un bar programmé dans la sélection
    return programmedBarNames
        .any((barName) => selectedBarName.contains(barName));
  }

  /// Fonction principale de filtrage
  List<Map<String, dynamic>> filterMatches(
    DateTime targetDate,
    List<dynamic>? selectedTeams,
    List<dynamic>? selectedGames,
    List<dynamic>? selectedLeagues,
    List<dynamic>? selectedBarName,
  ) {
    return matches.where((match) {
      if (widget.isFavoritesSelected) {
        // Si favoris sélectionnés, ne filtrer que par les favoris et ignorer les autres filtres
        return filterByFavorites(match, ref.watch(accountProvider).favorites) &&
            filterByDate(
                match, targetDate); // Seul le filtre de date s'applique
      } else {
        // Applique tous les filtres quand favoris n'est pas activé
        return filterByDate(match, targetDate) &&
            filterByTeams(match, selectedTeams) &&
            filterByGames(match, selectedGames) &&
            filterByLeagues(match, selectedLeagues) &&
            filterByBarName(match, selectedBarName);
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    String role = ref.watch(accountProvider).role;
    List? selectedGames = widget.filtersList['games'];
    List? selectedLeagues = widget.filtersList['leagues'];
    List? selectedTeams = widget.filtersList['teams'];
    List? selectedBarName = widget.filtersList['barName'];

    List<Map<String, dynamic>> filteredMatches = filterMatches(
        widget.selectedDate,
        selectedTeams,
        selectedGames,
        selectedLeagues,
        selectedBarName);

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
