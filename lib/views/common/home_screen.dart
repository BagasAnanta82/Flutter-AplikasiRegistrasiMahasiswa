// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../mahasiswa/dashboard_mahasiswa.dart';
import '../pegawai/dashboard_pegawai.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<Map<String, dynamic>?> getUserInfoFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || JwtDecoder.isExpired(token)) return null;

    final decodedToken = JwtDecoder.decode(token);
    return {
      'username': decodedToken['sub'],
      'role': decodedToken['roles'][0], // Ambil role pertama dari array
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserInfoFromToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return const LoginScreen(); // Token tidak ada / expired → redirect ke login
        }

        final user = snapshot.data!;
        final role = user['role'];

        // Redirect ke dashboard sesuai role
        if (role == 'ROLE_MAHASISWA') {
          return DashboardMahasiswa(username: user['username']);
        } else if (role == 'ROLE_PEGAWAI') {
          return DashboardPegawai(username: user['username']);
        } else {
          return Scaffold(
            body: Center(child: Text('Role tidak dikenali: $role')),
          );
        }
      },
    );
  }
}
