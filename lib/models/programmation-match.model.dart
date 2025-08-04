import 'package:hall_e_mobile/models/team.model.dart';

class ProgrammationMatch {
  String id;
  List<String> streamPlatform;
  int hypeScore;
  Team team1;
  Team team2;
  String leagueName;
  String gameName;
  String date;

  ProgrammationMatch({
    required this.id,
    required this.hypeScore,
    required this.streamPlatform,
    required this.team1,
    required this.team2,
    required this.gameName,
    required this.leagueName,
    required this.date,
  });

  factory ProgrammationMatch.fromJson(Map<String, dynamic> json) {
    return ProgrammationMatch(
      id: json['id'],
      streamPlatform: List<String>.from(json['streamPlatform'] ?? []),
      hypeScore: json['hypeScore'],
      team1: Team.fromJson(json['team1']),
      team2: Team.fromJson(json['team2']),
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
      'leagueName': leagueName,
      'gameName': gameName,
      'date': date,
    };
  }
}
