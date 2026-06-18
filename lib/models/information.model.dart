class Informations {

  // Champs spécifique aux clients
  String? firstName;
  String? lastName;

  // Champs spécifiques aux bars
  String? name;
  String? description;
  String? address;
  List<dynamic>? pictures;

  Informations({
    this.firstName,
    this.lastName,
    this.name,
    this.description,
    this.address,
    this.pictures,
  });

  factory Informations.fromJson(Map<String, dynamic> data) {
    return Informations(
      firstName: data['firstName']?? 'guest',
      lastName: data['lastName'],
      name: data['name'],
      description: data['description'],
      address: data['address'],
      pictures: data['pictures'],
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
    };
  }
}
