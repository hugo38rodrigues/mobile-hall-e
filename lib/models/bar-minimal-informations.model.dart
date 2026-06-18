class BarMinimalInformations {
  String id;
  String address;
  String name;
  double latitude;
  double longitude;

  BarMinimalInformations({
    required this.id,
    required this.address,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory BarMinimalInformations.fromJson(Map<String, dynamic> data) {
    return BarMinimalInformations(
      id: data['id'],
      address: data['address'],
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      name: data['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }
}
