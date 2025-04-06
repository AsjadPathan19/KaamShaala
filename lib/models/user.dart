class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? fcmToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.fcmToken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'fcmToken': fcmToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      fcmToken: map['fcmToken'],
    );
  }
}
