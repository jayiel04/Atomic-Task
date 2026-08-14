import 'package:atomic_task/features/timer/domain/entities/timer_mode.dart';
import 'package:atomic_task/features/timer/domain/entities/timer_session.dart';
import 'package:atomic_task/features/timer/domain/entities/user_progress.dart';
import 'package:atomic_task/features/timer/domain/repositories/timer_repository.dart';
import 'package:atomic_task/features/timer/domain/repositories/timer_session_repository.dart';
import 'package:atomic_task/features/timer/domain/services/focus_completion_ad_service.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:atomic_task/features/timer/domain/usecases/clear_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/load_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/save_progress.dart';
import 'package:atomic_task/features/timer/presentation/controllers/timer_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('limits normalized profile names to eighteen characters', () async {
    final repository = _MemoryTimerRepository(
      progress: const UserProgress(
        gems: 0,
        totalFocusSeconds: 0,
        profileName: 'Nombre demasiado largo',
      ),
    );
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: _FakeFocusCompletionAdService(),
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.progress.profileName, 'Nombre demasiado l');

    controller.updateProfileName('  Alejandro  ');
    await Future<void>.delayed(Duration.zero);

    expect(controller.progress.profileName, 'Alejandro');
    expect(repository.progress.profileName, 'Alejandro');
  });

  test(
    'keeps notifications and remaining time in sync with the clock',
    () async {
      final repository = _MemoryTimerRepository();
      final notifications = _FakeTimerNotificationService();
      final completionAds = _FakeFocusCompletionAdService();
      var now = DateTime(2026, 7, 29, 10);
      final controller = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: notifications,
        focusCompletionAdService: completionAds,
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
      expect(repository.saveCalls, 0);

      controller.pause();
      await Future<void>.delayed(Duration.zero);
      expect(notifications.cancelCalls, 1);
      expect(repository.saveCalls, 1);
      expect(completionAds.showCalls, 0);

      controller.startOrPause();
      now = now.add(Duration(seconds: controller.remainingSeconds));
      controller.syncWithClock();
      await Future<void>.delayed(Duration.zero);

      expect(controller.remainingSeconds, 0);
      expect(controller.sessionCompleted, isTrue);
      expect(notifications.completedTimerCalls, 1);
      expect(completionAds.showCalls, 1);

      controller.syncWithClock();
      expect(completionAds.showCalls, 1);
      expect(notifications.lastCompletedTitle, 'Sesión completada');
      expect(
        notifications.lastCompletedBody,
        '25 min de concentración · +8 gemas',
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
    final completionAds = _FakeFocusCompletionAdService();
    var now = DateTime(2026, 7, 29, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notifications,
      focusCompletionAdService: completionAds,
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
    await Future<void>.delayed(Duration.zero);

    expect(notifications.lastCompletedTitle, 'Descanso completado');
    expect(notifications.lastCompletedBody, '5 min de descanso · −5 gemas');
    expect(completionAds.showCalls, 0);
  });

  test('keeps a completed focus session when the ad fails', () async {
    final repository = _MemoryTimerRepository();
    final notifications = _FakeTimerNotificationService();
    final completionAds = _FakeFocusCompletionAdService(failOnShow: true);
    var now = DateTime(2026, 7, 29, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notifications,
      focusCompletionAdService: completionAds,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();

    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await Future<void>.delayed(Duration.zero);

    expect(controller.sessionCompleted, isTrue);
    expect(controller.remainingSeconds, 0);
    expect(notifications.completedTimerCalls, 1);
    expect(completionAds.showCalls, 1);
    expect(controller.pendingCompletionSummary?.adPending, isTrue);
  });

  test(
    'completes a linked task only when its focus session finishes',
    () async {
      final repository = _MemoryTimerRepository();
      final notifications = _FakeTimerNotificationService();
      final completionAds = _FakeFocusCompletionAdService();
      var now = DateTime(2026, 8, 10, 10);
      int? completedTaskId;
      DateTime? completedTaskAt;
      final controller = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: notifications,
        focusCompletionAdService: completionAds,
        onLinkedTaskFocusCompletedAtAsync: (taskId, completedAt) async {
          completedTaskId = taskId;
          completedTaskAt = completedAt;
          return true;
        },
        now: () => now,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      expect(
        controller.prepareFocusForTask(
          taskId: 42,
          taskTitle: 'Preparar propuesta',
          minutes: 1,
        ),
        isTrue,
      );
      expect(controller.minutes, 1);
      expect(controller.linkedTaskId, 42);
      expect(controller.statusMessage, contains('Preparar propuesta'));
      expect(completedTaskId, isNull);

      controller.startOrPause();
      expect(completedTaskId, isNull);
      now = now.add(const Duration(minutes: 1));
      controller.syncWithClock();
      await Future<void>.delayed(Duration.zero);

      expect(completedTaskId, 42);
      expect(completedTaskAt, now);
      expect(controller.linkedTaskId, isNull);
      expect(controller.sessionCompleted, isTrue);
    },
  );

  test(
    'restores an active session after the controller is recreated',
    () async {
      final repository = _MemoryTimerRepository();
      final sessions = _MemoryTimerSessionRepository();
      var now = DateTime(2026, 8, 14, 10);
      final firstController = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(),
        focusCompletionAdService: _FakeFocusCompletionAdService(),
        sessionRepository: sessions,
        now: () => now,
      );

      await firstController.initialize();
      firstController.setMinutes(1);
      firstController.startOrPause();
      now = now.add(const Duration(seconds: 10));
      firstController.syncWithClock();
      await firstController.flushPersistence();
      firstController.dispose();

      final secondController = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(),
        focusCompletionAdService: _FakeFocusCompletionAdService(),
        sessionRepository: sessions,
        now: () => now,
      );
      addTearDown(secondController.dispose);

      await secondController.initialize();

      expect(secondController.hasRestorableSession, isTrue);
      expect(secondController.isRunning, isTrue);
      expect(secondController.remainingSeconds, 50);

      secondController.resetTimer();
      await secondController.flushPersistence();
      expect(await sessions.loadActiveSession(), isNull);
    },
  );

  test(
    'retries pending completion work after the controller is recreated',
    () async {
      final repository = _MemoryTimerRepository();
      final sessions = _MemoryTimerSessionRepository();
      var now = DateTime(2026, 8, 14, 10);
      final firstController = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(),
        focusCompletionAdService: _FakeFocusCompletionAdService(
          failOnShow: true,
        ),
        sessionRepository: sessions,
        now: () => now,
      );

      await firstController.initialize();
      firstController.setMinutes(1);
      firstController.startOrPause();
      now = now.add(const Duration(minutes: 1));
      firstController.syncWithClock();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await firstController.flushPersistence();
      expect((await sessions.loadPendingSummary())?.adPending, isTrue);
      firstController.dispose();

      final recoveredAds = _FakeFocusCompletionAdService();
      CompletionSummary? recoveredSummary;
      final secondController = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(),
        focusCompletionAdService: recoveredAds,
        sessionRepository: sessions,
        onCompletionSummary: (summary) => recoveredSummary = summary,
        now: () => now,
      );
      addTearDown(secondController.dispose);

      await secondController.initialize();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(recoveredAds.showCalls, 1);
      expect(recoveredSummary?.adPending, isFalse);
      secondController.consumePendingCompletionSummary();
      await secondController.flushPersistence();
      expect(await sessions.loadPendingSummary(), isNull);
    },
  );

  test('does not persist the default timer as an active session', () async {
    final sessions = _MemoryTimerSessionRepository();
    final repository = _MemoryTimerRepository();
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: _FakeFocusCompletionAdService(),
      sessionRepository: sessions,
    );

    await controller.initialize();
    controller.dispose();
    await controller.flushPersistence();

    expect(await sessions.loadActiveSession(), isNull);
  });

  test('keeps a completion notification pending when delivery fails', () async {
    final sessions = _MemoryTimerSessionRepository();
    final repository = _MemoryTimerRepository();
    final notifications = _FakeTimerNotificationService(failOnCompletion: true);
    var now = DateTime(2026, 8, 14, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: notifications,
      focusCompletionAdService: _FakeFocusCompletionAdService(),
      sessionRepository: sessions,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await controller.flushPersistence();

    expect(controller.sessionCompleted, isTrue);
    expect((await sessions.loadPendingSummary())?.notificationPending, isTrue);
  });
}

