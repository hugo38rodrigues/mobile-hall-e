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

  factory Favorites.fromJson(Map<String, dynamic> json) {
    return Favorites(
      gameName: List<String>.from(json['gameName'] ?? []),
      leagueName: List<String>.from(json['leagueName'] ?? []),
      teams: (json['teams'] as List<dynamic>?)
              ?.map((team) => Team.fromJson(team))
              .toList() ??
          [],
      barName: List<String>.from(json['barName'] ?? []), // Ajout de barName
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameName': gameName,
      'leagueName': leagueName,
      'teams': teams.map((team) => team.toJson()).toList(),
      'barName': barName, // Ajout à l'objet JSON
    };
  }
}
