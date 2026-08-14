import 'dart:io';
import 'dart:ui' as ui;

import 'package:atomic_task/core/theme/app_theme.dart';
import 'package:atomic_task/features/home/presentation/pages/statistics_view.dart';
import 'package:atomic_task/features/tasks/domain/entities/atomic_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/assign_task_focus.dart';
import 'package:atomic_task/features/tasks/domain/usecases/create_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/delete_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/toggle_task_completion.dart';
import 'package:atomic_task/features/tasks/domain/usecases/update_task.dart';
import 'package:atomic_task/features/tasks/domain/usecases/watch_tasks.dart';
import 'package:atomic_task/features/tasks/presentation/controllers/task_controller.dart';
import 'package:atomic_task/features/tasks/presentation/pages/task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'task_test_support.dart';

const _profiles = <String, Size>{
  'iphone-se': Size(320, 568),
  'android-compact': Size(360, 640),
  'iphone-14': Size(390, 844),
  'pixel-7': Size(412, 915),
  'iphone-15-pro-max': Size(430, 932),
  'compact-landscape': Size(568, 320),
  'android-large-landscape': Size(915, 412),
};

void main() {
  for (final profile in _profiles.entries) {
    testWidgets('task view is responsive on ${profile.key}', (tester) async {
      _configureView(tester, profile.value);
      final repository = MemoryTaskRepository(initialTasks: _mixedTasks());
      addTearDown(repository.dispose);
      final controller = _buildController(repository)..initialize();
      addTearDown(controller.dispose);
      repository.emit();
      final captureKey = GlobalKey();

      await tester.pumpWidget(
        _ResponsiveTestApp(controller: controller, captureKey: captureKey),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await _expandTaskGroup(tester, 'Atrasadas');
      final screen = Offset.zero & profile.value;
      expect(
        screen.contains(
          tester.getRect(find.byKey(const Key('createTaskButton'))).center,
        ),
        isTrue,
      );
      expect(
        tester.getSize(find.byKey(const Key('createTaskButton'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(
        tester.getSize(find.byKey(const Key('taskToggle-1'))).height,
        greaterThanOrEqualTo(48),
      );

      await _capture(tester, captureKey, '${profile.key}_mixed');

      await tester.tap(find.text('Atrasadas'));
      await tester.pumpAndSettle();
      await _expandTaskGroup(tester, 'Sin fecha');
      await tester.scrollUntilVisible(
        find.byKey(const Key('taskToggle-7')),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('taskList')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('taskToggle-7')), findsOneWidget);
      expect(find.byKey(const Key('taskToggle-8')), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  for (final profileName in ['iphone-se', 'compact-landscape']) {
    testWidgets('statistics history is responsive on $profileName', (
      tester,
    ) async {
      _configureView(tester, _profiles[profileName]!);
      final repository = MemoryTaskRepository(initialTasks: _mixedTasks());
      addTearDown(repository.dispose);
      final controller = _buildController(repository)..initialize();
      addTearDown(controller.dispose);
      repository.emit();

      await tester.pumpWidget(_StatisticsTestApp(controller: controller));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('statisticsView')), findsOneWidget);
      await tester.scrollUntilVisible(
        find.byKey(const Key('completedTasksSection')),
        180,
        scrollable: find.descendant(
          of: find.byKey(const Key('statisticsView')),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('completedTasksSection')), findsOneWidget);
      await tester.ensureVisible(find.byKey(const Key('taskToggle-8')));
      expect(
        tester.getSize(find.byKey(const Key('taskToggle-8'))).height,
        greaterThanOrEqualTo(48),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('captures empty and task form states', (tester) async {
    _configureView(tester, _profiles['iphone-14']!);
    final repository = MemoryTaskRepository();
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    final captureKey = GlobalKey();

    await tester.pumpWidget(
      _ResponsiveTestApp(controller: controller, captureKey: captureKey),
    );
    await tester.pumpAndSettle();
    await _capture(tester, captureKey, 'iphone-14_empty');

    await tester.tap(find.byKey(const Key('createTaskButton')));
    await tester.pumpAndSettle();
    await _capture(tester, captureKey, 'iphone-14_create-form');
    await tester.tap(find.byKey(const Key('saveTaskButton')));
    await tester.pumpAndSettle();
    expect(find.text('Escribe un título para la tarea'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, captureKey, 'iphone-14_form-error');
  });

  testWidgets('captures completion and duration choices', (tester) async {
    _configureView(tester, _profiles['android-compact']!);
    final repository = MemoryTaskRepository(
      initialTasks: _mixedTasks().take(1).toList(),
    );
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    final captureKey = GlobalKey();

    await tester.pumpWidget(
      _ResponsiveTestApp(controller: controller, captureKey: captureKey),
    );
    await tester.pumpAndSettle();
    await _expandTaskGroup(tester, 'Atrasadas');
    await tester.tap(find.byKey(const Key('taskToggle-1')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _capture(tester, captureKey, 'android-compact_completion-choice');

    await tester.tap(find.byKey(const Key('associateTaskFocusOption')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focusMinutesSlider')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _capture(tester, captureKey, 'android-compact_focus-duration');
  });

  testWidgets('supports enlarged text and safe areas', (tester) async {
    _configureView(tester, _profiles['iphone-15-pro-max']!);
    final repository = MemoryTaskRepository(initialTasks: _mixedTasks());
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    final captureKey = GlobalKey();

    await tester.pumpWidget(
      _ResponsiveTestApp(
        controller: controller,
        captureKey: captureKey,
        textScale: 1.3,
        padding: const EdgeInsets.only(top: 47, bottom: 34),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await _capture(tester, captureKey, 'iphone-15-pro-max_text-1.3-safe-area');
  });

  testWidgets('task form remains usable above a simulated keyboard', (
    tester,
  ) async {
    _configureView(tester, _profiles['pixel-7']!);
    final repository = MemoryTaskRepository(
      initialTasks: _mixedTasks().take(1).toList(),
    );
    addTearDown(repository.dispose);
    final controller = _buildController(repository)..initialize();
    addTearDown(controller.dispose);
    repository.emit();
    final captureKey = GlobalKey();

    await tester.pumpWidget(
      _ResponsiveTestApp(
        controller: controller,
        captureKey: captureKey,
        viewInsets: const EdgeInsets.only(bottom: 260),
      ),
    );
    await tester.pumpAndSettle();
    await _expandTaskGroup(tester, 'Atrasadas');
    await tester.tap(find.byKey(const Key('editTask-1')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('saveTaskButton')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('saveTaskButton')));
    expect(tester.takeException(), isNull);
    await _capture(tester, captureKey, 'pixel-7_edit-with-keyboard');
  });
}

Future<void> _expandTaskGroup(WidgetTester tester, String label) async {
  await tester.scrollUntilVisible(
    find.text(label),
    180,
    scrollable: find.descendant(
      of: find.byKey(const Key('taskList')),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.ensureVisible(find.text(label));
  await tester.pumpAndSettle();
  await tester.tap(find.text(label));
  await tester.pumpAndSettle();
}

void _configureView(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

TaskController _buildController(MemoryTaskRepository repository) {
  return TaskController(
    WatchTasks(repository),
    CreateTask(repository),
    UpdateTask(repository),
    ToggleTaskCompletion(repository),
    DeleteTask(repository),
    AssignTaskFocus(repository),
  );
}

List<AtomicTask> _mixedTasks() {
  final createdAt = DateTime(2026, 1, 1);
  return [
    AtomicTask(
      id: 1,
      title: 'Preparar propuesta para el cliente',
      isCompleted: false,
      dueDate: DateTime(2020, 1, 1),
      focusMinutes: 25,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
    AtomicTask(
      id: 2,
      title:
          'Revisar métricas semanales y documentar los próximos pasos del equipo',
      isCompleted: false,
      dueDate: DateTime(2030, 1, 1),
      focusMinutes: 45,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
    AtomicTask(
      id: 3,
      title: 'Responder mensajes importantes',
      isCompleted: false,
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
    for (var id = 4; id <= 7; id++)
      AtomicTask(
        id: id,
        title: 'Tarea pendiente número $id con información adicional',
        isCompleted: false,
        createdAt: createdAt.add(Duration(minutes: id)),
        updatedAt: createdAt,
      ),
    AtomicTask(
      id: 8,
      title: 'Organizar archivos del proyecto',
      isCompleted: true,
      focusMinutes: 15,
      completedAt: DateTime(2026, 8, 14, 8),
      createdAt: createdAt,
      updatedAt: createdAt,
    ),
  ];
}

class _StatisticsTestApp extends StatelessWidget {
  const _StatisticsTestApp({required this.controller});

  final TaskController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: StatisticsView(
          totalFocusSeconds: 7200,
          gems: 8,
          controller: controller,
        ),
      ),
    );
  }
}

Future<void> _capture(
  WidgetTester tester,
  GlobalKey captureKey,
  String name,
) async {
  final outputPath = Platform.environment['TASK_SCREENSHOT_DIR'];
  if (outputPath == null || outputPath.isEmpty) {
    return;
  }

  await tester.runAsync(() async {
    final boundary =
        captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory(outputPath);
    await directory.create(recursive: true);
    await File(
      '${directory.path}/$name.png',
    ).writeAsBytes(data!.buffer.asUint8List());
  });
}

class _ResponsiveTestApp extends StatelessWidget {
  const _ResponsiveTestApp({
    required this.controller,
    required this.captureKey,
    this.textScale = 1,
    this.padding = EdgeInsets.zero,
    this.viewInsets = EdgeInsets.zero,
  });

  final TaskController controller;
  final GlobalKey captureKey;
  final double textScale;
  final EdgeInsets padding;
  final EdgeInsets viewInsets;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        return RepaintBoundary(
          key: captureKey,
          child: MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(textScale),
              padding: padding,
              viewPadding: padding,
              viewInsets: viewInsets,
            ),
            child: child!,
          ),
        );
      },
      home: TaskPage(
        controller: controller,
        onStartFocus: (_, _) async => true,
      ),
    );
  }
}
