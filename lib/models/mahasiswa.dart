class Mahasiswa {
  int? id;
  String? username;
  String? password;
  String? nim;
  String? prodi;

  Mahasiswa({
    this.id,
    this.username,
    this.password,
    this.nim,
    this.prodi,
  });

  factory Mahasiswa.fromJson(Map<String, dynamic> json) {
    return Mahasiswa(
      id: json['id'],
      username: json['username'],
      password: json['password'],
      nim: json['nim'],
      prodi: json['prodi'],
    );
  }

  Map<String, dynamic> toJson({bool includePassword = true}) {
    final map = {
      'username': username,
      'nim': nim,
      'prodi': prodi,
    };

    if (includePassword && password != null) {
      map['password'] = password;
    }

    return map;
  }
}
