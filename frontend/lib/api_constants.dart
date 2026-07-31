class ApiConstants {
  // Render Live Backend URL
  static const String baseUrl = 'https://restosync-pos.onrender.com';

  // API Endpoints
  static const String healthCheck = '$baseUrl/health';
  static const String syncStatus = '$baseUrl/sync/status';
  static const String login = '$baseUrl/api/auth/login';
  static const String products = '$baseUrl/api/products';
  static const String orders = '$baseUrl/api/orders';
}
