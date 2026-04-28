import 'package:dharma_app/AskPandit/ask_pandit_controller.dart';
import 'package:dharma_app/AskPandit/ask_pandit_model.dart';
import 'package:dharma_app/Profile/profile_setup_view.dart';
import 'package:dharma_app/Subscription/subscription_view.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
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
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller =
        Get.isRegistered<AskPanditController>()
            ? Get.find<AskPanditController>()
            : Get.put(AskPanditController(), permanent: true);
    ever<List<AskPanditMessage>>(_controller.chat, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
        );
      });
    });
  }

  @override
  void dispose() {
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
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F1E8),
        appBar: AppBar(
          backgroundColor: AppColors.homePrimary,
          foregroundColor: Colors.white,
          title: const Text('Ask Pandit'),
        ),
        body: Obx(() {
          final blocked = _controller.canAsk != true;
          final useLocation = _controller.includeCurrentLocation.value == true;
          return Column(
            children: [
              if (blocked) _AccessCard(scale: scale),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12 * scale,
                  10 * scale,
                  12 * scale,
                  0,
                ),
                child: Row(
                  children: [
                    Switch(
                      value: useLocation,
                      onChanged: (v) =>
                          _controller.includeCurrentLocation.value = v,
                    ),
                    Expanded(
                      child: Text(
                        'Use current lat/lng for Panchang context',
                        style: TextStyle(
                          fontSize: 12.5 * scale,
                          color: AppColors.homePrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(12 * scale),
                  itemCount: _controller.chat.isEmpty
                      ? 1
                      : _controller.chat.length,
                  itemBuilder: (context, index) {
                    if (_controller.chat.isEmpty) {
                      return _StarterCard(scale: scale);
                    }
                    final msg = _controller.chat[index];
                    return _ChatBubble(scale: scale, message: msg);
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    12 * scale,
                    8 * scale,
                    12 * scale,
                    10 * scale,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          enabled: !blocked && !_controller.isSending.value,
                          maxLength: 2000,
                          minLines: 1,
                          maxLines: 4,
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'Type your question...',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16 * scale),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8 * scale),
                      SizedBox(
                        height: 48 * scale,
                        width: 48 * scale,
                        child: ElevatedButton(
                          onPressed: blocked || _controller.isSending.value
                              ? null
                              : () async {
                                  final q = _inputController.text;
                                  _inputController.clear();
                                  await _controller.sendQuestion(q);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.homePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * scale),
                            ),
                            padding: EdgeInsets.zero,
                          ),
                          child: _controller.isSending.value
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
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
      margin: EdgeInsets.fromLTRB(12 * scale, 12 * scale, 12 * scale, 0),
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile completion and active subscription are required to use Ask Pandit.',
            style: TextStyle(
              fontSize: 13 * scale,
              color: AppColors.homePrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileSetupView()),
                  );
                },
                child: const Text('Complete Profile'),
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
                  backgroundColor: AppColors.homePrimary,
                ),
                child: const Text('Take Subscription'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarterCard extends StatelessWidget {
  const _StarterCard({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Text(
        'Namaste. You can ask about career, marriage, finance, health, planetary periods, or daily guidance (Hindi/English/Hinglish).',
        style: TextStyle(
          fontSize: 13 * scale,
          color: const Color(0xFF5C4A3F),
          height: 1.4,
        ),
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
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8 * scale),
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 10 * scale),
        constraints: BoxConstraints(maxWidth: 300 * scale),
        decoration: BoxDecoration(
          color: isUser ? AppColors.homePrimary : Colors.white,
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: message.isTyping
            ? _TypingDots(scale: scale)
            : Text(
                message.text,
                style: TextStyle(
                  fontSize: 13.2 * scale,
                  color: isUser ? Colors.white : const Color(0xFF2E2F33),
                  height: 1.35,
                ),
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
            color: Color(0xFF8B8E97).withOpacity(on ? 0.95 : 0.45),
          ),
        );
      }),
    );
  }
}
