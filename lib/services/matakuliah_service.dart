import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/matakuliah.dart';
import 'api_service.dart';

class MataKuliahService {
  static const String baseUrl = '${ApiService.baseUrl}/api/matakuliah';

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

  Future<List<MataKuliah>> fetchAll() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse(baseUrl), headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => MataKuliah.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data mata kuliah');
    }
  }

  Future<bool> add(MataKuliah mk) async {
    final headers = await _getHeaders();
    final body = jsonEncode({
      'kode': mk.kode,
      'nama': mk.nama,
      'sks': mk.sks,
      'day': mk.day,
      'startTime': mk.startTime,
      'endTime': mk.endTime,
    });

    print('=== DEBUG add() ===');
    print('URL: $baseUrl');
    print('Headers: $headers');
    print('Request Body: $body');

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: headers,
      body: body,
    );

    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> update(MataKuliah mk) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/${mk.id}'),
      headers: headers,
      body: jsonEncode({
        'kode': mk.kode,
        'nama': mk.nama,
        'sks': mk.sks,
        'day': mk.day,
        'startTime': mk.startTime,
        'endTime': mk.endTime,
      }),
    );
    return response.statusCode == 200;
  }

  Future<MataKuliah> fetchById(int id) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$id'), // Assuming endpoint is like /api/matakuliah/{id}
      headers: headers,
    );

    if (response.statusCode == 200) {
      return MataKuliah.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Mata Kuliah with ID $id not found.');
    } else {
      throw Exception('Failed to load Mata Kuliah: ${response.statusCode}');
    }
  }


  Future<bool> delete(int id) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: headers,
    );
    return response.statusCode == 204;
  }
}
