class League {
  String id;
  String name;


  League({
    required this.id,
    required this.name,
  });

  factory League.fromJson(Map<String, dynamic> data) {
    return League(
      id: data['id'] ?? '',
      name: data['name'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
