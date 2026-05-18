import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentErrorDetails {
  const PaymentErrorDetails({
    required this.apiCode,
    required this.apiDescription,
    required this.userMessage,
    required this.showToast,
  });

  final String apiCode;
  final String apiDescription;
  final String userMessage;
  final bool showToast;
}

class PaymentErrorMapper {
  PaymentErrorMapper._();

  static PaymentErrorDetails fromFailure(PaymentFailureResponse response) {
    final rawMessage = response.message?.trim();
    final normalizedMessage = rawMessage?.toLowerCase() ?? '';
    final code = response.code;

    if (code == Razorpay.PAYMENT_CANCELLED ||
        normalizedMessage.contains('cancel')) {
      return PaymentErrorDetails(
        apiCode: 'PAYMENT_CANCELLED',
        apiDescription: 'Payment was cancelled by user.',
        userMessage: 'payment_cancelled_by_user'.tr,
        showToast: false,
      );
    }

    if (code == Razorpay.NETWORK_ERROR ||
        normalizedMessage.contains('network') ||
        normalizedMessage.contains('internet') ||
        normalizedMessage.contains('timeout')) {
      return PaymentErrorDetails(
        apiCode: 'NETWORK_ERROR',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'Network issue while processing payment.',
        userMessage: 'payment_error_network'.tr,
        showToast: true,
      );
    }

    if (code == Razorpay.INVALID_OPTIONS ||
        normalizedMessage.contains('invalid')) {
      return PaymentErrorDetails(
        apiCode: 'INVALID_PAYMENT_OPTIONS',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'Invalid payment configuration.',
        userMessage: 'payment_error_invalid_options'.tr,
        showToast: true,
      );
    }

    if (code == Razorpay.TLS_ERROR ||
        normalizedMessage.contains('tls') ||
        normalizedMessage.contains('ssl') ||
        normalizedMessage.contains('secure')) {
      return PaymentErrorDetails(
        apiCode: 'TLS_ERROR',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'Secure payment connection failed.',
        userMessage: 'payment_error_secure_connection'.tr,
        showToast: true,
      );
    }

    if (normalizedMessage.contains('insufficient') ||
        normalizedMessage.contains('balance') ||
        normalizedMessage.contains('fund')) {
      return PaymentErrorDetails(
        apiCode: 'INSUFFICIENT_FUNDS',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'Insufficient funds for this payment.',
        userMessage: 'payment_error_insufficient_funds'.tr,
        showToast: true,
      );
    }

    if (normalizedMessage.contains('bank')) {
      return PaymentErrorDetails(
        apiCode: 'BANK_ERROR',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'Bank declined or could not process the payment.',
        userMessage: 'payment_error_bank_declined'.tr,
        showToast: true,
      );
    }

    if (normalizedMessage.contains('upi')) {
      return PaymentErrorDetails(
        apiCode: 'UPI_ERROR',
        apiDescription: rawMessage?.isNotEmpty == true
            ? rawMessage!
            : 'UPI payment could not be completed.',
        userMessage: 'payment_error_upi'.tr,
        showToast: true,
      );
    }

    return PaymentErrorDetails(
      apiCode: code?.toString() ?? 'PAYMENT_FAILED',
      apiDescription: rawMessage?.isNotEmpty == true
          ? rawMessage!
          : 'Payment failed.',
      userMessage: rawMessage?.isNotEmpty == true
          ? rawMessage!
          : 'payment_failed'.tr,
      showToast: true,
    );
  }
}
