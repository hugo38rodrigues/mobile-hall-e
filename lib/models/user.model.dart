// user.model.dart
import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';

abstract class User {
  final String id;
  final String token;
  final String email;
  final String role;
  final Informations informations;
  final Location userLocation;
  final Favorites? favorites;

  User({
    required this.id,
    required this.token,
    required this.email,
    required this.role,
    required this.informations,
    required this.userLocation,
    this.favorites,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'token': token,
        'email': email,
        'role': role,
        'informations': informations.toJson(),
        'favorites': favorites?.toJson(),
        'userLocation': userLocation.toJson(),
      };

  factory User.fromMap(Map<String, dynamic> data) {
    switch (data['role'] ?? 'guest') {
      case 'client':
        return ClientUser.fromMap(data);
      case 'bar':
        return BarUser.fromMap(data);
      default:
        return GuestUser.fromLocation(
          data['userLocation'] != null
              ? Location.fromJson(data['userLocation'])
              : null,
        );
    }
  }
}

// client_user.model.dart
class ClientUser extends User {
  ClientUser({
    required super.id,
    required super.token,
    required super.email,
    required super.informations,
    required super.userLocation,
    super.favorites,
  }) : super(role: 'client');

  factory ClientUser.fromMap(Map<String, dynamic> data) {
    return ClientUser(
      id: data['id'] ?? '',
      token: data['token'] ?? '',
      email: data['email'] ?? '',
      informations: Informations(
        firstName: data['informations']['firstName'],
        lastName: data['informations']['lastName'],
      ),
      favorites: data['favorites'] != null
          ? Favorites.fromMapInitial(data['favorites'])
          : null,
      userLocation: _locationFrom(data),
    );
  }
}

// bar_user.model.dart
class BarUser extends User {
  final List<ProgrammationMatch>? programations;

  BarUser({
    required super.id,
    required super.token,
    required super.email,
    required super.informations,
    required super.userLocation,
    super.favorites,
    this.programations,
  }) : super(role: 'bar');

  factory BarUser.fromMap(Map<String, dynamic> data) {
    return BarUser(
      id: data['id'] ?? '',
      token: data['token'] ?? '',
      email: data['email'] ?? '',
      informations: Informations(
        name: data['informations']['name'] ?? '',
        address: data['informations']['address'],
        description: data['informations']['description'],
        pictures: data['informations']['pictures'],
      ),
      programations: (data['programations'] as List<dynamic>?)
          ?.map((m) => ProgrammationMatch.fromJson(m))
          .toList(),
      favorites: data['favorites'] != null
          ? Favorites.fromMapInitial(data['favorites'])
          : null,
      userLocation: _locationFrom(data),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'programations': programations?.map((m) => m.toJson()).toList(),
      };
}

// guest_user.model.dart
class GuestUser extends User {
  GuestUser({required super.userLocation})
      : super(
          id: '',
          token: '',
          email: '',
          role: 'guest',
          informations: Informations(name: 'guest'),
        );

  factory GuestUser.fromLocation(Location? location) {
    return GuestUser(
      userLocation: location ??
          Location(latitude: 0.0, longitude: 0.0, isActivated: false),
    );
  }
}

Location _locationFrom(Map<String, dynamic> map) {
  return map['userLocation'] != null
      ? Location.fromJson(map['userLocation'])
      : Location(latitude: 0.0, longitude: 0.0, isActivated: false);
}
