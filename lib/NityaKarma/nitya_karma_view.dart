import 'package:dharma_app/NityaKarma/nitya_karma_controller.dart';
import 'package:dharma_app/NityaKarma/nitya_karma_model.dart';
import 'package:dharma_app/Profile/profile_controller.dart';
import 'package:dharma_app/core/constants/api_constants.dart';
import 'package:dharma_app/core/constants/app_colors.dart';
import 'package:dharma_app/core/widgets/shree_svg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NityaKarmaView extends StatelessWidget {
  const NityaKarmaView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NityaKarmaController>()
        ? Get.find<NityaKarmaController>()
        : Get.put(NityaKarmaController(), permanent: true);
    final profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);

    final width = MediaQuery.of(context).size.width;
    final scale = (width / 390).clamp(0.92, 1.12);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EFE7),
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                24 * scale,
                topInset > 0 ? 10 * scale : 24 * scale,
                24 * scale,
                0,
              ),
              child: _PinnedHeader(
                scale: scale,
                controller: controller,
                profileController: profileController,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.homePrimary,
                onRefresh: () => controller.loadChecklist(
                  date: controller.selectedDate.value,
                  silent: true,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      24 * scale,
                      0,
                      24 * scale,
                      28 * scale,
                    ),
                    child: _ScrollableBody(scale: scale, controller: controller),
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

class _PinnedHeader extends StatelessWidget {
  const _PinnedHeader({
    required this.scale,
    required this.controller,
    required this.profileController,
  });

  final double scale;
  final NityaKarmaController controller;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      final displayDate = _formatLongDate(controller.selectedDate.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TopBar(scale: scale, profileController: profileController),
          SizedBox(height: 10 * scale),
          Text(
            'Nitya Karma',
            style: theme.textTheme.displaySmall?.copyWith(
              color: const Color(0xFF861015),
              fontSize: 33 * scale,
              fontWeight: FontWeight.w700,
              height: 0.95,
            ),
          ),
          SizedBox(height: 18 * scale),
          Text(
            displayDate,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF861015),
              fontSize: 14.5 * scale,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 28 * scale),
          _DaySelector(
            labels: controller.dayStrip,
            selectedIndex: controller.activeDayIndex,
            onSelected: controller.selectDayIndex,
            scale: scale,
          ),
          SizedBox(height: 28 * scale),
        ],
      );
    });
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}

class _ScrollableBody extends StatelessWidget {
  const _ScrollableBody({required this.scale, required this.controller});

  final double scale;
  final NityaKarmaController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final theme = Theme.of(context);
      final data = controller.checklist.value;
      final screen = data?.screen;
      final habits = data?.habits ?? const <NityaKarmaItem>[];
      final schedules = data?.schedules ?? const <NityaKarmaItem>[];
      final routineCard = screen?.routineCard;
      final deitySections =
          screen?.deitySections ?? const <NityaKarmaSection>[];
      final celebration = data?.celebration;
      final displayDate = _formatLongDate(controller.selectedDate.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SizedBox(height: 34 * scale),
          if (controller.isLoading.value && data == null)
            const Center(
              child: CircularProgressIndicator(color: AppColors.homePrimary),
            )
          else if (!controller.hasData)
            _EmptyState(scale: scale, selectedDate: displayDate)
          else ...[
            Center(
              child: Text(
                'Sacred Routine',
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: const Color(0xFF861015),
                  fontSize: 27 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            SizedBox(height: 18 * scale),
            if (routineCard != null) ...[
              _RoutineCard(
                items: habits.isNotEmpty ? habits : routineCard.items,
                controller: controller,
                scale: scale,
                fillColor: const Color(0xFFF2F5FB),
                showIcons: true,
              ),
              for (final section in deitySections) ...[
                SizedBox(height: 28 * scale),
                _DeityFocusSection(
                  section: section,
                  controller: controller,
                  scale: scale,
                ),
              ],
            ] else ...[
              if (habits.isNotEmpty)
                _RoutineCard(
                  items: habits,
                  controller: controller,
                  scale: scale,
                  fillColor: const Color(0xFFF2F5FB),
                  showIcons: true,
                ),
              if (habits.isNotEmpty && schedules.isNotEmpty)
                SizedBox(height: 24 * scale),
              if (schedules.isNotEmpty) ...[
                Center(
                  child: Text(
                    'Today\'s Checklist',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: const Color(0xFF861015),
                      fontSize: 24 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
                _RoutineCard(
                  items: schedules,
                  controller: controller,
                  scale: scale,
                  fillColor: const Color(0xFFF2F5FB),
                  showIcons: true,
                ),
              ] else if (habits.isEmpty)
                _RoutineCard(
                  items: schedules,
                  controller: controller,
                  scale: scale,
                  fillColor: const Color(0xFFF2F5FB),
                  showIcons: true,
                ),
            ],
          ],
          SizedBox(height: 28 * scale),
        ],
      );
    });
  }

