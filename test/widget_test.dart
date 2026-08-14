import 'dart:async';

import 'package:atomic_task/app.dart';
import 'package:atomic_task/features/home/presentation/widgets/home_app_bar.dart';
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
    const Size(430, 932),
    const Size(820, 1180),
    const Size(568, 320),
    const Size(915, 412),
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
      expect(find.byKey(const Key('tasksTab')), findsOneWidget);
      expect(find.byKey(const Key('homeBottomNavigation')), findsOneWidget);

      await tester.tap(find.byKey(const Key('focusTab')));
      await tester.pumpAndSettle();
      expect(find.text('INICIAR'), findsOneWidget);
      expect(find.byKey(const Key('resetTimerButton')), findsOneWidget);
      expect(
        tester.getBottomRight(find.byKey(const Key('resetTimerButton'))).dy,
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
      'Sebastian',
    );
    await tester.tap(find.byKey(const Key('saveFirstLaunchName')));
    await tester.pumpAndSettle();

    expect(find.text('\u00a1Bienvenido!'), findsNothing);
    expect(find.text('Sebastian'), findsOneWidget);
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

  testWidgets('keeps the compact shared header geometry on both tabs', (
    tester,
  ) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: AtomicTimerBootstrap(
          notificationService: _NoopNotificationService(),
          focusCompletionAdService: _NoopFocusCompletionAdService(),
          localDataSource: _MemoryTimerLocalDataSource(
            progress: const ProgressModel(
              gems: 7,
              totalFocusSeconds: 1200,
              profileName: 'Javier',
            ),
          ),
          taskLocalDataSource: _EmptyTaskLocalDataSource(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    void verifyHeader() {
      final menu = tester.getRect(find.byKey(const Key('homeMenuButton')));
      final title = tester.getRect(find.byKey(const Key('homeTitle')));
      final profile = tester.getRect(find.byKey(const Key('profileCard')));
      final name = tester.getRect(find.byKey(const Key('profileName')));
      final stats = tester.getRect(find.byKey(const Key('focusTimeStat')));

      expect(menu.right, lessThanOrEqualTo(title.left));
      expect(profile.left, lessThan(name.left));
      expect(profile.right, greaterThan(name.right));
      expect(profile.bottom, lessThanOrEqualTo(stats.top));
      expect(profile.width, lessThanOrEqualTo(148));
      expect(title.right, lessThanOrEqualTo(profile.left));
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      expect(find.byIcon(Icons.schedule_rounded), findsOneWidget);
      expect(find.byIcon(Icons.diamond_rounded), findsOneWidget);
      expect(find.text('Javier'), findsOneWidget);
      expect(find.text('20m'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
    }

    verifyHeader();
    await tester.tap(find.byKey(const Key('focusTab')));
    await tester.pumpAndSettle();
    verifyHeader();
  });

  testWidgets('header and sidebar fit at 320 px with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: AtomicTimerBootstrap(
          notificationService: _NoopNotificationService(),
          focusCompletionAdService: _NoopFocusCompletionAdService(),
          localDataSource: _MemoryTimerLocalDataSource(
            progress: const ProgressModel(
              gems: 9999,
              totalFocusSeconds: 3596400,
              profileName: 'Sebastian',
            ),
          ),
          taskLocalDataSource: _EmptyTaskLocalDataSource(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const Key('homeMenuButton'))),
      const Size(48, 48),
    );
    final title = tester.getRect(find.byKey(const Key('homeTitle')));
    final profile = tester.getRect(find.byKey(const Key('profileCard')));
    final firstRow = tester.getRect(
      find.byKey(const Key('compactHomeHeaderFirstRow')),
    );
    final summary = tester.getRect(
      find.byKey(const Key('compactHomeHeaderSummary')),
    );
    expect(profile.width, lessThanOrEqualTo(148));
    expect(title.width, greaterThan(0));
    expect(title.right, lessThanOrEqualTo(firstRow.right));
    expect(firstRow.bottom, lessThanOrEqualTo(summary.top));
    expect(find.text('Sebastian'), findsOneWidget);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    expect(
      tester
          .getBottomRight(find.byKey(const Key('resetProgressSidebarButton')))
          .dy,
      lessThanOrEqualTo(568),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses a centered floating footer with semantic selection', (
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

    final exterior = tester.getRect(
      find.byKey(const Key('homeBottomNavigation')),
    );
    final surface = tester.getRect(
      find.byKey(const Key('homeBottomNavigationSurface')),
    );
    expect(surface.width, lessThanOrEqualTo(460));
    expect(surface.width, lessThan(exterior.width));
    expect(surface.center.dx, closeTo(exterior.center.dx, 0.1));
    expect(tester.getSize(find.byKey(const Key('tasksTab'))).height, 48);
    expect(tester.getSize(find.byKey(const Key('focusTab'))).height, 48);
    expect(find.text('Tareas'), findsWidgets);
    expect(find.text('Concentración'), findsOneWidget);

    Semantics taskSemantics() => tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const Key('tasksTab')),
            matching: find.byType(Semantics),
          )
          .first,
    );
    Semantics focusSemantics() => tester.widget<Semantics>(
      find
          .descendant(
            of: find.byKey(const Key('focusTab')),
            matching: find.byType(Semantics),
          )
          .first,
    );

    expect(taskSemantics().properties.selected, isTrue);
    expect(focusSemantics().properties.selected, isFalse);
    await tester.tap(find.byKey(const Key('focusTab')));
    await tester.pumpAndSettle();
    expect(taskSemantics().properties.selected, isFalse);
    expect(focusSemantics().properties.selected, isTrue);

    await tester.tap(find.byKey(const Key('profileButton')));
    await tester.pumpAndSettle();
    expect(taskSemantics().properties.selected, isFalse);
    expect(focusSemantics().properties.selected, isFalse);
  });

  testWidgets('shows every compact header title without ellipsis', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var menuCalls = 0;
    var profileCalls = 0;
    for (final title in [
      'Tareas',
      'Concentración',
      'Ajustes',
      'Estadísticas',
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: HomeAppBar(
                title: title,
                profileName: 'Nombre muy extenso',
                totalFocusSeconds: 3600,
                gems: 999,
                onMenuPressed: () => menuCalls += 1,
                onProfilePressed: () => profileCalls += 1,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final widget = tester.widget<Text>(find.byKey(const Key('homeTitle')));
      expect(widget.data, title);
      expect(widget.overflow, isNot(TextOverflow.ellipsis));
      expect(find.byKey(const Key('homeTitle')), findsOneWidget);
      expect(
        find.byKey(const Key('compactHomeHeaderFirstRow')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.tap(find.byKey(const Key('profileButton')));
    expect(menuCalls, 1);
    expect(profileCalls, 1);
  });

  testWidgets('switches between tasks and focus in one home shell', (
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

    expect(find.byKey(const Key('tasksTab')), findsOneWidget);
    expect(find.byKey(const Key('createTaskButton')), findsOneWidget);

    await tester.tap(find.byKey(const Key('focusTab')));
    await tester.pumpAndSettle();
    expect(find.text('INICIAR'), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsOneWidget);

    await tester.tap(find.byKey(const Key('tasksTab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('taskList')), findsOneWidget);
    expect(find.byKey(const Key('focusTab')), findsOneWidget);
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

    expect(find.byKey(const Key('tasksTab')), findsOneWidget);
    await tester.tap(find.text('Sin fecha'));
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
    expect(find.text('TAREA ACTUAL'), findsOneWidget);
    expect(find.byKey(const Key('linkedTaskAssetIcon')), findsOneWidget);
    expect(find.text('Escribir informe'), findsWidgets);
  });

  testWidgets('opens the sidebar and selects all home views', (tester) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 8,
            totalFocusSeconds: 7200,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();

    final sidebar = find.byKey(const Key('homeSidebar'));
    expect(sidebar, findsOneWidget);
    expect(tester.getRect(sidebar).left, 0);
    expect(find.byKey(const Key('sidebarLogo')), findsOneWidget);
    expect(find.text('Atomic Task'), findsOneWidget);
    expect(find.byKey(const Key('sidebarTasksDestination')), findsOneWidget);
    expect(find.byKey(const Key('sidebarFocusDestination')), findsOneWidget);
    expect(find.byKey(const Key('sidebarSettingsDestination')), findsOneWidget);
    expect(
      find.byKey(const Key('sidebarStatisticsDestination')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('resetProgressSidebarButton')), findsOneWidget);
    expect(
      find.descendant(of: sidebar, matching: find.text('Javier')),
      findsNothing,
    );
    expect(
      find.descendant(of: sidebar, matching: find.text('2h 0m')),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('sidebarSettingsDestination')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('settingsView')), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsOneWidget);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarStatisticsDestination')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statisticsView')), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);

    await tester.tap(find.byKey(const Key('tasksTab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('taskList')), findsOneWidget);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('closeSidebarButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeSidebar')), findsNothing);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(400, 300));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeSidebar')), findsNothing);
  });

  testWidgets(
    'opens settings and limits the profile name to eighteen characters',
    (tester) async {
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

      await tester.tap(find.byKey(const Key('profileButton')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('settingsView')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('settingsNameField')),
        'Alejandro',
      );
      await tester.tap(find.byKey(const Key('saveSettingsNameButton')));
      await tester.pumpAndSettle();

      expect(find.text('Alejandro'), findsWidgets);
    },
  );

  testWidgets('shows current progress and task counts in statistics', (
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
            gems: 8,
            totalFocusSeconds: 7200,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: taskDataSource,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarStatisticsDestination')));
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const Key('totalFocusStatistic')),
        matching: find.text('2h 0m'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('gemsStatistic')),
        matching: find.text('8'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('pendingTasksStatistic')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('completedTasksStatistic')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('moves a completed task to statistics and allows restoring it', (
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

    await tester.tap(find.text('Sin fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('completeTaskNowOption')));
    await tester.pumpAndSettle();

    expect(find.text('Escribir informe'), findsNothing);
    expect(find.text('0 pendientes · 1 completada hoy'), findsOneWidget);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarStatisticsDestination')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('completedTasksSection')), findsOneWidget);
    expect(find.text('Escribir informe'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('completedTasksStatistic')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    await tester.ensureVisible(find.byKey(const Key('editTask-1')));
    await tester.tap(find.byKey(const Key('editTask-1')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('taskTitleField')),
      'Informe terminado',
    );
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Informe terminado'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('taskToggle-1')));
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();

    expect(find.text('Todavía no has completado tareas.'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('completedTasksStatistic')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('tasksTab')));
    await tester.pumpAndSettle();
    expect(find.text('Informe terminado'), findsOneWidget);
    expect(find.text('1 pendiente · 0 completadas hoy'), findsOneWidget);
  });

  testWidgets('deletes a completed task from statistics', (tester) async {
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

    await tester.tap(find.text('Sin fecha'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('completeTaskNowOption')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarStatisticsDestination')));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('deleteTask-1')));
    await tester.tap(find.byKey(const Key('deleteTask-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmDeleteTaskButton')));
    await tester.pumpAndSettle();

    expect(taskDataSource.isDeleted, isTrue);
    expect(find.text('Todavía no has completado tareas.'), findsOneWidget);
  });

  testWidgets('confirms reset and requests the profile name again', (
    tester,
  ) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 8,
            totalFocusSeconds: 7200,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('resetProgressSidebarButton')));
    await tester.pumpAndSettle();
    expect(find.text('Restablecer progreso'), findsWidgets);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('homeSidebar')), findsOneWidget);

    await tester.tap(find.byKey(const Key('resetProgressSidebarButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmResetProgressButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('firstLaunchNameField')), findsOneWidget);
    expect(find.byKey(const Key('homeSidebar')), findsNothing);
  });
}

class _SeededTaskLocalDataSource implements TaskLocalDataSource {
  final _changes = StreamController<List<TaskModel>>.broadcast();
  bool _isDeleted = false;
  TaskModel task = TaskModel(
    id: 1,
    title: 'Escribir informe',
    isCompleted: false,
    createdAt: DateTime(2026, 8, 10),
    updatedAt: DateTime(2026, 8, 10),
  );

  bool get isDeleted => _isDeleted;

  List<TaskModel> get _tasks => _isDeleted ? const [] : [task];

  @override
  Stream<List<TaskModel>> watchAll() async* {
    yield _tasks;
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
      completedAt: task.completedAt,
      occurrenceDate: task.occurrenceDate,
      recurrenceRule: task.recurrenceRule,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
    _changes.add(_tasks);
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
      completedAt: isCompleted ? updatedAt : null,
      occurrenceDate: task.occurrenceDate,
      recurrenceRule: task.recurrenceRule,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
    _changes.add(_tasks);
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
  }) async {
    task = TaskModel(
      id: task.id,
      title: title,
      isCompleted: task.isCompleted,
      dueDate: dueDate,
      focusMinutes: task.focusMinutes,
      completedAt: task.completedAt,
      occurrenceDate: task.occurrenceDate,
      recurrenceRule: task.recurrenceRule,
      createdAt: task.createdAt,
      updatedAt: updatedAt,
    );
    _changes.add(_tasks);
  }

  @override
  Future<void> delete(int id) async {
    _isDeleted = true;
    _changes.add(_tasks);
  }

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
  Future<FocusCompletionAdResult> showAfterFocusCompletionResult() async =>
      FocusCompletionAdResult.shown;

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
