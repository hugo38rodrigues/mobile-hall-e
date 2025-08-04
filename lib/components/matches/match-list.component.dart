import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
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
  List<Match> matches = [];
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
        setState(() {
          matches = (response.data as List)
              .map((match) => Match.fromJson(match))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  Future<void> sendProgrammationMatch(matchId) async {
    String? apiUrl = dotenv.env['API_URL'];
    Dio dio = Dio();
    User profile = ref.watch(accountProvider);
    String id = profile.id;

    try {
      Response response = await dio
          .post('$apiUrl/bar',
              data: {"matchId": matchId, "barId": id},
              options: Options(
                headers: {
                  "Content-Type": "application/json",
                  'Authorization': 'Bearer ${profile.token}'
                },
              ))
          .timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // Gère le timeout en lançant une exception
          throw DioException(
            requestOptions: RequestOptions(path: '$apiUrl/bar'),
            type: DioExceptionType
                .connectionTimeout, // Utilisation de connectionTimeout pour gérer le timeout
            message: 'Timeout',
          );
        },
      );

      if (response.statusCode == 200) {
        // Extraire la liste des matchs depuis "data"
        setState(() {
          fetchMatches();
        });
      }
    } catch (e) {
      if (e is DioException) {
        if (!mounted) return;

        await handleError(e, context);
      }
    }
  }

  /// Vérifie si la date du match correspond à la date sélectionnée
  bool isSameDay(DateTime matchDate, DateTime targetDate) {
    return matchDate.year == targetDate.year &&
        matchDate.month == targetDate.month &&
        matchDate.day == targetDate.day;
  }

  Duration getTimeWithBo(String gameName, String bo) {
    final normalizedGame = gameName.toLowerCase();

    final Map<String, Map<String, Duration>> gameDurations = {
      'league of legends': {
        '1': const Duration(minutes: 33),
        '3': const Duration(hours: 1, minutes: 50),
        '5': const Duration(hours: 3, minutes: 50),
      },
      'cs go': {
        '1': const Duration(minutes: 50),
        '3': const Duration(hours: 2, minutes: 30),
        '5': const Duration(hours: 5),
      },
      'valorant': {
        '1': const Duration(minutes: 45),
        '3': const Duration(hours: 2, minutes: 15),
        '5': const Duration(hours: 4, minutes: 30),
      },
    };

    final durations = gameDurations[normalizedGame];
    if (durations != null && durations.containsKey(bo)) {
      return durations[bo]!;
    }

    // Durée par défaut si jeu ou BO non reconnu
    return const Duration(hours: 2);
  }


  /// Filtre les matchs du jour sélectionné
  bool filterByDate(Match match, DateTime targetDate) {
    Duration timeWithBo = getTimeWithBo(match.gameName, match.numberOfGame);
    DateTime matchDate = DateTime.parse(match.date).toLocal();

    DateTime startOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    DateTime endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    bool isInSelectedDay =
        !matchDate.isBefore(startOfDay) && !matchDate.isAfter(endOfDay);
    if (!isInSelectedDay) return false;

    // Si c’est aujourd’hui, on exclut les matchs déjà passés
    final now = DateTime.now();
    if (isSameDay(targetDate, now)) {
      final matchEndTime = matchDate.add(timeWithBo);
      return matchEndTime.isAfter(now);
    }

    return true;
  }

  /// Filtre par équipes sélectionnées (peut en avoir plusieurs)
  bool filterByTeams(Match match, List<dynamic>? selectedTeams) {
    if (selectedTeams == null || selectedTeams.isEmpty) return true;

    bool isTeam1Selected = selectedTeams.contains(match.team1.name);
    bool isTeam2Selected = selectedTeams.contains(match.team2.name);
    return isTeam1Selected || isTeam2Selected;
  }

  /// Filtre par jeux sélectionnés (peut en avoir plusieurs)
  bool filterByGames(Match match, List<dynamic>? selectedGames) {
    if (selectedGames == null || selectedGames.isEmpty) return true;

    return selectedGames.contains(match.gameName);
  }

  /// Filtre par ligues sélectionnées (peut en avoir plusieurs)
  bool filterByLeagues(Match match, List<dynamic>? selectedLeagues) {
    if (selectedLeagues == null || selectedLeagues.isEmpty) return true;

    return selectedLeagues.contains(match.leagueName);
  }

  /// Filtre par favoris (équipes, ligues ou jeux)
  bool filterByFavorites(Match match, Favorites favoris) {
    String role = ref.watch(accountProvider).role;
    bool isFavoriteBarName = false;

    List<String> arrayTeams =
        favoris.teams.map<String>((team) => team.name.toString()).toList();

    bool isFavoriteTeam = arrayTeams.contains(match.team1.name) ||
        arrayTeams.contains(match.team2.name);

    bool isFavoriteLeague = favoris.leagueName.contains(match.leagueName);

    bool isFavoriteGame = favoris.gameName.contains(match.gameName);

    if (role == 'client') {
      // Créer une liste des noms de bars programmés
      List<String> barNames =
          match.programmed!.map((programed) => programed.name).toList();

      // Vérifier si l'un des noms dans `favoris.barName` est dans `barNames`
      isFavoriteBarName =
          favoris.barName.any((barName) => barNames.contains(barName));
    }

    return isFavoriteTeam ||
        isFavoriteLeague ||
        isFavoriteGame ||
        isFavoriteBarName;
  }

  bool filterByBarName(
    Match match,
    List<dynamic>? selectedBarName,
  ) {
    if (selectedBarName == null || selectedBarName.isEmpty) return true;
    if (match.programmed!.isEmpty) {
      return false;
    }

    // On récupère tous les noms de bars qui ont programmé ce match
    List<String> barNames =
        match.programmed!.map((programed) => programed.name).toList();

    // On vérifie s'il y a au moins un bar programmé dans la sélection
    return barNames.any((barName) => selectedBarName.contains(barName));
  }

  List<Match> filterMatchesProgrammed(List<Match> listMatches) {
    List<Match> matches = listMatches
        .where((Match match) =>
            match.programmed != null && match.programmed!.isEmpty)
        .toList();
    return matches;
  }

  /// Fonction principale de filtrage
  List<Match> filterMatches(
    DateTime targetDate,
    List<dynamic>? selectedTeams,
    List<dynamic>? selectedGames,
    List<dynamic>? selectedLeagues,
    List<dynamic>? selectedBarName,
  ) {
    return matches.where((match) {
      if (widget.isFavoritesSelected) {
        // Si favoris sélectionnés, ne filtrer que par les favoris et ignorer les autres filtres
        return filterByFavorites(
                match, ref.watch(accountProvider).favorites!) &&
            filterByDate(match, targetDate);
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
    List<Match> filteredMatches = filterMatches(widget.selectedDate,
        selectedTeams, selectedGames, selectedLeagues, selectedBarName);

    List<Match> filteredMatchesProgrammed =
        filterMatchesProgrammed(filteredMatches);

    List<Match> listMatches =
        role == 'bar' ? filteredMatchesProgrammed : filteredMatches;

    listMatches.sort((a, b) {
      DateTime dateA = DateTime.parse(a.date);
      DateTime dateB = DateTime.parse(b.date);
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
            : SingleChildScrollView(
                child: Column(
                  children: listMatches.map(
                    (match) {
                      return MatchCard(
                        role: role,
                        streamPlatform: match.streamPlatform,
                        hypeScore: match.hypeScore,
                        getIdMatch: sendProgrammationMatch,
                        programmed: match.programmed,
                        leagueName: match.leagueName,
                        gameName: match.gameName,
                        idMatch: match.id,
                        date: match.date,
                        team1: match.team1,
                        team2: match.team2,
                      );
                    },
                  ).toList(),
                ),
              );
  }
}
