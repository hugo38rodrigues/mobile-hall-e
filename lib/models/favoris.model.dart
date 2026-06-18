import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';

class Favorites {
  final List<Game> games; 
  final List<League> leagues; 
  final List<Team> teams; 
  final List<Map<String, dynamic>> barName; 
  
  const Favorites({
    required this.games,
    required this.leagues,
    required this.teams,
    required this.barName,
  });

  factory Favorites.empty() => const Favorites(
        games: [],
        leagues: [],
        teams: [],
        barName: [],
      );

  factory Favorites.fromMapInitial(Map<String, dynamic>? data) {
    return Favorites(
      games: (data?['games'] as List?)?.map((e) => Game.fromJson(e)).toList() ??
          [],
      leagues: (data?['leagues'] as List?)
              ?.map((e) => League.fromJson(e))
              .toList() ??
          [],
      teams: (data?['teams'] as List?)?.map((e) => Team.fromJson(e)).toList() ??
          [],
      barName: List<Map<String, dynamic>>.from(data?['barName'] ?? []),
    );
  }

  Favorites copyWith({
    List<Game>? games,
    List<League>? leagues,
    List<Team>? teams,
    List<Map<String, dynamic>>? barName,
  }) {
    return Favorites(
      games: games ?? this.games,
      leagues: leagues ?? this.leagues,
      teams: teams ?? this.teams,
      barName: barName ?? this.barName,
    );
  }

  Map<String, dynamic> toJson() => {
        'games': games.map((g) => {'id': g.id, 'name': g.name}).toList(),
        'leagues': leagues.map((l) => {'id': l.id, 'name': l.name}).toList(),
        'teams': teams.map((t) => {'id': t.id, 'name': t.name}).toList(),
        'barName':
            barName.map((b) => {'id': b['id'], 'name': b['name']}).toList(),
      };
}
