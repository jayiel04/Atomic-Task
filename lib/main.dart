import 'package:flutter/material.dart';

import 'app.dart';
import 'features/tasks/data/services/local_task_reminder_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(AtomicTimerBootstrap(taskReminderService: LocalTaskReminderService()));
}
