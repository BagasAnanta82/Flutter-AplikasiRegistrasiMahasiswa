import 'package:flutter/material.dart';
import '../../models/matakuliahmahasiswa.dart';
import '../../services/matakuliahmahasiswa_service.dart';
import '../../utils/generate_pdf.dart';

class TranskripMahasiswaPage extends StatefulWidget {
  const TranskripMahasiswaPage({Key? key}) : super(key: key);

  @override
  State<TranskripMahasiswaPage> createState() => _TranskripMahasiswaPageState();
}

class _TranskripMahasiswaPageState extends State<TranskripMahasiswaPage> {
  late Future<List<MataKuliahMahasiswa>> _transkripFuture;

  @override
  void initState() {
    super.initState();
    _transkripFuture = MataKuliahMahasiswaService().fetchTranskrip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transkrip Mahasiswa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final transkrip = await _transkripFuture;
              await generatePdf(transkrip); // Fungsi generate PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF berhasil dibuat')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<MataKuliahMahasiswa>>(
        future: _transkripFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data transkrip.'));
          }

          final transkrip = snapshot.data!;
          return ListView.builder(
            itemCount: transkrip.length,
            itemBuilder: (context, index) {
              final data = transkrip[index];
              final mk = data.mataKuliah;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${mk.nama} (${mk.kode})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('SKS: ${mk.sks}'),
                      const SizedBox(height: 4),
                      Text('UTS: ${data.uts}, UAS: ${data.uas}, Kuis: ${data.kuis}'),
                      const SizedBox(height: 4),
                      Text('Total: ${data.total}, Grade: ${data.grade ?? "-"}'),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: (data.total / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getProgressColor(data.total),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getProgressColor(int total) {
    if (total >= 85) return Colors.green;
    if (total >= 70) return Colors.lightGreen;
    if (total >= 60) return Colors.orange;
    return Colors.redAccent;
  }
}
