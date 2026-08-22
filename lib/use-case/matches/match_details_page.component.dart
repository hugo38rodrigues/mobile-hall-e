import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hall_e_mobile/use-case/map/map_wrapper.dart';
import 'package:hall_e_mobile/use-case/my_app_bar.component.dart';
import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';
import 'package:hall_e_mobile/providers/account.providers.dart';
import 'package:hall_e_mobile/styles/font_colors.dart';
import 'package:hall_e_mobile/utils/handle-error.utils.dart';
import 'package:intl/intl.dart';

class MatchDetailsPage extends ConsumerStatefulWidget {
  final League league;
  final Game game;
  final String date;
  final String numberOfGame;
  final List<BarMinimalInformations>? barList;
  final Team team1;
  final Team team2;

  const MatchDetailsPage({
    super.key,
    required this.league,
    required this.game,
    required this.date,
    required this.numberOfGame,
    required this.team1,
    required this.team2,
    required this.barList,
  });

  @override
  ConsumerState<MatchDetailsPage> createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends ConsumerState<MatchDetailsPage> {
  late final String _hours;
  late final String _days;
  late final Dio _dio;

  List<Game> _gameFavorites = [];
  List<League> _leagueFavorites = [];
  List<Team> _teamsFavorites = [];
  late User profile;

  @override
  void initState() {
    super.initState();
    profile = ref.read(accountProvider);
    _dio = Dio();
    _parseDate();
    _loadFavorites();
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = profile.role;
    final isNotGuest = role != 'guest';
    final isNotBar = role != 'bar';

    return Scaffold(
      appBar: MyAppBar(),
      backgroundColor: background,
      body: Center(
        child: Column(
          children: [
            _buildHeader(isNotGuest),
            _buildTeamsRow(isNotGuest),
            const SizedBox(height: 10),
            if (isNotBar) _buildMapSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isNotGuest) {
    return Container(
      margin: const EdgeInsets.only(left: 30, top: 50, right: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.game.name,
                  style: const TextStyle(
                      color: textGold, fontWeight: FontWeight.bold),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              if (isNotGuest)
                _favoriteIcon(
                  isFavorite: _gameFavorites.any((g) => g.id == widget.game.id),
                  onTap: () => _toggleFavorite('game', widget.game.id),
                ),
            ],
          ),
          Row(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Text(
                  _days,
                  style: const TextStyle(
                      color: textGold, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Compétitions:',
                  style: TextStyle(color: textGold, fontSize: 12)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.league.name,
                  style: const TextStyle(
                      color: textGold, fontWeight: FontWeight.bold),
                  softWrap: true,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              if (isNotGuest)
                _favoriteIcon(
                  isFavorite:
                      _leagueFavorites.any((l) => l.id == widget.league.id),
                  onTap: () => _toggleFavorite('league', widget.league.id),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                widget.numberOfGame == '1'
                    ? 'Nombre de game:'
                    : 'Nombre de games',
                style: const TextStyle(color: textGold, fontSize: 12),
              ),
              const SizedBox(width: 10),
              Text(
                widget.numberOfGame,
                style: const TextStyle(
                    color: textGold, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsRow(bool isNotGuest) {
    return Container(
      padding: const EdgeInsets.only(top: 50),
      child: SizedBox(
        width: 350,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment.center, // aligne les 3 blocs sur la même ligne
          children: [
            Expanded(child: _buildTeamColumn(widget.team1, isNotGuest)),
            _matchHourBadge(),
            Expanded(child: _buildTeamColumn(widget.team2, isNotGuest)),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamColumn(Team team, bool isNotGuest) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: _teamAcronym(team.acronym),
            ),
            if (isNotGuest) ...[
              const SizedBox(width: 6), // espace entre l'acronyme et le cœur
              _favoriteIcon(
                isFavorite: _teamsFavorites.any((t) => t.id == team.id),
                onTap: () => _toggleFavorite('team', team.id),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection() {
    final bars = widget.barList;
    if (bars == null || bars.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          children: [
            Text('Aucun bar ne programme ce match,',
                style: TextStyle(fontSize: 15, color: textGold)),
            Text("n'hésitez pas à leur en parler",
                style: TextStyle(fontSize: 15, color: textGold)),
          ],
        ),
      );
    }
    return MapWrapper(barMinimalInformations: bars);
  }

  Widget _favoriteIcon(
      {required bool isFavorite, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_outline,
        color: textGold,
      ),
    );
  }

  Widget _teamAcronym(String acronym) => Text(
        acronym,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: textGold, fontSize: 14, fontWeight: FontWeight.bold),
        softWrap: true,
        maxLines: 2,
        overflow: TextOverflow.visible,
      );

  Widget _matchHourBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
            color: textGold, borderRadius: BorderRadius.circular(20)),
        child: Text(
          _hours,
          style: const TextStyle(
              color: background, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );

  void _parseDate() {
    final dateTime = DateTime.parse(widget.date).toLocal();
    _hours = DateFormat("HH'h'mm").format(dateTime);
    _days =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void _loadFavorites() {
    final fav = profile.favorites;
    if (profile.role == 'guest' || fav == null) return;
    _gameFavorites = List.of(fav.games);
    _leagueFavorites = List.of(fav.leagues);
    _teamsFavorites = List.of(fav.teams);
  }

  Future<void> _toggleFavorite(String type, String id) async {
    bool wasPresent = false;

    setState(() {
      switch (type) {
        case 'game':
          wasPresent = _gameFavorites.any((game) => game.id == id);
          wasPresent
              ? _gameFavorites.removeWhere((game) => game.id == id)
              : _gameFavorites.add(widget.game);
          break;
        case 'league':
          wasPresent = _leagueFavorites.any((league) => league.id == id);
          wasPresent
              ? _leagueFavorites.removeWhere((league) => league.id == id)
              : _leagueFavorites.add(widget.league);
          break;
        case 'team':
          wasPresent = _teamsFavorites.any((team) => team.id == id);
          wasPresent
              ? _teamsFavorites.removeWhere((team) => team.id == id)
              : _teamsFavorites
                  .add(widget.team1.id == id ? widget.team1 : widget.team2);
          break;
      }
    });

    final apiType = type == 'team' ? 'teams' : type;

    try {
      await _sendFavoriteRequest(
        apiType: apiType,
        method: wasPresent ? 'DELETE' : 'POST',
        id: id,
      );
    } catch (_) {
      setState(() {
        switch (type) {
          case 'game':
            wasPresent
                ? _gameFavorites.add(widget.game)
                : _gameFavorites.removeWhere((game) => game.id == id);
            break;
          case 'league':
            wasPresent
                ? _leagueFavorites.add(widget.league)
                : _leagueFavorites.removeWhere((league) => league.id == id);
            break;
          case 'team':
            final team = widget.team1.id == id ? widget.team1 : widget.team2;
            wasPresent
                ? _teamsFavorites.add(team)
                : _teamsFavorites.removeWhere((team) => team.id == id);
            break;
        }
      });
    }
  }

  Future<void> _sendFavoriteRequest({
    required String apiType,
    required String method,
    required String id,
  }) async {
    final profile = ref.read(accountProvider);
    final apiUrl = dotenv.env['API_URL'];
    final path = '$apiUrl/favoris';

    final data = {'type': apiType, 'userId': profile.id, 'id': id};

    final options = Options(headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${profile.token}',
    });

    try {
      final response = await (method == 'POST'
              ? _dio.post(path, data: data, options: options)
              : _dio.delete(path, data: data, options: options))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        ref.read(accountProvider.notifier).updateAccount({
          'favorites': {
            'games': _gameFavorites
                .map((g) => {'id': g.id, 'name': g.name})
                .toList(),
            'leagues': _leagueFavorites
                .map((l) => {'id': l.id, 'name': l.name})
                .toList(),
            'teams': _teamsFavorites
                .map((t) => {'id': t.id, 'name': t.name})
                .toList(),
            'barName': profile.favorites?.barName ?? [],
          }
        });
      }
    } on DioException catch (e) {
      if (mounted) await handleError(e, context);
      rethrow;
    }
  }
}
