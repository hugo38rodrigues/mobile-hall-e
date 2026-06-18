class Team {
  String id;
  String name;
  String acronym;
  String logoUrl;

  Team({
    required this.id,
    required this.name,
    required this.acronym,
    required this.logoUrl,
  });

  factory Team.fromJson(Map<String, dynamic> data) {
    return Team(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      acronym: data['acronym'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'acronym': acronym,
      'logoUrl': logoUrl,
    };
  }
}
