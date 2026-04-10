import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/GanaMatch/gana_match_result_view.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GanaMatchingView extends StatefulWidget {
  const GanaMatchingView({super.key});

  @override
  State<GanaMatchingView> createState() => _GanaMatchingViewState();
}

class _GanaMatchingViewState extends State<GanaMatchingView> {
  final TextEditingController _groomNameController = TextEditingController();
  final TextEditingController _groomDobController = TextEditingController();
  final TextEditingController _groomTimeController = TextEditingController();
  final TextEditingController _groomPlaceController = TextEditingController();
  final TextEditingController _brideNameController = TextEditingController();
  final TextEditingController _brideDobController = TextEditingController();
  final TextEditingController _brideTimeController = TextEditingController();
  final TextEditingController _bridePlaceController = TextEditingController();

  @override
  void dispose() {
    _groomNameController.dispose();
    _groomDobController.dispose();
    _groomTimeController.dispose();
    _groomPlaceController.dispose();
    _brideNameController.dispose();
    _brideDobController.dispose();
    _brideTimeController.dispose();
    _bridePlaceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = mediaQuery.padding.bottom;
    final scale = (width / 390).clamp(0.84, 1.08);
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
                      const Color(0xFFBCD5F0).withOpacity(0.98),
                      const Color(0xFFD5D9F5).withOpacity(0.88),
                      const Color(0xFFF1F6FB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 112 * scale,
              left: -90 * scale,
              child: _GlowOrb(
                size: 220 * scale,
                colors: const [Color(0xA6ABC7FF), Color(0x00ABC7FF)],
              ),
            ),
            Positioned(
              top: 310 * scale,
              right: -70 * scale,
              child: _GlowOrb(
                size: 240 * scale,
                colors: const [Color(0x6CF7D88E), Color(0x00F7D88E)],
              ),
            ),
            Positioned(
              bottom: 170 * scale,
              left: width * 0.18,
              child: _GlowOrb(
                size: 180 * scale,
                colors: const [Color(0x6CE5D0FF), Color(0x00E5D0FF)],
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22 * scale,
                  12 * scale,
                  22 * scale,
                  navHeight + centerNavSize * 0.25,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 34 * scale),
                    Text(
                      'Gana Matching',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28 * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 22 * scale),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _ProfileColumn(
                            scale: scale,
                            title: "Groom's Details (Boy)",
                            icon: Icons.person,
                            nameController: _groomNameController,
                            dobController: _groomDobController,
                            timeController: _groomTimeController,
                            placeController: _groomPlaceController,
                            onDobTap: () => _pickDate(_groomDobController),
                            onTimeTap: () => _pickTime(_groomTimeController),
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: _ProfileColumn(
                            scale: scale,
                            title: "Bride's Details (Girl)",
                            icon: Icons.face_3,
                            nameController: _brideNameController,
                            dobController: _brideDobController,
                            timeController: _brideTimeController,
                            placeController: _bridePlaceController,
                            onDobTap: () => _pickDate(_brideDobController),
                            onTimeTap: () => _pickTime(_brideTimeController),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30 * scale),
                    Container(
                      width: double.infinity,
                      height: 56 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32 * scale),
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
                            color: Color(0x24000000),
                            blurRadius: 14,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GanaMatchResultView(
                                groomName: _groomNameController.text.trim().isEmpty
                                    ? 'Krishna'
                                    : _groomNameController.text.trim(),
                                brideName: _brideNameController.text.trim().isEmpty
                                    ? 'Radha'
                                    : _brideNameController.text.trim(),
                              ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.homePrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32 * scale),
                          ),
                        ),
                        child: Text(
                          'Check Compatibility',
                          style: TextStyle(
                            fontSize: 19 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 34 * scale),
                    Text(
                      'Traditional Ashtakoot Guna Milan (Ashta Koota) system which evaluates 8 different aspects of compatibility, totaling 36 points (gunas). This includes checking for Manglik Dosha, Nadi Dosha, Bhakoot Dosha and other important factors.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15 * scale,
                        height: 1.28,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
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

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.homePrimary,
              onPrimary: AppColors.white,
              onSurface: AppColors.homePrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return;

    final day = pickedDate.day.toString().padLeft(2, '0');
    final month = pickedDate.month.toString().padLeft(2, '0');
    controller.text = '$day/$month/${pickedDate.year}';
  }

  Future<void> _pickTime(TextEditingController controller) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.homePrimary,
              onPrimary: AppColors.white,
              onSurface: AppColors.homePrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime == null) return;

    controller.text = pickedTime.format(context);
  }
}

