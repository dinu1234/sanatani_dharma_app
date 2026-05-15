import 'package:dharma_app/NityaKarma/nitya_karma_model.dart';
import 'package:dharma_app/NityaKarma/nitya_karma_repository.dart';
import 'package:dharma_app/core/utils/toast_utils.dart';
import 'package:dharma_app/services/storage_service.dart';
import 'package:get/get.dart';

class NityaKarmaController extends GetxController {
  NityaKarmaController({NityaKarmaRepository? repository})
    : _repository =
          repository ??
          (Get.isRegistered<NityaKarmaRepository>()
              ? Get.find<NityaKarmaRepository>()
              : Get.put(NityaKarmaRepository(), permanent: true));

  final NityaKarmaRepository _repository;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final checklist = Rxn<NityaKarmaChecklistData>();
  final selectedDate = DateTime.now().obs;
  final togglingItemKeys = <int>{}.obs;

  List<String> get dayStrip =>
      checklist.value?.screen?.header?.dayStrip ??
      const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  int get activeDayIndex => (selectedDate.value.weekday - 1).clamp(0, 6);
  bool get hasData =>
      checklist.value?.screen?.routineCard?.items.isNotEmpty == true ||
      checklist.value?.screen?.deitySections.isNotEmpty == true ||
      checklist.value?.schedules.isNotEmpty == true ||
      checklist.value?.habits.isNotEmpty == true;

  @override
  void onInit() {
    super.onInit();
    if (StorageService.getToken()?.isNotEmpty == true) {
      loadChecklist();
    }
  }

