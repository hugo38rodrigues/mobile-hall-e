import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/programmationMatch.dart';

class User {
  String id;
  String email;
  String role;
  Informations informations;
  Favorites favorites;
  List<ProgrammationMatch> programmations;
  Location userLocation;

  User(
      {required this.id,
      required this.email,
      required this.role,
      required this.informations,
      required this.favorites,
      required this.programmations,
      required this.userLocation});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'guest',
        informations:
            Informations.fromJson(map['informations'] ?? {}, map['role']),
        favorites: Favorites.fromMapInitial(map['favorites']),
        programmations: (map['programmedMatches'] is List)
            ? List<ProgrammationMatch>.from((map['programmedMatches'] as List)
                .map((element) => ProgrammationMatch.fromJson(element ?? {})))
            : [],
        userLocation: Location.fromJson(map['userLocation'] ?? {}));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'informations': informations.toJson(),
      'favorites': favorites.toJson(),
      'programmations': programmations,
      'userLocation': userLocation
    };
  }
}
