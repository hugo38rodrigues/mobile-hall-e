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

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      acronym: json['acronym'] ?? '',
      logoUrl: json['logoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'acronym': acronym,
      'logoUrl': logoUrl,
    };
  }
}
