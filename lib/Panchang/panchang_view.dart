import 'package:dharma_app/Panchang/panchang_controller.dart';
import 'package:dharma_app/Panchang/panchang_model.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/widgets/common_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PanchangView extends StatefulWidget {
  const PanchangView({super.key});

  @override
  State<PanchangView> createState() => _PanchangViewState();
}

class _PanchangViewState extends State<PanchangView> {
  late final PanchangController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<PanchangController>()
        ? Get.find<PanchangController>()
        : Get.put(PanchangController(), permanent: true);
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
            Obx(() {
              final data = _controller.panchang.value;
              final loading =
                  _controller.isLoading.value ||
                  _controller.isRequestingLocation.value;

              return RefreshIndicator(
                color: AppColors.homePrimary,
                onRefresh: () => _controller.refreshPanchang(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: centerNavSize * 0.15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeaderCard(
                        scale: scale,
                        topPadding: mediaQuery.padding.top,
                        controller: _controller,
                        data: data,
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          10 * scale,
                          14 * scale,
                          10 * scale,
                          0,
                        ),
                        child: loading
                            ? SizedBox(
                                height: mediaQuery.size.height * 0.5,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.homePrimary,
                                  ),
                                ),
                              )
                            : data == null
                                ? _PermissionOrErrorCard(
                                    scale: scale,
                                    controller: _controller,
                                  )
                                : _PanchangContent(
                                    scale: scale,
                                    data: data,
                                  ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
        bottomNavigationBar: CommonBottomNav(
          currentItem: AppNavItem.panchang,
          scale: scale,
          safeBottom: safeBottom,
          centerNavSize: centerNavSize,
          height: navHeight,
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.scale,
    required this.topPadding,
    required this.controller,
    required this.data,
  });

  final double scale;
  final double topPadding;
  final PanchangController controller;
  final PanchangData? data;

  @override
  Widget build(BuildContext context) {
    final subtitle = data?.displayDate ?? 'location_permission_required'.tr;

    return Container(
      padding: EdgeInsets.fromLTRB(
        18 * scale,
        topPadding + 14 * scale,
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
            "todays_panchang".tr,
            style: TextStyle(
              fontSize: 17 * scale,
              color: AppColors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            controller.locationLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15 * scale,
              color: AppColors.white.withOpacity(0.96),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionOrErrorCard extends StatelessWidget {
  const _PermissionOrErrorCard({
    required this.scale,
    required this.controller,
  });

  final double scale;
  final PanchangController controller;

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
                ? 'location_on_required'.tr
                : 'location_permission_needed'.tr,
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
                : 'panchang_location_message'.tr,
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
              onPressed: () => controller.refreshPanchang(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.homePrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14 * scale),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
              ),
              child: Text(
                locationDisabled ? 'turn_on_location'.tr : 'allow_location'.tr,
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
                child: Text('open_app_settings'.tr),
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
                child: Text('open_location_settings'.tr),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PanchangContent extends StatelessWidget {
  const _PanchangContent({
    required this.scale,
    required this.data,
  });

  final double scale;
  final PanchangData data;

  @override
  Widget build(BuildContext context) {
    final elements = <Map<String, String>>[
      {
        'title': 'tithi'.tr,
        'value': _formatElement(data.elements?.tithi, fallback: data.tithi?.name),
      },
      {
        'title': 'nakshatra'.tr,
        'value': _formatElement(
          data.elements?.nakshatra,
          fallback: data.nakshatra?.name,
        ),
      },
      {
        'title': 'yoga'.tr,
        'value': _formatElement(data.elements?.yoga, fallback: data.yoga?.name),
      },
      {
        'title': 'karana'.tr,
        'value': _formatElement(
          data.elements?.karana,
          fallback: data.karana?.name,
        ),
      },
      {
        'title': 'vishti'.tr,
        'value': _formatVishti(data.elements?.vishti),
      },
      {
        'title': 'weekday'.tr,
        'value': _formatWeekday(data.elements?.weekday, data.vara),
      },
    ];

    final timings = <_TimingItem>[
      _TimingItem(
        label: _formatRangeLabel(
          'amrit_kaal'.tr,
          data.auspiciousInauspiciousTimings?.amritKaal,
        ),
        color: const Color(0xFF0AA533),
        textColor: Colors.white,
      ),
      _TimingItem(
        label:
            '${_formatRangeLabel('rahu_kaal'.tr, data.auspiciousInauspiciousTimings?.rahuKaal)} (${ 'inauspicious'.tr })',
        color: const Color(0xFF2A2327),
        textColor: Colors.white,
      ),
      _TimingItem(
        label: _formatRangeLabel(
          'gulika_kaal'.tr,
          data.auspiciousInauspiciousTimings?.gulikaKaal,
        ),
        color: const Color(0xFF2A2327),
        textColor: Colors.white,
      ),
      _TimingItem(
        label: _formatRangeLabel(
          'yamaganda'.tr,
          data.auspiciousInauspiciousTimings?.yamaganda,
        ),
        color: const Color(0xFF2A2327),
        textColor: Colors.white,
      ),
      _TimingItem(
        label: _formatAbhijit(
          data.auspiciousInauspiciousTimings?.abhijitMuhurta,
        ),
        color: const Color(0xFFFFEE58),
        textColor: AppColors.homePrimary,
      ),
    ];

    return Column(
      children: [
        Text(
          'panchang_elements'.tr,
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
          'auspicious_inauspicious_timings'.tr,
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
              label: item.label,
              color: item.color,
              textColor: item.textColor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatElement(ElementInfo? info, {String? fallback}) {
    final label = info?.label?.trim();
    final until = _formatDateTime(info?.until);
    if (label != null && label.isNotEmpty && until != null) {
      return '$label ${'until'.tr} $until';
    }
    if (label != null && label.isNotEmpty) return label;
    if (fallback != null && fallback.trim().isNotEmpty) return fallback.trim();
    return 'not_available'.tr;
  }

  String _formatVishti(TimeRangeLabel? info) {
    final label = info?.label?.trim();
    final start = _formatDateTime(info?.start);
    final end = _formatDateTime(info?.end);
    if (label != null && label.isNotEmpty && start != null && end != null) {
      return '$label: $start to $end';
    }
    if (label != null && label.isNotEmpty) return label;
    return 'not_available'.tr;
  }

  String _formatWeekday(WeekdayInfo? weekday, VaraData? vara) {
    final sanskrit = weekday?.sanskrit?.trim() ?? vara?.nameSa?.trim();
    final english = weekday?.english?.trim() ?? vara?.name?.trim();
    final lord = weekday?.lord?.trim() ?? vara?.lord?.trim();

    final parts = <String>[
      if (sanskrit != null && sanskrit.isNotEmpty) sanskrit,
      if (english != null && english.isNotEmpty) english,
      if (lord != null && lord.isNotEmpty) '${'lord'.tr}: $lord',
    ];
    return parts.isEmpty ? 'not_available'.tr : parts.join(' - ');
  }

  String _formatRangeLabel(String title, TimeRange? range) {
    final start = _formatTimeOnly(range?.start);
    final end = _formatTimeOnly(range?.end);
    if (start != null && end != null) {
      return '$title: $start ${'to'.tr} $end';
    }
    return '$title: ${'not_available'.tr}';
  }

  String _formatAbhijit(AbhijitMuhurta? muhurta) {
    if (muhurta == null) return '${'abhijit_muhurta'.tr}: ${'not_available'.tr}';
    if (!muhurta.available) {
      return '${'abhijit_muhurta'.tr}: ${'not_available'.tr}';
    }
    return _formatRangeLabel('abhijit_muhurta'.tr, muhurta);
  }

  String? _formatDateTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final month = _monthShort(parsed.month);
    final day = parsed.day.toString().padLeft(2, '0');
    return '${_formatHourMinute(parsed)}, $day $month';
  }

  String? _formatTimeOnly(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.contains('T')) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return _formatHourMinute(parsed);
    }

    final parts = value.split(':');
    if (parts.length < 2) return value;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return value;
    return _formatHourMinute(DateTime(2000, 1, 1, hour, minute));
  }

  String _formatHourMinute(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $suffix';
  }

  String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
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

class _TimingItem {
  const _TimingItem({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;
}
