import 'package:flutter/material.dart';
import '../../models/matakuliah.dart';
import '../../services/matakuliah_service.dart';
import 'matakuliah_form.dart';

class MataKuliahList extends StatefulWidget {
  const MataKuliahList({super.key});

  @override
  State<MataKuliahList> createState() => _MataKuliahListState();
}

class _MataKuliahListState extends State<MataKuliahList> {
  final service = MataKuliahService();
  late Future<List<MataKuliah>> _futureData;
  List<MataKuliah> _allData = [];
  String _searchQuery = '';
  int _selectedSks = 0; // 0 = All
  Set<int> _availableSks = {0};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _futureData = service.fetchAll().then((data) {
        _allData = data;
        final sksSet = data.map((e) => e.sks).whereType<int>().toSet();
        _availableSks = {0, ...sksSet};
        return data;
      });
    });
  }

  void _openForm({MataKuliah? mk}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MataKuliahForm(mk: mk),
      ),
    );
    if (result == true) _loadData();
  }

  void _delete(int id) async {
    final success = await service.delete(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Berhasil dihapus')),
      );
      _loadData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus')),
      );
    }
  }

  List<MataKuliah> _filteredData() {
    return _allData.where((mk) {
      final query = _searchQuery.toLowerCase();
      final matchSearch =
          mk.nama.toLowerCase().contains(query) || mk.kode.toLowerCase().contains(query);
      final matchSks = _selectedSks == 0 || mk.sks == _selectedSks;
      return matchSearch && matchSks;
    }).toList();
  }

  String _formatJadwal(MataKuliah mk) {
    if ((mk.day?.isEmpty ?? true) ||
        (mk.startTime?.isEmpty ?? true) ||
        (mk.endTime?.isEmpty ?? true)) {
      return 'Jadwal belum lengkap';
    }
    return '${mk.day} (${mk.startTime} - ${mk.endTime})';
  }

  void _showQrPopup(MataKuliah mk) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9), // transparan
        title: Text(
          'QR Mata Kuliah',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              mk.nama.toString(),
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Image.network(
              'https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${mk.id}',
              height: 300,
              width: 300,
              errorBuilder: (_, __, ___) =>
                  Icon(Icons.error, size: 150, color: Colors.red),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<MataKuliah>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = _filteredData();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari mata kuliah...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _availableSks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final sks = _availableSks.elementAt(index);
                    final label = sks == 0 ? 'All' : '$sks SKS';
                    final isSelected = sks == _selectedSks;

                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedSks = sks);
                      },
                      selectedColor: Colors.purple.shade200,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.purple.shade900 : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
              if (data.isEmpty)
                Expanded(child: Center(child: Text('Tidak ada data')))
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => Divider(height: 1, thickness: 1),
                    itemBuilder: (context, i) {
                      final mk = data[i];
                      final bgColor = i % 2 == 0 ? Colors.grey[100] : Colors.white;
                      return Container(
                        color: bgColor,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          title: Text(
                            mk.nama,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${mk.kode} • ${mk.sks} SKS\n${_formatJadwal(mk)}'),
                          isThreeLine: true,
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              // Tombol QR
                              IconButton(
                                icon: Icon(Icons.qr_code, color: Colors.deepPurple),
                                onPressed: () => _showQrPopup(mk),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openForm(mk: mk),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _delete(mk.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: Icon(Icons.add),
        tooltip: 'Tambah Mata Kuliah',
        shape: const CircleBorder(),
      ),
    );
  }
}
