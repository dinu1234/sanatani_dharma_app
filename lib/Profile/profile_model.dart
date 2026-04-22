class UpdateProfileResponseModel {
  UpdateProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final ProfileResponseData? data;

  factory UpdateProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ProfileResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class GetProfileResponseModel {
  GetProfileResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final ProfileResponseData? data;

  factory GetProfileResponseModel.fromJson(Map<String, dynamic> json) {
    return GetProfileResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? ProfileResponseData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ProfileResponseData {
  ProfileResponseData({
    this.user,
    this.profileImagePath,
    this.subscription,
  });

  final ProfileUser? user;
  final String? profileImagePath;
  final ProfileSubscription? subscription;

  factory ProfileResponseData.fromJson(Map<String, dynamic> json) {
    return ProfileResponseData(
      user: json['user'] is Map<String, dynamic>
          ? ProfileUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      profileImagePath: _parseString(json['profile_image_path']),
      subscription: json['subscription'] is Map<String, dynamic>
          ? ProfileSubscription.fromJson(
              json['subscription'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class ProfileUser {
  ProfileUser({
    this.id,
    this.mobile,
    this.email,
    this.countryCode,
    this.fullName,
    this.currentLocation,
    this.gender,
    this.birthDate,
    this.birthPlace,
    this.googleId,
    this.profileImage,
    this.imageType,
    this.sanatanId,
    this.coin,
    this.isOtpVerified,
    this.isSubscriptionPaid,
    this.subscriptionExpiryAt,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.tokenVersion,
  });

  final int? id;
  final String? mobile;
  final String? email;
  final String? countryCode;
  final String? fullName;
  final String? currentLocation;
  final String? gender;
  final String? birthDate;
  final String? birthPlace;
  final String? googleId;
  final String? profileImage;
  final String? imageType;
  final String? sanatanId;
  final double? coin;
  final int? isOtpVerified;
  final int? isSubscriptionPaid;
  final String? subscriptionExpiryAt;
  final String? createdAt;
  final String? updatedAt;
  final int? isActive;
  final int? tokenVersion;

  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) => value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    double? parseDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');

    return ProfileUser(
      id: parseInt(json['id']),
      mobile: _parseString(json['mobile']),
      email: _parseString(json['email']),
      countryCode: _parseString(json['country_code']),
      fullName: _parseString(json['full_name']),
      currentLocation: _parseString(json['current_location']),
      gender: _parseString(json['gender']),
      birthDate: _parseString(json['birth_date']),
      birthPlace: _parseString(json['birth_place']),
      googleId: _parseString(json['google_id']),
      profileImage: _parseString(json['profile_image']),
      imageType: _parseString(json['image_type']),
      sanatanId: _parseString(json['sanatan_id']),
      coin: parseDouble(json['coin']),
      isOtpVerified: parseInt(json['is_otp_verified']),
      isSubscriptionPaid: parseInt(json['is_subscription_paid']),
      subscriptionExpiryAt: _parseString(json['subscription_expiry_at']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
      isActive: parseInt(json['is_active']),
      tokenVersion: parseInt(json['token_version']),
    );
  }
}

class ProfileSubscription {
  ProfileSubscription({
    this.planId,
    this.planName,
    this.price,
    this.durationDays,
    this.coinReward,
    this.endDate,
    this.status,
  });

  final int? planId;
  final String? planName;
  final double? price;
  final int? durationDays;
  final double? coinReward;
  final String? endDate;
  final String? status;

  factory ProfileSubscription.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) => value is int
        ? value
        : int.tryParse(value?.toString() ?? '');
    double? parseDouble(dynamic value) => value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '');

    return ProfileSubscription(
      planId: parseInt(json['plan_id']),
      planName: _parseString(json['plan_name']),
      price: parseDouble(json['price']),
      durationDays: parseInt(json['duration_days']),
      coinReward: parseDouble(json['coin_reward']),
      endDate: _parseString(json['end_date']),
      status: _parseString(json['status']),
    );
  }
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') {
    return null;
  }
  return text;
}