class GanaMatchingResultView extends StatelessWidget {
  const GanaMatchingResultView({
    super.key,
    required this.groomName,
    required this.brideName,
  });

  final String groomName;
  final String brideName;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = mediaQuery.padding.bottom;
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    const breakdown = <Map<String, dynamic>>[
      {'title': 'Varna', 'score': 0.78, 'marker': 0.87},
      {'title': 'Vasya', 'score': 0.86, 'marker': 0.92},
      {'title': 'Tara', 'score': 0.26, 'marker': 0.43},
      {'title': 'Yoni', 'score': 0.62, 'marker': 0.66},
      {'title': 'Maitri', 'score': 0.82, 'marker': 0.91},
      {'title': 'Gana', 'score': 0.80, 'marker': 0.90},
      {'title': 'Bhakoot', 'score': 0.83, 'marker': 0.92},
      {'title': 'Nadi', 'score': 0.79, 'marker': 0.90},
    ];

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
                      const Color(0xFFBED6F1).withOpacity(0.98),
                      const Color(0xFFDCE4FA).withOpacity(0.88),
                      const Color(0xFFF3F7FC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  12 * scale,
                  10 * scale,
                  12 * scale,
                  navHeight + centerNavSize * 0.22,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 14 * scale),
                    Text(
                      'Gana Matching',
                      style: TextStyle(
                        fontSize: 22 * scale,
                        color: AppColors.homePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 22 * scale),
                    _ScoreMandala(scale: scale),
                    SizedBox(height: 14 * scale),
                    _CoupleRow(
                      scale: scale,
                      groomName: groomName,
                      brideName: brideName,
                    ),
                    SizedBox(height: 16 * scale),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        10 * scale,
                        12 * scale,
                        10 * scale,
                        14 * scale,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(18 * scale),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 14,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'BREAKDOWN',
                            style: TextStyle(
                              fontSize: 15 * scale,
                              fontWeight: FontWeight.w700,
                              color: AppColors.homePrimary,
                            ),
                          ),
                          SizedBox(height: 10 * scale),
                          ...breakdown.map(
                            (item) => _BreakdownRow(
                              scale: scale,
                              title: item['title']! as String,
                              score: item['score']! as double,
                              marker: item['marker']! as double,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Text(
                      "The boy's nadi is Antya and the girl belongs to Adi nadi.\nThis is very good combination from the\nviewpoint of match making.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11 * scale,
                        height: 1.22,
                        color: AppColors.homePrimary,
                      ),
                    ),
                    SizedBox(height: 12 * scale),
                    Container(
                      width: width * 0.64,
                      height: 32 * scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20 * scale),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.homeGoldDark,
                            AppColors.homeGoldLight,
                            AppColors.homeGoldDark,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
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
                          padding: EdgeInsets.zero,
                          foregroundColor: AppColors.homePrimary,
                        ),
                        child: Text(
                          'Share on Whatsapp',
                          style: TextStyle(
                            fontSize: 13.5 * scale,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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

class _ProfileColumn extends StatelessWidget {
  const _ProfileColumn({
    required this.scale,
    required this.title,
    required this.icon,
    required this.nameController,
    required this.dobController,
    required this.timeController,
    required this.placeController,
    required this.onDobTap,
    required this.onTimeTap,
  });

  final double scale;
  final String title;
  final IconData icon;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController timeController;
  final TextEditingController placeController;
  final VoidCallback onDobTap;
  final VoidCallback onTimeTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AvatarBadge(scale: scale, icon: icon),
        SizedBox(height: 12 * scale),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.5 * scale,
            height: 1.15,
            color: AppColors.homePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 18 * scale),
        _EntryField(
          hint: 'Full Name',
          scale: scale,
          controller: nameController,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Date of Birth',
          scale: scale,
          controller: dobController,
          readOnly: true,
          onTap: onDobTap,
          suffixIcon: Icons.calendar_month_rounded,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Time of Birth',
          scale: scale,
          controller: timeController,
          readOnly: true,
          onTap: onTimeTap,
          suffixIcon: Icons.access_time_rounded,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Place of Birth',
          scale: scale,
          controller: placeController,
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.scale,
    required this.icon,
  });

  final double scale;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132 * scale,
      height: 132 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.homeGoldBorder,
          width: 3 * scale,
        ),
        gradient: const LinearGradient(
          colors: [Color(0xFFF7E48F), Color(0xFFC4903F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: EdgeInsets.all(8 * scale),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF4F4F6),
        ),
        child: Icon(
          icon,
          color: AppColors.homeGoldDark,
          size: 76 * scale,
        ),
      ),
    );
  }
}

