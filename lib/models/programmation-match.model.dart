import 'package:hall_e_mobile/models/game.model.dart';
import 'package:hall_e_mobile/models/league.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';

class ProgrammationMatch {
  String id;
  List<String> streamPlatform;
  int hypeScore;
  Team team1;
  Team team2;
  League league;
  Game game;
  String date;

  ProgrammationMatch({
    required this.id,
    required this.hypeScore,
    required this.streamPlatform,
    required this.team1,
    required this.team2,
    required this.game,
    required this.league,
    required this.date,
  });

  factory ProgrammationMatch.fromJson(Map<String, dynamic> data) {
    return ProgrammationMatch(
      id: data['id'],
      streamPlatform: List<String>.from(data['streamPlatform'] ?? []),
      hypeScore: data['hypeScore'],
      team1: Team.fromJson(data['team1']),
      team2: Team.fromJson(data['team2']),
      league: League.fromJson(data['league']),
      game: Game.fromJson(data['game']),
      date: data['date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streamPlatform': streamPlatform,
      'hypeScore': hypeScore,
      'team1': team1,
      'team2': team2,
      'league': league,
      'game': game,
      'date': date,
    };
  }
}
