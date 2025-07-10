import 'package:hall_e_mobile/models/programation-match.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';

class Match {
  String id;
  List<String> streamPlatform;
  int hypeScore;
  Team team1;
  Team team2;
  List<ProgramationMatch>? programmed;
  String leagueName;
  String gameName;
  String date;

  Match({
    required this.id,
    required this.streamPlatform,
    required this.hypeScore,
    required this.team1,
    required this.team2,
    required this.gameName,
    required this.leagueName,
    required this.programmed,
    required this.date,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['_id'],
      streamPlatform: List<String>.from(json['streamPlatform'] ?? []),
      hypeScore: json['hypeScore'],
      team1: Team.fromJson(json['team1']),
      team2: Team.fromJson(json['team2']),
      programmed: (json['programmed'] as List<dynamic>? ?? [])
          .map((prog) => ProgramationMatch.fromJson(prog))
          .toList(),
      leagueName: json['leagueName'],
      gameName: json['gameName'],
      date: json['date'],
    );
  }

   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streamPlatform': streamPlatform,
      'hypeScore': hypeScore,
      'team1': team1,
      'team2': team2,
      'programmed': programmed,
      'leagueName': leagueName,
      'gameName': gameName,
      'date': date,
    };
  }
}
