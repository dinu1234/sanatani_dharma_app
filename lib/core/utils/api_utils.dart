class ApiUtils {
  ApiUtils._();

  static Map<String, dynamic>? asMap(dynamic body) {
    if (body is Map<String, dynamic>) {
      return body;
    }
    if (body is Map) {
      return Map<String, dynamic>.from(body);
    }
    return null;
  }

  static String? message(dynamic body) {
    final map = asMap(body);
    return map?['message']?.toString();
  }
}