class _EntryField extends StatelessWidget {
  const _EntryField({
    required this.hint,
    required this.scale,
    required this.controller,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  final String hint;
  final double scale;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 16,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: const Color(0xFF767676),
            fontSize: 14 * scale,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: 16 * scale,
          ),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(
                  suffixIcon,
                  color: AppColors.homePrimary.withOpacity(0.72),
                  size: 20 * scale,
                ),
        ),
        style: TextStyle(
          color: AppColors.homePrimary,
          fontSize: 14 * scale,
          fontWeight: FontWeight.w500,
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

class _ScoreMandala extends StatelessWidget {
  const _ScoreMandala({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 238 * scale,
      height: 238 * scale,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 224 * scale,
            height: 224 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.homeGoldBorder.withOpacity(0.4),
                width: 2 * scale,
              ),
            ),
          ),
          Container(
            width: 196 * scale,
            height: 196 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.homeGoldLight.withOpacity(0.8),
                width: 1.5 * scale,
              ),
            ),
          ),
          ...List.generate(
            18,
            (index) => Transform.rotate(
              angle: (index * 20) * 3.1415926535 / 180,
              child: Container(
                width: 228 * scale,
                height: 228 * scale,
                alignment: Alignment.topCenter,
                child: Container(
                  width: 50 * scale,
                  height: 88 * scale,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40 * scale),
                      topRight: Radius.circular(40 * scale),
                      bottomLeft: Radius.circular(14 * scale),
                      bottomRight: Radius.circular(14 * scale),
                    ),
                    border: Border.all(
                      color: AppColors.homeGoldBorder.withOpacity(0.32),
                      width: 1.3 * scale,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: 132 * scale,
            height: 132 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF5D361),
                  Color(0xFFFFF6A4),
                  Color(0xFFD39B3B),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border.all(
                color: AppColors.homeGoldLight,
                width: 2 * scale,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OBTAINED POINTS',
                  style: TextStyle(
                    fontSize: 12 * scale,
                    color: AppColors.homePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  '32/36',
                  style: TextStyle(
                    fontSize: 31 * scale,
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

class _CoupleRow extends StatelessWidget {
  const _CoupleRow({
    required this.scale,
    required this.groomName,
    required this.brideName,
  });

  final double scale;
  final String groomName;
  final String brideName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ResultAvatar(scale: scale, icon: Icons.person, name: groomName),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10 * scale),
          child: Text(
            '&',
            style: TextStyle(
              fontSize: 26 * scale,
              color: AppColors.homePrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _ResultAvatar(scale: scale, icon: Icons.face_3, name: brideName),
      ],
    );
  }
}

class _ResultAvatar extends StatelessWidget {
  const _ResultAvatar({
    required this.scale,
    required this.icon,
    required this.name,
  });

  final double scale;
  final IconData icon;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 66 * scale,
          height: 66 * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.homeGoldBorder, width: 1.3),
            gradient: const LinearGradient(
              colors: [Color(0xFFF7E48F), Color(0xFFC4903F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Container(
            margin: EdgeInsets.all(4 * scale),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF4F4F6),
            ),
            child: Icon(
              icon,
              color: AppColors.homeGoldDark,
              size: 34 * scale,
            ),
          ),
        ),
        SizedBox(height: 5 * scale),
        SizedBox(
          width: 80 * scale,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14 * scale,
              color: AppColors.homePrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.scale,
    required this.title,
    required this.score,
    required this.marker,
  });

  final double scale;
  final String title;
  final double score;
  final double marker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Row(
        children: [
          SizedBox(
            width: 68 * scale,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5 * scale,
                color: AppColors.homePrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 16 * scale,
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.78),
                borderRadius: BorderRadius.circular(20 * scale),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final markerLeft = (width * marker).clamp(
                    12.0,
                    width - 12.0,
                  );

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: width * score,
                          decoration: BoxDecoration(
                            color: score < 0.5
                                ? const Color(0xFFE81C4F)
                                : const Color(0xFF08B14A),
                            borderRadius: BorderRadius.circular(20 * scale),
                          ),
                        ),
                      ),
                      Positioned(
                        left: markerLeft - (8 * scale),
                        top: -1 * scale,
                        child: Container(
                          width: 18 * scale,
                          height: 18 * scale,
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
                            child: Container(
                              width: 6 * scale,
                              height: 6 * scale,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
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
