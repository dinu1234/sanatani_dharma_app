class PanchangResponseModel {
  PanchangResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String? message;
  final PanchangData? data;
  final List<PanchangError> errors;

  factory PanchangResponseModel.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return PanchangResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: _mapOrNull(json['data'], PanchangData.fromJson),
      errors: rawErrors is List
          ? rawErrors
              .whereType<Map>()
              .map(
                (item) =>
                    PanchangError.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList()
          : const [],
    );
  }

  bool get isSandboxDateRestriction =>
      errors.any((error) => error.code == '1004') ||
      errors.any(
        (error) =>
            error.detail.toLowerCase().contains('only january 1st is allowed'),
      );
}

class PanchangData {
  PanchangData({
    this.date,
    this.displayDate,
    this.cached = false,
    this.location,
    this.vara,
    this.tithi,
    this.nakshatra,
    this.yoga,
    this.karana,
    this.timings,
    this.rahuKaal,
    this.elements,
    this.auspiciousInauspiciousTimings,
  });

  final String? date;
  final String? displayDate;
  final bool cached;
  final PanchangLocation? location;
  final VaraData? vara;
  final PanchangSlice? tithi;
  final PanchangSlice? nakshatra;
  final PanchangSlice? yoga;
  final PanchangSlice? karana;
  final TimingBlock? timings;
  final TimeRange? rahuKaal;
  final PanchangElements? elements;
  final PanchangTimings? auspiciousInauspiciousTimings;

  factory PanchangData.fromJson(Map<String, dynamic> json) {
    return PanchangData(
      date: json['date']?.toString(),
      displayDate: json['display_date']?.toString(),
      cached: json['cached'] == true,
      location: _mapOrNull(json['location'], PanchangLocation.fromJson),
      vara: _mapOrNull(json['vara'], VaraData.fromJson),
      tithi: _mapOrNull(json['tithi'], PanchangSlice.fromJson),
      nakshatra: _mapOrNull(json['nakshatra'], PanchangSlice.fromJson),
      yoga: _mapOrNull(json['yoga'], PanchangSlice.fromJson),
      karana: _mapOrNull(json['karana'], PanchangSlice.fromJson),
      timings: _mapOrNull(json['timings'], TimingBlock.fromJson),
      rahuKaal: _mapOrNull(json['rahu_kaal'], TimeRange.fromJson),
      elements: _mapOrNull(json['elements'], PanchangElements.fromJson),
      auspiciousInauspiciousTimings: _mapOrNull(
        json['auspicious_inauspicious_timings'],
        PanchangTimings.fromJson,
      ),
    );
  }
}

class PanchangLocation {
  PanchangLocation({
    this.lat,
    this.lng,
    this.cacheLat,
    this.cacheLng,
    this.city,
  });

  final double? lat;
  final double? lng;
  final double? cacheLat;
  final double? cacheLng;
  final String? city;

  factory PanchangLocation.fromJson(Map<String, dynamic> json) {
    return PanchangLocation(
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      cacheLat: _parseDouble(json['cache_lat']),
      cacheLng: _parseDouble(json['cache_lng']),
      city: json['city']?.toString().trim(),
    );
  }
}

class VaraData {
  VaraData({
    this.name,
    this.nameSa,
    this.lord,
  });

  final String? name;
  final String? nameSa;
  final String? lord;

  factory VaraData.fromJson(Map<String, dynamic> json) {
    return VaraData(
      name: json['name']?.toString(),
      nameSa: json['name_sa']?.toString(),
      lord: json['lord']?.toString(),
    );
  }
}

class PanchangSlice {
  PanchangSlice({
    this.number,
    this.name,
    this.paksha,
    this.deity,
    this.start,
    this.end,
  });

  final int? number;
  final String? name;
  final String? paksha;
  final String? deity;
  final String? start;
  final String? end;

  factory PanchangSlice.fromJson(Map<String, dynamic> json) {
    return PanchangSlice(
      number: _parseInt(json['number']),
      name: json['name']?.toString(),
      paksha: json['paksha']?.toString(),
      deity: json['deity']?.toString(),
      start: json['start']?.toString(),
      end: json['end']?.toString(),
    );
  }
}

class TimingBlock {
  TimingBlock({
    this.sunrise,
    this.sunset,
    this.moonrise,
    this.moonset,
  });

  final String? sunrise;
  final String? sunset;
  final String? moonrise;
  final String? moonset;

  factory TimingBlock.fromJson(Map<String, dynamic> json) {
    return TimingBlock(
      sunrise: json['sunrise']?.toString(),
      sunset: json['sunset']?.toString(),
      moonrise: json['moonrise']?.toString(),
      moonset: json['moonset']?.toString(),
    );
  }
}

