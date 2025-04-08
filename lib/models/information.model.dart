

abstract class Informations {
  factory Informations.fromJson(Map<String, dynamic> json, String role) {
    if (role == 'client') {
      return ClientInformationsModel.fromJson(json);
    } else if (role == 'bar') {
      return BarInformationsModel.fromJson(json);
    } else {
      return GuessInformationsModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class BarInformationsModel implements Informations {
  String name;
  String description;
  String address;
  List pictures;
  double longitude;
  double latitude;

  BarInformationsModel({
    required this.name,
    required this.description,
    required this.address,
    required this.pictures,
    required this.longitude,
    required this.latitude,
  });

  factory BarInformationsModel.fromJson(Map<String, dynamic> json) {
    return BarInformationsModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'],
      pictures: json['pictures'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'pictures': pictures,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}

class ClientInformationsModel implements Informations {
  String firstName;
  String lastName;

  ClientInformationsModel({
    required this.firstName,
    required this.lastName,
  });

  factory ClientInformationsModel.fromJson(Map<String, dynamic> json) {
    return ClientInformationsModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}

class GuessInformationsModel implements Informations {
  String firstName;
  String lastName;

  GuessInformationsModel({
    required this.firstName,
    required this.lastName,
  });

  factory GuessInformationsModel.fromJson(Map<String, dynamic> json) {
    return GuessInformationsModel(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
