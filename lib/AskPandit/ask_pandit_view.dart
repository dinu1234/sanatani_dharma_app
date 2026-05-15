import 'package:dharma_app/AskPandit/ask_pandit_controller.dart';
import 'package:dharma_app/AskPandit/ask_pandit_model.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/Profile/profile_setup_view.dart';
import 'package:dharma_app/Subscription/subscription_view.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AskPanditView extends StatefulWidget {
  const AskPanditView({super.key});

  @override
  State<AskPanditView> createState() => _AskPanditViewState();
}

class _AskPanditViewState extends State<AskPanditView> {
  late final AskPanditController _controller;
  late final ProfileController _profileController;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _hasInput = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<AskPanditController>()
        ? Get.find<AskPanditController>()
        : Get.put(AskPanditController(), permanent: true);
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    ever<List<AskPanditMessage>>(_controller.chat, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  @override
  void dispose() {
    _hasInput.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 390).clamp(0.84, 1.08);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF8F1E8),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F1E8),
        body: SafeArea(
          child: Obx(() {
            final blocked = _controller.canAsk != true;
            final useLocation =
                _controller.includeCurrentLocation.value == true;
            final messages = _controller.chat;
            final isLoadingWelcome = _controller.isLoadingWelcome.value;

            return Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            18 * scale,
                            10 * scale,
                            18 * scale,
                            0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _TopBar(
                                scale: scale,
                                profileController: _profileController,
                              ),
                              SizedBox(height: 10 * scale),
                              _HeroPanel(scale: scale),
                              SizedBox(height: 12 * scale),
                              Opacity(
                                opacity: 0.92,
                                child: _LocationToggle(
                                  scale: scale,
                                  value: useLocation,
                                  onChanged: (value) =>
                                      _controller.includeCurrentLocation.value =
                                          value,
                                ),
                              ),
                              if (blocked) ...[
                                // SizedBox(height: 14 * scale),
                                _AccessCard(scale: scale),
                              ],
                              if (messages.isEmpty && isLoadingWelcome) ...[
                                // SizedBox(height: 18 * scale),
                                _ChatBubble(
                                  scale: scale,
                                  message: AskPanditMessage(
                                    text: '',
                                    isUser: false,
                                    time: DateTime.now(),
                                    isTyping: true,
                                  ),
                                ),
                              ] else ...[
                                // SizedBox(height: 18 * scale),
                                ...messages.map(
                                  (message) => _ChatBubble(
                                    scale: scale,
                                    message: message,
                                  ),
                                ),
                              ],
                              SizedBox(height: 18 * scale),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                _ComposerBar(
                  scale: scale,
                  controller: _inputController,
                  hasInput: _hasInput,
                  blocked: blocked,
                  isSending: _controller.isSending.value,
                  onSend: () async {
                    final q = _inputController.text;
                    _inputController.clear();
                    await _controller.sendQuestion(q);
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.scale, required this.profileController});

  final double scale;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            height: 42 * scale,
            width: 42 * scale,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.76),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7D8C7)),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18 * scale,
              color: const Color(0xFF861015),
            ),
          ),
        ),
        const Spacer(),
        Obx(() {
          final imageUrl = profileController.profileImageUrl;
          return Container(
            padding: EdgeInsets.all(2 * scale),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.82),
            ),
            child: SizedBox(
              height: 40 * scale,
              width: 40 * scale,
              child: ClipOval(
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const ShreeSvg(fit: BoxFit.cover),
                      )
                    : const ShreeSvg(fit: BoxFit.cover),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ask_pandit'.tr,
          style: TextStyle(
            color: const Color(0xFF861015),
            fontSize: 34 * scale,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
        SizedBox(height: 12 * scale),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 5 * scale),
              height: 16 * scale,
              width: 16 * scale,
              decoration: const BoxDecoration(
                color: Color(0xFF18BE8C),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 10 * scale),
            Expanded(
              child: Text(
                'ask_pandit_online'.tr,
                style: TextStyle(
                  color: const Color(0xFF861015),
                  fontSize: 13.8 * scale,
                  height: 1.15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20 * scale),
        Center(
          child: Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFF5EA), Color(0xFFF2DED1)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A1C).withValues(alpha: 0.12),
                  blurRadius: 22,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Container(
              padding: EdgeInsets.all(7 * scale),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/ask_pandit_guru.png',
                  width: 132 * scale,
                  height: 132 * scale,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 18 * scale),
        Center(
          child: Text(
            'pranam'.tr,
            style: TextStyle(
              color: const Color(0xFF861015),
              fontSize: 30 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(height: 14 * scale),
        Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 290 * scale),
            child: Text(
              'ask_pandit_intro'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF861015),
                fontSize: 15.5 * scale,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocationToggle extends StatelessWidget {
  const _LocationToggle({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * scale,
        vertical: 8 * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(18 * scale),
        border: Border.all(color: const Color(0xFFF0D8C7)),
      ),
      child: Row(
        children: [
          Container(
            height: 28 * scale,
            width: 28 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0E4),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Icon(
              Icons.location_on_outlined,
              color: const Color(0xFFB24C1A),
              size: 16 * scale,
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Text(
              'ask_pandit_use_location'.tr,
              style: TextStyle(
                color: const Color(0xFF7A332B),
                fontSize: 11.8 * scale,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFFD8A1B),
          ),
        ],
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E8),
        borderRadius: BorderRadius.circular(28 * scale),
        border: Border.all(color: const Color(0xFFF1D3BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44 * scale,
                width: 44 * scale,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFE4D0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_open_rounded,
                  color: const Color(0xFFB24C1A),
                  size: 24 * scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Text(
                  'ask_pandit_access_required'.tr,
                  style: TextStyle(
                    fontSize: 13.5 * scale,
                    color: const Color(0xFF7A332B),
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14 * scale),
          Wrap(
            spacing: 10 * scale,
            runSpacing: 10 * scale,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileSetupView()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF861015),
                  side: const BorderSide(color: Color(0xFF861015)),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 12 * scale,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text('complete_profile'.tr),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionPlansView(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFD8A1B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 12 * scale,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text('take_subscription'.tr),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.scale, required this.message});

  final double scale;
  final AskPanditMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: EdgeInsets.only(bottom: 16 * scale),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(maxWidth: 304 * scale),
              padding: EdgeInsets.symmetric(
                horizontal: 18 * scale,
                vertical: 18 * scale,
              ),
              decoration: BoxDecoration(
                color: isUser ? Colors.white : const Color(0xFFFFF2E8),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28 * scale),
                  topRight: Radius.circular(28 * scale),
                  bottomLeft: Radius.circular(isUser ? 28 * scale : 8 * scale),
                  bottomRight: Radius.circular(isUser ? 8 * scale : 28 * scale),
                ),
                border: isUser
                    ? Border.all(color: Colors.white.withValues(alpha: 0.92))
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: message.isTyping
                  ? _TypingDots(scale: scale)
                  : Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 16.4 * scale,
                        color: const Color(0xFF171616),
                        height: 1.72,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 8 * scale),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10 * scale),
            child: Text(
              _formatTime(message.time),
              style: TextStyle(
                fontSize: 13.5 * scale,
                color: const Color(0xFF231F1F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.scale,
    required this.controller,
    required this.hasInput,
    required this.blocked,
    required this.isSending,
    required this.onSend,
  });

  final double scale;
  final TextEditingController controller;
  final ValueNotifier<bool> hasInput;
  final bool blocked;
  final bool isSending;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          18 * scale,
          12 * scale,
          18 * scale,
          14 * scale,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E0E0),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF861015),
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: controller,
                  enabled: !blocked && !isSending,
                  maxLength: 2000,
                  minLines: 1,
                  maxLines: 4,
                  onChanged: (value) => hasInput.value = value.trim().isNotEmpty,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) async {
                    if (blocked || isSending || controller.text.trim().isEmpty) {
                      return;
                    }
                    await onSend();
                    hasInput.value = false;
                  },
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ask_pandit_hint'.tr,
                    hintStyle: TextStyle(
                      color: const Color(0xFF8B8B8B),
                      fontSize: 16 * scale,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 22 * scale,
                      vertical: 18 * scale,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14 * scale),
            ValueListenableBuilder<bool>(
              valueListenable: hasInput,
              builder: (context, hasText, _) {
                return SizedBox(
                  height: 56 * scale,
                  width: 56 * scale,
                  child: ElevatedButton(
                    onPressed: blocked || isSending || !hasText
                        ? null
                        : () async {
                            await onSend();
                            hasInput.value = false;
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      disabledBackgroundColor: const Color(0xFFFFC48B),
                      elevation: 0,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                    ),
                    child: isSending
                        ? SizedBox(
                            height: 20 * scale,
                            width: 20 * scale,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Transform.rotate(
                            angle: -0.25,
                            child: Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 24 * scale,
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots({required this.scale});

  final double scale;

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> {
  int _active = 0;

  @override
  void initState() {
    super.initState();
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      setState(() => _active = (_active + 1) % 3);
      _tick();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final on = _active == i;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: EdgeInsets.symmetric(horizontal: 2 * widget.scale),
          width: (on ? 8 : 6) * widget.scale,
          height: (on ? 8 : 6) * widget.scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF8B8E97).withValues(alpha: on ? 0.95 : 0.45),
          ),
        );
      }),
    );
  }
}
