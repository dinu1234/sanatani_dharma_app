import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dharma_app/GanaMatch/gana_match_model.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GanaMatchResultView extends StatefulWidget {
  const GanaMatchResultView({
    super.key,
    required this.result,
  });

  final KundliMatchResult result;

  @override
  State<GanaMatchResultView> createState() => _GanaMatchResultViewState();
}

class _GanaMatchResultViewState extends State<GanaMatchResultView> {
  static const MethodChannel _shareChannel = MethodChannel(
    'dharma_app/whatsapp_share',
  );

  final GlobalKey _captureKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final safeBottom = CommonBottomNav.bottomInset(mediaQuery);
    final scale = (width / 390).clamp(0.84, 1.08);
    final compactWidth = width < 380;
    final verticalScale = height < 700
        ? 0.74
        : height < 780
            ? 0.86
            : 1.0;
    final compactLayout = height < 780;
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);
    final breakdown = widget.result.breakdown
        .map(
          (item) => _BreakdownItem(
            item.name ?? '-',
            ((item.obtainedPoints ?? 0) / ((item.maximumPoints ?? 1) == 0 ? 1 : (item.maximumPoints ?? 1)))
                .clamp(0, 1)
                .toDouble(),
            (item.percentage ?? 0) / 100,
            fillColor: _indicatorColor(item.indicatorColor),
            subtitle: _buildSubtitle(item),
          ),
        )
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.homeBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFD8E7F7),
                      const Color(0xFFEAE7FB),
                      const Color(0xFFF6F7FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 50 * scale,
              left: -56 * scale,
              child: _GlowOrb(
                size: 170 * scale,
                colors: const [Color(0x66B7D1F4), Color(0x00B7D1F4)],
              ),
            ),
            Positioned(
              top: 260 * scale,
              right: -70 * scale,
              child: _GlowOrb(
                size: 180 * scale,
                colors: const [Color(0x55DAD6FF), Color(0x00DAD6FF)],
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                (compactWidth ? 12 : 14) * scale,
                mediaQuery.padding.top + (8 * scale * verticalScale),
                (compactWidth ? 12 : 14) * scale,
                navHeight + centerNavSize * (compactLayout ? 0.45 : 0.35),
              ),
              child: Column(
                children: [
                  SizedBox(height: 4 * scale * verticalScale),
                  Text(
                    'gana_matching'.tr,
                    style: TextStyle(
                      fontSize: (compactLayout ? 20 : 22) * scale,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 10 * scale * verticalScale),
                  RepaintBoundary(
                    key: _captureKey,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD8E7F7),
                            const Color(0xFFEAE7FB),
                            const Color(0xFFF6F7FC),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28 * scale),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        8 * scale,
                        8 * scale,
                        8 * scale,
                        8 * scale,
                      ),
                      child: Column(
                        children: [
                          _MandalaScore(
                            scale: scale,
                            verticalScale: verticalScale,
                            scoreText: widget.result.score?.display ?? '0/36',
                          ),
                          SizedBox(height: 4 * scale * verticalScale),
                          _CoupleSection(
                            scale: scale,
                            compactLayout: compactLayout,
                            compactWidth: compactWidth,
                            groomName: widget.result.couple?.boy?.name ?? 'boy'.tr,
                            brideName: widget.result.couple?.girl?.name ?? 'girl'.tr,
                          ),
                          SizedBox(height: 2 * scale * verticalScale),
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                              vertical: (compactWidth ? 6 : 8) * scale,
                            ).add(EdgeInsets.only(bottom: 4 * scale)),
                            padding: EdgeInsets.fromLTRB(
                              14 * scale,
                              14 * scale * verticalScale,
                              14 * scale,
                              14 * scale * verticalScale,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withOpacity(0.46),
                              borderRadius: BorderRadius.circular(22 * scale),
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.35),
                                width: 1.1 * scale,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x14000000),
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'breakdown'.tr,
                                  style: TextStyle(
                                    fontSize: (compactLayout ? 15 : 16.5) * scale,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.homePrimary,
                                  ),
                                ),
                                SizedBox(height: 10 * scale * verticalScale),
                                Column(
                                  children: breakdown
                                      .map(
                                        (item) => _BreakdownRow(
                                          scale: scale,
                                          compactLayout: compactLayout,
                                          item: item,
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 6 * scale * verticalScale),
                          Text(
                            _buildSummaryText(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: (compactLayout ? 14.4 : 16.2) * scale,
                              height: 1.25,
                              color: AppColors.homePrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8 * scale * verticalScale),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: math.min(width * 0.72, 220 * scale),
                      maxWidth: math.min(width * 0.86, 300 * scale),
                    ),
                    margin: EdgeInsets.only(bottom: 8 * scale),
                    height: (compactLayout ? 31 : 33) * scale,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22 * scale),
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.homeGoldDark,
                          AppColors.homeGoldLight,
                          AppColors.homeGoldDark,
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _isSharing ? null : () => _shareOnWhatsApp(),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.homePrimary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22 * scale),
                        ),
                      ),
                      child: Text(
                        'share_on_whatsapp'.tr,
                        style: TextStyle(
                          fontSize: (compactLayout ? 14.8 : 15.5) * scale,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: CommonBottomNav(
          currentItem: AppNavItem.ganaMatch,
          scale: scale,
          safeBottom: safeBottom,
          centerNavSize: centerNavSize,
          height: navHeight,
        ),
      ),
    );
  }

  String _buildSummaryText() {
    final summary = widget.result.summary?.message?.trim();
    if (summary != null && summary.isNotEmpty) {
      return summary;
    }
    return 'compatibility_result_available'.tr;
  }

  String? _buildSubtitle(KundliBreakdownItem item) {
    final girlValue = item.girlValue?.trim();
    final boyValue = item.boyValue?.trim();
    if ((girlValue == null || girlValue.isEmpty) &&
        (boyValue == null || boyValue.isEmpty)) {
      return null;
    }
    return '${girlValue ?? '-'} / ${boyValue ?? '-'}';
  }

  Color _indicatorColor(String? value) {
    switch (value?.toLowerCase()) {
      case 'green':
        return const Color(0xFF11B455);
      case 'yellow':
        return const Color(0xFFE7D628);
      case 'red':
        return const Color(0xFFE61E50);
      default:
        return const Color(0xFF11B455);
    }
  }

  Future<void> _shareOnWhatsApp() async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final imagePath = await _captureShareImage();
      final shared = await _shareChannel.invokeMethod<bool>(
        'shareImageToWhatsApp',
        {'imagePath': imagePath},
      );

      if (shared != true) {
        ToastUtils.show('whatsapp_not_available'.tr);
      }
    } catch (exception) {
      ToastUtils.show('WhatsApp image share failed: $exception');
      print('Error sharing image to WhatsApp: $exception');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<String> _captureShareImage() async {
    await Future<void>.delayed(const Duration(milliseconds: 32));

    final boundary =
        _captureKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('capture_boundary_not_ready'.tr);
    }

    final pixelRatio = MediaQuery.of(context).devicePixelRatio.clamp(2.0, 3.0);
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFD8E7F7),
          Color(0xFFEAE7FB),
          Color(0xFFF6F7FC),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRect(rect, backgroundPaint);
    canvas.drawImage(image, Offset.zero, Paint());

    final composedImage = await recorder.endRecording().toImage(
          image.width,
          image.height,
        );
    final byteData = await composedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    composedImage.dispose();
    if (byteData == null) {
      throw StateError('unable_to_encode_image'.tr);
    }

    final bytes = byteData.buffer.asUint8List();
    final directory = Directory.systemTemp;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/gana_match_$timestamp.png');
    await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);

    return file.path;
  }
}

