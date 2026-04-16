import 'package:dharma_app/GanaMatch/gana_match_model.dart';
import 'package:dharma_app/GanaMatch/gana_match_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as location;

class GanaMatchController extends GetxController {
  GanaMatchController({GanaMatchRepository? repository})
      : _repository = repository ??
            (Get.isRegistered<GanaMatchRepository>()
                ? Get.find<GanaMatchRepository>()
                : Get.put(GanaMatchRepository(), permanent: true));

  final GanaMatchRepository _repository;
  final location.Location _location = location.Location();

  final isRequestingLocation = false.obs;
  final isSubmitting = false.obs;
  final isLocationEnabled = true.obs;
  final isPermissionGranted = false.obs;
  final isPermissionDeniedForever = false.obs;
  final showLocationHelp = false.obs;
  final currentLatitude = RxnDouble();
  final currentLongitude = RxnDouble();
  final errorMessage = ''.obs;
  final result = Rxn<KundliMatchResult>();
  _PendingMatchRequest? _pendingRequest;

  Future<void> refreshLocation() async {
    final position = await _resolveLocation();
    if (position != null && _pendingRequest != null) {
      final request = _pendingRequest!;
      _pendingRequest = null;
      await submitMatching(
        girlName: request.girlName,
        girlDate: request.girlDate,
        girlTime: request.girlTime,
        boyName: request.boyName,
        boyDate: request.boyDate,
        boyTime: request.boyTime,
      );
    }
  }

  Future<Position?> _resolveLocation() async {
    errorMessage.value = '';
    showLocationHelp.value = false;
    isRequestingLocation.value = true;
    try {
      var serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
      }
      isLocationEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        errorMessage.value =
            'Location service is off. Please enable location to continue.';
        showLocationHelp.value = true;
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
            'Location permission is required for kundli matching.';
        showLocationHelp.value = true;
        return null;
      }
      if (permission == location.PermissionStatus.deniedForever) {
        errorMessage.value =
            'Location permission is permanently denied. Please allow it from app settings.';
        showLocationHelp.value = true;
        return null;
      }

      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        currentLatitude.value = lastKnown.latitude;
        currentLongitude.value = lastKnown.longitude;
      }

      await _location.changeSettings(
        accuracy: location.LocationAccuracy.low,
        interval: 1000,
        distanceFilter: 0,
      );

      final data = await _location.getLocation().timeout(
        const Duration(seconds: 6),
        onTimeout: () => location.LocationData.fromMap(<String, dynamic>{
          'latitude': currentLatitude.value,
          'longitude': currentLongitude.value,
          'accuracy': 0.0,
          'altitude': 0.0,
          'heading': 0.0,
          'speed': 0.0,
        }),
      );
      if (data.latitude == null || data.longitude == null) {
        errorMessage.value =
            'Unable to access current location right now. Please try again.';
        showLocationHelp.value = true;
        return null;
      }

      currentLatitude.value = data.latitude;
      currentLongitude.value = data.longitude;
      errorMessage.value = '';
      showLocationHelp.value = false;
      return Position(
        longitude: data.longitude!,
        latitude: data.latitude!,
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
      showLocationHelp.value = true;
      return null;
    } finally {
      isRequestingLocation.value = false;
    }
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<KundliMatchResult?> submitMatching({
    String? girlName,
    required String girlDate,
    required String girlTime,
    String? boyName,
    required String boyDate,
    required String boyTime,
  }) async {
    _pendingRequest = _PendingMatchRequest(
      girlName: girlName,
      girlDate: girlDate,
      girlTime: girlTime,
      boyName: boyName,
      boyDate: boyDate,
      boyTime: boyTime,
    );
    showLocationHelp.value = false;
    isSubmitting.value = true;
    if (currentLatitude.value == null || currentLongitude.value == null) {
      final position = await _resolveLocation();
      if (position == null) {
        isSubmitting.value = false;
        return null;
      }
    }

    final girlIso = _toIsoDateTime(girlDate, girlTime);
    final boyIso = _toIsoDateTime(boyDate, boyTime);
    if (girlIso == null || boyIso == null) {
      _pendingRequest = null;
      isSubmitting.value = false;
      ToastUtils.show('Please select valid date and time for both profiles.');
      return null;
    }

    try {
      final lat = currentLatitude.value!;
      final lng = currentLongitude.value!;
      var response = await _repository.getDetailedKundliMatching(
        girlName: _cleanName(girlName),
        girlLat: lat,
        girlLng: lng,
        girlDob: girlIso,
        boyName: _cleanName(boyName),
        boyLat: lat,
        boyLng: lng,
        boyDob: boyIso,
      );

      if (!response.success && response.isSandboxDateRestriction) {
        response = await _repository.getDetailedKundliMatching(
          girlName: _cleanName(girlName),
          girlLat: lat,
          girlLng: lng,
          girlDob: _coerceToJanuaryFirst(girlIso),
          boyName: _cleanName(boyName),
          boyLat: lat,
          boyLng: lng,
          boyDob: _coerceToJanuaryFirst(boyIso),
        );
      }

      if (!response.success || response.data?.result == null) {
        _pendingRequest = null;
        ToastUtils.show(response.message ?? 'Failed to fetch kundli matching.');
        return null;
      }

      result.value = response.data!.result;
      _pendingRequest = null;
      return response.data!.result;
    } finally {
      isSubmitting.value = false;
    }
  }

  String? _cleanName(String? name) {
    final value = name?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? _toIsoDateTime(String date, String time) {
    final dateParts = date.split('/');
    if (dateParts.length != 3) return null;
    final day = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final year = int.tryParse(dateParts[2]);
    if (day == null || month == null || year == null) return null;

    final normalizedTime = time
        .trim()
        .replaceAll('\u202F', ' ')
        .replaceAll('\u00A0', ' ')
        .toUpperCase();

    int? hour;
    int? minute;

    final twelveHourMatch =
        RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)$').firstMatch(normalizedTime);
    if (twelveHourMatch != null) {
      hour = int.tryParse(twelveHourMatch.group(1)!);
      minute = int.tryParse(twelveHourMatch.group(2)!);
      final meridiem = twelveHourMatch.group(3)!;
      if (hour == null || minute == null) return null;
      if (meridiem == 'PM' && hour < 12) hour += 12;
      if (meridiem == 'AM' && hour == 12) hour = 0;
    } else {
      final twentyFourHourMatch =
          RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(normalizedTime);
      if (twentyFourHourMatch == null) return null;
      hour = int.tryParse(twentyFourHourMatch.group(1)!);
      minute = int.tryParse(twentyFourHourMatch.group(2)!);
      if (hour == null || minute == null) return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}T${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00+05:30';
  }

  String _coerceToJanuaryFirst(String iso) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return '${parsed.year.toString().padLeft(4, '0')}-01-01T${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}:00+05:30';
  }
}

class _PendingMatchRequest {
  const _PendingMatchRequest({
    this.girlName,
    required this.girlDate,
    required this.girlTime,
    this.boyName,
    required this.boyDate,
    required this.boyTime,
  });

  final String? girlName;
  final String girlDate;
  final String girlTime;
  final String? boyName;
  final String boyDate;
  final String boyTime;
}
