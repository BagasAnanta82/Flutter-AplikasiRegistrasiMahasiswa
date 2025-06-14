import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pegawai.dart';
import 'api_service.dart';

class PegawaiService {
  static const String baseUrl = '${ApiService.baseUrl}/api/pegawai';

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

  Future<List<Pegawai>> fetchPegawai() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => Pegawai.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat data pegawai');
    }
  }

  Future<bool> addPegawai(Pegawai pegawai, String password) async {
    final headers = await _getHeaders();

    final data = {
      'username': pegawai.username,
      'nip': pegawai.nip,
      'posisi': pegawai.posisi,
      'password': password,
      'roles': ['ROLE_PEGAWAI'], // 🚀 Tambahkan role default
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> updatePegawai(Pegawai pegawai) async {
    final headers = await _getHeaders();

    final data = {
      'username': pegawai.username,
      'nip': pegawai.nip,
      'posisi': pegawai.posisi,
      'password': pegawai.password, // Keep existing password
      'roles': pegawai.roles ?? ['ROLE_PEGAWAI'], // Keep or default role
    };

    final response = await http.put(
      Uri.parse('$baseUrl/${pegawai.id}'),
      headers: headers,
      body: jsonEncode(data),
    );

    return response.statusCode == 200;
  }

  Future<bool> deletePegawai(int id) async {
    final headers = await _getHeaders();

    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );

    return response.statusCode == 204;
  }
}
