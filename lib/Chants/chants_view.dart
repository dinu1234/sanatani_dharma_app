import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:dharma_app/content/content_controller.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/japa/japa_controller.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

class ChantsView extends StatefulWidget {
  const ChantsView({super.key});

  @override
  State<ChantsView> createState() => _ChantsViewState();
}

class _ChantsViewState extends State<ChantsView> with WidgetsBindingObserver {
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _hapticsOn = false;
  bool _isAudioLoading = false;
  bool _isPlayingAudio = false;
  bool _allowPop = false;
  String? _activeAudioUrl;
  int? _boundMantraId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = false;
        _isAudioLoading = false;
      });
    });
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = state == PlayerState.playing;
        if (state != PlayerState.playing) {
          _isAudioLoading = false;
        }
      });
    });
  }

  Future<void> _incrementCount(
    ContentController contentController,
    JapaController japaController,
  ) async {
    if (_hapticsOn) {
      await _triggerCountVibration();
    }
    await japaController.incrementCount(contentController.featuredMantra);
  }

  Future<void> _triggerCountVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 140, amplitude: 180);
        return;
      }
    } catch (_) {}

    HapticFeedback.heavyImpact();
  }

  Future<void> _toggleMantraAudio(String? audioPath) async {
    if (audioPath == null || audioPath.trim().isEmpty) {
      ToastUtils.show('audio_not_available_for_mantra'.tr);
      return;
    }

    final audioUrl = '${ApiConstants.baseUrl}${audioPath.trim()}';

    try {
      if (_isPlayingAudio && _activeAudioUrl == audioUrl) {
        await _audioPlayer.pause().timeout(const Duration(seconds: 5));
        if (!mounted) return;
        setState(() {
          _isPlayingAudio = false;
          _isAudioLoading = false;
        });
        return;
      }

      if (mounted) {
        setState(() {
          _isAudioLoading = true;
          _activeAudioUrl = audioUrl;
        });
      }

      await _audioPlayer.stop().timeout(const Duration(seconds: 5));
      await _audioPlayer
          .play(UrlSource(audioUrl))
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isAudioLoading = false;
        _isPlayingAudio = false;
      });
      ToastUtils.show('audio_loading_timeout'.tr);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isAudioLoading = false;
        _isPlayingAudio = false;
      });
      ToastUtils.show('unable_to_play_audio'.tr);
    }
  }

  void _bindJapaData(
    ContentController contentController,
    JapaController japaController,
  ) {
    final mantra = contentController.featuredMantra;
    final mantraId = mantra?.id;
    if (mantraId == null || _boundMantraId == mantraId) return;
    _boundMantraId = mantraId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await japaController.ensureLoaded(mantra);
      if (!mounted) return;
      await japaController.refreshFromServer(mantra);
    });
  }

  Future<void> _saveAndPop() async {
    final japaController =
        Get.isRegistered<JapaController>() ? Get.find<JapaController>() : null;
    await japaController?.saveNow();
    if (!mounted) return;
    setState(() => _allowPop = true);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    final japaController =
        Get.isRegistered<JapaController>() ? Get.find<JapaController>() : null;
    japaController?.saveNow();
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final contentController =
          Get.isRegistered<ContentController>() ? Get.find<ContentController>() : null;
      final japaController =
          Get.isRegistered<JapaController>() ? Get.find<JapaController>() : null;
      japaController?.refreshFromServer(contentController?.featuredMantra);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      final japaController =
          Get.isRegistered<JapaController>() ? Get.find<JapaController>() : null;
      japaController?.saveNow();
    }
  }

  @override
  Widget build(BuildContext context) {
    final contentController =
        Get.isRegistered<ContentController>()
            ? Get.find<ContentController>()
            : Get.put(ContentController(), permanent: true);
    final japaController =
        Get.isRegistered<JapaController>()
            ? Get.find<JapaController>()
            : Get.put(JapaController(), permanent: true);

    _bindJapaData(contentController, japaController);

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final safeBottom = CommonBottomNav.bottomInset(mediaQuery);
    final scale = (width / 390).clamp(0.84, 1.08);
    final compactWidth = width < 370;
    final verticalScale = height < 720
        ? 0.8
        : height < 820
            ? 0.9
            : 1.0;
    final compactLayout = height < 760;
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.white,
      ),
      child: PopScope(
        canPop: _allowPop,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop || _allowPop) return;
          await _saveAndPop();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            (compactWidth ? 16 : 22) * scale,
            mediaQuery.padding.top + (12 * scale * verticalScale),
            (compactWidth ? 16 : 22) * scale,
            0,
          ),
          child: Column(
            children: [
              SizedBox(height: 24 * scale * verticalScale),
              Text(
                'daily_japa'.tr,
                style: TextStyle(
                  fontSize: (compactLayout ? 24 : 27) * scale,
                  color: AppColors.homePrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 18 * scale * verticalScale),
              Obx(
                () => _JapaCounterMandala(
                  availableWidth: width - ((compactWidth ? 32 : 44) * scale),
                  scale: scale,
                  verticalScale: verticalScale,
                  compactWidth: compactWidth,
                  count: japaController.count,
                  targetCount: japaController.targetCount,
                  onTap: () => _incrementCount(
                    contentController,
                    japaController,
                  ),
                ),
              ),
              SizedBox(height: 10 * scale * verticalScale),
              Obx(() {
                final mantra = contentController.featuredMantra;
                final audioPath = japaController.audioPath ?? mantra?.audioPath;
                final hasAudio = audioPath?.trim().isNotEmpty == true;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  'haptic_vibration'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize:
                                        (compactLayout ? 14 : 15.5) * scale,
                                    color: AppColors.homePrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              _MiniToggle(
                                scale: scale,
                                value: _hapticsOn,
                                onChanged: (value) {
                                  setState(() => _hapticsOn = value);
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        _AudioAction(
                          scale: scale,
                          enabled: hasAudio,
                          isPlaying: _isPlayingAudio,
                          isLoading: _isAudioLoading,
                          onTap: hasAudio
                              ? () => _toggleMantraAudio(audioPath)
                              : null,
                        ),
                      ],
                    );
                  },
                );
              }),
              SizedBox(height: 14 * scale * verticalScale),
              Obx(() {
                final mantraName = japaController.mantraName.trim().isNotEmpty
                    ? japaController.mantraName
                    : contentController.featuredMantra?.name?.trim().isNotEmpty ==
                            true
                        ? contentController.featuredMantra!.name!
                        : 'Om Shreem Maha\nLakshmiyei Namaha';

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: (compactWidth ? 14 : 18) * scale,
                    vertical: 16 * scale * verticalScale,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18 * scale),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFD49A42),
                        Color(0xFFF9E788),
                        Color(0xFFF8E977),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1C000000),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Text(
                    mantraName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize:
                          (compactWidth ? 16.8 : compactLayout ? 18 : 20) *
                              scale,
                      height: 1.15,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }),
              Obx(() {
                final audioPath =
                    japaController.audioPath ??
                    contentController.featuredMantra?.audioPath;
                if (audioPath == null || audioPath.trim().isEmpty) {
                  return SizedBox(height: 18 * scale * verticalScale);
                }

                final audioUrl = '${ApiConstants.baseUrl}$audioPath';
                return Padding(
                  padding: EdgeInsets.only(
                    top: 10 * scale,
                    bottom: 18 * scale * verticalScale,
                  ),
                  child: Text(
                    _activeAudioUrl == audioUrl
                        ? 'audio_ready'.tr
                        : 'audio_available'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12 * scale,
                      color: AppColors.homePrimary.withOpacity(0.7),
                    ),
                  ),
                );
              }),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  16 * scale,
                  16 * scale * verticalScale,
                  16 * scale,
                  14 * scale * verticalScale,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FD),
                  borderRadius: BorderRadius.circular(20 * scale),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'daily_summary'.tr,
                      style: TextStyle(
                        fontSize: (compactLayout ? 16 : 17) * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 16 * scale * verticalScale),
                    Obx(
                      () => _SummaryRow(
                        scale: scale,
                        title: 'chants_today'.tr,
                        value: '${japaController.chantsToday}',
                      ),
                    ),
                    Divider(
                      height: 24 * scale * verticalScale,
                      color: const Color(0xFFE2E2EC),
                    ),
                    Obx(
                      () => _SummaryRow(
                        scale: scale,
                        title: 'malas_completed'.tr,
                        value: '${japaController.malasCompleted}/30',
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8 * scale),
            ],
          ),
          ),
          bottomNavigationBar: CommonBottomNav(
            currentItem: AppNavItem.chants,
            scale: scale,
            safeBottom: safeBottom,
            centerNavSize: centerNavSize,
            height: navHeight,
          ),
        ),
      ),
    );
  }
}

