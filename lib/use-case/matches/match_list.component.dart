import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/match.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/constants.utils.dart';
import 'package:hall_e_mobile/utils/dio.utils.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:hall_e_mobile/utils/snackbar.utils.dart';

import '../loader.component.dart';
import 'match-card.component.dart';

class MatchList extends ConsumerStatefulWidget {
  final DateTime selectedDate;
  final Map<String, List<dynamic>> filtersList;
  final bool isFavoritesSelected;

  const MatchList({
    super.key,
    required this.selectedDate,
    required this.filtersList,
    required this.isFavoritesSelected,
  });

  @override
  ConsumerState<MatchList> createState() => _MatchListState();
}

class _MatchListState extends ConsumerState<MatchList> {
  List<Match> matches = [];
  bool isLoading = true;
  bool isReconnecting = false;
  bool connectionFailed = false;
  int _retryCount = 0;

  static const int _maxRetries = 1;
  static const Duration _retryDelay = Duration(seconds: 3);
  static const Duration _requestTimeout = Duration(seconds: 10);

  String? get _apiUrl => dotenv.env['API_URL'];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  // ──────────────────── API ────────────────────

  Future<void> fetchMatches() async {
    try {
      final Response response =
          await request('$_apiUrl/matches', 'GET').timeout(_requestTimeout);

      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          matches =
              (response.data as List).map((m) => Match.fromJson(m)).toList();
          isLoading = false;
          isReconnecting = false;
          connectionFailed = false;
          _retryCount = 0; // on réinitialise après un succès
        });
      }
    } catch (e) {
      // on attrape DioException ET TimeoutException
      await _handleFetchError(e);
    }
  }

  Future<void> sendProgrammationMatch(String matchId) async {
    final profile = ref.read(accountProvider); // read, pas watch
    try {
      final response = await request(
        '$_apiUrl/bar',
        'POST',
        data: {"matchId": matchId, "barId": profile.id},
        token: profile.token,
      ).timeout(_requestTimeout);

      if (response.statusCode == 200) fetchMatches();
    } on DioException catch (e) {
      if (!mounted) return;
      await handleError(e, context);
    }
  }

  Future<void> _handleFetchError(Object e) async {
    if (!mounted) return;

    if (_retryCount < _maxRetries) {
      _retryCount++;
      setState(() => isReconnecting = true);

      showInfoWithCirculairSnackBar(
          context, 'Tentative de reconnexion... ($_retryCount/$_maxRetries)');

      // délai progressif : 3s, 6s, 9s... (backoff)
      await Future.delayed(_retryDelay * _retryCount);
      if (!mounted) return;
      await fetchMatches(); // nouvelle tentative
      return;
    }

    // échec après toutes les tentatives → on affiche l'erreur réelle
    setState(() {
      isReconnecting = false;
      isLoading = false;
      connectionFailed = true;
    });
    if (e is DioException) {
      showErrorSnackBar(
          context, 'Impossible de se connecter au serveur, revenez plus tard');
    }
  }

  // ──────────────────── DURÉES ────────────────────

  static const _gameDurations = {
    'league of legends': {
      '1': Duration(minutes: 33),
      '3': Duration(hours: 1, minutes: 50),
      '5': Duration(hours: 3, minutes: 50),
    },
    'cs go': {
      '1': Duration(minutes: 50),
      '3': Duration(hours: 2, minutes: 30),
      '5': Duration(hours: 5),
    },
    'valorant': {
      '1': Duration(minutes: 45),
      '3': Duration(hours: 2, minutes: 15),
      '5': Duration(hours: 4, minutes: 30),
    },
  };

  Duration _getMatchDuration(Game game, String bo) {
    return _gameDurations[game.name.toLowerCase()]?[bo] ??
        const Duration(hours: 2);
  }

  // ──────────────────── FILTRES ────────────────────

  bool _filterByDate(Match match, DateTime targetDate) {
    final matchDate = DateTime.parse(match.date).toLocal();
    final startOfDay =
        DateTime(targetDate.year, targetDate.month, targetDate.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    if (matchDate.isBefore(startOfDay) || !matchDate.isBefore(endOfDay)) {
      return false;
    }

    // Exclure les matchs terminés si c'est aujourd'hui
    final now = DateTime.now();
    if (_isSameDay(targetDate, now)) {
      final duration = _getMatchDuration(match.game, match.numberOfGame);
      return matchDate.add(duration).isAfter(now);
    }
    return true;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _filterByBarName(Match match, List<dynamic>? selected) {
    if (selected == null || selected.isEmpty) return false;
    if (match.programmed == null || match.programmed!.isEmpty) return false;
    final barNames = match.programmed!.map((p) => p.name).toSet();
    return barNames.any((name) => selected.contains(name));
  }

  bool _filterByFavorites(Match match, Favorites favoris, String role) {
    final teamNames = favoris.teams.map((t) => t.name).toSet();
    final isTeam = teamNames.contains(match.team1.name) ||
        teamNames.contains(match.team2.name);
    final isLeague = favoris.leagues.contains(match.league);
    final isGame = favoris.games.contains(match.game);

    bool isBar = false;
    if (role == 'client' && match.programmed != null) {
      final barNames = match.programmed!.map((p) => p.name).toSet();
      isBar = favoris.barName.any((b) => barNames.contains(b["name"]));
    }

    return isTeam || isLeague || isGame || isBar;
  }

  /// Logique de filtrage :
  ///
  /// games et leagues sont liés intelligemment :
  ///   - Un jeu SANS league sélectionnée → tous ses matchs passent
  ///   - Un jeu AVEC league(s) sélectionnée(s) → seulement les matchs de ce jeu dans ces leagues
  ///   - Une league dont le jeu parent N'EST PAS sélectionné → la league filtre seule
  ///
  /// Exemple : LoL + CSGO + LCK
  ///   → LoL a une league (LCK) → matchs LoL dans LCK seulement
  ///   → CSGO n'a pas de league → tous les matchs CSGO passent ✅
  ///
  /// teams et barName sont des OR indépendants.
  bool _filterBySelections(
    Match match, {
    required List<dynamic>? games,
    required List<dynamic>? leagues,
    required List<dynamic>? teams,
    required List<dynamic>? barName,
  }) {
    final hasGames = games != null && games.isNotEmpty;
    final hasLeagues = leagues != null && leagues.isNotEmpty;
    final hasTeams = teams != null && teams.isNotEmpty;
    final hasBarName = barName != null && barName.isNotEmpty;

    if (!hasGames && !hasLeagues && !hasTeams && !hasBarName) return true;

    bool gameLeaguePass = false;

    if (hasGames || hasLeagues) {
      final matchGame = match.game.name;
      final matchLeague = match.league.name;
      final gameSelected = hasGames && games.contains(matchGame);
      final leagueSelected = hasLeagues && leagues.contains(matchLeague);

      if (gameSelected && leagueSelected) {
        // Jeu ET league sélectionnés → les deux correspondent
        gameLeaguePass = true;
      } else if (gameSelected && !hasLeagues) {
        // Jeu sélectionné, aucune league filtrée → tous ses matchs passent
        gameLeaguePass = true;
      } else if (gameSelected) {
        // Jeu sélectionné mais des leagues sont filtrées : le jeu passe
        // librement seulement si sa league n'est pas dans la sélection.
        gameLeaguePass = !leagueSelected;
      } else if (leagueSelected) {
        // League sélectionnée sans son jeu parent → la league filtre seule
        gameLeaguePass = true;
      }
    }

    final teamsPass = hasTeams &&
        (teams.contains(match.team1.name) || teams.contains(match.team2.name));
    final barPass = hasBarName && _filterByBarName(match, barName);

    return gameLeaguePass || teamsPass || barPass;
  }

  List<Match> _getFilteredMatches({
    required DateTime date,
    required String role,
    Favorites? favorites,
    List<dynamic>? teams,
    List<dynamic>? games,
    List<dynamic>? leagues,
    List<dynamic>? barName,
  }) {
    final filtered = matches.where((match) {
      if (!_filterByDate(match, date)) return false;

      if (widget.isFavoritesSelected && favorites != null) {
        return _filterByFavorites(match, favorites, role);
      }

      return _filterBySelections(
        match,
        games: games,
        leagues: leagues,
        teams: teams,
        barName: barName,
      );
    }).toList();

    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  // ──────────────────── BUILD ────────────────────

  Widget _buildCenteredMessage(String message) {
    return Center(
      child: Text(
        message.toUpperCase(),
        style: TextStyle(color: textGold),
      ),
    );
  }

  void _retryFetch() {
    setState(() {
      connectionFailed = false;
      isLoading = true;
      _retryCount = 0;
    });
    fetchMatches();
  }

  Widget _buildRetryMessage() {
    return Center(
      child: InkWell(
        onTap: _retryFetch,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh, color: textGold),
              const SizedBox(height: 8),
              Text(
                "Veuillez réessayer".toUpperCase(),
                style: TextStyle(color: textGold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchList(List<Match> filteredMatches, String role) {
    return SingleChildScrollView(
      child: Column(
        children: filteredMatches
            .map((match) => MatchCard(
                  role: role,
                  streamPlatform: match.streamPlatform,
                  hypeScore: match.hypeScore,
                  getIdMatch: sendProgrammationMatch,
                  programmed: match.programmed,
                  league: match.league,
                  numberOfGame: match.numberOfGame,
                  game: match.game,
                  idMatch: match.id,
                  date: match.date,
                  team1: match.team1,
                  team2: match.team2,
                ))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider);
    final filteredMatches = _getFilteredMatches(
      date: widget.selectedDate,
      role: account.role,
      favorites: account.favorites,
      teams: widget.filtersList['teams'],
      games: widget.filtersList['games'],
      leagues: widget.filtersList['leagues'],
      barName: widget.filtersList['barName'],
    );

    if (isLoading) {
      return CustomLoader(text: loadMatchText);
    }

    if (connectionFailed) {
      return _buildRetryMessage();
    }

    if (filteredMatches.isEmpty) {
      return _buildCenteredMessage("Pas de match pour aujourd'hui");
    }

    return _buildMatchList(filteredMatches, account.role);
  }
}
