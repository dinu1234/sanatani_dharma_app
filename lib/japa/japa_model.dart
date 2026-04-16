class JapaStatusResponseModel {
  JapaStatusResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final JapaStatusData? data;

  factory JapaStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return JapaStatusResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? JapaStatusData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JapaStatusData {
  JapaStatusData({this.japa});

  final JapaProgress? japa;

  factory JapaStatusData.fromJson(Map<String, dynamic> json) {
    return JapaStatusData(
      japa: json['japa'] is Map<String, dynamic>
          ? JapaProgress.fromJson(json['japa'] as Map<String, dynamic>)
          : null,
    );
  }
}

class JapaProgress {
  JapaProgress({
    this.date,
    this.mantraId,
    this.mantraName,
    this.audioFile,
    this.audioPath,
    this.currentCount,
    this.targetCount,
    this.malaSize,
    this.chantsToday,
    this.malasCompleted,
  });

  final String? date;
  final int? mantraId;
  final String? mantraName;
  final String? audioFile;
  final String? audioPath;
  final int? currentCount;
  final int? targetCount;
  final int? malaSize;
  final int? chantsToday;
  final int? malasCompleted;

  factory JapaProgress.fromJson(Map<String, dynamic> json) {
    return JapaProgress(
      date: _parseString(json['date']),
      mantraId: _parseInt(json['mantra_id']),
      mantraName: _parseString(json['mantra_name']),
      audioFile: _parseString(json['audio_file']),
      audioPath: _parseString(json['audio_path']),
      currentCount: _parseInt(json['current_count']),
      targetCount: _parseInt(json['target_count']),
      malaSize: _parseInt(json['mala_size']),
      chantsToday: _parseInt(json['chants_today']),
      malasCompleted: _parseInt(json['malas_completed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'mantra_id': mantraId,
      'mantra_name': mantraName,
      'audio_file': audioFile,
      'audio_path': audioPath,
      'current_count': currentCount,
      'target_count': targetCount,
      'mala_size': malaSize,
      'chants_today': chantsToday,
      'malas_completed': malasCompleted,
    };
  }

  JapaProgress copyWith({
    String? date,
    int? mantraId,
    String? mantraName,
    String? audioFile,
    String? audioPath,
    int? currentCount,
    int? targetCount,
    int? malaSize,
    int? chantsToday,
    int? malasCompleted,
  }) {
    return JapaProgress(
      date: date ?? this.date,
      mantraId: mantraId ?? this.mantraId,
      mantraName: mantraName ?? this.mantraName,
      audioFile: audioFile ?? this.audioFile,
      audioPath: audioPath ?? this.audioPath,
      currentCount: currentCount ?? this.currentCount,
      targetCount: targetCount ?? this.targetCount,
      malaSize: malaSize ?? this.malaSize,
      chantsToday: chantsToday ?? this.chantsToday,
      malasCompleted: malasCompleted ?? this.malasCompleted,
    );
  }
}

int? _parseInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
