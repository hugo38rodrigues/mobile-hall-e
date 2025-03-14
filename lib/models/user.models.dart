import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';


class User {
  String id;
  String email;
  String role;
  String token;
  Informations informations;
  Favorites favorites;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.informations,
    required this.favorites
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'invité',
      token: map['token'] ?? '',
      informations: Informations.fromJson(map['informations'] ?? {}, map['role']),
      favorites: Favorites.fromJson(map['favorites'] ?? {})
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'informations': informations.toJson(), 
      'favorites': favorites.toJson(), 
    };
  }
}
