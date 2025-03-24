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

  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      acronym: map['acronym'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
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
