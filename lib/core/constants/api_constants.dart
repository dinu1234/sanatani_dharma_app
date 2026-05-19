class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://sriramcoin.com/global_sanatani/";

  static const String sendOtp = "send_otp.php";
  static const String resendOtp = "resend_otp.php";
  static const String verifyOtp = "verify_otp.php";
  static const String googleLogin = "google_login.php";
  static const String updateProfile = "update_profile.php";
  static const String getProfile = "get_profile.php";
  static const String updateFirebaseToken = "update_firebase_token.php";
  static const String sponsors = "user/sponsors/list_sponsors.php";
  static const String mantras = "user/mantras/list_mantras.php";
  static const String notifications =
      "user/notifications/list_notifications.php";
  static const String markNotificationRead =
      "user/notifications/mark_notification_read.php";
  static const String listLiveDarshan =
      "user/live_darshan/list_live_darshan.php";
  static const String listSubscriptionPlans =
      "user/subscriptions/list_plans.php";
  static const String createSubscriptionOrder =
      "user/subscriptions/create_order.php";
  static const String verifySubscriptionPayment =
      "user/subscriptions/verify_payment.php";
  static const String createSrcOrder = "user/src/create_src_order.php";
  static const String verifySrcPayment = "user/src/verify_src_payment.php";
  static const String srcHistory = "user/src/src_history.php";
  static const String getJapaStatus = "user/japa/get_japa_status.php";
  static const String saveJapaProgress = "user/japa/save_japa_progress.php";
  static const String getTodayPanchang = "user/panchang/get_today_panchang.php";
  static const String getDetailedKundliMatching =
      "user/kundli/get_detailed_kundli_matching.php";
  static const String askPandit = "user/ask_pandit/chat.php";
  static const String askPanditWelcome =
      "user/ask_pandit/get_welcome_message.php";
  static const String getTodayNityaKarmaChecklist =
      "user/nitya_karma/get_today_checklist.php";
  static const String toggleNityaKarmaCompletion =
      "user/nitya_karma/toggle_completion.php";
  static const String publicSettings = "user/settings/get_settings.php";
}
