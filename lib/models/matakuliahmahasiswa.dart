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
      prodi: json['prodi']
    );
  }
}

class MataKuliah {
  final int id;
  final String nama;
  final String kode;
  final int sks;

  MataKuliah({
    required this.id,
    required this.nama,
    required this.kode,
    required this.sks,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      sks: json['sks'],
    );
  }
}

class MataKuliahMahasiswa {
  final int id;
  final MataKuliah mataKuliah;
  final int uts;
  final int uas;
  final int kuis;
  final int total;
  final String? grade;

  MataKuliahMahasiswa({
    required this.id,
    required this.mataKuliah,
    required this.uts,
    required this.uas,
    required this.kuis,
    required this.total,
    required this.grade,
  });

  factory MataKuliahMahasiswa.fromJson(Map<String, dynamic> json) {
    return MataKuliahMahasiswa(
      id: json['id'],
      mataKuliah: MataKuliah.fromJson(json['mataKuliah']),
      uts: json['uts'],
      uas: json['uas'],
      kuis: json['kuis'],
      total: json['total'],
      grade: json['grade'],
    );
  }
}
