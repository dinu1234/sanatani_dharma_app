import 'dart:io';

import 'package:dharma_app/Profile/profile_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class ProfileRepository {
  ProfileRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<GetProfileResponseModel> getProfile() async {
    final response = await _apiService.getProfile();
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return GetProfileResponseModel.fromJson(mapBody);
    }

    return GetProfileResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch profile',
    );
  }

  Future<UpdateProfileResponseModel> updateProfile({
    String? fullName,
    String? currentLocation,
    String? gender,
    String? birthDate,
    String? birthTime,
    String? birthPlace,
    double? birthLat,
    double? birthLng,
    String? birthTimezone,
    String? profileImagePath,
  }) async {
    final fields = <String, dynamic>{};

    void addIfNotBlank(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        fields[key] = value.trim();
      }
    }

    addIfNotBlank('full_name', fullName);
    addIfNotBlank('current_location', currentLocation);
    addIfNotBlank('gender', gender);
    addIfNotBlank('birth_date', birthDate);
    addIfNotBlank('birth_time', birthTime);
    addIfNotBlank('birth_place', birthPlace);
    if (birthLat != null) {
      fields['birth_lat'] = birthLat.toString();
    }
    if (birthLng != null) {
      fields['birth_lng'] = birthLng.toString();
    }
    addIfNotBlank('birth_timezone', birthTimezone);

    dynamic payload = FormData(fields);
    const contentType = 'multipart/form-data';

    if (profileImagePath != null && profileImagePath.trim().isNotEmpty) {
      final file = File(profileImagePath);
      if (await file.exists()) {
        payload = FormData({
          ...fields,
          'profile_image': MultipartFile(
            file,
            filename: file.uri.pathSegments.isNotEmpty
                ? file.uri.pathSegments.last
                : 'profile_image.jpg',
          ),
        });
      }
    }

    final response = await _apiService.updateProfile(
      body: payload,
      contentType: contentType,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return UpdateProfileResponseModel.fromJson(mapBody);
    }

    return UpdateProfileResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to update profile',
    );
  }

  Future<SearchPlacesResponseModel> searchPlaces({
    required String query,
    int limit = 5,
  }) async {
    final response = await _apiService.searchPlaces(query: query, limit: limit);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return SearchPlacesResponseModel.fromJson(mapBody);
    }

    return SearchPlacesResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch location suggestions',
    );
  }
}