  String _formatLongDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }

  String _buildSectionHeading(NityaKarmaSection section) {
    final title = section.title?.trim() ?? '';
    final subtitle = section.subtitle?.trim() ?? '';
    if (title.isEmpty) return subtitle;
    if (subtitle.isEmpty) return title;
    return '$title\n$subtitle';
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
              size: 20 * scale,
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
              color: Colors.white.withValues(alpha: 0.9),
            ),
            child: SizedBox(
              height: 42 * scale,
              width: 42 * scale,
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

class _DaySelector extends StatelessWidget {
  const _DaySelector({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    required this.scale,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final safeLabels = labels.isEmpty
        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : labels;
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemExtent = (constraints.maxWidth / safeLabels.length).clamp(
          36.0,
          54.0 * scale,
        );
        final fontSize = (itemExtent * 0.56).clamp(20.0, 30.0 * scale);
        final radius = (itemExtent * 0.3).clamp(12.0, 16.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(safeLabels.length, (index) {
            final isSelected = index == selectedIndex;
            return GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                height: itemExtent,
                width: itemExtent,
                decoration: isSelected
                    ? BoxDecoration(
                        color: const Color(0xFF920B0F),
                        borderRadius: BorderRadius.circular(radius),
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  safeLabels[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF920B0F),
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.summary, required this.scale});

  final NityaKarmaSummary? summary;
  final double scale;

  @override
  Widget build(BuildContext context) {
    if (summary == null) return const SizedBox.shrink();

    return Wrap(
      spacing: 10 * scale,
      runSpacing: 10 * scale,
      alignment: WrapAlignment.center,
      children: [
        _MetricChip(
          label: '${summary!.completedHabits ?? 0} done',
          background: const Color(0xFFE7F6E8),
          color: const Color(0xFF2D8A42),
          scale: scale,
        ),
        _MetricChip(
          label: '${summary!.pendingHabits ?? 0} pending',
          background: const Color(0xFFFFEFE8),
          color: const Color(0xFFB55034),
          scale: scale,
        ),
        _MetricChip(
          label: '${summary!.completionPercentage ?? 0}% complete',
          background: const Color(0xFFF6E7CF),
          color: const Color(0xFF8D5E11),
          scale: scale,
        ),
      ],
    );
  }
}

class _CelebrationCard extends StatelessWidget {
  const _CelebrationCard({
    required this.title,
    required this.message,
    required this.scale,
  });

  final String title;
  final String message;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2E0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8C979)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: const Color(0xFF861015),
              fontSize: 20 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8 * scale),
          Text(
            message,
            style: TextStyle(
              color: const Color(0xFF7B4732),
              fontSize: 15 * scale,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressInsights extends StatelessWidget {
  const _ProgressInsights({
    required this.streak,
    required this.weeklySummary,
    required this.scale,
  });

  final NityaKarmaStreak? streak;
  final NityaKarmaWeeklySummary? weeklySummary;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];
    if (streak?.currentStreak != null) {
      chips.add(
        _MetricChip(
          label: '${streak!.currentStreak} day streak',
          background: const Color(0xFFFFEFE0),
          color: const Color(0xFFB45620),
          scale: scale,
        ),
      );
    }
    if (streak?.longestStreak != null) {
      chips.add(
        _MetricChip(
          label: 'Best ${streak!.longestStreak} days',
          background: const Color(0xFFF2E9FF),
          color: const Color(0xFF7443B6),
          scale: scale,
        ),
      );
    }
    if (weeklySummary?.completedDays != null) {
      chips.add(
        _MetricChip(
          label: 'Week ${weeklySummary!.completedDays}/7 days',
          background: const Color(0xFFE8F1FF),
          color: const Color(0xFF2F68B1),
          scale: scale,
        ),
      );
    }
    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10 * scale,
      runSpacing: 10 * scale,
      alignment: WrapAlignment.center,
      children: chips,
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.background,
    required this.color,
    required this.scale,
  });

  final String label;
  final Color background;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 14 * scale,
        vertical: 9 * scale,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13.5 * scale,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.items,
    required this.controller,
    required this.scale,
    required this.fillColor,
    required this.showIcons,
    this.showToggle = true,
  });

  final List<NityaKarmaItem> items;
  final NityaKarmaController controller;
  final double scale;
  final Color fillColor;
  final bool showIcons;
  final bool showToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 18 * scale,
        vertical: 18 * scale,
      ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8 * scale),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showIcons)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 8 * scale,
                          right: 14 * scale,
                        ),
                        child: SizedBox(
                          width: 50 * scale,
                          child: Center(
                            child: _LeadingIcon(item: item, size: 46 * scale),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title ?? 'Untitled',
                            style: TextStyle(
                              color: const Color(0xFF861015),
                              fontSize: 15.8 * scale,
                              fontWeight: FontWeight.w700,
                              height: 1.22,
                            ),
                          ),
                          if ((item.description ?? '').isNotEmpty) ...[
                            SizedBox(height: 5 * scale),
                            Text(
                              item.description!,
                              style: TextStyle(
                                color: const Color(0xFF861015),
                                fontSize: 13 * scale,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                              ),
                            ),
                          ],
                          SizedBox(height: 8 * scale),
                          _ItemMeta(item: item, scale: scale),
                        ],
                      ),
                    ),
                    if (showToggle) ...[
                      SizedBox(width: 12 * scale),
                      Obx(
                        () {
                          final _ = controller.togglingItemKeys.length;
                          final isUpdating = controller.isItemUpdating(item);
                          final isLocked = item.completed;
                          return GestureDetector(
                            onTap: isUpdating || isLocked || !item.canToggle
                                ? null
                                : () => controller.toggleItem(item),
                            child: _CompletionCircle(
                              isDone: item.completed,
                              isBusy: isUpdating,
                              enabled:
                                  !isLocked &&
                                  item.canToggle &&
                                  item.toggleRequestId != null,
                              scale: scale,
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                if (index != items.length - 1)
                  Padding(
                    padding: EdgeInsets.only(top: 14 * scale),
                    child: Divider(
                      thickness: 1,
                      height: 1,
                      color: const Color(0xFFB0463E).withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _DeityFocusSection extends StatelessWidget {
  const _DeityFocusSection({
    required this.section,
    required this.controller,
    required this.scale,
  });

  final NityaKarmaSection section;
  final NityaKarmaController controller;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final headingStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
      color: const Color(0xFF861015),
      fontSize: 22 * scale,
      fontWeight: FontWeight.w700,
      height: 1.18,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _buildSectionHeading(section),
          textAlign: TextAlign.center,
          style: headingStyle,
        ),
        SizedBox(height: 18 * scale),
        _DeityMedallion(section: section, size: 118 * scale),
        SizedBox(height: 18 * scale),
        ...List.generate(section.items.length, (index) {
          final item = section.items[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 14 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title ?? 'Untitled',
                              style: TextStyle(
                                color: const Color(0xFF861015),
                                fontSize: 15 * scale,
                                fontWeight: FontWeight.w700,
                                height: 1.24,
                              ),
                            ),
                            if ((item.description ?? '').isNotEmpty) ...[
                              SizedBox(height: 6 * scale),
                              Text(
                                item.description!,
                                style: TextStyle(
                                  color: const Color(0xFF861015),
                                  fontSize: 12.8 * scale,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 18 * scale),
                      Obx(
                        () {
                          final _ = controller.togglingItemKeys.length;
                          final isUpdating = controller.isItemUpdating(item);
                          final isLocked = item.completed;
                          return GestureDetector(
                            onTap: isUpdating || isLocked || !item.canToggle
                                ? null
                                : () => controller.toggleItem(item),
                            child: _CompletionCircle(
                              isDone: item.completed,
                              isBusy: isUpdating,
                              enabled:
                                  !isLocked &&
                                  item.canToggle &&
                                  item.toggleRequestId != null,
                              scale: scale,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (index != section.items.length - 1)
                  Padding(
                    padding: EdgeInsets.only(top: 12 * scale),
                    child: Divider(
                      thickness: 1.2,
                      height: 1,
                      color: const Color(0xFFB0463E).withValues(alpha: 0.75),
                    ),
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _buildSectionHeading(NityaKarmaSection section) {
    final title = section.title?.trim() ?? '';
    final subtitle = section.subtitle?.trim() ?? '';
    if (title.isEmpty) return subtitle;
    if (subtitle.isEmpty) return title;
    return '$title\n$subtitle';
  }
}

class _DeityMedallion extends StatelessWidget {
  const _DeityMedallion({required this.section, required this.size});

  final NityaKarmaSection section;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(
      section.deityImageUrl ?? section.items.firstOrNull?.deityImageUrl,
    );

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null
          ? Container(
              padding: EdgeInsets.all(0),
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (_, __, ___) => _defaultIcon(),
              ),
            )
          : _defaultIcon(),
    );
  }

  Widget _defaultIcon() {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFFFFCF7),
      ),
      child: const Center(child: ShreeSvg(width: 86, height: 86)),
    );
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiConstants.baseUrl}$path';
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.item, required this.size});

  final NityaKarmaItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final imageUrl = _resolveImageUrl(
      item.habitImageUrl ??
          item.habitImage ??
          item.deityImageUrl ??
          item.deityImage,
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(size * 0.34),
        border: Border.all(
          color: const Color(0xFFEBC9AB).withValues(alpha: 0.9),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null ? _buildNetworkImage(imageUrl) : _fallbackIcon(),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    final isSvg =
        item.habitImageType?.toLowerCase() == 'svg' ||
        imageUrl.toLowerCase().endsWith('.svg');
    if (isSvg) {
      return SvgPicture.network(
        imageUrl,
        fit: BoxFit.cover,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    final key = '${item.title} ${item.description}'.toLowerCase();
    IconData icon = Icons.self_improvement_outlined;

    if (key.contains('water') || key.contains('jal')) {
      icon = Icons.water_drop_outlined;
    } else if (key.contains('jap') || key.contains('chant')) {
      icon = Icons.brightness_5_outlined;
    } else if (key.contains('lamp') || key.contains('aarti')) {
      icon = Icons.local_fire_department_outlined;
    } else if (key.contains('sun') || key.contains('surya')) {
      icon = Icons.wb_sunny_outlined;
    } else if (key.contains('kind') ||
        key.contains('feed') ||
        key.contains('seva')) {
      icon = Icons.volunteer_activism_outlined;
    } else if (key.contains('prayer') || key.contains('meditat')) {
      icon = Icons.spa_outlined;
    } else if (key.contains('attire') || key.contains('wear')) {
      icon = Icons.checkroom_outlined;
    }

    return Icon(icon, color: const Color(0xFF6A3427), size: size * 0.72);
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiConstants.baseUrl}$path';
  }
}

class _ItemMeta extends StatelessWidget {
  const _ItemMeta({required this.item, required this.scale});

  final NityaKarmaItem item;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _CompletionCircle extends StatelessWidget {
  const _CompletionCircle({
    required this.isDone,
    required this.isBusy,
    required this.enabled,
    required this.scale,
  });

  final bool isDone;
  final bool isBusy;
  final bool enabled;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      height: 54 * scale,
      width: 54 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDone
            ? const Color(0xFF67C16B)
            : enabled
            ? const Color(0xFFF4FBF4)
            : const Color(0xFFF4FBF4),
        border: Border.all(
          color: enabled ? const Color(0xFF67C16B) : const Color(0xFF67C16B),
          width: 2.4,
        ),
      ),
      child: isBusy
          ? Padding(
              padding: EdgeInsets.all(14 * scale),
              child: const CircularProgressIndicator(
                strokeWidth: 2.3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF67C16B)),
              ),
            )
          : isDone
          ? Icon(Icons.check_rounded, color: Colors.white, size: 34 * scale)
          : Center(
              child: Container(
                height: 16 * scale,
                width: 16 * scale,
                decoration: const BoxDecoration(
                  color: Color(0x8067C16B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.scale, required this.selectedDate});

  final double scale;
  final String selectedDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(28 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5FB),
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.event_note_rounded,
            size: 56 * scale,
            color: const Color(0xFF861015),
          ),
          SizedBox(height: 14 * scale),
          Text(
            'No Nitya Karma scheduled',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF861015),
              fontSize: 24 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 10 * scale),
          Text(
            'No checklist items were found for $selectedDate from the user API.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF9A4A44),
              fontSize: 16 * scale,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
