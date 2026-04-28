class AskPanditResponseModel {
  AskPanditResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.requiredFields = const [],
  });

  final bool success;
  final String message;
  final AskPanditData? data;
  final List<String> requiredFields;

  factory AskPanditResponseModel.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'];
    final required = dataMap is Map<String, dynamic> && dataMap['required_fields'] is List
        ? (dataMap['required_fields'] as List)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : const <String>[];
    return AskPanditResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: dataMap is Map<String, dynamic>
          ? AskPanditData.fromJson(dataMap)
          : null,
      requiredFields: required,
    );
  }
}

class AskPanditData {
  AskPanditData({
    this.question,
    this.answer,
    this.sessionId,
    this.cacheHit,
    this.model,
  });

  final String? question;
  final String? answer;
  final String? sessionId;
  final bool? cacheHit;
  final String? model;

  factory AskPanditData.fromJson(Map<String, dynamic> json) {
    return AskPanditData(
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
      sessionId: json['session_id']?.toString(),
      cacheHit: json['cache_hit'] == true,
      model: json['model']?.toString(),
    );
  }
}

class AskPanditMessage {
  AskPanditMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.isTyping = false,
  });

  final String text;
  final bool isUser;
  final DateTime time;
  final bool isTyping;
}
