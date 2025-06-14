import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../common/login_screen.dart';
import '../matakuliahmahasiswa/transkrip_mahasiswa.dart';
import '../matakuliahmahasiswa/regis_matkul.dart';
import '../matakuliahmahasiswa/scan_matkul_page.dart';

class DashboardMahasiswa extends StatefulWidget {
  final String username;

  const DashboardMahasiswa({super.key, required this.username});

  @override
  State<DashboardMahasiswa> createState() => _DashboardMahasiswaState();
}

class _DashboardMahasiswaState extends State<DashboardMahasiswa> {
  int _currentIndex = 0;
  String _location = 'Memuat lokasi...';

  // Pastikan path untuk halaman-halaman ini benar
  final List<Widget> _pages = [
    TranskripMahasiswaPage(),
    ScanMatkulPage(),
    RegisMatkulPage(),
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _location = 'Lokasi tidak aktif');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _location = 'Izin ditolak');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted)
        setState(() => _location = 'Izin lokasi permanen ditolak');
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty && mounted) {
      setState(() {
        _location = placemarks.first.locality ?? 'Tidak diketahui';
      });
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup konfirmasi
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Ya'),
          ),
        ],
      ),
    );
  }

  void _showUserPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Username: ${widget.username}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup popup pertama
                _showLogoutConfirmation(); // Tampilkan konfirmasi
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
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
              onPressed: _showUserPopup,
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner), label: 'Scan Matkul'),
          BottomNavigationBarItem(icon: Icon(Icons.sync_alt), label: 'Relasi'),
        ],
      ),
    );
  }
}