import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../mahasiswa/mahasiswa_list.dart';
import '../matakuliah/matakuliah_list.dart';
import 'pegawai_list.dart';
import '../common/login_screen.dart';
import '../matakuliahmahasiswa/update_nilai.dart';

class DashboardPegawai extends StatefulWidget {
  final String username;

  const DashboardPegawai({super.key, required this.username});

  @override
  State<DashboardPegawai> createState() => _DashboardPegawaiState();
}

class _DashboardPegawaiState extends State<DashboardPegawai> {
  int _currentIndex = 0;
  String _location = 'Memuat lokasi...';

  late final List<Widget> _pages = [
    const PegawaiList(),
    const MahasiswaList(),
    const MataKuliahList(),
    const UpdateNilaiPage(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _location = 'Lokasi tidak aktif');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _location = 'Izin ditolak');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _location = 'Izin lokasi permanen ditolak');
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks =
      await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _location = placemarks.first.locality ?? placemarks.first.subLocality ?? 'Tidak diketahui';
        });
      } else {
        setState(() => _location = 'Lokasi tidak ditemukan');
      }
    } catch (e) {
      setState(() => _location = 'Error: ${e.toString()}');
    }
  }

  void _showProfilePopup() {
    showDialog(
      context: context,
      builder: (context) {
        bool showConfirmLogout = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Profil Pengguna'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.username),
                  const SizedBox(height: 16),
                  if (!showConfirmLogout)
                    ElevatedButton(
                      onPressed: () => setState(() => showConfirmLogout = true),
                      child: const Text('Logout'),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => showConfirmLogout = false),
                          child: const Text('Tidak'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Tutup popup
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text('Ya'),
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.location_on, color: Colors.red, size: 20),
            const SizedBox(width: 4),
            Text(_location, style: const TextStyle(fontSize: 14)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.account_circle, size: 30),
              onPressed: _showProfilePopup,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pegawai'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Mahasiswa'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Mata Kuliah'),
          BottomNavigationBarItem(icon: Icon(Icons.edit), label: 'Edit Nilai'),
        ],
      ),
    );
  }
}
