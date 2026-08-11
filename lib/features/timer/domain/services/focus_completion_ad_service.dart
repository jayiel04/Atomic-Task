abstract interface class FocusCompletionAdService {
  Future<void> initialize();

  Future<void> showAfterFocusCompletion();

  Future<void> dispose();
}
