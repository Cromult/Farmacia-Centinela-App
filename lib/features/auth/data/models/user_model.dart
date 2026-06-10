class UserModel {
  final String id; // Según tu backend 'sub' puede ser number o string, lo tipamos a int si tu DB usa IDs numéricos
  final String email;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.email,
    required this.roles,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
    );
  }
}