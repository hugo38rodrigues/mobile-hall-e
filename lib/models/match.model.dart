import 'package:hall_e_mobile/models/programation-match.model.dart';
import 'package:hall_e_mobile/models/team.model.dart';

class Match {
  String id;
  Team team1;
  Team team2;
  List<ProgramationMatch>? programmed;
  String leagueName;
  String gameName;
  String date;

  Match({
    required this.id,
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
      'firstName': id,
      'team1': team1,
      'team2': team2,
      'programmed': programmed,
      'leagueName': leagueName,
      'gameName': gameName,
      'date': date,
    };
  }
}
