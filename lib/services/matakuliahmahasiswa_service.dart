import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/matakuliahmahasiswa.dart';
import 'api_service.dart';

class MataKuliahMahasiswaService {
  static const String baseUrl = '${ApiService.baseUrl}/api/matakuliahmahasiswa';

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

  Future<List<MataKuliahMahasiswa>> fetchTranskrip() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/transkrip'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => MataKuliahMahasiswa.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data transkrip');
    }
  }

  // Menambahkan MataKuliah ke Mahasiswa
  Future<bool> assignMataKuliah(int mahasiswaId, int mataKuliahId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/assign?mahasiswaId=$mahasiswaId&mataKuliahId=$mataKuliahId'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // Membatalkan Pendaftaran MataKuliah
  Future<bool> cancelAssignMataKuliah(int mahasiswaId, int mataKuliahId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/delete?mahasiswaId=$mahasiswaId&mataKuliahId=$mataKuliahId'),
      headers: headers,
    );

    return response.statusCode == 204;
  }

  // Metode untuk memperbarui nilai (UTS, UAS, Kuis)
  Future<bool> updateNilai(int id, int uts, int uas, int kuis) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/update-nilai?id=$id&uts=$uts&uas=$uas&kuis=$kuis'),
      headers: headers,
    );

    return response.statusCode == 200;
  }

  // NEW: Metode untuk mengambil semua relasi MataKuliahMahasiswa
  Future<List<MataKuliahMahasiswa>> fetchAllMataKuliahMahasiswaRelations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/all'), // Panggil endpoint baru yang sudah dibuat di backend
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Pastikan MataKuliahMahasiswa.fromJson dapat mengurai Mahasiswa dan MataKuliah nested objects.
      return data.map((e) => MataKuliahMahasiswa.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil semua relasi Mata Kuliah Mahasiswa: ${response.statusCode}');
    }
  }
}
