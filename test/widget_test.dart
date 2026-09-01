import 'dart:async';

import 'package:atomic_task/app.dart';
import 'package:atomic_task/core/theme/app_colors.dart';
import 'package:atomic_task/features/home/presentation/pages/home_shell_page.dart';
import 'package:atomic_task/features/home/presentation/widgets/home_app_bar.dart';
import 'package:atomic_task/features/tasks/data/datasources/task_local_data_source.dart';
import 'package:atomic_task/features/tasks/data/models/task_model.dart';
import 'package:atomic_task/features/timer/data/datasources/timer_local_data_source.dart';
import 'package:atomic_task/features/timer/data/models/progress_model.dart';
import 'package:atomic_task/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:atomic_task/features/timer/domain/entities/timer_mode.dart';
import 'package:atomic_task/features/timer/domain/entities/timer_session.dart';
import 'package:atomic_task/features/timer/domain/repositories/timer_session_repository.dart';
import 'package:atomic_task/features/timer/domain/services/focus_completion_ad_service.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:atomic_task/features/timer/domain/usecases/clear_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/load_progress.dart';
import 'package:atomic_task/features/timer/domain/usecases/save_progress.dart';
import 'package:atomic_task/features/timer/presentation/controllers/timer_controller.dart';
import 'package:atomic_task/features/timer/presentation/pages/timer_page.dart';
import 'package:atomic_task/features/timer/presentation/widgets/focus_completion_summary_sheet.dart';
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
      final focusTime = tester.getRect(find.byKey(const Key('focusTimeStat')));
      final gems = tester.getRect(find.byKey(const Key('gemsStat')));

      expect(menu.right, lessThanOrEqualTo(title.left));
      expect(title.right, lessThanOrEqualTo(profile.left));
      expect(profile.top, lessThan(title.bottom));
      expect(profile.bottom, greaterThan(title.top));
      expect(profile.left, lessThan(name.left));
      expect(profile.right, greaterThan(name.right));
      expect(profile.bottom, lessThanOrEqualTo(focusTime.top));
      expect(focusTime.right, lessThanOrEqualTo(gems.left));
      expect(focusTime.height, 48);
      expect(gems.height, 48);
      expect(focusTime.width, greaterThanOrEqualTo(48));
      expect(gems.width, greaterThanOrEqualTo(48));
      expect(profile.width, lessThanOrEqualTo(148.1));
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
    expect(profile.width, lessThanOrEqualTo(148.1));
    expect(title.width, greaterThan(0));
    expect(title.right, lessThanOrEqualTo(profile.left));
    expect(title.right, lessThanOrEqualTo(firstRow.right));
    expect(firstRow.contains(profile.center), isTrue);
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

  testWidgets('uses colored metric capsules with accessible tap targets', (
    tester,
  ) async {
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 9999,
            totalFocusSeconds: 3596400,
            profileName: 'Nombre de dieciocho',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    final focusFinder = find.byKey(const Key('focusTimeStat'));
    final gemsFinder = find.byKey(const Key('gemsStat'));
    final focusMaterial = tester.widget<Material>(
      find.descendant(of: focusFinder, matching: find.byType(Material)).first,
    );
    final gemsMaterial = tester.widget<Material>(
      find.descendant(of: gemsFinder, matching: find.byType(Material)).first,
    );
    final focusSemantics = tester.widget<Semantics>(
      find.descendant(of: focusFinder, matching: find.byType(Semantics)).first,
    );
    final gemsSemantics = tester.widget<Semantics>(
      find.descendant(of: gemsFinder, matching: find.byType(Semantics)).first,
    );

    expect(focusMaterial.color, AppColors.focusAccentSoft);
    expect(gemsMaterial.color, AppColors.primarySoft);
    expect(tester.getSize(focusFinder).height, 48);
    expect(tester.getSize(gemsFinder).height, 48);
    expect(focusSemantics.properties.button, isTrue);
    expect(
      focusSemantics.properties.label,
      'Tiempo de concentración: 999h 0m. Mostrar detalle',
    );
    expect(gemsSemantics.properties.button, isTrue);
    expect(gemsSemantics.properties.label, 'Gemas: 9999. Mostrar detalle');
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens progress details and keeps their values live', (
    tester,
  ) async {
    final dataSource = _MemoryTimerLocalDataSource(
      progress: const ProgressModel(
        gems: 7,
        totalFocusSeconds: 1200,
        profileName: 'Javier',
      ),
    );
    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: dataSource,
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
      ),
    );
    await tester.pumpAndSettle();

    final controller = tester
        .widget<HomeShellPage>(find.byType(HomeShellPage))
        .timerController;

    await tester.tap(find.byKey(const Key('focusTimeStat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focusTimeDetailSheet')), findsOneWidget);
    expect(find.byKey(const Key('gemsDetailSheet')), findsNothing);
    expect(find.text('Tiempo de concentración'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('progressDetailValue'))).data,
      '20 min',
    );
    expect(
      find.textContaining('Las pausas y los descansos no cuentan.'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const Key('focusTimeDetailSheet'))).width,
      lessThanOrEqualTo(480),
    );

    dataSource._progress = const ProgressModel(
      gems: 12,
      totalFocusSeconds: 5400,
      profileName: 'Javier',
    );
    await controller.initialize();
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('progressDetailValue'))).data,
      '1 h 30 min',
    );

    await tester.tap(find.byKey(const Key('closeProgressDetailButton')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focusTimeDetailSheet')), findsNothing);
    expect(find.text('1h 30m'), findsOneWidget);

    await tester.tap(find.byKey(const Key('gemsStat')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('gemsDetailSheet')), findsOneWidget);
    expect(find.byKey(const Key('focusTimeDetailSheet')), findsNothing);
    expect(find.text('Gemas disponibles'), findsOneWidget);
    expect(
      tester.widget<Text>(find.byKey(const Key('progressDetailValue'))).data,
      '12',
    );
    expect(
      find.textContaining('Cada minuto completo de descanso consume 1 gema.'),
      findsOneWidget,
    );

    dataSource._progress = const ProgressModel(
      gems: 15,
      totalFocusSeconds: 5400,
      profileName: 'Javier',
    );
    await controller.initialize();
    await tester.pump();
    expect(
      tester.widget<Text>(find.byKey(const Key('progressDetailValue'))).data,
      '15',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows and consumes a persisted focus completion panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final sessions = _MemoryTimerSessionRepository(
      pendingSummary: CompletionSummary(
        sessionId: 'focus-summary-1',
        mode: TimerMode.focus,
        completedSeconds: 1500,
        gemDelta: 8,
        completedAt: DateTime(2026, 8, 15, 10, 25),
        taskId: 4,
        taskTitle: 'Preparar propuesta',
        inAppPending: true,
        notificationPending: false,
        adPending: false,
        taskCompletionPending: false,
        completedWhileAppWasAway: true,
        awaySecondsAfterCompletion: 444,
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: AtomicTimerBootstrap(
          notificationService: _NoopNotificationService(),
          focusCompletionAdService: _NoopFocusCompletionAdService(),
          localDataSource: _MemoryTimerLocalDataSource(
            progress: const ProgressModel(
              gems: 8,
              totalFocusSeconds: 1500,
              profileName: 'Javier',
            ),
          ),
          taskLocalDataSource: _EmptyTaskLocalDataSource(),
          sessionRepository: sessions,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('focusCompletionSummarySheet')),
      findsOneWidget,
    );
    expect(find.text('Resumen de la sesión'), findsOneWidget);
    expect(find.text('Gemas generadas'), findsOneWidget);
    expect(find.text('+8'), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    expect(find.text('Tarea finalizada'), findsOneWidget);
    expect(find.text('Preparar propuesta'), findsOneWidget);
    expect(find.text('Tiempo fuera'), findsOneWidget);
    expect(find.text('7 min 24 s'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(
      find.byKey(const Key('closeFocusCompletionSummaryButton')),
    );
    await tester.tap(
      find.byKey(const Key('closeFocusCompletionSummaryButton')),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byKey(const Key('focusCompletionSummarySheet')), findsNothing);
    expect(sessions.pendingSummary, isNull);
  });

  testWidgets('keeps the floating summary for completed rest sessions', (
    tester,
  ) async {
    final sessions = _MemoryTimerSessionRepository(
      pendingSummary: CompletionSummary(
        sessionId: 'rest-summary-1',
        mode: TimerMode.rest,
        completedSeconds: 300,
        gemDelta: -5,
        completedAt: DateTime(2026, 8, 15, 10, 30),
        inAppPending: true,
        notificationPending: false,
      ),
    );

    await tester.pumpWidget(
      AtomicTimerBootstrap(
        notificationService: _NoopNotificationService(),
        focusCompletionAdService: _NoopFocusCompletionAdService(),
        localDataSource: _MemoryTimerLocalDataSource(
          progress: const ProgressModel(
            gems: 3,
            totalFocusSeconds: 1500,
            profileName: 'Javier',
          ),
        ),
        taskLocalDataSource: _EmptyTaskLocalDataSource(),
        sessionRepository: sessions,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Descanso completado'), findsOneWidget);
    expect(find.textContaining('5 min de descanso · −5 gemas'), findsOneWidget);
    expect(find.byKey(const Key('focusCompletionSummarySheet')), findsNothing);
    expect(sessions.pendingSummary, isNull);
  });

  testWidgets('completion panel omits optional rows and fits landscape', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(568, 320);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: Scaffold(
            body: FocusCompletionSummarySheet(
              gemsGenerated: 0,
              completedSeconds: 60,
              onClose: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('+0'), findsOneWidget);
    expect(find.text('1 min'), findsOneWidget);
    expect(find.byKey(const Key('completionSummaryTask')), findsNothing);
    expect(find.byKey(const Key('completionSummaryAwayTime')), findsNothing);
    await tester.ensureVisible(
      find.byKey(const Key('closeFocusCompletionSummaryButton')),
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
    expect(find.byKey(const Key('settingsView')), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsNothing);
    expect(find.byKey(const Key('profileButton')), findsNothing);
    expect(find.byKey(const Key('focusTimeStat')), findsNothing);
    expect(find.byKey(const Key('gemsStat')), findsNothing);
    expect(find.byKey(const Key('homeMenuButton')), findsOneWidget);
    expect(find.byKey(const Key('homeTitle')), findsOneWidget);
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
                showUserSummary: true,
                profileName: 'Nombre muy extenso',
                totalFocusSeconds: 3600,
                gems: 999,
                onMenuPressed: () => menuCalls += 1,
                onProfilePressed: () => profileCalls += 1,
                onFocusTimePressed: () {},
                onGemsPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final widget = tester.widget<Text>(find.byKey(const Key('homeTitle')));
      final titleRect = tester.getRect(find.byKey(const Key('homeTitle')));
      final profileRect = tester.getRect(find.byKey(const Key('profileCard')));
      expect(widget.data, title);
      expect(widget.overflow, isNot(TextOverflow.ellipsis));
      expect(titleRect.right, lessThanOrEqualTo(profileRect.left));
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

  testWidgets('keeps profile beside the title across the header breakpoint', (
    tester,
  ) async {
    for (final width in [519.0, 520.0]) {
      tester.view.physicalSize = Size(width, 640);
      tester.view.devicePixelRatio = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: Scaffold(
              body: HomeAppBar(
                title: 'Concentración',
                showUserSummary: true,
                profileName: 'Nombre de dieciocho',
                totalFocusSeconds: 3600,
                gems: 999,
                onMenuPressed: () {},
                onProfilePressed: () {},
                onFocusTimePressed: () {},
                onGemsPressed: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final title = tester.getRect(find.byKey(const Key('homeTitle')));
      final profile = tester.getRect(find.byKey(const Key('profileCard')));
      final metrics = tester.getRect(find.byKey(const Key('focusTimeStat')));
      expect(title.right, lessThanOrEqualTo(profile.left));
      expect(profile.top, lessThan(title.bottom));
      expect(profile.bottom, greaterThan(title.top));
      expect(profile.bottom, lessThanOrEqualTo(metrics.top));
      expect(
        find.byKey(Key(width < 520 ? 'compactHomeHeader' : 'wideHomeHeader')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

  testWidgets('compact reset is red and always confirms cancellation', (
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
    final controller = tester
        .widget<HomeShellPage>(find.byType(HomeShellPage))
        .timerController;

    await tester.tap(find.byKey(const Key('focusTab')));
    await tester.pumpAndSettle();

    IconButton resetButton() =>
        tester.widget<IconButton>(find.byKey(const Key('resetTimerButton')));

    expect(resetButton().onPressed, isNull);
    expect(
      resetButton().style?.backgroundColor?.resolve({WidgetState.disabled}),
      isNot(AppColors.destructive),
    );

    await tester.tap(find.text('INICIAR'));
    await tester.pump();
    expect(controller.isRunning, isTrue);
    expect(resetButton().onPressed, isNotNull);
    expect(
      resetButton().style?.backgroundColor?.resolve({}),
      AppColors.destructive,
    );
    expect(resetButton().style?.foregroundColor?.resolve({}), Colors.white);

    await tester.tap(find.byKey(const Key('resetTimerButton')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('cancelTimerConfirmationDialog')),
      findsOneWidget,
    );
    expect(find.text('Cancelar temporizador'), findsOneWidget);
    expect(find.byKey(const Key('keepTimerButton')), findsOneWidget);
    expect(find.byKey(const Key('confirmCancelTimerButton')), findsOneWidget);
    expect(
      find.text(
        '¿Estás seguro de que quieres cancelar el temporizador actual? '
        'Se perderá el progreso de esta sesión.',
      ),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('cancelTimerConfirmationDialog')),
      findsNothing,
    );
    expect(controller.isRunning, isTrue);

    await tester.tap(find.byKey(const Key('resetTimerButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmCancelTimerButton')));
    await tester.pumpAndSettle();

    expect(controller.controlsLocked, isFalse);
    expect(resetButton().onPressed, isNull);
    expect(find.text('INICIAR'), findsOneWidget);
  });

  testWidgets('wide reset shares the enabled style and confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(820, 1180);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var now = DateTime(2026, 8, 15, 10);
    final controller = await _buildInitializedTimerController(now: () => now);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FocusView(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    OutlinedButton resetButton() => tester.widget<OutlinedButton>(
      find.byKey(const Key('resetTimerButton')),
    );

    expect(resetButton().onPressed, isNull);
    await tester.tap(find.text('INICIAR'));
    await tester.pump();
    expect(resetButton().onPressed, isNotNull);
    expect(
      resetButton().style?.backgroundColor?.resolve({}),
      AppColors.destructive,
    );
    expect(resetButton().style?.foregroundColor?.resolve({}), Colors.white);

    now = now.add(const Duration(seconds: 1));
    controller.syncWithClock();
    controller.pause();
    await tester.pump();
    expect(controller.isRunning, isFalse);
    expect(controller.controlsLocked, isTrue);
    expect(find.text('CONTINUAR'), findsOneWidget);
    expect(
      resetButton().style?.backgroundColor?.resolve({}),
      AppColors.destructive,
    );

    await tester.tap(find.byKey(const Key('resetTimerButton')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('cancelTimerConfirmationDialog')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('keepTimerButton')));
    await tester.pumpAndSettle();
    expect(controller.isRunning, isFalse);
    expect(controller.controlsLocked, isTrue);
    expect(find.text('Reiniciar temporizador'), findsOneWidget);
    controller.resetTimer();
  });

  testWidgets('does not reset a session completed behind the dialog', (
    tester,
  ) async {
    var now = DateTime(2026, 8, 15, 10);
    final controller = await _buildInitializedTimerController(now: () => now);
    addTearDown(controller.dispose);
    controller.setMinutes(1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: FocusView(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('INICIAR'));
    await tester.pump();
    await tester.tap(find.byKey(const Key('resetTimerButton')));
    await tester.pumpAndSettle();

    now = now.add(const Duration(minutes: 1));
    controller.syncWithClock();
    await tester.pumpAndSettle();
    expect(controller.sessionCompleted, isTrue);
    expect(controller.controlsLocked, isFalse);
    expect(controller.remainingSeconds, 0);

    await tester.tap(find.byKey(const Key('confirmCancelTimerButton')));
    await tester.pumpAndSettle();

    expect(controller.sessionCompleted, isTrue);
    expect(controller.remainingSeconds, 0);
    expect(
      tester
          .widget<OutlinedButton>(find.byKey(const Key('resetTimerButton')))
          .onPressed,
      isNull,
    );
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
    expect(
      tester
          .widget<IconButton>(find.byKey(const Key('resetTimerButton')))
          .onPressed,
      isNull,
    );
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
    expect(find.byKey(const Key('sidebarAlarmDestination')), findsOneWidget);
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
    expect(find.byKey(const Key('homeBottomNavigation')), findsNothing);
    expect(find.byKey(const Key('profileButton')), findsNothing);
    expect(find.byKey(const Key('focusTimeStat')), findsNothing);
    expect(find.byKey(const Key('gemsStat')), findsNothing);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarAlarmDestination')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('alarmView')), findsOneWidget);
    expect(find.text('Alarma'), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsNothing);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarStatisticsDestination')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('statisticsView')), findsOneWidget);
    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsNothing);
    expect(find.byKey(const Key('profileButton')), findsNothing);
    expect(find.byKey(const Key('focusTimeStat')), findsNothing);
    expect(find.byKey(const Key('gemsStat')), findsNothing);

    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarTasksDestination')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('taskList')), findsOneWidget);
    expect(find.byKey(const Key('homeBottomNavigation')), findsOneWidget);
    expect(find.byKey(const Key('profileButton')), findsOneWidget);
    expect(find.byKey(const Key('focusTimeStat')), findsOneWidget);
    expect(find.byKey(const Key('gemsStat')), findsOneWidget);

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
    await tester.tap(find.byKey(const Key('homeMenuButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('sidebarTasksDestination')));
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

Future<TimerController> _buildInitializedTimerController({
  DateTime Function()? now,
}) async {
  final repository = TimerRepositoryImpl(
    _MemoryTimerLocalDataSource(
      progress: const ProgressModel(
        gems: 0,
        totalFocusSeconds: 0,
        profileName: 'Javier',
      ),
    ),
  );
  final controller = TimerController(
    loadProgress: LoadProgress(repository),
    saveProgress: SaveProgress(repository),
    clearProgress: ClearProgress(repository),
    notificationService: _NoopNotificationService(),
    focusCompletionAdService: _NoopFocusCompletionAdService(),
    now: now,
  );
  await controller.initialize();
  return controller;
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

class _MemoryTimerSessionRepository implements TimerSessionRepository {
  _MemoryTimerSessionRepository({this.pendingSummary});

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
