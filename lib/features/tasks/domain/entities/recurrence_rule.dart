enum RecurrenceFrequency { daily, weekly, monthly }

class RecurrenceRule {
  const RecurrenceRule({
    required this.id,
    required this.frequency,
    required this.interval,
    required this.startDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.endDate,
    this.reminderTimeMinutes,
  });

  final int id;
  final RecurrenceFrequency frequency;
  final int interval;
  final DateTime startDate;
  final DateTime? endDate;
  final int? reminderTimeMinutes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecurrenceRule copyWith({
    int? id,
    RecurrenceFrequency? frequency,
    int? interval,
    DateTime? startDate,
    DateTime? endDate,
    bool clearEndDate = false,
    int? reminderTimeMinutes,
    bool clearReminderTime = false,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurrenceRule(
      id: id ?? this.id,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : endDate ?? this.endDate,
      reminderTimeMinutes: clearReminderTime
          ? null
          : reminderTimeMinutes ?? this.reminderTimeMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
