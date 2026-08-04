import 'package:atomic_task/app.dart';
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
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('\u00a1Bienvenido!'), findsNothing);
    expect(find.text('Javier'), findsOneWidget);
  });
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
