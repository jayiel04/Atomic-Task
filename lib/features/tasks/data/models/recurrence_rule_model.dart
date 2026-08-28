import '../../../../core/database/app_database.dart';
import '../../domain/entities/recurrence_rule.dart';

class RecurrenceRuleModel extends RecurrenceRule {
  const RecurrenceRuleModel({
    required super.id,
    required super.frequency,
    required super.interval,
    required super.startDate,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.endDate,
    super.reminderTimeMinutes,
  });

  factory RecurrenceRuleModel.fromRow(TaskRecurrenceRuleRow row) {
    return RecurrenceRuleModel(
      id: row.id,
      frequency: RecurrenceFrequency.values.byName(row.frequency),
      interval: row.interval,
      startDate: row.startDate,
      endDate: row.endDate,
      reminderTimeMinutes: row.reminderTimeMinutes,
      isActive: row.isActive,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
