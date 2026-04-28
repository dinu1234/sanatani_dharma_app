import 'package:dharma_app/AskPandit/ask_pandit_model.dart';
import 'package:dharma_app/AskPandit/ask_pandit_repository.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Subscription/subscription_controller.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:get/get.dart';
import 'package:location/location.dart' as location;

class AskPanditController extends GetxController {
  AskPanditController({AskPanditRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<AskPanditRepository>()
              ? Get.find<AskPanditRepository>()
              : Get.put(AskPanditRepository(), permanent: true));

  final AskPanditRepository _repository;
  final location.Location _location = location.Location();

  final isSending = false.obs;
  final includeCurrentLocation = true.obs;
  final sessionId = RxnString();
  final chat = <AskPanditMessage>[].obs;
  final currentLat = RxnDouble();
  final currentLng = RxnDouble();

  bool get canAsk {
    try {
      final profileController =
          Get.isRegistered<ProfileController>()
              ? Get.find<ProfileController>()
              : Get.put(ProfileController(), permanent: true);
      final user = profileController.user;
      final hasProfile =
          _hasText(user?.fullName) &&
          _hasText(user?.birthDate) &&
          _hasText(user?.birthTime) &&
          _hasText(user?.birthPlace);
      final subscribed = profileController.hasActiveSubscription == true;
      return hasProfile && subscribed;
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _prefetchLocation();
  }

  Future<void> sendQuestion(String question) async {
    final text = question.trim();
    if (text.isEmpty) {
      ToastUtils.show('Question is required.');
      return;
    }
    if (text.length > 2000) {
      ToastUtils.show('Question max 2000 characters allowed.');
      return;
    }

    final profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);
    await profileController.ensureProfileLoaded();
    if (!_isProfileComplete()) {
      ToastUtils.show('Please complete your profile birth details first.');
      return;
    }

    final subscriptionController =
        Get.isRegistered<SubscriptionController>()
            ? Get.find<SubscriptionController>()
            : Get.put(SubscriptionController(), permanent: true);
    await subscriptionController.ensurePlansLoaded();
    if (!profileController.hasActiveSubscription) {
      ToastUtils.show('Active subscription is required to use Ask Pandit.');
      return;
    }

    chat.add(AskPanditMessage(text: text, isUser: true, time: DateTime.now()));
    chat.add(
      AskPanditMessage(
        text: '',
        isUser: false,
        time: DateTime.now(),
        isTyping: true,
      ),
    );
    isSending.value = true;
    try {
      final lat =
          includeCurrentLocation.value == true ? currentLat.value : null;
      final lng =
          includeCurrentLocation.value == true ? currentLng.value : null;

      final response = await _repository.askQuestion(
        question: text,
        sessionId: sessionId.value,
        stream: 0,
        lat: lat,
        lng: lng,
      );

      if (!response.success) {
        _replaceTypingBubble(
          response.message.isNotEmpty
              ? response.message
              : 'Unable to get a response from Pandit ji right now.',
        );
        return;
      }

      if (_hasText(response.data?.sessionId)) {
        sessionId.value = response.data!.sessionId!.trim();
      }

      final answer = response.data?.answer?.trim();
      _replaceTypingBubble(
        (answer != null && answer.isNotEmpty)
            ? answer
            : 'Pandit ji has not sent a response yet.',
      );
    } catch (_) {
      _replaceTypingBubble('Something went wrong. Please try again.');
    } finally {
      isSending.value = false;
    }
  }

  void _replaceTypingBubble(String text) {
    final i = chat.lastIndexWhere((m) => !m.isUser && m.isTyping);
    if (i >= 0) {
      chat[i] = AskPanditMessage(
        text: text,
        isUser: false,
        time: DateTime.now(),
      );
      chat.refresh();
      return;
    }
    chat.add(AskPanditMessage(text: text, isUser: false, time: DateTime.now()));
  }

  bool _isProfileComplete() {
    final profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController(), permanent: true);
    final user = profileController.user;
    return _hasText(user?.fullName) &&
        _hasText(user?.birthDate) &&
        _hasText(user?.birthTime) &&
        _hasText(user?.birthPlace);
  }

  bool _hasText(String? value) {
    final t = value?.trim();
    return t != null && t.isNotEmpty && t.toLowerCase() != 'null';
  }

  Future<void> _prefetchLocation() async {
    try {
      final data = await _location.getLocation();
      currentLat.value = data.latitude;
      currentLng.value = data.longitude;
    } catch (_) {}
  }
}
