import 'package:dharma_app/Profile/profile_model.dart';
import 'package:get/get.dart';

class CreateSrcOrderResponseModel {
  CreateSrcOrderResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SrcOrderData? data;

  factory CreateSrcOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return CreateSrcOrderResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SrcOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SrcOrderData {
  SrcOrderData({
    this.transactionId,
    this.razorpayKeyId,
    this.src,
    this.order,
  });

  final int? transactionId;
  final String? razorpayKeyId;
  final SrcOrderSummary? src;
  final SrcRazorpayOrder? order;

  factory SrcOrderData.fromJson(Map<String, dynamic> json) {
    return SrcOrderData(
      transactionId: _parseInt(json['transaction_id']),
      razorpayKeyId: _parseString(json['razorpay_key_id']),
      src: json['src'] is Map<String, dynamic>
          ? SrcOrderSummary.fromJson(json['src'] as Map<String, dynamic>)
          : null,
      order: json['order'] is Map<String, dynamic>
          ? SrcRazorpayOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SrcOrderSummary {
  SrcOrderSummary({
    this.srcQuantity,
    this.srcUnitPrice,
    this.amount,
  });

  final int? srcQuantity;
  final double? srcUnitPrice;
  final double? amount;

  factory SrcOrderSummary.fromJson(Map<String, dynamic> json) {
    return SrcOrderSummary(
      srcQuantity: _parseInt(json['src_quantity']),
      srcUnitPrice: _parseDouble(json['src_unit_price']),
      amount: _parseDouble(json['amount']),
    );
  }
}

class SrcRazorpayOrder {
  SrcRazorpayOrder({
    this.orderId,
    this.amount,
    this.currency,
    this.receipt,
  });

  final String? orderId;
  final int? amount;
  final String? currency;
  final String? receipt;

  factory SrcRazorpayOrder.fromJson(Map<String, dynamic> json) {
    return SrcRazorpayOrder(
      orderId: _parseString(json['order_id']),
      amount: _parseInt(json['amount']),
      currency: _parseString(json['currency']),
      receipt: _parseString(json['receipt']),
    );
  }
}

class VerifySrcPaymentResponseModel {
  VerifySrcPaymentResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  factory VerifySrcPaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifySrcPaymentResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
    );
  }
}

class SrcHistoryResponseModel {
  SrcHistoryResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final SrcHistoryData? data;

  factory SrcHistoryResponseModel.fromJson(Map<String, dynamic> json) {
    return SrcHistoryResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? SrcHistoryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SrcHistoryData {
  SrcHistoryData({
    this.srcUnitPrice,
    this.user,
    required this.transactions,
  });

  final double? srcUnitPrice;
  final ProfileUser? user;
  final List<SrcHistoryTransaction> transactions;

  factory SrcHistoryData.fromJson(Map<String, dynamic> json) {
    final transactions = json['transactions'];
    return SrcHistoryData(
      srcUnitPrice: _parseDouble(json['src_unit_price']),
      user: json['user'] is Map<String, dynamic>
          ? ProfileUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      transactions: transactions is List
          ? transactions
              .whereType<Map>()
              .map(
                (item) => SrcHistoryTransaction.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const [],
    );
  }
}

class SrcHistoryTransaction {
  SrcHistoryTransaction({
    this.id,
    this.srcQuantity,
    this.srcUnitPrice,
    this.amount,
    this.currency,
    this.sourceType,
    this.sourceLabel,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.status,
    this.captureStatus,
    this.paymentMethod,
    this.errorCode,
    this.errorDescription,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final int? srcQuantity;
  final double? srcUnitPrice;
  final double? amount;
  final String? currency;
  final String? sourceType;
  final String? sourceLabel;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? status;
  final String? captureStatus;
  final String? paymentMethod;
  final String? errorCode;
  final String? errorDescription;
  final String? createdAt;
  final String? updatedAt;

  bool get isSuccess {
    final normalizedStatus = status?.trim().toLowerCase();
    final normalizedCapture = captureStatus?.trim().toLowerCase();
    return normalizedStatus == 'captured' ||
        normalizedStatus == 'success' ||
        normalizedCapture == 'captured';
  }

  String get statusLabel {
    final normalized = status?.trim().toLowerCase();
    if (normalized == 'captured' || normalized == 'success') {
      return 'status_success'.tr;
    }
    if (normalized == 'failed') {
      return 'status_failed'.tr;
    }
    if (normalized == 'pending') {
      return 'status_pending'.tr;
    }
    return status?.trim().isNotEmpty == true
        ? status!.trim()
        : 'status_unknown'.tr;
  }

  String get sourceTitle {
    final label = sourceLabel?.trim().toLowerCase();
    if (label == 'user_purchase') return 'src_purchase'.tr;
    if (label == 'festival_bonus') return 'festival_bonus'.tr;
    if (label == 'referral_reward') return 'referral_reward'.tr;
    if (label == 'subscription_plan') return 'subscription_reward'.tr;

    final type = sourceType?.trim().toLowerCase();
    if (type == 'purchase') return 'src_purchase'.tr;
    if (type == 'admin_credit') return 'admin_credit'.tr;
    if (type == 'referral') return 'referral_reward'.tr;
    if (type == 'subscription') return 'subscription_reward'.tr;

    return 'src_transaction'.tr;
  }

  factory SrcHistoryTransaction.fromJson(Map<String, dynamic> json) {
    return SrcHistoryTransaction(
      id: _parseInt(json['id']),
      srcQuantity: _parseInt(json['src_quantity']),
      srcUnitPrice: _parseDouble(json['src_unit_price']),
      amount: _parseDouble(json['amount']),
      currency: _parseString(json['currency']),
      sourceType: _parseString(json['source_type']),
      sourceLabel: _parseString(json['source_label']),
      razorpayOrderId: _parseString(json['razorpay_order_id']),
      razorpayPaymentId: _parseString(json['razorpay_payment_id']),
      status: _parseString(json['status']),
      captureStatus: _parseString(json['capture_status']),
      paymentMethod: _parseString(json['payment_method']),
      errorCode: _parseString(json['error_code']),
      errorDescription: _parseString(json['error_description']),
      createdAt: _parseString(json['created_at']),
      updatedAt: _parseString(json['updated_at']),
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
