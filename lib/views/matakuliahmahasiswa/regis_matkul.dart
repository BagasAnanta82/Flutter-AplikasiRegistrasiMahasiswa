import 'package:flutter/material.dart';
import '../../models/matakuliah.dart';
import '../../services/matakuliahmahasiswa_service.dart';
import '../../services/matakuliah_service.dart';
import '../../services/mahasiswa_service.dart';

class RegisMatkulPage extends StatefulWidget {
  @override
  _RegisMatkulPageState createState() => _RegisMatkulPageState();
}

class _RegisMatkulPageState extends State<RegisMatkulPage> {
  int? _mahasiswaId;
  List<MataKuliah> _mataKuliahList = [];
  Set<int> _selectedMatkulIds = Set();

  final MataKuliahMahasiswaService _matakuliahmahasiswaService = MataKuliahMahasiswaService();
  final MataKuliahService _matakuliahService = MataKuliahService();
  final MahasiswaService _mahasiswaService = MahasiswaService();

  @override
  void initState() {
    super.initState();
    _initPage();
  }

  Future<void> _initPage() async {
    try {
      final id = await _mahasiswaService.fetchMahasiswaId();

      if (id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mahasiswa ID tidak ditemukan')),
        );
        return;
      }

      final transkrip = await _matakuliahmahasiswaService.fetchTranskrip();
      final selectedMatkulIds = transkrip.map((e) => e.mataKuliah.id).toSet();

      final mataKuliahList = await _matakuliahService.fetchAll();

      setState(() {
        _mahasiswaId = id;
        _mataKuliahList = mataKuliahList;
        _selectedMatkulIds = selectedMatkulIds;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> _assignMataKuliah(int mataKuliahId) async {
    if (_mahasiswaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mahasiswa tidak ditemukan')),
      );
      return;
    }

    try {
      final success = await _matakuliahmahasiswaService.assignMataKuliah(
        _mahasiswaId!,
        mataKuliahId,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Registrasi berhasil' : 'Gagal melakukan registrasi'),
      ));

      if (success) {
        setState(() {
          _selectedMatkulIds.add(mataKuliahId);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> _confirmCancel(int mataKuliahId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus Mata Kuliah ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (_mahasiswaId != null) {
                  try {
                    final success = await _matakuliahmahasiswaService.cancelAssignMataKuliah(
                      _mahasiswaId!,
                      mataKuliahId,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mata Kuliah berhasil dibatalkan')),
                      );
                      setState(() {
                        _selectedMatkulIds.remove(mataKuliahId);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal membatalkan Mata Kuliah')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Terjadi kesalahan: $e')),
                    );
                  }
                }
                Navigator.of(context).pop();
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  String _formatJadwal(MataKuliah mk) {
    return '${mk.day} (${mk.startTime} - ${mk.endTime})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrasi Mata Kuliah')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _mataKuliahList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.5, // lebih tinggi dari 2 jadi 1.5
          ),
          itemCount: _mataKuliahList.length,
          itemBuilder: (context, index) {
            final matkul = _mataKuliahList[index];
            final isSelected = _selectedMatkulIds.contains(matkul.id);

            return GestureDetector(
              onTap: () {
                if (isSelected) {
                  _confirmCancel(matkul.id!);
                } else {
                  _assignMataKuliah(matkul.id!);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.red : Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        matkul.nama,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${matkul.sks} SKS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatJadwal(matkul),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
