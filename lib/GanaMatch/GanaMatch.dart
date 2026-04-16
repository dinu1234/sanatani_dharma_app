import 'package:dharma_app/GanaMatch/gana_match_controller.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/GanaMatch/gana_match_result_view.dart';
import 'package:dharma_app/core/widgets/app_svg_asset.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GanaMatchingView extends StatefulWidget {
  const GanaMatchingView({super.key});

  @override
  State<GanaMatchingView> createState() => _GanaMatchingViewState();
}

class _GanaMatchingViewState extends State<GanaMatchingView> {
  late final GanaMatchController _controller;
  Worker? _resultWorker;
  final TextEditingController _groomNameController = TextEditingController();
  final TextEditingController _groomDobController = TextEditingController();
  final TextEditingController _groomTimeController = TextEditingController();
  final TextEditingController _groomPlaceController = TextEditingController();
  final TextEditingController _brideNameController = TextEditingController();
  final TextEditingController _brideDobController = TextEditingController();
  final TextEditingController _brideTimeController = TextEditingController();
  final TextEditingController _bridePlaceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<GanaMatchController>()
        ? Get.find<GanaMatchController>()
        : Get.put(GanaMatchController(), permanent: false);
    _resultWorker = ever(_controller.result, (result) {
      if (!mounted || result == null) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GanaMatchResultView(result: result),
        ),
      );
      _controller.result.value = null;
    });
  }

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
    _resultWorker?.dispose();
    if (Get.isRegistered<GanaMatchController>()) {
      Get.delete<GanaMatchController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final safeBottom = CommonBottomNav.bottomInset(mediaQuery);
    final scale = (width / 390).clamp(0.84, 1.08);
    final navHeight = CommonBottomNav.navHeight(safeBottom);
    final centerNavSize = CommonBottomNav.centerSize(scale);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFB8D6EC),
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
                      const Color(0xFFB8D6EC),
                      const Color(0xFFD9E8F7),
                      const Color(0xFFF9FBFF),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomCenter,
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
              child: Obx(
                () => SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    22 * scale,
                    12 * scale,
                    22 * scale,
                    centerNavSize * 0.25,
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
                              assetName: 'assets/images/Ganamale.svg',
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
                              assetName: 'assets/images/Ganafemale.svg',
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
                          onPressed: _controller.isSubmitting.value
                              ? null
                              : _submit,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.homePrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32 * scale),
                            ),
                          ),
                          child: Text(
                            _controller.isSubmitting.value
                                ? 'Checking...'
                                : 'Check Compatibility',
                            style: TextStyle(
                              fontSize: 19 * scale,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      if (_controller.showLocationHelp.value) ...[
                        SizedBox(height: 18 * scale),
                        _LocationRequiredCard(
                          scale: scale,
                          controller: _controller,
                        ),
                      ],
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

  Future<void> _submit() async {
   
    FocusScope.of(context).unfocus();
    final groomName = _groomNameController.text.trim();
    final groomDob = _groomDobController.text.trim();
    final groomTime = _groomTimeController.text.trim();
    final groomPlace = _groomPlaceController.text.trim();
    final brideName = _brideNameController.text.trim();
    final brideDob = _brideDobController.text.trim();
    final brideTime = _brideTimeController.text.trim();
    final bridePlace = _bridePlaceController.text.trim();

    if (groomName.isEmpty ||
        groomDob.isEmpty ||
        groomTime.isEmpty ||
        groomPlace.isEmpty ||
        brideName.isEmpty ||
        brideDob.isEmpty ||
        brideTime.isEmpty ||
        bridePlace.isEmpty) {
      ToastUtils.show(
        'Please fill all groom and bride details.',
        backgroundColor: const Color(0xFFD32F2F),
      );
      return;
    }

    final result = await _controller.submitMatching(
      girlName: brideName,
      girlDate: brideDob,
      girlTime: brideTime,
      boyName: groomName,
      boyDate: groomDob,
      boyTime: groomTime,
    );

    if (!mounted || result == null) return;
  }
}

class _LocationRequiredCard extends StatelessWidget {
  const _LocationRequiredCard({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final GanaMatchController controller;

  @override
  Widget build(BuildContext context) {
    final locationDisabled = !controller.isLocationEnabled.value;
    final error = controller.errorMessage.value.trim();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
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
        children: [
          Text(
            locationDisabled
                ? 'Location On Chahiye'
                : 'Location Permission Chahiye',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18 * scale,
              fontWeight: FontWeight.w700,
              color: AppColors.homePrimary,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            error.isNotEmpty
                ? error
                : 'Gana match ke liye current location permission aur GPS on hona chahiye.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13 * scale,
              color: AppColors.homePrimary.withOpacity(0.82),
              height: 1.35,
            ),
          ),
          SizedBox(height: 18 * scale),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.refreshLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.homePrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
              ),
              child: Text(
                locationDisabled ? 'Turn On Location' : 'Allow Location',
              ),
            ),
          ),
          if (controller.isPermissionDeniedForever.value) ...[
            SizedBox(height: 10 * scale),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.openAppSettings,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.homePrimary,
                  side: const BorderSide(color: AppColors.homePrimary),
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                ),
                child: const Text('Open App Settings'),
              ),
            ),
          ],
          if (locationDisabled) ...[
            SizedBox(height: 10 * scale),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: controller.openLocationSettings,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.homePrimary,
                  side: const BorderSide(color: AppColors.homePrimary),
                  padding: EdgeInsets.symmetric(vertical: 14 * scale),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                ),
                child: const Text('Open Location Settings'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileColumn extends StatelessWidget {
  const _ProfileColumn({
    required this.scale,
    required this.title,
    required this.assetName,
    required this.nameController,
    required this.dobController,
    required this.timeController,
    required this.placeController,
    required this.onDobTap,
    required this.onTimeTap,
    this.compact = false,
  });

  final double scale;
  final String title;
  final String assetName;
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController timeController;
  final TextEditingController placeController;
  final VoidCallback onDobTap;
  final VoidCallback onTimeTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final avatarSize = compact ? 112.0 * scale : 140.0 * scale;

    return Column(
      children: [
        _AvatarBadge(scale: scale, assetName: assetName, size: avatarSize),
        SizedBox(height: (compact ? 10 : 12) * scale),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: (compact ? 13.2 : 14.5) * scale,
            height: 1.15,
            color: AppColors.homePrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: (compact ? 14 : 18) * scale),
        _EntryField(
          hint: 'Full Name',
          scale: scale,
          controller: nameController,
          compact: compact,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Date of Birth',
          scale: scale,
          controller: dobController,
          readOnly: true,
          onTap: onDobTap,
          suffixIcon: Icons.calendar_month_rounded,
          compact: compact,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Time of Birth',
          scale: scale,
          controller: timeController,
          readOnly: true,
          onTap: onTimeTap,
          suffixIcon: Icons.access_time_rounded,
          compact: compact,
        ),
        SizedBox(height: 14 * scale),
        _EntryField(
          hint: 'Place of Birth',
          scale: scale,
          controller: placeController,
          compact: compact,
        ),
      ],
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({
    required this.scale,
    required this.assetName,
    required this.size,
  });

  final double scale;
  final String assetName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _ResultAvatar(
      scale: scale,
      assetName: assetName,
      name: '',
      size: size,
      showName: false,
    );
  }
}

