import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hacky_pizza_pos/models/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const _baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://your-backend-url.com/api');
  static final _storage = const FlutterSecureStorage();

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.write(key: 'accessToken', value: data['accessToken']);
      await _storage.write(key: 'refreshToken', value: data['refreshToken']);
      return data;
    }
    return null;
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  static Future<String?> getAccessToken() async => await _storage.read(key: 'accessToken');
}
