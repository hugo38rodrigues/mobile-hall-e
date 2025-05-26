class Location {
  bool isActivated;
  double latitude;
  double longitude;

  Location({
    required this.isActivated,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> map) {
    return Location(
      isActivated: map['isActivated'] ?? false,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isActivated': isActivated,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
