class ProgramationMatch {
  String id;
  String address;
  String name;
  double latitude;
  double longitude;

  ProgramationMatch({
    required this.id,
    required this.address,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory ProgramationMatch.fromJson(Map<String, dynamic> json) {
    return ProgramationMatch(
      id: json['_id'],
      address: json['address'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      name: json['name'],
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
