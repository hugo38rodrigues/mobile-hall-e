import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/match.model.dart';

class User {
  String id;
  String token;
  String email;
  String role;
  Informations? informations;
  Favorites? favorites;
  List<Match>? programations;
  Location? userLocation;

  User({
    required this.id,
    required this.token,
    required this.email,
    required this.role,
    this.informations,
    this.favorites,
    this.programations,
    this.userLocation,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      token: map['token'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'guest',
      informations: map['informations'] != null
          ? Informations.fromJson(map['informations'])
          : null,
      favorites: map['favorites'] != null
          ? Favorites.fromMapInitial(map['favorites'])
          : null,
      programations: (map['programmedMatches'] as List<dynamic>?)
          ?.map((match) => Match.fromJson(match))
          .toList(),
      userLocation: map['userLocation'] != null
          ? Location.fromJson(map['userLocation'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'email': email,
      'role': role,
      'informations': informations?.toJson(),
      'favorites': favorites?.toJson(),
      'programations': programations?.map((m) => m.toJson()).toList(),
      'userLocation': userLocation?.toJson(),
    };
  }
}
