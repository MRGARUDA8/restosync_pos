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

  // Base URL aur endpoint double-slash handling
  static Uri _buildUrl(String endpoint) {
    String baseUrl = AppConstants.apiBaseUrl;
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    return Uri.parse('$baseUrl$endpoint');
  }

  static dynamic _handleResponse(http.Response response) {
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
          'Server Returned Invalid Response (${response.statusCode})');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      final errorMessage = body is Map && body.containsKey('message')
          ? body['message']
          : 'Server Error (${response.statusCode})';
      throw Exception(errorMessage);
    }
  }

  static Future<dynamic> get(String endpoint) async {
    final url = _buildUrl(endpoint);
    final response = await http.get(url, headers: await _headers());
    return _handleResponse(response);
  }

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> body) async {
    final url = _buildUrl(endpoint);
    final response =
        await http.post(url, headers: await _headers(), body: jsonEncode(body));
    return _handleResponse(response);
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUrl(endpoint);
    final response =
        await http.put(url, headers: await _headers(), body: jsonEncode(body));
    return _handleResponse(response);
  }
}
