import 'package:atomic_task/features/tasks/presentation/task_due_date_shortcuts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('calculates today and tomorrow from the local day', () {
    final from = DateTime(2026, 8, 15, 23, 45);

    expect(
      TaskDueDateShortcuts.calculate(TaskDueDateShortcut.today, from),
      DateTime(2026, 8, 15),
    );
    expect(
      TaskDueDateShortcuts.calculate(TaskDueDateShortcut.tomorrow, from),
      DateTime(2026, 8, 16),
    );
  });

  test('tomorrow crosses the year boundary', () {
    expect(
      TaskDueDateShortcuts.calculate(
        TaskDueDateShortcut.tomorrow,
        DateTime(2026, 12, 31),
      ),
      DateTime(2027, 1, 1),
    );
  });
}
