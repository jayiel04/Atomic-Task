import 'dart:math' as math;

enum TaskDueDateShortcut { tomorrow, oneWeek, oneMonth }

abstract final class TaskDueDateShortcuts {
  static DateTime calculate(TaskDueDateShortcut shortcut, DateTime from) {
    final local = from.toLocal();
    final today = DateTime(local.year, local.month, local.day);

    return switch (shortcut) {
      TaskDueDateShortcut.tomorrow => DateTime(
        today.year,
        today.month,
        today.day + 1,
      ),
      TaskDueDateShortcut.oneWeek => DateTime(
        today.year,
        today.month,
        today.day + 7,
      ),
      TaskDueDateShortcut.oneMonth => _addCalendarMonth(today),
    };
  }

  static bool isSameDay(DateTime? left, DateTime right) {
    if (left == null) {
      return false;
    }
    final localLeft = left.toLocal();
    final localRight = right.toLocal();
    return localLeft.year == localRight.year &&
        localLeft.month == localRight.month &&
        localLeft.day == localRight.day;
  }

  static DateTime _addCalendarMonth(DateTime date) {
    final targetMonth = date.month == DateTime.december
        ? DateTime.january
        : date.month + 1;
    final targetYear = date.month == DateTime.december
        ? date.year + 1
        : date.year;
    final lastTargetDay = DateTime(targetYear, targetMonth + 1, 0).day;
    return DateTime(targetYear, targetMonth, math.min(date.day, lastTargetDay));
  }
}