class _ResultAvatar extends StatelessWidget {
  const _ResultAvatar({
    required this.scale,
    required this.assetName,
    required this.name,
    this.size,
    this.showName = true,
  });

  final double scale;
  final String assetName;
  final String name;
  final double? size;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final avatarSize = size ?? (66 * scale);

    return Column(
      children: [
        SizedBox(
          width: avatarSize,
          height: avatarSize,
          child: AppSvgAsset(
            assetName: assetName,
            fit: BoxFit.contain,
          ),
        ),
        if (showName) SizedBox(height: 5 * scale),
        if (showName)
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

class _EntryField extends StatelessWidget {
  const _EntryField({
    required this.hint,
    required this.scale,
    required this.controller,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.compact = false,
  });

  final String hint;
  final double scale;
  final TextEditingController controller;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final bool compact;

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
            fontSize: (compact ? 13 : 14) * scale,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16 * scale,
            vertical: (compact ? 14 : 16) * scale,
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
          fontSize: (compact ? 13 : 14) * scale,
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
        _ResultAvatar(
          scale: scale,
          assetName: 'assets/images/Ganamale.svg',
          name: groomName,
        ),
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
        _ResultAvatar(
          scale: scale,
          assetName: 'assets/images/Ganafemale.svg',
          name: brideName,
        ),
      ],
    );
  }
}
