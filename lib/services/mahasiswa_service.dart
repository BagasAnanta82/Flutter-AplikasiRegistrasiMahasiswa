import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mahasiswa.dart';
import 'api_service.dart';

class MahasiswaService {
  static final String baseUrl = '${ApiService.baseUrl}/api/mahasiswa';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }


  Future<List<Mahasiswa>> fetchMahasiswa() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Mahasiswa.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data mahasiswa');
    }
  }

  Future<bool> addMahasiswa(Mahasiswa mahasiswa, String password) async {
    final headers = await _getHeaders();

    final data = {
      'username': mahasiswa.username,
      'nim': mahasiswa.nim,
      'prodi': mahasiswa.prodi,
      'password': password,
      'roles': ['ROLE_MAHASISWA'], // Tambahkan role default
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updateMahasiswa(Mahasiswa mahasiswa) async {
    final headers = await _getHeaders();

    final data = {
      'username': mahasiswa.username,
      'nim': mahasiswa.nim,
      'prodi': mahasiswa.prodi,
      'password': mahasiswa.password, // Keep existing password
      'roles': ['ROLE_MAHASISWA'], // Keep or default role
    };

    final response = await http.put(
      Uri.parse('$baseUrl/${mahasiswa.id}'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> deleteMahasiswa(int id) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  Future<int?> fetchMahasiswaId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final mahasiswaId = data['mahasiswaId'];
      await prefs.setInt('mahasiswaId', mahasiswaId); // simpan lokal
      return mahasiswaId;
    } else {
      print("Gagal ambil mahasiswaId: ${response.body}");
      return null;
    }
  }
}
