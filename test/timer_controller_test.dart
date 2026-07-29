import 'package:atomic_task/features/timer/domain/entities/timer_mode.dart';
import 'package:atomic_task/features/timer/domain/entities/user_progress.dart';
import 'package:atomic_task/features/timer/domain/repositories/timer_repository.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:atomic_task/features/timer/domain/usecases/clear_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/load_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/save_progress.dart';
import 'package:atomic_task/features/timer/presentation/controllers/timer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'keeps notifications and remaining time in sync with the clock',
    () async {
      final repository = _MemoryTimerRepository();
      final notifications = _FakeTimerNotificationService();
      var now = DateTime(2026, 7, 29, 10);
      final controller = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: notifications,
        now: () => now,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      controller.startOrPause();

      expect(notifications.runningTimerCalls, 1);
      expect(notifications.lastEndsAt, now.add(const Duration(minutes: 25)));
      expect(notifications.lastScheduledTitle, 'Trabajo finalizado');
      expect(
        notifications.lastScheduledBody,
        '¡Sesión completada! Tómate un descanso.',
      );

      now = now.add(const Duration(seconds: 5));
      controller.syncWithClock();

      expect(controller.remainingSeconds, (25 * 60) - 5);
      expect(controller.progress.totalFocusSeconds, 5);

      controller.pause();
      expect(notifications.cancelCalls, 1);

      controller.startOrPause();
      now = now.add(Duration(seconds: controller.remainingSeconds));
      controller.syncWithClock();

      expect(controller.remainingSeconds, 0);
      expect(controller.sessionCompleted, isTrue);
      expect(notifications.completedTimerCalls, 1);
      expect(notifications.lastCompletedTitle, 'Trabajo finalizado');
      expect(
        notifications.lastCompletedBody,
        '¡Sesión completada! Tómate un descanso.',
      );
    },
  );

  test('uses the requested completion message for a rest timer', () async {
    final repository = _MemoryTimerRepository(
      progress: const UserProgress(
        gems: 5,
        totalFocusSeconds: 0,
        profileName: 'NOMBRE',
      ),
    );
    final notifications = _FakeTimerNotificationService();
    var now = DateTime(2026, 7, 29, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notifications,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMode(TimerMode.rest);
    controller.startOrPause();

    expect(notifications.lastScheduledTitle, 'Descanso finalizado');
    expect(
      notifications.lastScheduledBody,
      'El descanso terminó. ¿Listo para continuar?',
    );

    now = now.add(const Duration(minutes: 5));
    controller.syncWithClock();

    expect(notifications.lastCompletedTitle, 'Descanso finalizado');
    expect(
      notifications.lastCompletedBody,
      'El descanso terminó. ¿Listo para continuar?',
    );
  });
}

class _MemoryTimerRepository implements TimerRepository {
  _MemoryTimerRepository({this.progress = UserProgress.empty});

  UserProgress progress;

  @override
  Future<void> clearProgress() async {
    progress = UserProgress.empty;
  }

  @override
  Future<UserProgress> loadProgress() async => progress;

  @override
  Future<void> saveProgress(UserProgress progress) async {
    this.progress = progress;
  }
}

class _FakeTimerNotificationService implements TimerNotificationService {
  int runningTimerCalls = 0;
  int cancelCalls = 0;
  int completedTimerCalls = 0;
  DateTime? lastEndsAt;
  String? lastScheduledTitle;
  String? lastScheduledBody;
  String? lastCompletedTitle;
  String? lastCompletedBody;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showRunningTimer({
    required String timerName,
    required int remainingSeconds,
    required DateTime endsAt,
    required String completionTitle,
    required String completionBody,
  }) async {
    runningTimerCalls += 1;
    lastEndsAt = endsAt;
    lastScheduledTitle = completionTitle;
    lastScheduledBody = completionBody;
  }

  @override
  Future<void> cancelTimerNotifications() async {
    cancelCalls += 1;
  }

  @override
  Future<void> showTimerCompleted({
    required String title,
    required String body,
  }) async {
    completedTimerCalls += 1;
    lastCompletedTitle = title;
    lastCompletedBody = body;
  }
}
