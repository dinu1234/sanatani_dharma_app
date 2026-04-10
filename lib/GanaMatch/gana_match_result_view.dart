import 'dart:math' as math;

import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GanaMatchResultView extends StatelessWidget {
  const GanaMatchResultView({
    super.key,
    required this.groomName,
    required this.brideName,
  });

  final String groomName;
  final String brideName;

  static const _breakdown = <_BreakdownItem>[
    _BreakdownItem('Varna', 0.76, 0.87),
    _BreakdownItem('Vasya', 0.84, 0.94),
    _BreakdownItem('Tara', 0.28, 0.44),
    _BreakdownItem('Yoni', 0.51, 0.67, fillColor: Color(0xFFE7D628)),
    _BreakdownItem('Maitri', 0.85, 0.94),
    _BreakdownItem('Gana', 0.81, 0.91),
    _BreakdownItem('Bhakoot', 0.82, 0.93),
    _BreakdownItem('Nadi', 0.8, 0.91),
  ];

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    final safeBottom = mediaQuery.padding.bottom;
    final scale = (width / 390).clamp(0.84, 1.08);
    final verticalScale = height < 700
        ? 0.74
        : height < 780
            ? 0.86
            : 1.0;
    final compactLayout = height < 780;
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homeBackground,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
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
                14 * scale,
                mediaQuery.padding.top + (8 * scale * verticalScale),
                14 * scale,
                navHeight + centerNavSize * 0.15,
              ),
              child: Column(
                children: [
                    SizedBox(height: 4 * scale * verticalScale),
                    Text(
                      'Gana Matching',
                      style: TextStyle(
                        fontSize: (compactLayout ? 20 : 22) * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10 * scale * verticalScale),
                    _MandalaScore(scale: scale, verticalScale: verticalScale),
                    SizedBox(height: 4 * scale * verticalScale),
                    _CoupleSection(
                      scale: scale,
                      compactLayout: compactLayout,
                      groomName: groomName,
                      brideName: brideName,
                    ),
                    SizedBox(height: 2 * scale * verticalScale),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        12 * scale,
                        10 * scale * verticalScale,
                        12 * scale,
                        12 * scale * verticalScale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(18 * scale),
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
                            'BREAKDOWN',
                            style: TextStyle(
                              fontSize: (compactLayout ? 14 : 15) * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 6 * scale * verticalScale),
                          ..._breakdown.map(
                            (item) => _BreakdownRow(
                              scale: scale,
                              compactLayout: compactLayout,
                              item: item,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6 * scale * verticalScale),
                    Text(
                      "The boy's nadi is Antya and the girl belongs to Adi nadi.\nThis is very good combination from the\nviewpoint of match making.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (compactLayout ? 10.4 : 11.2) * scale,
                        height: 1.25,
                        color: AppColors.homePrimary,
                      ),
                    ),
                    SizedBox(height: 8 * scale * verticalScale),
                    Container(
                      constraints: BoxConstraints(
                        minWidth: math.min(width * 0.72, 220 * scale),
                        maxWidth: math.min(width * 0.86, 300 * scale),
                      ),
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
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('WhatsApp sharing will be added next.'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.homePrimary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22 * scale),
                          ),
                        ),
                        child: Text(
                          'Share on Whatsapp',
                          style: TextStyle(
                            fontSize: (compactLayout ? 12.8 : 13.5) * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CommonBottomNav(
                currentItem: AppNavItem.ganaMatch,
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

class _MandalaScore extends StatelessWidget {
  const _MandalaScore({
    required this.scale,
    required this.verticalScale,
  });

  final double scale;
  final double verticalScale;

  @override
  Widget build(BuildContext context) {
    final outerSize = 256 * scale * (0.9 + (verticalScale * 0.1));
    final outerPaintSize = 226 * scale * (0.9 + (verticalScale * 0.1));
    final centerSize = 136 * scale * (0.92 + (verticalScale * 0.08));

    return SizedBox(
      width: outerSize,
      height: outerSize * 0.97,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: outerPaintSize,
            height: outerPaintSize,
            child: CustomPaint(
              painter: _LotusPainter(
                color: AppColors.homeGoldBorder.withOpacity(0.22),
                strokeWidth: 1.6 * scale,
              ),
            ),
          ),
          Container(
            width: centerSize,
            height: centerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF4CB58),
                  Color(0xFFF8F0A7),
                  Color(0xFFE1AC47),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(
                color: const Color(0xFFF6E2A2),
                width: 3 * scale,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OBTAINED POINTS',
                  style: TextStyle(
                    fontSize: (11.2 + (verticalScale - 0.74) * 2) * scale,
                    color: AppColors.homePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  '32/36',
                  style: TextStyle(
                    fontSize: (28 + (verticalScale * 3)) * scale,
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
    required this.groomName,
    required this.brideName,
  });

  final double scale;
  final bool compactLayout;
  final String groomName;
  final String brideName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _PersonAvatar(
          scale: scale,
          name: groomName,
          icon: Icons.person_rounded,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: (compactLayout ? 10 : 12) * scale,
            right: (compactLayout ? 10 : 12) * scale,
            bottom: (compactLayout ? 14 : 18) * scale,
          ),
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
          name: brideName,
          icon: Icons.face_3_rounded,
        ),
      ],
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.scale,
    required this.name,
    required this.icon,
  });

  final double scale;
  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70 * scale,
          height: 70 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.homeGoldBorder.withOpacity(0.82),
              width: 1.2 * scale,
            ),
            gradient: const LinearGradient(
              colors: [Color(0xFFF4E7AC), Color(0xFFD4A64D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(4 * scale),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF4F4F5),
            ),
            child: Icon(
              icon,
              size: 38 * scale,
              color: const Color(0xE3D1A134),
            ),
          ),
        ),
        SizedBox(height: 5 * scale),
        SizedBox(
          width: 82 * scale,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
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
  });

  final String title;
  final double progress;
  final double marker;
  final Color? fillColor;
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
      padding: EdgeInsets.only(bottom: (compactLayout ? 10 : 13) * scale),
      child: Row(
        children: [
          SizedBox(
            width: (compactLayout ? 72 : 78) * scale,
            child: Text(
              item.title,
              style: TextStyle(
                fontSize: (compactLayout ? 12.6 : 13.5) * scale,
                color: AppColors.homePrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: (compactLayout ? 9 : 12) * scale),
          Expanded(
            child: Container(
              height: (compactLayout ? 10 : 12) * scale,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(99),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final markerLeft = (constraints.maxWidth * item.progress).clamp(
                    12.0,
                    constraints.maxWidth - 12.0,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: constraints.maxWidth * item.progress,
                          decoration: BoxDecoration(
                            color: fillColor,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      Positioned(
                        left: markerLeft -
                            ((compactLayout ? 9.5 : 10.5) * scale),
                        top: (compactLayout ? -4.5 : -5) * scale,
                        child: Container(
                          width: (compactLayout ? 20 : 22) * scale,
                          height: (compactLayout ? 20 : 22) * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF4D7A),
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
                              size: (compactLayout ? 8.5 : 9.5) * scale,
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
        ],
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

class _LotusPainter extends CustomPainter {
  const _LotusPainter({
    required this.color,
    required this.strokeWidth,
  });

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.42;
    final petalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (var i = 0; i < 16; i++) {
      final angle = (math.pi * 2 / 16) * i;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);

      final petal = Path()
        ..moveTo(0, -innerRadius * 0.9)
        ..quadraticBezierTo(
          outerRadius * 0.16,
          -outerRadius * 0.84,
          0,
          -outerRadius,
        )
        ..quadraticBezierTo(
          -outerRadius * 0.16,
          -outerRadius * 0.84,
          0,
          -innerRadius * 0.9,
        );
      canvas.drawPath(petal, petalPaint);
      canvas.restore();
    }

    final ringPaint = Paint()
      ..color = color.withOpacity(0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.8;
    canvas.drawCircle(center, innerRadius, ringPaint);
    canvas.drawCircle(center, outerRadius * 0.76, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _LotusPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
