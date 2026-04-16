import 'package:dharma_app/Panchang/panchang_model.dart';
import 'package:dharma_app/Panchang/panchang_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as location;

class PanchangController extends GetxController {
  PanchangController({PanchangRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<PanchangRepository>()
                ? Get.find<PanchangRepository>()
                : Get.put(PanchangRepository(), permanent: true));

  final PanchangRepository _repository;
  final location.Location _location = location.Location();

  final isLoading = false.obs;
  final isRequestingLocation = false.obs;
  final isLocationEnabled = true.obs;
  final isPermissionGranted = false.obs;
  final isPermissionDeniedForever = false.obs;
  final panchang = Rxn<PanchangData>();
  final currentLatitude = RxnDouble();
  final currentLongitude = RxnDouble();
  final errorMessage = ''.obs;
  final infoMessage = ''.obs;
  final requestedDate = Rxn<DateTime>();

  String get locationLabel {
    final location = panchang.value?.location;
    final lat = location?.lat ?? currentLatitude.value;
    final lng = location?.lng ?? currentLongitude.value;
    if (lat == null || lng == null) {
      return 'Current location';
    }
    return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
  }

  @override
  void onInit() {
    super.onInit();
    refreshPanchang();
  }

  Future<void> refreshPanchang({DateTime? date}) async {
    requestedDate.value = date;
    errorMessage.value = '';
    infoMessage.value = '';

    final position = await _resolveLocation();
    if (position == null) return;

    isLoading.value = true;
    try {
      final formattedDate = _formatDate(date);
      var response = await _repository.getTodayPanchang(
        lat: position.latitude,
        lng: position.longitude,
        date: formattedDate,
      );

      if (!response.success && response.isSandboxDateRestriction) {
        final fallbackDate = DateTime(DateTime.now().year, 1, 1);
        response = await _repository.getTodayPanchang(
          lat: position.latitude,
          lng: position.longitude,
          date: _formatDate(fallbackDate),
        );
        if (response.success) {
          requestedDate.value = fallbackDate;
          infoMessage.value =
              'Sandbox mode detected, so January 1 data is being shown.';
        }
      }

      if (response.success && response.data != null) {
        panchang.value = response.data;
        if (response.data!.cached) {
          infoMessage.value = infoMessage.value.isEmpty
              ? 'Cached Panchang data loaded for this location.'
              : '${infoMessage.value} Cached Panchang data loaded.';
        }
      } else {
        panchang.value = null;
        errorMessage.value = response.message ?? 'Failed to fetch Panchang.';
        if (errorMessage.value.isNotEmpty) {
          ToastUtils.show(errorMessage.value);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<Position?> _resolveLocation() async {
    isRequestingLocation.value = true;
    try {
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
      }
      isLocationEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        errorMessage.value =
            'Location service is off. Please enable location to view Panchang.';
        return null;
      }

      var permission = await _location.hasPermission();
      if (permission == location.PermissionStatus.denied) {
        permission = await _location.requestPermission();
      }

      isPermissionGranted.value =
          permission == location.PermissionStatus.granted ||
          permission == location.PermissionStatus.grantedLimited;
      isPermissionDeniedForever.value =
          permission == location.PermissionStatus.deniedForever;

      if (permission == location.PermissionStatus.denied) {
        errorMessage.value =
            'Location permission is required to fetch Panchang.';
        return null;
      }

      if (permission == location.PermissionStatus.deniedForever) {
        errorMessage.value =
            'Location permission is permanently denied. Please allow it from app settings.';
        return null;
      }

      final data = await _location.getLocation();
      final latitude = data.latitude;
      final longitude = data.longitude;
      if (latitude == null || longitude == null) {
        errorMessage.value =
            'Unable to access current location right now. Please try again.';
        return null;
      }

      currentLatitude.value = latitude;
      currentLongitude.value = longitude;
      return Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.now(),
        accuracy: data.accuracy ?? 0,
        altitude: data.altitude ?? 0,
        altitudeAccuracy: 0,
        heading: data.heading ?? 0,
        headingAccuracy: 0,
        speed: data.speed ?? 0,
        speedAccuracy: 0,
      );
    } catch (_) {
      errorMessage.value =
          'Unable to access current location right now. Please try again.';
      return null;
    } finally {
      isRequestingLocation.value = false;
    }
  }

  String? _formatDate(DateTime? date) {
    if (date == null) return null;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
