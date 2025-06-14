class MataKuliah {
  final int id;
  final String kode;
  final String nama;
  final int sks;
  final String day;
  final String startTime;
  final String endTime;

  MataKuliah({
    required this.id,
    required this.kode,
    required this.nama,
    required this.sks,
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      id: json['id'] ?? 0,
      kode: json['kode'] ?? '',
      nama: json['nama'] ?? '',
      sks: json['sks'] ?? 0,
      day: json['day'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kode': kode,
      'nama': nama,
      'sks': sks,
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}