class PanchangElements {
  PanchangElements({
    this.tithi,
    this.nakshatra,
    this.yoga,
    this.karana,
    this.vishti,
    this.weekday,
  });

  final ElementInfo? tithi;
  final ElementInfo? nakshatra;
  final ElementInfo? yoga;
  final ElementInfo? karana;
  final TimeRangeLabel? vishti;
  final WeekdayInfo? weekday;

  factory PanchangElements.fromJson(Map<String, dynamic> json) {
    return PanchangElements(
      tithi: _mapOrNull(json['tithi'], ElementInfo.fromJson),
      nakshatra: _mapOrNull(json['nakshatra'], ElementInfo.fromJson),
      yoga: _mapOrNull(json['yoga'], ElementInfo.fromJson),
      karana: _mapOrNull(json['karana'], ElementInfo.fromJson),
      vishti: _mapOrNull(json['vishti'], TimeRangeLabel.fromJson),
      weekday: _mapOrNull(json['weekday'], WeekdayInfo.fromJson),
    );
  }
}

class ElementInfo {
  ElementInfo({
    this.label,
    this.until,
    this.number,
    this.paksha,
    this.deity,
  });

  final String? label;
  final String? until;
  final int? number;
  final String? paksha;
  final String? deity;

  factory ElementInfo.fromJson(Map<String, dynamic> json) {
    return ElementInfo(
      label: json['label']?.toString(),
      until: json['until']?.toString(),
      number: _parseInt(json['number']),
      paksha: json['paksha']?.toString(),
      deity: json['deity']?.toString(),
    );
  }
}

class TimeRange {
  TimeRange({
    this.start,
    this.end,
  });

  final String? start;
  final String? end;

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      start: json['start']?.toString(),
      end: json['end']?.toString(),
    );
  }
}

class TimeRangeLabel extends TimeRange {
  TimeRangeLabel({
    this.label,
    super.start,
    super.end,
  });

  final String? label;

  factory TimeRangeLabel.fromJson(Map<String, dynamic> json) {
    return TimeRangeLabel(
      label: json['label']?.toString(),
      start: json['start']?.toString(),
      end: json['end']?.toString(),
    );
  }
}

class WeekdayInfo {
  WeekdayInfo({
    this.sanskrit,
    this.english,
    this.lord,
  });

  final String? sanskrit;
  final String? english;
  final String? lord;

  factory WeekdayInfo.fromJson(Map<String, dynamic> json) {
    return WeekdayInfo(
      sanskrit: json['sanskrit']?.toString(),
      english: json['english']?.toString(),
      lord: json['lord']?.toString(),
    );
  }
}

class PanchangTimings {
  PanchangTimings({
    this.amritKaal,
    this.rahuKaal,
    this.gulikaKaal,
    this.yamaganda,
    this.abhijitMuhurta,
  });

  final TimeRange? amritKaal;
  final TimeRange? rahuKaal;
  final TimeRange? gulikaKaal;
  final TimeRange? yamaganda;
  final AbhijitMuhurta? abhijitMuhurta;

  factory PanchangTimings.fromJson(Map<String, dynamic> json) {
    return PanchangTimings(
      amritKaal: _mapOrNull(json['amrit_kaal'], TimeRange.fromJson),
      rahuKaal: _mapOrNull(json['rahu_kaal'], TimeRange.fromJson),
      gulikaKaal: _mapOrNull(json['gulika_kaal'], TimeRange.fromJson),
      yamaganda: _mapOrNull(json['yamaganda'], TimeRange.fromJson),
      abhijitMuhurta: _mapOrNull(
        json['abhijit_muhurta'],
        AbhijitMuhurta.fromJson,
      ),
    );
  }
}

class AbhijitMuhurta extends TimeRange {
  AbhijitMuhurta({
    this.available = false,
    super.start,
    super.end,
  });

  final bool available;

  factory AbhijitMuhurta.fromJson(Map<String, dynamic> json) {
    return AbhijitMuhurta(
      available: json['available'] == true,
      start: json['start']?.toString(),
      end: json['end']?.toString(),
    );
  }
}

class PanchangError {
  PanchangError({
    this.code,
    this.title,
    this.detail = '',
  });

  final String? code;
  final String? title;
  final String detail;

  factory PanchangError.fromJson(Map<String, dynamic> json) {
    return PanchangError(
      code: json['code']?.toString(),
      title: json['title']?.toString(),
      detail: json['detail']?.toString() ?? '',
    );
  }
}

T? _mapOrNull<T>(
  dynamic value,
  T Function(Map<String, dynamic> json) fromJson,
) {
  if (value is Map<String, dynamic>) {
    return fromJson(value);
  }
  if (value is Map) {
    return fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
