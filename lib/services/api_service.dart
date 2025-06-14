// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  // static const String baseUrl = 'http://192.168.18.10:8080';
  static const String baseUrl = 'http://10.0.2.2:8080'; // Emulator
  //static const String baseUrl = 'http://ipv4Adr:8080';

  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final token = body['token'];
      final decodedToken = JwtDecoder.decode(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('username', decodedToken['sub']);
      await prefs.setString('role', decodedToken['roles'][0]); // Simpan role pertama

      return true;
    } else {
      print('Login failed: ${response.body}');
      return false;
    }
  }


  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}
