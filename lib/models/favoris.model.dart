import 'package:hall_e_mobile/models/team.model.dart';

class Favorites {
  List<String> gameName;
  List<String> leagueName;
  List<Team> teams;
  List<String> barName;

  Favorites({
    required this.gameName,
    required this.leagueName,
    required this.teams,
    required this.barName,
  });

  factory Favorites.fromMap(Map<String, dynamic> json, Favorites current) {
    return Favorites(
      gameName: json.containsKey('gameName')
          ? List<String>.from(json['gameName'])
          : current.gameName,
      leagueName: json.containsKey('leagueName')
          ? List<String>.from(json['leagueName'])
          : current.leagueName,
      teams: json.containsKey('teams')
          ? (json['teams'] as List).map((team) => _mapToTeam(team)).toList()
          : current.teams,
      barName: json.containsKey('barName')
          ? List<String>.from(json['barName'])
          : current.barName,
    );
  }

  factory Favorites.fromMapInitial(Map<String, dynamic>? json) {
    return Favorites(
      gameName: List<String>.from(json?['gameName'] ?? []),
      leagueName: List<String>.from(json?['leagueName'] ?? []),
      teams:
          (json?['teams'] as List?)?.map((team) => _mapToTeam(team)).toList() ??
              [],
      barName: List<String>.from(json?['barName'] ?? []),
    );
  }

  static Team _mapToTeam(dynamic data) {
    if (data is Map<String, dynamic>) {
      return Team.fromMap(data);
    } else if (data is String) {
      return Team(id: data, name: '', acronym: '', logoUrl: '');
    } else {
      return Team(id: '', name: '', acronym: '', logoUrl: '');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'gameName': gameName,
      'leagueName': leagueName,
      'teams': teams
          .map((team) => {
                'id': team.id,
                'name': team.name,
              })
          .toList(),
      'barName': barName,
    };
  }
}
