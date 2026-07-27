import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await http.get(url, headers: await _headers());
    return jsonDecode(response.body);
  }

  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await http.post(url, headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(response.body);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final response = await http.put(url, headers: await _headers(), body: jsonEncode(body));
    return jsonDecode(response.body);
  }
}
