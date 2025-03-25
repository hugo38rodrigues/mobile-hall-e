import 'package:hall_e_mobile/models/programmationMatch.dart';
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';



class User {
  String id;
  String email;
  String role;
  Informations informations;
  Favorites favorites;
  List<ProgrammationMatch> programmations;


  User({
    required this.id,
    required this.email,
    required this.role,
    required this.informations,
    required this.favorites,
    required this.programmations

  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'guest',
      informations: Informations.fromJson(map['informations'] ?? {}, map['role']),
      favorites: Favorites.fromJson(map['favorites'] ?? {}),
      programmations: (map['programmedMatches'] is List)
        ? List<ProgrammationMatch>.from(
            (map['programmedMatches'] as List)
                .map((element) => ProgrammationMatch.fromJson(element ?? {})))
        : [], 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'informations': informations.toJson(), 
      'favorites': favorites.toJson(), 
      'programmations': programmations,
    };
  }
}
