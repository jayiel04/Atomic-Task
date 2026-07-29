import 'package:atomic_task/app.dart';
import 'package:atomic_task/features/timer/domain/services/timer_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final size in [const Size(320, 568), const Size(390, 844)]) {
    testWidgets('main view fits without scrolling at $size', (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        AtomicTimerBootstrap(notificationService: _NoopNotificationService()),
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
