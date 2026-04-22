class SendOtpResponseModel {
  SendOtpResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SendOtpData? data;

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return SendOtpResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SendOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SendOtpData {
  SendOtpData({
    this.countryCode,
    this.mobile,
    this.otpExpiry,
    this.debugOtp,
  });

  final String? countryCode;
  final String? mobile;
  final String? otpExpiry;
  final String? debugOtp;

  factory SendOtpData.fromJson(Map<String, dynamic> json) {
    return SendOtpData(
      countryCode: json['country_code']?.toString(),
      mobile: json['mobile']?.toString(),
      otpExpiry: json['otp_expiry']?.toString(),
      debugOtp: json['debug_otp']?.toString(),
    );
  }
}

class VerifyOtpResponseModel {
  VerifyOtpResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final VerifyOtpData? data;

  factory VerifyOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? VerifyOtpData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class VerifyOtpData {
  VerifyOtpData({
    this.token,
    this.expiresIn,
    this.user,
  });

  final String? token;
  final int? expiresIn;
  final AuthUser? user;

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyOtpData(
      token: json['token']?.toString(),
      expiresIn: json['expires_in'] is int
          ? json['expires_in'] as int
          : int.tryParse(json['expires_in']?.toString() ?? ''),
      user: json['user'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class AuthUser {
  AuthUser({
    this.id,
    this.countryCode,
    this.mobile,
    this.email,
    this.fullName,
    this.currentLocation,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.googleId,
    this.isOtpVerified,
    this.isActive,
    this.tokenVersion,
  });

  final int? id;
  final String? countryCode;
  final String? mobile;
  final String? email;
  final String? fullName;
  final String? currentLocation;
  final String? gender;
  final String? birthDate;
  final String? birthPlace;
  final String? googleId;
  final int? isOtpVerified;
  final int? isActive;
  final int? tokenVersion;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) => value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    String? parseString(dynamic value) {
      if (value == null) return null;
      final text = value.toString().trim();
      if (text.isEmpty || text.toLowerCase() == 'null') return null;
      return text;
    }

    return AuthUser(
      id: parseInt(json['id']),
      countryCode: parseString(json['country_code']),
      mobile: parseString(json['mobile']),
      email: parseString(json['email']),
      fullName: parseString(json['full_name']),
      currentLocation: parseString(json['current_location']),
      gender: parseString(json['gender']),
      birthDate: parseString(json['birth_date']),
      birthPlace: parseString(json['birth_place']),
      googleId: parseString(json['google_id']),
      isOtpVerified: parseInt(json['is_otp_verified']),
      isActive: parseInt(json['is_active']),
      tokenVersion: parseInt(json['token_version']),
    );
  }
}
