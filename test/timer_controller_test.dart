import 'dart:async';

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
    'keeps loaded progress when restoring the timer session fails',
    () async {
      final repository = _MemoryTimerRepository(
        progress: const UserProgress(
          gems: 7,
          totalFocusSeconds: 540,
          profileName: 'Javier',
        ),
      );
      final controller = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(),
        focusCompletionAdService: _FakeFocusCompletionAdService(),
        sessionRepository: _FailingTimerSessionRepository(),
      );
      addTearDown(controller.dispose);

      await controller.initialize();

      expect(controller.isInitialized, isTrue);
      expect(controller.progress.gems, 7);
      expect(controller.progress.totalFocusSeconds, 540);
      expect(controller.progress.profileName, 'Javier');
      expect(controller.statusIsError, isTrue);
      expect(controller.statusMessage, contains('sesión anterior'));
    },
  );

  test('does not restore a session after the controller is disposed', () async {
    final repository = _MemoryTimerRepository();
    final sessions = _DelayedActiveSessionRepository();
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: _FakeFocusCompletionAdService(),
      sessionRepository: sessions,
    );

    final initialization = controller.initialize();
    await _waitUntil(() => sessions.loadCalls == 1);
    controller.dispose();
    sessions.complete(
      ActiveTimerSession(
        sessionId: 'pending-restoration',
        mode: TimerMode.focus,
        state: TimerSessionState.running,
        selectedSeconds: 60,
        remainingSeconds: 60,
        elapsedSeconds: 0,
        rewardedBlocks: 0,
        chargedMinutes: 0,
        lastCheckpointAt: DateTime(2026, 8, 15, 10),
        endsAt: DateTime(2026, 8, 15, 10, 1),
      ),
    );

    await initialization;

    expect(controller.isInitialized, isFalse);
    expect(controller.isRunning, isFalse);
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
    expect(controller.pendingCompletionSummary, isNull);
  });

  test('publishes the focus summary only after the ad is dismissed', () async {
    final repository = _MemoryTimerRepository();
    final sessions = _MemoryTimerSessionRepository();
    final completionAds = _ControlledFocusCompletionAdService();
    var now = DateTime(2026, 8, 15, 10);
    var publishedSummaries = 0;
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: completionAds,
      sessionRepository: sessions,
      onCompletionSummary: (_) => publishedSummaries += 1,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await _waitUntil(() => completionAds.showCalls == 1);

    expect(controller.pendingCompletionSummary, isNull);
    expect(publishedSummaries, 0);

    completionAds.complete(FocusCompletionAdResult.shown);
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    final summary = controller.pendingCompletionSummary!;
    expect(summary.completedSeconds, 60);
    expect(summary.gemDelta, 0);
    expect(summary.adPending, isFalse);
    expect(publishedSummaries, 1);
  });

  test(
    'orders linked task, notification, ad and summary publication',
    () async {
      final repository = _MemoryTimerRepository();
      final events = <String>[];
      final completionAds = _ControlledFocusCompletionAdService(
        onShow: () => events.add('ad'),
      );
      var now = DateTime(2026, 8, 15, 10);
      final controller = TimerController(
        loadProgress: LoadProgress(repository),
        saveProgress: SaveProgress(repository),
        clearProgress: ClearProgress(repository),
        notificationService: _FakeTimerNotificationService(
          onCompletion: () => events.add('notification'),
        ),
        focusCompletionAdService: completionAds,
        onLinkedTaskFocusCompletedAtAsync: (taskId, completedAt) async {
          events.add('task');
          return true;
        },
        onCompletionSummary: (_) => events.add('summary'),
        now: () => now,
      );
      addTearDown(controller.dispose);

      await controller.initialize();
      controller.prepareFocusForTask(
        taskId: 42,
        taskTitle: 'Preparar propuesta',
        minutes: 1,
      );
      controller.startOrPause();
      now = now.add(const Duration(minutes: 1));
      controller.syncWithClock();
      await _waitUntil(() => completionAds.showCalls == 1);

      expect(events, ['task', 'notification', 'ad']);
      completionAds.complete(FocusCompletionAdResult.shown);
      await _waitUntil(() => controller.pendingCompletionSummary != null);

      expect(events, ['task', 'notification', 'ad', 'summary']);
      expect(
        controller.pendingCompletionSummary?.taskTitle,
        'Preparar propuesta',
      );
      expect(
        controller.pendingCompletionSummary?.taskCompletionPending,
        isFalse,
      );
    },
  );

  test('publishes the summary when ads are unsupported', () async {
    final repository = _MemoryTimerRepository();
    final completionAds = _ControlledFocusCompletionAdService();
    var now = DateTime(2026, 8, 15, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: completionAds,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await _waitUntil(() => completionAds.showCalls == 1);

    completionAds.complete(FocusCompletionAdResult.unsupported);
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    expect(controller.pendingCompletionSummary?.adPending, isFalse);
  });

  test('records time outside after the scheduled focus completion', () async {
    final repository = _MemoryTimerRepository();
    final sessions = _MemoryTimerSessionRepository();
    final completionAds = _FakeFocusCompletionAdService();
    var publishedSummaries = 0;
    var now = DateTime(2026, 8, 15, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: completionAds,
      sessionRepository: sessions,
      onCompletionSummary: (_) => publishedSummaries += 1,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    controller.handleAppPaused();
    now = DateTime(2026, 8, 15, 10, 8);
    controller.handleAppResumed();
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    final summary = controller.pendingCompletionSummary!;
    expect(summary.completedAt, DateTime(2026, 8, 15, 10, 1));
    expect(summary.completedWhileAppWasAway, isTrue);
    expect(summary.awaySecondsAfterCompletion, 7 * 60);

    now = DateTime(2026, 8, 15, 10, 20);
    controller.handleAppPaused();
    controller.handleAppResumed();
    expect(
      controller.pendingCompletionSummary?.awaySecondsAfterCompletion,
      7 * 60,
    );
    expect(completionAds.showCalls, 1);
    expect(publishedSummaries, 1);
  });

  test('normalizes a return at the exact scheduled end to zero', () async {
    final repository = _MemoryTimerRepository();
    var now = DateTime(2026, 8, 15, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: _FakeFocusCompletionAdService(),
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    controller.handleAppPaused();
    now = DateTime(2026, 8, 15, 10, 1);
    controller.handleAppResumed();
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    expect(
      controller.pendingCompletionSummary?.completedWhileAppWasAway,
      isTrue,
    );
    expect(controller.pendingCompletionSummary?.awaySecondsAfterCompletion, 0);
  });

  test('does not include ad display time in the time outside', () async {
    final repository = _MemoryTimerRepository();
    final completionAds = _ControlledFocusCompletionAdService();
    var now = DateTime(2026, 8, 15, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: completionAds,
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    controller.handleAppPaused();
    now = DateTime(2026, 8, 15, 10, 8);
    controller.handleAppResumed();
    await _waitUntil(() => completionAds.showCalls == 1);

    now = DateTime(2026, 8, 15, 10, 12);
    completionAds.complete(FocusCompletionAdResult.shown);
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    expect(
      controller.pendingCompletionSummary?.awaySecondsAfterCompletion,
      7 * 60,
    );
  });

  test('omits time outside for a foreground completion', () async {
    final repository = _MemoryTimerRepository();
    var now = DateTime(2026, 8, 15, 10);
    final controller = TimerController(
      loadProgress: LoadProgress(repository),
      saveProgress: SaveProgress(repository),
      clearProgress: ClearProgress(repository),
      notificationService: _FakeTimerNotificationService(),
      focusCompletionAdService: _FakeFocusCompletionAdService(),
      now: () => now,
    );
    addTearDown(controller.dispose);

    await controller.initialize();
    controller.setMinutes(1);
    controller.startOrPause();
    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await _waitUntil(() => controller.pendingCompletionSummary != null);

    expect(
      controller.pendingCompletionSummary?.completedWhileAppWasAway,
      isFalse,
    );
    expect(
      controller.pendingCompletionSummary?.awaySecondsAfterCompletion,
      isNull,
    );
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

  test('records time outside when an expired session is restored', () async {
    final repository = _MemoryTimerRepository();
    final sessions = _MemoryTimerSessionRepository();
    var now = DateTime(2026, 8, 15, 10);
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
    firstController.handleAppPaused();
    await firstController.flushPersistence();
    firstController.dispose();

    now = DateTime(2026, 8, 15, 10, 8);
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
    await _waitUntil(() => secondController.pendingCompletionSummary != null);

    final summary = secondController.pendingCompletionSummary!;
    expect(summary.completedAt, DateTime(2026, 8, 15, 10, 1));
    expect(summary.completedWhileAppWasAway, isTrue);
    expect(summary.awaySecondsAfterCompletion, 7 * 60);
  });

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

class _ControlledFocusCompletionAdService implements FocusCompletionAdService {
  _ControlledFocusCompletionAdService({this.onShow});

  final _completion = Completer<FocusCompletionAdResult>();
  final void Function()? onShow;
  int showCalls = 0;

  void complete(FocusCompletionAdResult result) {
    if (!_completion.isCompleted) {
      _completion.complete(result);
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showAfterFocusCompletion() async {
    await showAfterFocusCompletionResult();
  }

  @override
  Future<FocusCompletionAdResult> showAfterFocusCompletionResult() {
    showCalls += 1;
    onShow?.call();
    return _completion.future;
  }

  @override
  Future<void> dispose() async {
    complete(FocusCompletionAdResult.retry);
  }
}

Future<void> _waitUntil(bool Function() condition) async {
  for (var attempt = 0; attempt < 100; attempt += 1) {
    if (condition()) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  fail('Timed out while waiting for asynchronous timer work.');
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

class _FailingTimerSessionRepository extends _MemoryTimerSessionRepository {
  @override
  Future<ActiveTimerSession?> loadActiveSession() {
    throw StateError('simulated session restoration failure');
  }
}

class _DelayedActiveSessionRepository extends _MemoryTimerSessionRepository {
  final _activeSessionCompletion = Completer<ActiveTimerSession?>();
  int loadCalls = 0;

  void complete(ActiveTimerSession session) {
    _activeSessionCompletion.complete(session);
  }

  @override
  Future<ActiveTimerSession?> loadActiveSession() {
    loadCalls += 1;
    return _activeSessionCompletion.future;
  }
}

class _FakeTimerNotificationService implements TimerNotificationService {
  _FakeTimerNotificationService({
    this.failOnCompletion = false,
    this.onCompletion,
  });

  final bool failOnCompletion;
  final void Function()? onCompletion;
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
    onCompletion?.call();
    completedTimerCalls += 1;
    lastCompletedTitle = title;
    lastCompletedBody = body;
  }
}
