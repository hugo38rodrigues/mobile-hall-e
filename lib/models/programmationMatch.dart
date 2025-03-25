import 'package:hall_e_mobile/models/team.model.dart';

class ProgrammationMatch {
  String id;
  String date;
  String gameName;
  String leagueName;
  Team team1;
  Team team2;

  ProgrammationMatch({
    required this.id,
    required this.date,
    required this.gameName,
    required this.leagueName,
    required this.team1,
    required this.team2
  });

  
  factory ProgrammationMatch.fromJson(Map<String, dynamic> json) {
    return ProgrammationMatch(
        id: json['_id'],
        date: json['date'],
        gameName: json['gameName'],
        leagueName: json['leagueName'],
        team1: Team.fromMap(json['team1']),
        team2: Team.fromMap(json['team2'])
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'gameName': gameName,
      'leagueName': leagueName,
      'team1': team1,
      'team2': team2,
    };
  }
}
