import 'dart:io';
import 'package:get/get.dart';
import 'storage_service.dart';

class ApiService extends GetConnect {

  @override
  void onInit() {
    httpClient.baseUrl = "https://yourapi.com/api/";
    httpClient.timeout = const Duration(seconds: 30);

    // 🔐 TOKEN AUTO ATTACH
httpClient.addRequestModifier<dynamic>((request) {

      final token = StorageService.getToken();

      if (token != null) {
        request.headers['Authorization'] = "Bearer $token";
      }

      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    // 🚨 RESPONSE HANDLE
    httpClient.addResponseModifier((request, response) {

      if (response.statusCode == 400 || response.statusCode == 401) {
        _logout();
      }

      return response;
    });

    super.onInit();
  }

  // =========================
  // ✅ POST
  // =========================
  Future<Response> postRequest(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await post(endpoint, body);
      return response;

    } on SocketException {
      return _noInternet();
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // =========================
  // ✅ MULTIPART
  // =========================
  Future<Response> multipartRequest(
    String endpoint,
    Map<String, dynamic> fields,
    String fileField,
    String filePath,
  ) async {
    try {
      final formData = FormData({
        ...fields,
        fileField: MultipartFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await post(endpoint, formData);
      return response;

    } on SocketException {
      return _noInternet();
    } catch (e) {
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // =========================
  // ❌ NO INTERNET
  // =========================
  Response _noInternet() {
    Get.snackbar("No Internet", "Check your connection");

    return Response(
      statusCode: 0,
      statusText: "No Internet",
    );
  }

  // =========================
  // 🔐 LOGOUT
  // =========================
  void _logout() {
    StorageService.clear();
    Get.offAllNamed("/login");

    Get.snackbar("Session Expired", "Login again");
  }
}