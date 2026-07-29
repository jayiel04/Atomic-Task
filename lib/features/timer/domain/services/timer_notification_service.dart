abstract interface class TimerNotificationService {
  Future<void> initialize();

  Future<void> showRunningTimer({
    required String timerName,
    required int remainingSeconds,
    required DateTime endsAt,
    required String completionTitle,
    required String completionBody,
  });

  Future<void> cancelTimerNotifications();

  Future<void> showTimerCompleted({
    required String title,
    required String body,
  });
}
