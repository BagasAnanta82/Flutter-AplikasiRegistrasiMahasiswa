enum Role { MAHASISWA, PEGAWAI }

Role roleFromString(String role) {
  return Role.values.firstWhere((e) => e.name == role);
}

class User {
  final int id;
  final String username;
  final String password;
  final Role role;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      role: roleFromString(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'role': role.name,
    };
  }
}
