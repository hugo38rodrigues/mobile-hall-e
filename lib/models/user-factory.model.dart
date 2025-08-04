import 'package:hall_e_mobile/models/favoris.model.dart';
import 'package:hall_e_mobile/models/information.model.dart';
import 'package:hall_e_mobile/models/location.model.dart';
import 'package:hall_e_mobile/models/programmation-match.model.dart';
import 'package:hall_e_mobile/models/user.model.dart';

class UserFactory {
  static User createFromMap(Map<String, dynamic> map) {
    final role = map['role'] ?? 'guest';

    switch (role) {
      case 'client':
        return _createClient(map);
      case 'bar':
        return _createBar(map);
      default:
        return createGuest(
          location: _getLocationOrDefault(map),
        );
    }
  }

  static User _createClient(Map<String, dynamic> map) {
    final informations = Informations(
        firstName: map['informations']['firstName'],
        lastName: map['informations']['lastName']);

    return User(
      id: map['id'],
      token: map['token'] ,
      email: map['email'],
      role: 'client',
      informations: informations,
      favorites: map['favorites'] != null
          ? Favorites.fromMapInitial(map['favorites'])
          : null,
      userLocation: _getLocationOrDefault(map),
    );
  }

  static User _createBar(Map<String, dynamic> map) {
    final informations = Informations(
        name: map['informations']['name'] ?? '',
        address: map['informations']['address'],
        description: map['informations']['description'],
        pictures: map['informations']['pictures']);

    return User(
      id: map['id'],
      token: map['token'] ?? '',
      email: map['email'] ?? '',
      role: 'bar',
      informations: informations,
      programations: (map['programmedMatches'] as List<dynamic>?)
          ?.map((match) => ProgrammationMatch.fromJson(match))
          .toList(),
      favorites: map['favorites'] != null
          ? Favorites.fromMapInitial(map['favorites'])
          : null,
      userLocation: _getLocationOrDefault(map),
    );
  }

  static User createGuest({Location? location}) {
    final informations = Informations(name: 'guest');

    return User(
      id: '',
      token: '',
      email: '',
      role: 'guest',
      informations: informations,
      userLocation: location ??
          Location(latitude: 0.0, longitude: 0.0, isActivated: false),
    );
  }

  static Location _getLocationOrDefault(Map<String, dynamic> map) {
    return map['userLocation'] != null
        ? Location.fromJson(map['userLocation'])
        : Location(latitude: 0.0, longitude: 0.0, isActivated: false);
  }
}
