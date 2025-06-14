import 'package:flutter/material.dart';
import '../../services/matakuliahmahasiswa_service.dart';
import '../../models/matakuliahmahasiswa.dart'; // Pastikan ini diimpor dan modelnya sudah benar
import '../../models/mahasiswa.dart'; // Import Mahasiswa model
import '../../models/matakuliah.dart'; // Import MataKuliah model

class UpdateNilaiPage extends StatefulWidget {
  const UpdateNilaiPage({super.key});

  @override
  State<UpdateNilaiPage> createState() => _UpdateNilaiPageState();
}

class _UpdateNilaiPageState extends State<UpdateNilaiPage> {
  // TextEditingControllers untuk mengelola input teks dari kolom formulir
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _utsController = TextEditingController();
  final TextEditingController _uasController = TextEditingController();
  final TextEditingController _kuisController = TextEditingController();

  // Instance dari MataKuliahMahasiswaService untuk melakukan panggilan API
  final MataKuliahMahasiswaService _matakuliahmahasiswaService = MataKuliahMahasiswaService();

  // State untuk menyimpan daftar relasi dan relasi yang dipilih
  List<MataKuliahMahasiswa> _relations = [];
  MataKuliahMahasiswa? _selectedRelation;
  bool _isLoading = true; // State untuk indikator loading

  @override
  void initState() {
    super.initState();
    _loadRelations(); // Memuat relasi saat halaman diinisialisasi
  }

  // Metode untuk memuat semua relasi MataKuliahMahasiswa dari API
  Future<void> _loadRelations() async {
    setState(() {
      _isLoading = true; // Mulai loading
    });
    try {
      final List<MataKuliahMahasiswa> fetchedRelations =
      await _matakuliahmahasiswaService.fetchAllMataKuliahMahasiswaRelations();
      setState(() {
        _relations = fetchedRelations;
        _isLoading = false; // Selesai loading
      });
    } catch (e) {
      setState(() {
        _isLoading = false; // Selesai loading meskipun ada error
        _relations = []; // Kosongkan daftar jika ada error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat relasi: ${e.toString()}')),
      );
      print('Error loading relations: $e');
    }
  }

  // Metode untuk menangani pemilihan relasi dari daftar
  void _onRelationSelected(MataKuliahMahasiswa relation) {
    setState(() {
      _selectedRelation = relation;
      // Isi controller dengan data dari relasi yang dipilih
      _idController.text = relation.id.toString();
      _utsController.text = relation.uts.toString();
      _uasController.text = relation.uas.toString();
      _kuisController.text = relation.kuis.toString();
    });
  }

  @override
  void dispose() {
    // Buang controller untuk membebaskan sumber daya
    _idController.dispose();
    _utsController.dispose();
    _uasController.dispose();
    _kuisController.dispose();
    super.dispose();
  }

  // Metode asinkron untuk menangani pengiriman formulir dan panggilan API
  Future<void> _submitUpdateNilai() async {
    if (_selectedRelation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih relasi terlebih dahulu.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Memperbarui nilai...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      // Pastikan ID berasal dari relasi yang dipilih
      final int id = _selectedRelation!.id!;
      final int uts = int.parse(_utsController.text);
      final int uas = int.parse(_uasController.text);
      final int kuis = int.parse(_kuisController.text);

      final bool success = await _matakuliahmahasiswaService.updateNilai(
        id,
        uts,
        uas,
        kuis,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai berhasil diperbarui!')),
        );
        // Refresh daftar setelah update berhasil
        _loadRelations();
        // Kosongkan pemilihan dan input setelah berhasil
        setState(() {
          _selectedRelation = null;
          _idController.clear();
          _utsController.clear();
          _uasController.clear();
          _kuisController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memperbarui nilai. Cek ID atau data yang dimasukkan.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
      print('Error submitting update nilai: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Nilai Mahasiswa'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Tampilkan loading indicator
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bagian untuk menampilkan daftar relasi
            Expanded(
              child: _relations.isEmpty
                  ? const Center(child: Text('Tidak ada relasi mata kuliah mahasiswa ditemukan.'))
                  : ListView.builder(
                itemCount: _relations.length,
                itemBuilder: (context, index) {
                  final relation = _relations[index];
                  return Card(
                    color: _selectedRelation?.id == relation.id
                        ? Colors.blue.shade100 // Warna berbeda untuk yang terpilih
                        : null,
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      onTap: () => _onRelationSelected(relation),
                      title: Text(
                        'Relasi ${relation.id} - ${relation.mataKuliah.nama}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          'ID Relasi: ${relation.id} | UTS: ${relation.uts} | UAS: ${relation.uas} | Kuis: ${relation.kuis}'),
                      trailing: _selectedRelation?.id == relation.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 32, thickness: 1), // Pemisah antara daftar dan form
            const Text(
              'Form Update Nilai',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            // Input field untuk ID Mata Kuliah Mahasiswa (read-only)
            TextFormField(
              controller: _idController,
              readOnly: true, // Membuat field ini hanya-baca
              decoration: const InputDecoration(
                labelText: 'ID Mata Kuliah Mahasiswa (Terpilih)',
                hintText: 'Pilih relasi di atas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Input field untuk nilai UTS
            TextFormField(
              controller: _utsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai UTS',
                hintText: 'Masukkan Nilai UTS',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Input field untuk nilai UAS
            TextFormField(
              controller: _uasController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai UAS',
                hintText: 'Masukkan Nilai UAS',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            // Input field untuk nilai Kuis
            TextFormField(
              controller: _kuisController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nilai Kuis',
                hintText: 'Masukkan Nilai Kuis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24.0),
            // Tombol untuk mengirim formulir
            ElevatedButton(
              onPressed: _submitUpdateNilai,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Simpan Nilai',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
