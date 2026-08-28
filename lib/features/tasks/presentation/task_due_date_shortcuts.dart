enum TaskDueDateShortcut { today, tomorrow }

abstract final class TaskDueDateShortcuts {
  static DateTime calculate(TaskDueDateShortcut shortcut, DateTime from) {
    final local = from.toLocal();
    final today = DateTime(local.year, local.month, local.day);

    return switch (shortcut) {
      TaskDueDateShortcut.today => today,
      TaskDueDateShortcut.tomorrow => DateTime(
        today.year,
        today.month,
        today.day + 1,
      ),
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
}
