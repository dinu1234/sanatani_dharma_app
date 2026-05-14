import 'package:dharma_app/NityaKarma/nitya_karma_model.dart';
import 'package:dharma_app/core/utils/api_utils.dart';
import 'package:dharma_app/services/api_service.dart';
import 'package:get/get.dart';

class NityaKarmaRepository {
  NityaKarmaRepository({ApiService? apiService})
    : _apiService =
          apiService ??
          (Get.isRegistered<ApiService>()
              ? Get.find<ApiService>()
              : Get.put(ApiService(), permanent: true));

  final ApiService _apiService;

  Future<NityaKarmaChecklistResponseModel> getTodayChecklist({
    String? date,
  }) async {
    final response = await _apiService.getTodayNityaKarmaChecklist(date: date);
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return NityaKarmaChecklistResponseModel.fromJson(mapBody);
    }

    return NityaKarmaChecklistResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to fetch Nitya Karma checklist',
    );
  }

  Future<NityaKarmaChecklistResponseModel> toggleCompletion({
    int? scheduleId,
    int? habitId,
    required int isCompleted,
    String? date,
  }) async {
    final response = await _apiService.toggleNityaKarmaCompletion(
      scheduleId: scheduleId,
      habitId: habitId,
      isCompleted: isCompleted,
      date: date,
    );
    final mapBody = ApiUtils.asMap(response.body);

    if (mapBody != null) {
      return NityaKarmaChecklistResponseModel.fromJson(mapBody);
    }

    return NityaKarmaChecklistResponseModel(
      success: false,
      message: response.statusText ?? 'Failed to update Nitya Karma progress',
    );
  }
}
