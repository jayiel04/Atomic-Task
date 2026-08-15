import 'package:atomic_task/features/tasks/presentation/task_due_date_shortcuts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates tomorrow and one week from the local day', () {
    final from = DateTime(2026, 8, 15, 23, 45);

    expect(
      TaskDueDateShortcuts.calculate(TaskDueDateShortcut.tomorrow, from),
      DateTime(2026, 8, 16),
    );
    expect(
      TaskDueDateShortcuts.calculate(TaskDueDateShortcut.oneWeek, from),
      DateTime(2026, 8, 22),
    );
  });

  test('advances one calendar month and crosses the year boundary', () {
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2026, 11, 15),
      ),
      DateTime(2026, 12, 15),
    );
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2026, 12, 15),
      ),
      DateTime(2027, 1, 15),
    );
  });

  test('clamps one month to the final valid day', () {
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2025, 1, 31),
      ),
      DateTime(2025, 2, 28),
    );
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2024, 1, 31),
      ),
      DateTime(2024, 2, 29),
    );
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2026, 3, 31),
      ),
      DateTime(2026, 4, 30),
    );
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.oneMonth,
        DateTime(2024, 2, 29),
      ),
      DateTime(2024, 3, 29),
    );
  });
}
