class UserCredentiels {
  String email;
  String password;
  String role;

  UserCredentiels({
    required this.email,
    required this.password,
    required this.role,
  });

  factory UserCredentiels.fromJson(Map<String, dynamic> data) {
    return UserCredentiels(
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      role: data['role'] ?? '',
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