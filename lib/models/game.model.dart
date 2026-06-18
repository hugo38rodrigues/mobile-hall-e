class Game {
  String id;
  String name;


  Game({
    required this.id,
    required this.name,
  });

  factory Game.fromJson(Map<String, dynamic> data) {
    return Game(
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
