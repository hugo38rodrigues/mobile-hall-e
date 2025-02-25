// lib/models/user.dart
class User {
  final String id;
  final String email;
  final String role;
  final String token;
  final Map<String, dynamic> informations;

  User({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
    required this.informations,
  });
 
  // Convertir l'objet User en un Map pour la persistance
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'token': token,
      'informations': informations,
    };
  }

  // Créer un User à partir d'un Map
  static User fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'invité',
      token: map['token'] ?? '',
      informations: Map<String, String>.from(map['informations'] ?? {}),
    );
  }
  
}