class _MandalaScore extends StatelessWidget {
  const _MandalaScore({
    required this.scale,
    required this.verticalScale,
    required this.scoreText,
  });

  final double scale;
  final double verticalScale;
  final String scoreText;

  @override
  Widget build(BuildContext context) {
    final outerSize = 256 * scale * (0.9 + (verticalScale * 0.1));

    return SizedBox(
      width: outerSize,
      height: outerSize * 0.97,
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
              width: outerSize * 0.58,
              height: outerSize * 0.58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFE6BA54),
                    Color(0xFFF9F1A2),
                    Color(0xFFE0A947),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                border: Border.all(
                  color: const Color(0xFFF6E0A2),
                  width: 3 * scale,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x18000000),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'obtained_points'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (12.2 + (verticalScale - 0.74) * 2.2) * scale,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    scoreText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: (33 + (verticalScale * 3.8)) * scale,
                      height: 1,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoupleSection extends StatelessWidget {
  const _CoupleSection({
    required this.scale,
    required this.compactLayout,
    required this.compactWidth,
    required this.groomName,
    required this.brideName,
  });

  final double scale;
  final bool compactLayout;
  final bool compactWidth;
  final String groomName;
  final String brideName;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: (compactWidth ? 8 : 12) * scale,
      runSpacing: 12 * scale,
      children: [
        _PersonAvatar(
          scale: scale,
          compactWidth: compactWidth,
          name: groomName,
          assetName: 'assets/images/Ganamale.svg',
        ),
        Padding(
          padding: EdgeInsets.only(bottom: (compactLayout ? 14 : 18) * scale),
          child: Text(
            '&',
            style: TextStyle(
              fontSize: (compactLayout ? 24 : 28) * scale,
              fontWeight: FontWeight.w500,
              color: AppColors.homePrimary,
            ),
          ),
        ),
          _PersonAvatar(
            scale: scale,
            compactWidth: compactWidth,
            name: brideName,
            assetName: 'assets/images/Ganafemale.svg',
          ),
      ],
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.scale,
    required this.compactWidth,
    required this.name,
    required this.assetName,
  });

