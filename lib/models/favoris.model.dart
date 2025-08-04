import 'package:hall_e_mobile/models/team.model.dart';

class Favorites {
  List<String> gameName;
  List<String> leagueName;
  List<Team> teams;
  List<Map<String, dynamic>> barName;

  Favorites({
    required this.gameName,
    required this.leagueName,
    required this.teams,
    required this.barName,
  });


  factory Favorites.fromMapInitial(Map<String, dynamic>? json) {
    return Favorites(
      gameName: List<String>.from(json?['gameName'] ?? []),
      leagueName: List<String>.from(json?['leagueName'] ?? []),
      teams:
          (json?['teams'] as List?)?.map((team) => Team.fromJson(team)).toList() ??
              [],
      barName: List<Map<String, dynamic>>.from(json?['barName'] ?? []),
    );
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
