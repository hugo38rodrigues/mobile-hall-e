import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';

class User {
  String id;
  String token;
  String email;
  String role;
  Informations informations;
  Favorites? favorites;
  List<ProgrammationMatch>? programations;
  Location userLocation;

  User({
    required this.id,
    required this.token,
    required this.email,
    required this.role,
    required this.informations,
    required this.userLocation,
    this.favorites,
    this.programations,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
        id: map['id'] ?? '',
        token: map['token'] ?? '',
        email: map['email'] ?? '',
        role: map['role'] ?? 'guest',
        informations: Informations.fromJson(map['informations']),
        favorites: map['favorites'] != null
            ? Favorites.fromMapInitial(map['favorites'])
            : null,
        programations: (map['programmedMatches'] as List<dynamic>?)
            ?.map((match) => ProgrammationMatch.fromJson(match))
            .toList(),
        userLocation: Location.fromJson(map['userLocation']));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'role': role,
      'informations': informations.toJson(),
      'favorites': favorites?.toJson(),
      'programations': programations?.map((m) => m.toJson()).toList(),
      'userLocation': userLocation.toJson(),
    };
  }
}