class _JapaCounterMandala extends StatelessWidget {
  const _JapaCounterMandala({
    required this.availableWidth,
    required this.scale,
    required this.verticalScale,
    required this.compactWidth,
    required this.count,
    required this.targetCount,
    required this.onTap,
  });

  final double availableWidth;
  final double scale;
  final double verticalScale;
  final bool compactWidth;
  final int count;
  final int targetCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final desiredOuterSize = 286 * scale * (0.9 + (verticalScale * 0.1));
    final outerSize = math.min(desiredOuterSize, availableWidth);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AppSvgAsset(
              assetName: 'assets/images/dailyjapa.svg',
              width: outerSize,
              height: outerSize,
              fit: BoxFit.contain,
            ),
            Container(
              width: outerSize * 0.54,
              height: outerSize * 0.54,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$count / $targetCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (compactWidth ? 28 : 31) * scale,
                      height: 1,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12 * scale),
                  Text(
                    'tap_to_count'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (compactWidth ? 11.5 : 13) * scale,
                      color: AppColors.homePrimary.withOpacity(0.78),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({
    required this.scale,
    required this.value,
    required this.onChanged,
  });

  final double scale;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final knobSize = 20 * scale;
    final toggleWidth = 52 * scale;
    final activeColor = AppColors.homePrimary;
    final inactiveColor = const Color(0xFFD8DDE6);
    final textColor = value ? AppColors.white : const Color(0xFF6C7280);

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: toggleWidth,
        height: 30 * scale,
        padding: EdgeInsets.symmetric(horizontal: 3 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: value
                ? [activeColor.withOpacity(0.92), activeColor]
                : [inactiveColor, const Color(0xFFEDF1F6)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(
            color: value
                ? activeColor.withOpacity(0.85)
                : const Color(0xFFC7CDD8),
          ),
          boxShadow: [
            BoxShadow(
              color: (value ? activeColor : Colors.black).withOpacity(0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment:
              value ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!value)
              Expanded(
                child: Text(
                  'off'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.8 * scale,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: knobSize,
              height: knobSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                value ? Icons.check_rounded : Icons.close_rounded,
                size: 13 * scale,
                color: value ? activeColor : const Color(0xFF8A9099),
              ),
            ),
            if (value)
              Expanded(
                child: Text(
                  'on'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.8 * scale,
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AudioAction extends StatelessWidget {
  const _AudioAction({
    required this.scale,
    required this.enabled,
    required this.isPlaying,
    required this.isLoading,
    this.onTap,
  });

  final double scale;
  final bool enabled;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.homePrimary : Colors.grey;
    final icon = isLoading
        ? Icons.hourglass_top_rounded
        : isPlaying
            ? Icons.pause_circle_filled_rounded
            : Icons.play_circle_fill_rounded;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34 * scale,
        height: 34 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: enabled
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.12),
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.28)
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: 22 * scale,
          color: color,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.scale,
    required this.title,
    required this.value,
  });

  final double scale;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final compactWidth = MediaQuery.of(context).size.width < 370;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: (compactWidth ? 14.2 : 15.5) * scale,
              color: const Color(0xFF353535),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: (compactWidth ? 15 : 16.5) * scale,
            color: const Color(0xFF353535),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
