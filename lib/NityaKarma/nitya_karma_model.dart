class NityaKarmaChecklistResponseModel {
  NityaKarmaChecklistResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  final bool success;
  final String message;
  final NityaKarmaChecklistData? data;

  factory NityaKarmaChecklistResponseModel.fromJson(Map<String, dynamic> json) {
    return NityaKarmaChecklistResponseModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? NityaKarmaChecklistData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class NityaKarmaChecklistData {
  NityaKarmaChecklistData({
    this.date,
    this.dayName,
    this.habits = const [],
    this.schedules = const [],
    this.habit,
    this.deityGroups = const [],
    this.summary,
    this.streak,
    this.screen,
    this.weeklySummary,
    this.upcomingSchedule,
    this.celebration,
  });

  final String? date;
  final String? dayName;
  final List<NityaKarmaItem> habits;
  final List<NityaKarmaItem> schedules;
  final NityaKarmaItem? habit;
  final List<NityaKarmaDeityGroup> deityGroups;
  final NityaKarmaSummary? summary;
  final NityaKarmaStreak? streak;
  final NityaKarmaScreen? screen;
  final NityaKarmaWeeklySummary? weeklySummary;
  final NityaKarmaUpcomingSchedule? upcomingSchedule;
  final NityaKarmaCelebration? celebration;

  factory NityaKarmaChecklistData.fromJson(Map<String, dynamic> json) {
    return NityaKarmaChecklistData(
      date: _parseString(json['date']),
      dayName: _parseString(json['day_name']),
      habits: _parseList(
        json['habits'],
        (item) => NityaKarmaItem.fromJson(item, sourceType: 'habit'),
      ),
      schedules: _parseList(
        json['schedules'],
        (item) => NityaKarmaItem.fromJson(item, sourceType: 'schedule'),
      ),
      habit: json['habit'] is Map<String, dynamic>
          ? NityaKarmaItem.fromJson(
              json['habit'] as Map<String, dynamic>,
              sourceType: 'schedule',
            )
          : null,
      deityGroups: _parseList(
        json['deity_groups'],
        NityaKarmaDeityGroup.fromJson,
      ),
      summary: json['summary'] is Map<String, dynamic>
          ? NityaKarmaSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      streak: json['streak'] is Map<String, dynamic>
          ? NityaKarmaStreak.fromJson(json['streak'] as Map<String, dynamic>)
          : null,
      screen: json['screen'] is Map<String, dynamic>
          ? NityaKarmaScreen.fromJson(json['screen'] as Map<String, dynamic>)
          : null,
      weeklySummary: json['weekly_summary'] is Map<String, dynamic>
          ? NityaKarmaWeeklySummary.fromJson(
              json['weekly_summary'] as Map<String, dynamic>,
            )
          : null,
      upcomingSchedule: json['upcoming_schedule'] is Map<String, dynamic>
          ? NityaKarmaUpcomingSchedule.fromJson(
              json['upcoming_schedule'] as Map<String, dynamic>,
            )
          : null,
      celebration: json['celebration'] is Map<String, dynamic>
          ? NityaKarmaCelebration.fromJson(
              json['celebration'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  NityaKarmaChecklistData copyWith({
    String? date,
    String? dayName,
    List<NityaKarmaItem>? habits,
    List<NityaKarmaItem>? schedules,
    NityaKarmaItem? habit,
    List<NityaKarmaDeityGroup>? deityGroups,
    NityaKarmaSummary? summary,
    NityaKarmaStreak? streak,
    NityaKarmaScreen? screen,
    NityaKarmaWeeklySummary? weeklySummary,
    NityaKarmaUpcomingSchedule? upcomingSchedule,
    NityaKarmaCelebration? celebration,
  }) {
    return NityaKarmaChecklistData(
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
      habits: habits ?? this.habits,
      schedules: schedules ?? this.schedules,
      habit: habit ?? this.habit,
      deityGroups: deityGroups ?? this.deityGroups,
      summary: summary ?? this.summary,
      streak: streak ?? this.streak,
      screen: screen ?? this.screen,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      upcomingSchedule: upcomingSchedule ?? this.upcomingSchedule,
      celebration: celebration ?? this.celebration,
    );
  }
}

class NityaKarmaScreen {
  NityaKarmaScreen({
    this.header,
    this.routineCard,
    this.deitySections = const [],
  });

  final NityaKarmaHeader? header;
  final NityaKarmaSection? routineCard;
  final List<NityaKarmaSection> deitySections;

  factory NityaKarmaScreen.fromJson(Map<String, dynamic> json) {
    return NityaKarmaScreen(
      header: json['header'] is Map<String, dynamic>
          ? NityaKarmaHeader.fromJson(json['header'] as Map<String, dynamic>)
          : null,
      routineCard: json['routine_card'] is Map<String, dynamic>
          ? NityaKarmaSection.fromJson(
              json['routine_card'] as Map<String, dynamic>,
            )
          : null,
      deitySections: _parseList(
        json['deity_sections'],
        NityaKarmaSection.fromJson,
      ),
    );
  }

  NityaKarmaScreen copyWith({
    NityaKarmaHeader? header,
    NityaKarmaSection? routineCard,
    List<NityaKarmaSection>? deitySections,
  }) {
    return NityaKarmaScreen(
      header: header ?? this.header,
      routineCard: routineCard ?? this.routineCard,
      deitySections: deitySections ?? this.deitySections,
    );
  }
}

class NityaKarmaHeader {
  NityaKarmaHeader({
    this.date,
    this.dayName,
    this.dayStrip = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.activeDayIndex,
    this.title,
  });

  final String? date;
  final String? dayName;
  final List<String> dayStrip;
  final int? activeDayIndex;
  final String? title;

  factory NityaKarmaHeader.fromJson(Map<String, dynamic> json) {
    return NityaKarmaHeader(
      date: _parseString(json['date']),
      dayName: _parseString(json['day_name']),
      dayStrip:
          (json['day_strip'] as List?)
              ?.map((item) => item?.toString() ?? '')
              .where((item) => item.isNotEmpty)
              .toList() ??
          const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
      activeDayIndex: _parseInt(json['active_day_index']),
      title: _parseString(json['title']),
    );
  }
}

class NityaKarmaSection {
  NityaKarmaSection({
    this.sectionType,
    this.title,
    this.subtitle,
    this.deityName,
    this.deityImageUrl,
    this.scheduledDate,
    this.summary,
    this.items = const [],
  });

  final String? sectionType;
  final String? title;
  final String? subtitle;
  final String? deityName;
  final String? deityImageUrl;
  final String? scheduledDate;
  final NityaKarmaSummary? summary;
  final List<NityaKarmaItem> items;

  factory NityaKarmaSection.fromJson(Map<String, dynamic> json) {
    return NityaKarmaSection(
      sectionType: _parseString(json['section_type']),
      title: _parseString(json['title']),
      subtitle: _parseString(json['subtitle']),
      deityName: _parseString(json['deity_name']),
      deityImageUrl: _parseString(json['deity_image_url']),
      scheduledDate: _parseString(json['scheduled_date']),
      summary: json['summary'] is Map<String, dynamic>
          ? NityaKarmaSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : null,
      items: _parseList(
        json['items'],
        (item) => NityaKarmaItem.fromJson(item, sourceType: 'schedule'),
      ),
    );
  }

  NityaKarmaSection copyWith({
    String? sectionType,
    String? title,
    String? subtitle,
    String? deityName,
    String? deityImageUrl,
    String? scheduledDate,
    NityaKarmaSummary? summary,
    List<NityaKarmaItem>? items,
  }) {
    return NityaKarmaSection(
      sectionType: sectionType ?? this.sectionType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      deityName: deityName ?? this.deityName,
      deityImageUrl: deityImageUrl ?? this.deityImageUrl,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      summary: summary ?? this.summary,
      items: items ?? this.items,
    );
  }
}

class NityaKarmaDeityGroup {
  NityaKarmaDeityGroup({
    this.deityName,
    this.deityImageUrl,
    this.scheduledDate,
    this.dayName,
    this.items = const [],
    this.summary,
  });

  final String? deityName;
  final String? deityImageUrl;
  final String? scheduledDate;
  final String? dayName;
  final List<NityaKarmaItem> items;
  final NityaKarmaSummary? summary;

  factory NityaKarmaDeityGroup.fromJson(Map<String, dynamic> json) {
    final summary = NityaKarmaSummary(
      totalHabits: _parseInt(json['total_habits']),
      completedHabits: _parseInt(json['completed_habits']),
      pendingHabits: _parseInt(json['pending_habits']),
      completionPercentage: _parseInt(json['completion_percentage']),
      allCompleted: null,
    );
    return NityaKarmaDeityGroup(
      deityName: _parseString(json['deity_name']),
      deityImageUrl: _parseString(json['deity_image_url']),
      scheduledDate: _parseString(json['scheduled_date']),
      dayName: _parseString(json['day_name']),
      items: _parseList(
        json['habits'] ?? json['items'],
        (item) => NityaKarmaItem.fromJson(item, sourceType: 'schedule'),
      ),
      summary: json['summary'] is Map<String, dynamic>
          ? NityaKarmaSummary.fromJson(json['summary'] as Map<String, dynamic>)
          : summary,
    );
  }

  NityaKarmaDeityGroup copyWith({
    String? deityName,
    String? deityImageUrl,
    String? scheduledDate,
    String? dayName,
    List<NityaKarmaItem>? items,
    NityaKarmaSummary? summary,
  }) {
    return NityaKarmaDeityGroup(
      deityName: deityName ?? this.deityName,
      deityImageUrl: deityImageUrl ?? this.deityImageUrl,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dayName: dayName ?? this.dayName,
      items: items ?? this.items,
      summary: summary ?? this.summary,
    );
  }
}

class NityaKarmaSummary {
  NityaKarmaSummary({
    this.totalHabits,
    this.completedHabits,
    this.pendingHabits,
    this.completionPercentage,
    this.allCompleted,
  });

  final int? totalHabits;
  final int? completedHabits;
  final int? pendingHabits;
  final int? completionPercentage;
  final bool? allCompleted;

  factory NityaKarmaSummary.fromJson(Map<String, dynamic> json) {
    return NityaKarmaSummary(
      totalHabits: _parseInt(json['total_habits']),
      completedHabits: _parseInt(json['completed_habits']),
      pendingHabits: _parseInt(json['pending_habits']),
      completionPercentage: _parseInt(json['completion_percentage']),
      allCompleted: json['all_completed'] == true,
    );
  }
}

class NityaKarmaStreak {
  NityaKarmaStreak({this.currentStreak, this.longestStreak});

  final int? currentStreak;
  final int? longestStreak;

  factory NityaKarmaStreak.fromJson(Map<String, dynamic> json) {
    return NityaKarmaStreak(
      currentStreak: _parseInt(json['current_streak']),
      longestStreak: _parseInt(json['longest_streak']),
    );
  }
}

class NityaKarmaWeeklySummary {
  NityaKarmaWeeklySummary({this.startDate, this.endDate, this.completedDays});

  final String? startDate;
  final String? endDate;
  final int? completedDays;

  factory NityaKarmaWeeklySummary.fromJson(Map<String, dynamic> json) {
    return NityaKarmaWeeklySummary(
      startDate: _parseString(json['start_date']),
      endDate: _parseString(json['end_date']),
      completedDays: _parseInt(json['completed_days']),
    );
  }
}

class NityaKarmaUpcomingSchedule {
  NityaKarmaUpcomingSchedule({
    this.date,
    this.dayName,
    this.title,
    this.description,
    this.deityName,
  });

  final String? date;
  final String? dayName;
  final String? title;
  final String? description;
  final String? deityName;

  factory NityaKarmaUpcomingSchedule.fromJson(Map<String, dynamic> json) {
    return NityaKarmaUpcomingSchedule(
      date: _parseString(json['date']),
      dayName: _parseString(json['day_name']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      deityName: _parseString(json['deity_name']),
    );
  }
}

class NityaKarmaCelebration {
  NityaKarmaCelebration({
    this.showTodayCompletedCelebration,
    this.title,
    this.message,
  });

  final bool? showTodayCompletedCelebration;
  final String? title;
  final String? message;

  factory NityaKarmaCelebration.fromJson(Map<String, dynamic> json) {
    return NityaKarmaCelebration(
      showTodayCompletedCelebration:
          json['show_today_completed_celebration'] == true,
      title: _parseString(json['title']),
      message: _parseString(json['message']),
    );
  }
}

class NityaKarmaItem {
  NityaKarmaItem({
    this.id,
    this.scheduleId,
    this.scheduleItemId,
    this.habitId,
    this.title,
    this.description,
    this.deityName,
    this.deityImage,
    this.deityImageUrl,
    this.habitImage,
    this.habitImageUrl,
    this.habitImageType,
    this.habitImageWidth,
    this.habitImageHeight,
    this.scheduledDate,
    this.dayName,
    this.sortOrder,
    this.isActive,
    this.isCompleted,
    this.completedAt,
    this.logId,
    this.sourceType,
    this.isScheduled,
    this.toggleAllowed,
  });

  final int? id;
  final int? scheduleId;
  final int? scheduleItemId;
  final int? habitId;
  final String? title;
  final String? description;
  final String? deityName;
  final String? deityImage;
  final String? deityImageUrl;
  final String? habitImage;
  final String? habitImageUrl;
  final String? habitImageType;
  final int? habitImageWidth;
  final int? habitImageHeight;
  final String? scheduledDate;
  final String? dayName;
  final int? sortOrder;
  final int? isActive;
  final int? isCompleted;
  final String? completedAt;
  final int? logId;
  final String? sourceType;
  final int? isScheduled;
  final int? toggleAllowed;

  bool get completed => isCompleted == 1;
  int? get effectiveHabitId => isScheduleItem ? habitId : (habitId ?? id);
  int? get effectiveScheduleId =>
      isScheduleItem ? (scheduleId ?? id ?? scheduleItemId) : null;
  bool get isScheduleItem =>
      isScheduled == 1 ||
      sourceType?.toLowerCase() == 'schedule' ||
      sourceType?.toLowerCase() == 'scheduled_item';
  bool get canToggle =>
      isScheduleItem ? toggleAllowed == 1 : effectiveHabitId != null;
  int? get toggleRequestId =>
      isScheduleItem ? effectiveScheduleId : effectiveHabitId;

  factory NityaKarmaItem.fromJson(
    Map<String, dynamic> json, {
    String? sourceType,
  }) {
    return NityaKarmaItem(
      id: _parseInt(json['id']),
      scheduleId: _parseInt(json['schedule_id']),
      scheduleItemId: _parseInt(json['schedule_item_id']),
      habitId: _parseInt(json['habit_id']),
      title: _parseString(json['title']),
      description: _parseString(json['description']),
      deityName: _parseString(json['deity_name']),
      deityImage: _parseString(json['deity_image']),
      deityImageUrl: _parseString(json['deity_image_url']),
      habitImage: _parseString(json['habit_image']),
      habitImageUrl: _parseString(json['habit_image_url']),
      habitImageType: _parseString(json['habit_image_type']),
      habitImageWidth: _parseInt(json['habit_image_width']),
      habitImageHeight: _parseInt(json['habit_image_height']),
      scheduledDate: _parseString(json['scheduled_date']),
      dayName: _parseString(json['day_name']),
      sortOrder: _parseInt(json['sort_order']),
      isActive: _parseInt(json['is_active']),
      isCompleted: _parseInt(json['is_completed']),
      completedAt: _parseString(json['completed_at']),
      logId: _parseInt(json['log_id']),
      sourceType: _parseString(json['source_type']) ?? sourceType,
      isScheduled: _parseInt(json['is_scheduled']),
      toggleAllowed: _parseInt(json['toggle_allowed']),
    );
  }

  NityaKarmaItem copyWith({
    int? id,
    int? scheduleId,
    int? scheduleItemId,
    int? habitId,
    String? title,
    String? description,
    String? deityName,
    String? deityImage,
    String? deityImageUrl,
    String? habitImage,
    String? habitImageUrl,
    String? habitImageType,
    int? habitImageWidth,
    int? habitImageHeight,
    String? scheduledDate,
    String? dayName,
    int? sortOrder,
    int? isActive,
    int? isCompleted,
    String? completedAt,
    int? logId,
    String? sourceType,
    int? isScheduled,
    int? toggleAllowed,
  }) {
    return NityaKarmaItem(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduleItemId: scheduleItemId ?? this.scheduleItemId,
      habitId: habitId ?? this.habitId,
      title: title ?? this.title,
      description: description ?? this.description,
      deityName: deityName ?? this.deityName,
      deityImage: deityImage ?? this.deityImage,
      deityImageUrl: deityImageUrl ?? this.deityImageUrl,
      habitImage: habitImage ?? this.habitImage,
      habitImageUrl: habitImageUrl ?? this.habitImageUrl,
      habitImageType: habitImageType ?? this.habitImageType,
      habitImageWidth: habitImageWidth ?? this.habitImageWidth,
      habitImageHeight: habitImageHeight ?? this.habitImageHeight,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      dayName: dayName ?? this.dayName,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      logId: logId ?? this.logId,
      sourceType: sourceType ?? this.sourceType,
      isScheduled: isScheduled ?? this.isScheduled,
      toggleAllowed: toggleAllowed ?? this.toggleAllowed,
    );
  }
}

List<T> _parseList<T>(dynamic source, T Function(Map<String, dynamic>) mapper) {
  if (source is! List) return const [];
  return source
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList();
}

int? _parseInt(dynamic value) =>
    value is int ? value : int.tryParse(value?.toString() ?? '');

String? _parseString(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;
  return text;
}
