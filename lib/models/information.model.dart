abstract class Informations {
  factory Informations.fromJson(Map<String, dynamic> json, String role) {
    if (role == 'client') {
      return ClientInformationsModel.fromJson(json);
    } else {
      return BarInformationsModel.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class BarInformationsModel implements Informations {
  String name;
  String description;
  String address;
  List pictures;

  BarInformationsModel({
    required this.name,
    required this.description,
    required this.address,
    required this.pictures,
  });

  factory BarInformationsModel.fromJson(Map<String, dynamic> json) {
    return BarInformationsModel(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'],
      pictures: json['pictures'] ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'address': address,
      'pictures': pictures
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
