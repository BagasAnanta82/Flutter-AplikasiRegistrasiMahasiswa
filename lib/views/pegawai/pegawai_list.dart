import 'package:flutter/material.dart';
import '../../models/pegawai.dart';
import '../../services/pegawai_service.dart';
import 'pegawai_form.dart';

class PegawaiList extends StatefulWidget {
  const PegawaiList({Key? key}) : super(key: key);

  @override
  State<PegawaiList> createState() => _PegawaiListState();
}

class _PegawaiListState extends State<PegawaiList> {
  final PegawaiService _pegawaiService = PegawaiService();
  late Future<List<Pegawai>> _pegawaiList;
  Set<String> _posisiFilterSet = {'All'};
  String _selectedPosisi = 'All';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadPegawai();
  }

  void _loadPegawai() {
    _pegawaiList = _pegawaiService.fetchPegawai();
    _pegawaiList.then((list) {
      final posisiSet = list.map((p) => p.posisi).toSet();
      setState(() {
        _posisiFilterSet = {'All', ...posisiSet};
      });
    });
  }

  void _deletePegawai(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus pegawai ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await _pegawaiService.deletePegawai(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil dihapus')),
      );
      _loadPegawai();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus')),
      );
    }
  }

  void _openForm({Pegawai? pegawai}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PegawaiForm(pegawai: pegawai),
      ),
    );
    if (result == true) _loadPegawai();
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
                hintText: 'Cari pegawai...',
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
              itemCount: _posisiFilterSet.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = _posisiFilterSet.elementAt(index);
                final isSelected = _selectedPosisi == label;

                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedPosisi = label);
                  },
                  selectedColor: Colors.blue.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.blue.shade800 : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Pegawai>>(
              future: _pegawaiList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Tidak ada data pegawai'));
                }

                final filteredList = snapshot.data!.where((p) {
                  final username = p.username.toLowerCase();
                  final nip = p.nip.toLowerCase();
                  final posisi = p.posisi.toLowerCase();

                  final matchesSearch = username.contains(_searchQuery) ||
                      nip.contains(_searchQuery) ||
                      posisi.contains(_searchQuery);
                  final matchesFilter = _selectedPosisi == 'All' ||
                      posisi == _selectedPosisi.toLowerCase();

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredList.isEmpty) {
                  return const Center(child: Text('Data tidak ditemukan'));
                }

                return ListView.separated(
                  itemCount: filteredList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
                  itemBuilder: (context, index) {
                    final pegawai = filteredList[index];
                    final bgColor = index % 2 == 0 ? Colors.grey[100] : Colors.white;

                    return Container(
                      color: bgColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          pegawai.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('NIP: ${pegawai.nip} • Posisi: ${pegawai.posisi}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openForm(pegawai: pegawai),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePegawai(pegawai.id),
                            ),
                          ],
                        ),
                        onTap: () => _openForm(pegawai: pegawai),
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
        tooltip: 'Tambah Pegawai',
        shape: const CircleBorder(),
      ),
    );
  }
}
