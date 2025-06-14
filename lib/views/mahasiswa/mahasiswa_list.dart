import 'package:flutter/material.dart';
import '../../models/mahasiswa.dart';
import '../../services/mahasiswa_service.dart';
import 'mahasiswa_form.dart';

class MahasiswaList extends StatefulWidget {
  const MahasiswaList({Key? key}) : super(key: key);

  @override
  State<MahasiswaList> createState() => _MahasiswaListState();
}

class _MahasiswaListState extends State<MahasiswaList> {
  final MahasiswaService _mahasiswaService = MahasiswaService();
  late Future<List<Mahasiswa>> _mahasiswaList;
  Set<String> _prodiFilterSet = {'All'};
  String _selectedProdi = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMahasiswa();
  }

  void _loadMahasiswa() {
    _mahasiswaList = _mahasiswaService.fetchMahasiswa();
    _mahasiswaList.then((list) {
      final prodiSet = list.map((m) => m.prodi ?? '').toSet();
      setState(() {
        _prodiFilterSet = {'All', ...prodiSet.where((e) => e.isNotEmpty)};
      });
    });
  }

  void _deleteMahasiswa(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus data Mahasiswa ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Tutup dialog terlebih dahulu
              final success = await _mahasiswaService.deleteMahasiswa(id);
              if (success) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Berhasil dihapus')),
                );
                _loadMahasiswa();
              } else {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gagal menghapus')),
                );
              }
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _openForm({Mahasiswa? mahasiswa}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MahasiswaForm(mahasiswa: mahasiswa),
      ),
    );
    if (result == true) _loadMahasiswa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari mahasiswa...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _prodiFilterSet.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _prodiFilterSet.elementAt(index);
                final isSelected = _selectedProdi == label;

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedProdi = label);
                  },
                  selectedColor: Colors.green.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.green.shade800 : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Mahasiswa>>(
              future: _mahasiswaList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data mahasiswa'));
                }

                final filteredList = snapshot.data!.where((m) {
                  final username = m.username?.toLowerCase() ?? '';
                  final nim = m.nim?.toLowerCase() ?? '';
                  final prodi = m.prodi?.toLowerCase() ?? '';

                  final matchesSearch = username.contains(_searchQuery) ||
                      nim.contains(_searchQuery) ||
                      prodi.contains(_searchQuery);
                  final matchesFilter = _selectedProdi == 'All' ||
                      prodi == _selectedProdi.toLowerCase();

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                return ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
                  itemBuilder: (context, index) {
                    final mahasiswa = filteredList[index];
                    final bgColor = index % 2 == 0 ? Colors.grey[100] : Colors.white;

                    return Container(
                      color: bgColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          mahasiswa.username ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('NIM: ${mahasiswa.nim ?? '-'} • Prodi: ${mahasiswa.prodi ?? '-'}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openForm(mahasiswa: mahasiswa),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteMahasiswa(mahasiswa.id ?? 0),
                            ),
                          ],
                        ),
                        onTap: () => _openForm(mahasiswa: mahasiswa),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
        tooltip: 'Tambah Mahasiswa',
        shape: const CircleBorder(),
      ),
    );
  }
}
