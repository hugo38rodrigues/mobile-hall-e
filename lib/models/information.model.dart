class Informations {

  // Champs spécifique aux clients
  String? firstName;
  String? lastName;

  // Champs spécifiques aux bars
  String? name;
  String? description;
  String? address;
  List<dynamic>? pictures;
  double? longitude;
  double? latitude;

  Informations({
    this.firstName,
    this.lastName,
    this.name,
    this.description,
    this.address,
    this.pictures,
    this.longitude,
    this.latitude,
  });

  factory Informations.fromJson(Map<String, dynamic> json) {
    return Informations(
      firstName: json['firstName'],
      lastName: json['lastName'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      pictures: json['pictures'],
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'name': name,
      'description': description,
      'address': address,
      'pictures': pictures,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
