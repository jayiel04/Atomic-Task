import 'dart:async';

import 'package:atomic_task/app.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:atomic_task/features/tasks/data/models/task_model.dart';
import 'package:atomic_task/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:atomic_task/features/timer/data/models/progress_model.dart';
import 'package:atomic_task/features/timer/domain/services/focus_completion_ad_service.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [
    const Size(320, 568),
    const Size(360, 640),
    const Size(390, 844),
    const Size(412, 915),
    const Size(820, 1180),
    const Size(568, 320),
  ]) {
    testWidgets('main view fits without scrolling at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        AtomicTimerBootstrap(
          notificationService: _NoopNotificationService(),
          focusCompletionAdService: _NoopFocusCompletionAdService(),
          localDataSource: _MemoryTimerLocalDataSource(
            progress: const ProgressModel(
              gems: 0,
              totalFocusSeconds: 0,
              profileName: 'Javier',
            ),
          ),
          taskLocalDataSource: _EmptyTaskLocalDataSource(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(find.text('INICIAR'), findsOneWidget);
      expect(find.text('Reiniciar temporizador'), findsOneWidget);
      expect(
        tester.getBottomRight(find.text('Reiniciar temporizador')).dy,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('asks for and saves the name on first launch', (tester) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('\u00a1Bienvenido!'), findsOneWidget);
    expect(find.byKey(const Key('firstLaunchNameField')), findsOneWidget);

    await tester.tap(find.byKey(const Key('saveFirstLaunchName')));
    await tester.pump();
    expect(find.text('Ingresa tu nombre para continuar'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('firstLaunchNameField')),
      '  Javier  ',
    );
    await tester.tap(find.byKey(const Key('saveFirstLaunchName')));
    await tester.pumpAndSettle();

    expect(find.text('\u00a1Bienvenido!'), findsNothing);
    expect(find.text('Javier'), findsOneWidget);
  });

  testWidgets('does not ask for the name again when it is saved', (
    tester,
  ) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 0,
            totalFocusSeconds: 0,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('\u00a1Bienvenido!'), findsNothing);
    expect(find.text('Javier'), findsOneWidget);
  });

  testWidgets('opens the task view from the progress drawer', (tester) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 0,
            totalFocusSeconds: 0,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openTasksMenuItem')));
    await tester.pumpAndSettle();

    expect(find.text('Tareas'), findsOneWidget);
    expect(find.byKey(const Key('createTaskButton')), findsOneWidget);
  });

  testWidgets('prepares the timer from a task focus association', (
    tester,
  ) async {
    final taskDataSource = _SeededTaskLocalDataSource();
    addTearDown(taskDataSource.dispose);
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 0,
            totalFocusSeconds: 0,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: taskDataSource,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openTasksMenuItem')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('associateTaskFocusOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('focusMinutes-15')));
    await tester.tap(find.byKey(const Key('startTaskFocusButton')));
    await tester.pumpAndSettle();

    expect(taskDataSource.task.focusMinutes, 15);
    expect(taskDataSource.task.isCompleted, isFalse);
    expect(
      find.textContaining('Concentración preparada para “Escribir informe”'),
      findsOneWidget,
    );
  });
}

class _SeededTaskLocalDataSource implements TaskLocalDataSource {
  final _changes = StreamController<List<TaskModel>>.broadcast();
  TaskModel task = TaskModel(
    id: 1,
    title: 'Escribir informe',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 10),
    updatedAt: DateTime(2026, 8, 10),
  );

  @override
  Stream<List<TaskModel>> watchAll() async* {
    yield [task];
    yield* _changes.stream;
  }

  @override
  Future<void> setFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) async {
    task = TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: task.isCompleted,
      dueDate: task.dueDate,
      focusMinutes: focusMinutes,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
    _changes.add([task]);
  }

  @override
  Future<void> setCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {
    task = TaskModel(
      id: task.id,
      title: task.title,
      isCompleted: isCompleted,
      dueDate: task.dueDate,
      focusMinutes: task.focusMinutes,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
    _changes.add([task]);
  }

  @override
  Future<int> create({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) async => 2;

  @override
  Future<void> update({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) async {}

  @override
  Future<void> delete(int id) async {}

  Future<void> dispose() => _changes.close();
}

class _EmptyTaskLocalDataSource implements TaskLocalDataSource {
  @override
  Stream<List<TaskModel>> watchAll() => Stream.value(const []);

  @override
  Future<int> create({
    required String title,
    required DateTime? dueDate,
    required DateTime createdAt,
  }) async => 1;

  @override
  Future<void> update({
    required int id,
    required String title,
    required DateTime? dueDate,
    required DateTime updatedAt,
  }) async {}

  @override
  Future<void> setCompleted({
    required int id,
    required bool isCompleted,
    required DateTime updatedAt,
  }) async {}

  @override
  Future<void> setFocusMinutes({
    required int id,
    required int focusMinutes,
    required DateTime updatedAt,
  }) async {}

  @override
  Future<void> delete(int id) async {}
}

class _NoopFocusCompletionAdService implements FocusCompletionAdService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> showAfterFocusCompletion() async {}

  @override
  Future<void> dispose() async {}
}

class _MemoryTimerLocalDataSource implements TimerLocalDataSource {
  _MemoryTimerLocalDataSource({ProgressModel? progress})
    : _progress =
          progress ??
          const ProgressModel(
            gems: 0,
            totalFocusSeconds: 0,
            profileName: 'NOMBRE',
          );

  ProgressModel _progress;

  @override
  Future<ProgressModel> load() async => _progress;

  @override
  Future<void> save(ProgressModel progress) async {
    _progress = progress;
  }

  @override
  Future<void> clear() async {
    _progress = const ProgressModel(
      gems: 0,
      totalFocusSeconds: 0,
      profileName: 'NOMBRE',
    );
  }
}

class _NoopNotificationService implements TimerNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> cancelTimerNotifications() async {}

  @override
  Future<void> showRunningTimer({
    required String timerName,
    required int remainingSeconds,
    required DateTime endsAt,
    required String completionTitle,
    required String completionBody,
  }) async {}

  @override
  Future<void> showTimerCompleted({
    required String title,
    required String body,
  }) async {}
}