class _FakeFocusCompletionAdService implements FocusCompletionAdService {
  _FakeFocusCompletionAdService({this.failOnShow = false});

  final bool failOnShow;
  int showCalls = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showAfterFocusCompletion() async {
    showCalls += 1;
    if (failOnShow) {
      throw StateError('simulated ad failure');
    }
  }

  @override
  Future<FocusCompletionAdResult> showAfterFocusCompletionResult() async {
    try {
      await showAfterFocusCompletion();
      return FocusCompletionAdResult.shown;
    } catch (_) {
      return FocusCompletionAdResult.retry;
    }
  }

  @override
  Future<void> dispose() async {}
}

class _MemoryTimerRepository implements TimerRepository {
  _MemoryTimerRepository({this.progress = UserProgress.empty});

  UserProgress progress;
  int saveCalls = 0;

  @override
  Future<void> clearProgress() async {
    progress = UserProgress.empty;
  }

  @override
  Future<UserProgress> loadProgress() async => progress;

  @override
  Future<void> saveProgress(UserProgress progress) async {
    saveCalls += 1;
    this.progress = progress;
  }
}

class _MemoryTimerSessionRepository implements TimerSessionRepository {
  ActiveTimerSession? activeSession;
  CompletionSummary? pendingSummary;

  @override
  Future<ActiveTimerSession?> loadActiveSession() async => activeSession;

  @override
  Future<void> saveActiveSession(ActiveTimerSession session) async {
    activeSession = session;
  }

  @override
  Future<void> clearActiveSession() async {
    activeSession = null;
  }

  @override
  Future<CompletionSummary?> loadPendingSummary() async => pendingSummary;

  @override
  Future<void> savePendingSummary(CompletionSummary summary) async {
    pendingSummary = summary;
  }

  @override
  Future<void> clearPendingSummary() async {
    pendingSummary = null;
  }
}

class _FakeTimerNotificationService implements TimerNotificationService {
  _FakeTimerNotificationService({this.failOnCompletion = false});

  final bool failOnCompletion;
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
    if (failOnCompletion) {
      throw StateError('simulated notification failure');
    }
    completedTimerCalls += 1;
    lastCompletedTitle = title;
    lastCompletedBody = body;
  }
}
