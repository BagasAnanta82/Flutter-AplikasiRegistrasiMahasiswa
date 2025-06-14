class Pegawai {
  final int id;
  final String username;
  final String nip;
  final String posisi;
  final String? password;
  final List<String>? roles;

  Pegawai({
    required this.id,
    required this.username,
    required this.nip,
    required this.posisi,
    this.password,
    this.roles,
  });

  factory Pegawai.fromJson(Map<String, dynamic> json) {
    return Pegawai(
      id: json['id'],
      username: json['username'],
      nip: json['nip'],
      posisi: json['posisi'],
      password: json['password'],
      roles: List<String>.from(json['roles'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nip': nip,
      'posisi': posisi,
      'password': password,
      'roles': roles,
    };
  }
}
