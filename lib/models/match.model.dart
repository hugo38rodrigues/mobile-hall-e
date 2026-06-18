import 'package:hall_e_mobile/models/bar-minimal-informations.model.dart';
import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';

class Match {
  String id;
  List<String> streamPlatform;
  int hypeScore;
  String numberOfGame;
  Team team1;
  Team team2;
  List<BarMinimalInformations>? programmed;
  League league;
  Game game;
  String date;

  Match({
    required this.id,
    required this.streamPlatform,
    required this.numberOfGame,
    required this.hypeScore,
    required this.team1,
    required this.team2,
    required this.game,
    required this.league,
    required this.programmed,
    required this.date,
  });

  factory Match.fromJson(Map<String, dynamic> data) {
    return Match(
      id: data['id'] ?? '',
      streamPlatform: List<String>.from(data['streamPlatform'] ?? []),
      hypeScore: data['hypeScore'] ?? 0,
      team1: Team.fromJson(data['team1'] ?? {}),
      team2: Team.fromJson(data['team2'] ?? {}),
      numberOfGame: data['numberOfGame'] ?? '',
      programmed: (data['programmed'] as List?)
          ?.map((prog) => BarMinimalInformations.fromJson(prog))
          .toList(),
      league: League.fromJson(data['league'] ?? {}),
      game: Game.fromJson(data['game'] ?? {}),
      date: data['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streamPlatform': streamPlatform,
      'hypeScore': hypeScore,
      'team1': team1.toJson(),
      'team2': team2.toJson(),
      'numberOfGame': numberOfGame,
      'programmed': programmed?.map((bar) => bar.toJson()).toList(),
      'league': league.toJson(),
      'game': game.toJson(),
      'date': date,
    };
  }
}
