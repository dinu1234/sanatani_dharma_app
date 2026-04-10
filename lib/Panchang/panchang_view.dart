import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PanchangView extends StatelessWidget {
  const PanchangView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = mediaQuery.padding.bottom;
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    const elements = <Map<String, String>>[
      {'title': 'Tithi', 'value': 'Krishna Shashthi until 02:49 PM'},
      {'title': 'Nakshatra', 'value': 'Jyeshtha until 06:17 AM, April 14'},
      {'title': 'Yoga', 'value': 'Variyan until 07:44 AM, April 14'},
      {'title': 'Karana', 'value': 'Vanija Until 02:49 PM'},
      {'title': 'Vishti', 'value': 'Until 03:07 AM, April 14'},
      {'title': 'Weekday', 'value': 'Budhavara - Wednesday'},
    ];

    const timings = <Map<String, dynamic>>[
      {
        'label': 'Amrit Kaal: 09:37 PM to 11:19 PM',
        'color': Color(0xFF0AA533),
        'textColor': Colors.white,
      },
      {
        'label': 'Rahu Kaal: 12:21 PM to 01:54 PM (Inauspicious)',
        'color': Color(0xFF2A2327),
        'textColor': Colors.white,
      },
      {
        'label': 'Gulika Kaal: 10:48 AM to 12:21 PM',
        'color': Color(0xFF2A2327),
        'textColor': Colors.white,
      },
      {
        'label': 'Yamaganda: 07:42 AM to 09:15 AM',
        'color': Color(0xFF2A2327),
        'textColor': Colors.white,
      },
      {
        'label': 'Abhijit Muhurat: None (Not available on Wednesdays)',
        'color': Color(0xFFFFEE58),
        'textColor': AppColors.homePrimary,
      },
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppColors.homePrimary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5FC),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFEAF1FB),
                      const Color(0xFFDDE7F8),
                      const Color(0xFFF8FAFF),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: navHeight + centerNavSize * 0.15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      18 * scale,
                      mediaQuery.padding.top + 14 * scale,
                      18 * scale,
                      18 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.homePrimary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30 * scale),
                        bottomRight: Radius.circular(30 * scale),
                      ),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 10 * scale),
                        Text(
                          "Today's Panchang",
                          style: TextStyle(
                            fontSize: 17 * scale,
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Text(
                          'Bengaluru - Wednesday, April 14, 2026',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15 * scale,
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      10 * scale,
                      14 * scale,
                      10 * scale,
                      0,
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Panchang Elements',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            color: AppColors.homePrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10 * scale,
                            vertical: 12 * scale,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(22 * scale),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x18000000),
                                blurRadius: 18,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            children: elements
                                .map(
                                  (item) => Padding(
                                    padding: EdgeInsets.only(bottom: 10 * scale),
                                    child: _PanchangElementTile(
                                      scale: scale,
                                      title: item['title']!,
                                      value: item['value']!,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                        SizedBox(height: 14 * scale),
                        Text(
                          'Auspicious & Inauspicious Timings',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.5 * scale,
                            color: AppColors.homePrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 12 * scale),
                        ...timings.map(
                          (item) => Padding(
                            padding: EdgeInsets.only(bottom: 10 * scale),
                            child: _TimingPill(
                              scale: scale,
                              label: item['label']! as String,
                              color: item['color']! as Color,
                              textColor: item['textColor']! as Color,
                            ),
                          ),
                        ),
                      ],
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
                currentItem: AppNavItem.panchang,
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

class _PanchangElementTile extends StatelessWidget {
  const _PanchangElementTile({
    required this.scale,
    required this.title,
    required this.value,
  });

  final double scale;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 92 * scale,
          child: Padding(
            padding: EdgeInsets.only(left: 8 * scale),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14 * scale,
                color: AppColors.homePrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale,
              vertical: 18 * scale,
            ),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 11.8 * scale,
                height: 1.2,
                color: AppColors.homePrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TimingPill extends StatelessWidget {
  const _TimingPill({
    required this.scale,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final double scale;
  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10 * scale,
        vertical: 10 * scale,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.8 * scale,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
