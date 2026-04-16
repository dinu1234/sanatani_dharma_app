class KundliMatchResponseModel {
  KundliMatchResponseModel({
    required this.success,
    this.message,
    this.data,
    this.errors = const [],
  });

  final bool success;
  final String? message;
  final KundliMatchData? data;
  final List<KundliApiError> errors;

  factory KundliMatchResponseModel.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return KundliMatchResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: _asModel(json['data'], KundliMatchData.fromJson),
      errors: rawErrors is List
          ? rawErrors
              .whereType<Map>()
              .map(
                (item) =>
                    KundliApiError.fromJson(Map<String, dynamic>.from(item)),
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

class KundliMatchData {
  KundliMatchData({
    this.input,
    this.result,
  });

  final KundliMatchInput? input;
  final KundliMatchResult? result;

  factory KundliMatchData.fromJson(Map<String, dynamic> json) {
    return KundliMatchData(
      input: _asModel(json['input'], KundliMatchInput.fromJson),
      result: _asModel(json['result'], KundliMatchResult.fromJson),
    );
  }
}

class KundliMatchInput {
  KundliMatchInput({
    this.girl,
    this.boy,
  });

  final KundliPersonInput? girl;
  final KundliPersonInput? boy;

  factory KundliMatchInput.fromJson(Map<String, dynamic> json) {
    return KundliMatchInput(
      girl: _asModel(json['girl'], KundliPersonInput.fromJson),
      boy: _asModel(json['boy'], KundliPersonInput.fromJson),
    );
  }
}

class KundliPersonInput {
  KundliPersonInput({
    this.name,
    this.lat,
    this.lng,
    this.dob,
  });

  final String? name;
  final double? lat;
  final double? lng;
  final String? dob;

  factory KundliPersonInput.fromJson(Map<String, dynamic> json) {
    return KundliPersonInput(
      name: json['name']?.toString(),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      dob: json['dob']?.toString(),
    );
  }
}

class KundliMatchResult {
  KundliMatchResult({
    this.score,
    this.couple,
    this.breakdown = const [],
    this.summary,
  });

  final KundliScore? score;
  final KundliCouple? couple;
  final List<KundliBreakdownItem> breakdown;
  final KundliSummary? summary;

  factory KundliMatchResult.fromJson(Map<String, dynamic> json) {
    final rawBreakdown = json['breakdown'];
    return KundliMatchResult(
      score: _asModel(json['score'], KundliScore.fromJson),
      couple: _asModel(json['couple'], KundliCouple.fromJson),
      breakdown: rawBreakdown is List
          ? rawBreakdown
              .whereType<Map>()
              .map(
                (item) => KundliBreakdownItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
      summary: _asModel(json['summary'], KundliSummary.fromJson),
    );
  }
}

class KundliScore {
  KundliScore({
    this.obtainedPoints,
    this.maximumPoints,
    this.display,
    this.percentage,
  });

  final double? obtainedPoints;
  final double? maximumPoints;
  final String? display;
  final double? percentage;

  factory KundliScore.fromJson(Map<String, dynamic> json) {
    return KundliScore(
      obtainedPoints: _parseDouble(json['obtained_points']),
      maximumPoints: _parseDouble(json['maximum_points']),
      display: json['display']?.toString(),
      percentage: _parseDouble(json['percentage']),
    );
  }
}

class KundliCouple {
  KundliCouple({
    this.girl,
    this.boy,
  });

  final KundliPerson? girl;
  final KundliPerson? boy;

  factory KundliCouple.fromJson(Map<String, dynamic> json) {
    return KundliCouple(
      girl: _asModel(json['girl'], KundliPerson.fromJson),
      boy: _asModel(json['boy'], KundliPerson.fromJson),
    );
  }
}

class KundliPerson {
  KundliPerson({
    this.name,
    this.dob,
    this.lat,
    this.lng,
    this.rasi,
    this.nakshatra,
    this.nakshatraPada,
    this.koot,
  });

  final String? name;
  final String? dob;
  final double? lat;
  final double? lng;
  final String? rasi;
  final String? nakshatra;
  final int? nakshatraPada;
  final KundliKoot? koot;

  factory KundliPerson.fromJson(Map<String, dynamic> json) {
    return KundliPerson(
      name: json['name']?.toString(),
      dob: json['dob']?.toString(),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      rasi: json['rasi']?.toString(),
      nakshatra: json['nakshatra']?.toString(),
      nakshatraPada: _parseInt(json['nakshatra_pada']),
      koot: _asModel(json['koot'], KundliKoot.fromJson),
    );
  }
}

class KundliKoot {
  KundliKoot({
    this.varna,
    this.vasya,
    this.tara,
    this.yoni,
    this.grahaMaitri,
    this.gana,
    this.bhakoot,
    this.nadi,
  });

  final String? varna;
  final String? vasya;
  final String? tara;
  final String? yoni;
  final String? grahaMaitri;
  final String? gana;
  final String? bhakoot;
  final String? nadi;

  factory KundliKoot.fromJson(Map<String, dynamic> json) {
    return KundliKoot(
      varna: json['varna']?.toString(),
      vasya: json['vasya']?.toString(),
      tara: json['tara']?.toString(),
      yoni: json['yoni']?.toString(),
      grahaMaitri: json['grahaMaitri']?.toString(),
      gana: json['gana']?.toString(),
      bhakoot: json['bhakoot']?.toString(),
      nadi: json['nadi']?.toString(),
    );
  }
}

class KundliBreakdownItem {
  KundliBreakdownItem({
    this.id,
    this.name,
    this.girlValue,
    this.boyValue,
    this.obtainedPoints,
    this.maximumPoints,
    this.percentage,
    this.indicatorColor,
    this.description,
  });

  final int? id;
  final String? name;
  final String? girlValue;
  final String? boyValue;
  final double? obtainedPoints;
  final double? maximumPoints;
  final double? percentage;
  final String? indicatorColor;
  final String? description;

  factory KundliBreakdownItem.fromJson(Map<String, dynamic> json) {
    return KundliBreakdownItem(
      id: _parseInt(json['id']),
      name: json['name']?.toString(),
      girlValue: json['girl_value']?.toString(),
      boyValue: json['boy_value']?.toString(),
      obtainedPoints: _parseDouble(json['obtained_points']),
      maximumPoints: _parseDouble(json['maximum_points']),
      percentage: _parseDouble(json['percentage']),
      indicatorColor: json['indicator_color']?.toString(),
      description: json['description']?.toString(),
    );
  }
}

class KundliSummary {
  KundliSummary({
    this.type,
    this.message,
    this.exceptions = const [],
  });

  final String? type;
  final String? message;
  final List<String> exceptions;

  factory KundliSummary.fromJson(Map<String, dynamic> json) {
    final rawExceptions = json['exceptions'];
    return KundliSummary(
      type: json['type']?.toString(),
      message: json['message']?.toString(),
      exceptions: rawExceptions is List
          ? rawExceptions.map((item) => item.toString()).toList()
          : const [],
    );
  }
}

class KundliApiError {
  KundliApiError({
    this.code,
    this.title,
    this.detail = '',
  });

  final String? code;
  final String? title;
  final String detail;

  factory KundliApiError.fromJson(Map<String, dynamic> json) {
    return KundliApiError(
      code: json['code']?.toString(),
      title: json['title']?.toString(),
      detail: json['detail']?.toString() ?? '',
    );
  }
}

T? _asModel<T>(
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