  final double scale;
  final bool compactWidth;
  final String name;
  final String assetName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 90 * scale,
          height: 90 * scale,
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   border: Border.all(
          //     color: AppColors.homeGoldDark.withOpacity(0.7),
          //     width: 1.4 * scale,
          //   ),
          //   gradient: const LinearGradient(
          //     colors: [Color(0xFFF4D676), Color(0xFFD09B3F)],
          //     begin: Alignment.topLeft,
          //     end: Alignment.bottomRight,
          //   ),
          //   boxShadow: const [
          //     BoxShadow(
          //       color: Color(0x12000000),
          //       blurRadius: 8,
          //       offset: Offset(0, 3),
          //     ),
          //   ],
          // ),
          child: Container(
            margin: EdgeInsets.all(3.5 * scale),
            // decoration: const BoxDecoration(
            //   shape: BoxShape.circle,
            //   color: Color(0xFFF1F3F6),
            // ),
            child: AppSvgAsset(
              assetName: assetName,
              fit: BoxFit.contain,
            ),
          ),
        ),
        SizedBox(height: 5 * scale),
        SizedBox(
          width: (compactWidth ? 74 : 82) * scale,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: (compactWidth ? 12.8 : 14) * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem(
    this.title,
    this.progress,
    this.marker, {
    this.fillColor,
    this.subtitle,
  });

  final String title;
  final double progress;
  final double marker;
  final Color? fillColor;
  final String? subtitle;
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.scale,
    required this.compactLayout,
    required this.item,
  });

  final double scale;
  final bool compactLayout;
  final _BreakdownItem item;

  @override
  Widget build(BuildContext context) {
    final fillColor = item.fillColor ??
        (item.progress < 0.5 ? const Color(0xFFE61E50) : const Color(0xFF11B455));

    return Padding(
      padding: EdgeInsets.only(bottom: (compactLayout ? 8 : 10) * scale),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6 * scale),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFD9B8BB).withOpacity(0.9),
              width: 0.8 * scale,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: (compactLayout ? 88 : 96) * scale,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      fontSize: (compactLayout ? 13.2 : 14.5) * scale,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                
                ],
              ),
            ),
            SizedBox(width: (compactLayout ? 9 : 12) * scale),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: item.subtitle == null ? 4 * scale : 2 * scale,
                ),
                child: Container(
                  height: (compactLayout ? 22 : 24) * scale,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F5).withOpacity(0.95),
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final markerLeft = (constraints.maxWidth * item.progress)
                          .clamp(12.0, constraints.maxWidth - 12.0);

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: (constraints.maxWidth * item.progress)
                                  .clamp(0.0, constraints.maxWidth),
                              margin: EdgeInsets.symmetric(
                                horizontal: 4 * scale,
                                vertical: 5 * scale,
                              ),
                              decoration: BoxDecoration(
                                color: fillColor,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                          Positioned(
                            left: markerLeft -
                                ((compactLayout ? 10 : 11) * scale),
                            top: (compactLayout ? -0.5 : -1) * scale,
                            child: Container(
                              width: (compactLayout ? 24 : 26) * scale,
                              height: (compactLayout ? 24 : 26) * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6C92),
                                    Color(0xFFFF2E63),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2 * scale,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x22000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.favorite,
                                  color: AppColors.white,
                                  size: (compactLayout ? 11 : 12) * scale,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}