  Future<void> loadChecklist({
    DateTime? date,
    bool silent = false,
    bool showFailureToast = true,
  }) async {
    if (StorageService.getToken()?.isNotEmpty != true) return;
    final targetDate = date ?? selectedDate.value;
    selectedDate.value = _dateOnly(targetDate);

    if (silent) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final model = await _repository.getTodayChecklist(
        date: _formatDate(selectedDate.value),
      );
      if (!model.success) {
        if (showFailureToast && model.message.isNotEmpty) {
          ToastUtils.show(model.message);
        }
        return;
      }

      checklist.value = model.data;
      final resolvedDate = _parseDate(model.data?.date) ?? selectedDate.value;
      selectedDate.value = _dateOnly(resolvedDate);
    } finally {
      if (silent) {
        isRefreshing.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  Future<void> selectDayIndex(int index) async {
    final normalizedIndex = index.clamp(0, 6);
    final current = selectedDate.value;
    final weekStart = current.subtract(Duration(days: current.weekday - 1));
    final targetDate = weekStart.add(Duration(days: normalizedIndex));
    await loadChecklist(date: targetDate, silent: true);
  }

  Future<void> toggleItem(NityaKarmaItem item) async {
    if (!item.canToggle) {
      return;
    }

    final isScheduleItem = item.isScheduleItem;
    final requestId = item.toggleRequestId;
    if (requestId == null || togglingItemKeys.contains(requestId)) {
      if (requestId == null) {
        ToastUtils.show('nitya_karma_update_unavailable'.tr);
      }
      return;
    }

    togglingItemKeys.add(requestId);
    try {
      final model = await _repository.toggleCompletion(
        scheduleId: isScheduleItem ? requestId : null,
        habitId: isScheduleItem ? null : requestId,
        isCompleted: item.completed ? 0 : 1,
        date: _formatDate(selectedDate.value),
      );

      if (!model.success) {
        if (model.message.isNotEmpty) {
          ToastUtils.show(model.message);
        }
        return;
      }

      final updatedHabit = model.data?.habit;
      if (updatedHabit != null && checklist.value != null) {
        _applyToggleResponse(
          toggledItem: item,
          updatedHabit: updatedHabit,
          updatedHabits: model.data?.habits,
          updatedSchedules: model.data?.schedules,
          updatedSummary: model.data?.summary,
          date: model.data?.date,
        );
        return;
      }

      await loadChecklist(
        date: selectedDate.value,
        silent: true,
        showFailureToast: false,
      );
    } finally {
      togglingItemKeys.remove(requestId);
      togglingItemKeys.refresh();
    }
  }

  bool isItemUpdating(NityaKarmaItem item) {
    final itemKey = item.toggleRequestId;
    return itemKey != null && togglingItemKeys.contains(itemKey);
  }

  String formatDate(DateTime date) => _formatDate(date);

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  void _applyToggleResponse({
    required NityaKarmaItem toggledItem,
    required NityaKarmaItem updatedHabit,
    List<NityaKarmaItem>? updatedHabits,
    List<NityaKarmaItem>? updatedSchedules,
    NityaKarmaSummary? updatedSummary,
    String? date,
  }) {
    final current = checklist.value;
    if (current == null) return;

    List<NityaKarmaItem> replaceItems(List<NityaKarmaItem> items) {
      return items.map((item) {
        if (_isSameItem(item, updatedHabit, toggledItem)) {
          return item.copyWith(
            id: updatedHabit.id,
            scheduleId: updatedHabit.scheduleId,
            scheduleItemId: updatedHabit.scheduleItemId,
            habitId: updatedHabit.habitId ?? item.habitId,
            title: updatedHabit.title ?? item.title,
            description: updatedHabit.description ?? item.description,
            deityName: updatedHabit.deityName ?? item.deityName,
            deityImage: updatedHabit.deityImage ?? item.deityImage,
            deityImageUrl: updatedHabit.deityImageUrl ?? item.deityImageUrl,
            habitImage: updatedHabit.habitImage ?? item.habitImage,
            habitImageUrl: updatedHabit.habitImageUrl ?? item.habitImageUrl,
            habitImageType: updatedHabit.habitImageType ?? item.habitImageType,
            habitImageWidth:
                updatedHabit.habitImageWidth ?? item.habitImageWidth,
            habitImageHeight:
                updatedHabit.habitImageHeight ?? item.habitImageHeight,
            scheduledDate: updatedHabit.scheduledDate ?? item.scheduledDate,
            dayName: updatedHabit.dayName ?? item.dayName,
            sortOrder: updatedHabit.sortOrder ?? item.sortOrder,
            isActive: updatedHabit.isActive ?? item.isActive,
            isCompleted: updatedHabit.isCompleted,
            completedAt: updatedHabit.completedAt ?? item.completedAt,
            logId: updatedHabit.logId ?? item.logId,
            sourceType: updatedHabit.sourceType ?? item.sourceType,
            isScheduled: updatedHabit.isScheduled ?? item.isScheduled,
            toggleAllowed: updatedHabit.toggleAllowed ?? item.toggleAllowed,
          );
        }
        return item;
      }).toList();
    }

    final nextHabits = toggledItem.isScheduleItem
        ? current.habits
        : updatedHabits != null && updatedHabits.isNotEmpty
        ? updatedHabits
        : replaceItems(current.habits);
    final nextSchedules = toggledItem.isScheduleItem
        ? updatedSchedules != null && updatedSchedules.isNotEmpty
              ? updatedSchedules
              : replaceItems(current.schedules)
        : current.schedules;

    checklist.value = current.copyWith(
      date: date ?? current.date,
      habit: updatedHabit,
      habits: nextHabits,
      schedules: nextSchedules,
      deityGroups: current.deityGroups
          .map((group) => group.copyWith(items: replaceItems(group.items)))
          .toList(),
      screen: current.screen?.copyWith(
        routineCard: current.screen?.routineCard?.copyWith(
          items: replaceItems(current.screen?.routineCard?.items ?? const []),
        ),
        deitySections:
            current.screen?.deitySections
                .map(
                  (section) =>
                      section.copyWith(items: replaceItems(section.items)),
                )
                .toList() ??
            const [],
      ),
      summary: updatedSummary ?? current.summary,
    );

    final resolvedDate = _parseDate(date);
    if (resolvedDate != null) {
      selectedDate.value = _dateOnly(resolvedDate);
    }
  }

  bool _isSameItem(
    NityaKarmaItem item,
    NityaKarmaItem updatedHabit,
    NityaKarmaItem toggledItem,
  ) {
    if ((item.scheduleId ?? 0) > 0 &&
        (updatedHabit.scheduleId ?? 0) > 0 &&
        item.scheduleId == updatedHabit.scheduleId) {
      return true;
    }
    if ((item.id ?? 0) > 0 &&
        (updatedHabit.id ?? 0) > 0 &&
        item.id == updatedHabit.id) {
      return true;
    }
    if ((item.habitId ?? 0) > 0 &&
        (updatedHabit.habitId ?? 0) > 0 &&
        item.habitId == updatedHabit.habitId) {
      return true;
    }
    if (!toggledItem.isScheduleItem) {
      if ((item.id ?? 0) > 0 &&
          (toggledItem.id ?? 0) > 0 &&
          item.id == toggledItem.id) {
        return true;
      }
      if ((item.habitId ?? 0) > 0 &&
          (toggledItem.habitId ?? 0) > 0 &&
          item.habitId == toggledItem.habitId) {
        return true;
      }
    }
    return false;
  }
}
