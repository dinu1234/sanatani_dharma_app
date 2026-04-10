import 'dart:math' as math;

import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChantsView extends StatefulWidget {
  const ChantsView({super.key});

  @override
  State<ChantsView> createState() => _ChantsViewState();
}

class _ChantsViewState extends State<ChantsView> {
  static const int _targetCount = 108;
  int _count = 1;
  bool _hapticsOn = true;

  void _incrementCount() {
    setState(() {
      _count = _count >= _targetCount ? 1 : _count + 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final safeBottom = mediaQuery.padding.bottom;
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
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFFFFF),
                      const Color(0xFFFBFAFE),
                      const Color(0xFFF6F5FB),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                (compactWidth ? 16 : 22) * scale,
                mediaQuery.padding.top + (12 * scale * verticalScale),
                (compactWidth ? 16 : 22) * scale,
                navHeight + centerNavSize * 0.15,
              ),
              child: Column(
                children: [
                    SizedBox(height: 24 * scale * verticalScale),
                    Text(
                      'Daily Japa',
                      style: TextStyle(
                        fontSize: (compactLayout ? 24 : 27) * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 18 * scale * verticalScale),
                    _JapaCounterMandala(
                      availableWidth: width - ((compactWidth ? 32 : 44) * scale),
                      scale: scale,
                      verticalScale: verticalScale,
                      compactWidth: compactWidth,
                      count: _count,
                      targetCount: _targetCount,
                      onTap: _incrementCount,
                    ),
                    SizedBox(height: 20 * scale * verticalScale),
                    Column(
                      children: [
                        if (compactWidth)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Haptic vibration',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14 * scale,
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
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Haptic vibration',
                                    style: TextStyle(
                                      fontSize:
                                          (compactLayout ? 14 : 15.5) * scale,
                                      color: AppColors.homePrimary,
                                      fontWeight: FontWeight.w700,
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
                              Text(
                                'Listen mantra',
                                style: TextStyle(
                                  fontSize: (compactLayout ? 14 : 15.5) * scale,
                                  color: AppColors.homePrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        SizedBox(height: (compactWidth ? 10 : 0) * scale),
                        if (compactWidth)
                          Text(
                            'Listen mantra',
                            style: TextStyle(
                              fontSize: 14 * scale,
                              color: AppColors.homePrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 14 * scale * verticalScale),
                    Container(
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
                        'Om Shreem Maha\nLakshmiyei Namaha',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (compactWidth ? 16.8 : compactLayout ? 18 : 20) * scale,
                          height: 1.15,
                          color: AppColors.homePrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * scale * verticalScale),
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
                            'Daily Summary',
                            style: TextStyle(
                              fontSize: (compactLayout ? 16 : 17) * scale,
                              color: AppColors.homePrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 16 * scale * verticalScale),
                          _SummaryRow(
                            scale: scale,
                            title: 'Chants Today',
                            value: '356',
                          ),
                          Divider(
                            height: 24 * scale * verticalScale,
                            color: const Color(0xFFE2E2EC),
                          ),
                          _SummaryRow(
                            scale: scale,
                            title: 'Malas Completed',
                            value: '3/30',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CommonBottomNav(
                currentItem: AppNavItem.chants,
                scale: scale,
                safeBottom: safeBottom,
                centerNavSize: centerNavSize,
                height: navHeight,
              ),
            ),
          ],
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
    final centerSize = 170 * scale * (0.92 + (verticalScale * 0.08));

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: outerSize,
        height: outerSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: outerSize,
              height: outerSize,
              child: CustomPaint(
                painter: _MandalaPainter(
                  strokeColor: AppColors.homeGoldBorder.withOpacity(0.34),
                  fineColor: AppColors.homeGoldBorder.withOpacity(0.18),
                ),
              ),
            ),
            Container(
              width: centerSize,
              height: centerSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFFF0DFC4),
                  width: 2.6 * scale,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'COUNT',
                    style: TextStyle(
                      fontSize: (compactWidth ? 12 : 13) * scale,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    '$count / $targetCount',
                    style: TextStyle(
                      fontSize: (compactWidth ? 27 : 30) * scale,
                      height: 1,
                      color: AppColors.homePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14 * scale),
                  Text(
                    'TAP TO COUNT',
                    style: TextStyle(
                      fontSize: (compactWidth ? 10.8 : 11.8) * scale,
                      color: AppColors.homePrimary.withOpacity(0.78),
                      fontWeight: FontWeight.w500,
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
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 42 * scale,
        height: 22 * scale,
        padding: EdgeInsets.symmetric(horizontal: 2 * scale),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: const Color(0xFFE8E8E8),
          border: Border.all(color: const Color(0xFFD0D0D0)),
        ),
        child: Row(
          mainAxisAlignment:
              value ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!value)
              Padding(
                padding: EdgeInsets.only(left: 3 * scale),
                child: Text(
                  'OFF',
                  style: TextStyle(
                    fontSize: 8.5 * scale,
                    color: AppColors.homePrimary.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (value)
              Padding(
                padding: EdgeInsets.only(right: 3 * scale),
                child: Text(
                  'ON',
                  style: TextStyle(
                    fontSize: 8.5 * scale,
                    color: AppColors.homePrimary.withOpacity(0.65),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Container(
              width: 18 * scale,
              height: 18 * scale,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF14B53D),
              ),
            ),
          ],
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

class _MandalaPainter extends CustomPainter {
  const _MandalaPainter({
    required this.strokeColor,
    required this.fineColor,
  });

  final Color strokeColor;
  final Color fineColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final midRadius = outerRadius * 0.72;
    final innerRadius = outerRadius * 0.5;

    final mainPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.45;

    final finePaint = Paint()
      ..color = fineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    for (var i = 0; i < 16; i++) {
      final angle = (math.pi * 2 / 16) * i;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petal = Path()
        ..moveTo(0, -innerRadius * 0.84)
        ..quadraticBezierTo(
          outerRadius * 0.2,
          -outerRadius * 0.78,
          0,
          -outerRadius,
        )
        ..quadraticBezierTo(
          -outerRadius * 0.2,
          -outerRadius * 0.78,
          0,
          -innerRadius * 0.84,
        );
      canvas.drawPath(petal, mainPaint);

      for (var j = 1; j <= 3; j++) {
        final inset = j * outerRadius * 0.035;
        final detailPetal = Path()
          ..moveTo(0, -innerRadius * 0.84 - inset * 0.25)
          ..quadraticBezierTo(
            (outerRadius * 0.2) - inset * 0.2,
            (-outerRadius * 0.78) + inset * 0.5,
            0,
            -outerRadius + inset,
          )
          ..quadraticBezierTo(
            (-outerRadius * 0.2) + inset * 0.2,
            (-outerRadius * 0.78) + inset * 0.5,
            0,
            -innerRadius * 0.84 - inset * 0.25,
          );
        canvas.drawPath(detailPetal, finePaint);
      }

      final beadCenter = Offset(0, -midRadius);
      canvas.drawCircle(beadCenter, outerRadius * 0.03, mainPaint);
      canvas.drawCircle(beadCenter, outerRadius * 0.05, finePaint);
      canvas.restore();
    }

    for (var i = 0; i < 32; i++) {
      final angle = (math.pi * 2 / 32) * i;
      final point = Offset(
        center.dx + math.cos(angle) * midRadius,
        center.dy + math.sin(angle) * midRadius,
      );
      canvas.drawCircle(point, outerRadius * 0.016, finePaint);
      canvas.drawCircle(point, outerRadius * 0.028, finePaint);
    }

    canvas.drawCircle(center, innerRadius, mainPaint);
    canvas.drawCircle(center, innerRadius * 1.12, finePaint);
    canvas.drawCircle(center, midRadius * 0.94, finePaint);
  }

  @override
  bool shouldRepaint(covariant _MandalaPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.fineColor != fineColor;
  }
}
