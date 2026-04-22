class SubscriptionPlansResponseModel {
  SubscriptionPlansResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SubscriptionPlansData? data;

  factory SubscriptionPlansResponseModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlansResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SubscriptionPlansData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SubscriptionPlansData {
  SubscriptionPlansData({required this.plans});

  final List<SubscriptionPlan> plans;

  factory SubscriptionPlansData.fromJson(Map<String, dynamic> json) {
    final plans = json['plans'];
    return SubscriptionPlansData(
      plans: plans is List
          ? plans
              .whereType<Map>()
              .map(
                (plan) => SubscriptionPlan.fromJson(
                  Map<String, dynamic>.from(plan),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class SubscriptionPlan {
  SubscriptionPlan({
    this.id,
    this.planName,
    this.planKey,
    this.description,
    this.durationDays,
    this.price,
    this.offerPrice,
    this.coinReward,
    this.effectivePrice,
  });

  final int? id;
  final String? planName;
  final String? planKey;
  final String? description;
  final int? durationDays;
  final double? price;
  final double? offerPrice;
  final double? coinReward;
  final double? effectivePrice;

  String get displayName =>
      planName?.trim().isNotEmpty == true ? planName!.trim() : 'Premium Plan';

  String get displayDescription => description?.trim().isNotEmpty == true
      ? description!.trim()
      : 'Unlock premium access for Live Darshan.';

  String get displayPrice =>
      'Rs ${(effectivePrice ?? offerPrice ?? price ?? 0).toStringAsFixed(0)}';

  String? get displayOriginalPrice {
    final original = price;
    final effective = effectivePrice ?? offerPrice;
    if (original == null || effective == null || original <= effective) {
      return null;
    }
    return 'Rs ${original.toStringAsFixed(0)}';
  }

  String get durationLabel {
    final days = durationDays;
    if (days == null || days <= 0) return 'Premium access';
    return '$days days access';
  }

  String get coinRewardLabel {
    final coins = coinReward;
    if (coins == null || coins <= 0) return 'Premium benefits';
    final rounded = coins % 1 == 0 ? coins.toStringAsFixed(0) : '$coins';
    return '$rounded SRC reward';
  }

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) =>
        value is int ? value : int.tryParse(value?.toString() ?? '');
    double? parseDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');

    return SubscriptionPlan(
      id: parseInt(json['id']),
      planName: _parseString(json['plan_name']),
      planKey: _parseString(json['plan_key']),
      description: _parseString(json['description']),
      durationDays: parseInt(json['duration_days']),
      price: parseDouble(json['price']),
      offerPrice: parseDouble(json['offer_price']),
      coinReward: parseDouble(json['coin_reward']),
      effectivePrice: parseDouble(json['effective_price']),
    );
  }
}

class CreateSubscriptionOrderResponseModel {
  CreateSubscriptionOrderResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SubscriptionOrderData? data;

  factory CreateSubscriptionOrderResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateSubscriptionOrderResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SubscriptionOrderData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class SubscriptionOrderData {
  SubscriptionOrderData({
    this.transactionId,
    this.razorpayKeyId,
    this.order,
    this.plan,
  });

  final int? transactionId;
  final String? razorpayKeyId;
  final RazorpayOrder? order;
  final SubscriptionOrderPlan? plan;

  factory SubscriptionOrderData.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrderData(
      transactionId: _parseInt(json['transaction_id']),
      razorpayKeyId: _parseString(json['razorpay_key_id']),
      order: json['order'] is Map<String, dynamic>
          ? RazorpayOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      plan: json['plan'] is Map<String, dynamic>
          ? SubscriptionOrderPlan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }
}

class RazorpayOrder {
  RazorpayOrder({
    this.orderId,
    this.amount,
    this.currency,
    this.receipt,
  });

  final String? orderId;
  final int? amount;
  final String? currency;
  final String? receipt;

  factory RazorpayOrder.fromJson(Map<String, dynamic> json) {
    return RazorpayOrder(
      orderId: _parseString(json['order_id']),
      amount: _parseInt(json['amount']),
      currency: _parseString(json['currency']),
      receipt: _parseString(json['receipt']),
    );
  }
}

class SubscriptionOrderPlan {
  SubscriptionOrderPlan({
    this.id,
    this.planName,
    this.durationDays,
    this.coinReward,
  });

  final int? id;
  final String? planName;
  final int? durationDays;
  final double? coinReward;

  factory SubscriptionOrderPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionOrderPlan(
      id: _parseInt(json['id']),
      planName: _parseString(json['plan_name']),
      durationDays: _parseInt(json['duration_days']),
      coinReward: _parseDouble(json['coin_reward']),
    );
  }
}

class VerifySubscriptionPaymentResponseModel {
  VerifySubscriptionPaymentResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  factory VerifySubscriptionPaymentResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VerifySubscriptionPaymentResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }
}

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}

int? _parseInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

double? _parseDouble(dynamic value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
