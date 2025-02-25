class User {
  String id;
  String email;
  String role;
  String token;
  Map<String, dynamic> informations;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.informations,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'informations': informations,
    };
  }
  // Méthode de conversion pour créer un objet User à partir d'un Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'client',
      token: map['token'] ?? '',
      informations: map['informations'] != null
          ? Map<String, dynamic>.from(map['informations'])
          : {},
    );
  }
}
