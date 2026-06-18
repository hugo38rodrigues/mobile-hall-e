class Location {
  bool isActivated;
  double latitude;
  double longitude;

  Location({
    required this.isActivated,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> data) {
    return Location(
      isActivated: data['isActivated'] ?? false,
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
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
