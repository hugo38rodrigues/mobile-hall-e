class UserCredentiels {
  String email;
  String password;
  String role;

  UserCredentiels({
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserCredentiels.fromJson(Map<String, dynamic> json) {
    return UserCredentiels(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'role': role,
    };
  }

}