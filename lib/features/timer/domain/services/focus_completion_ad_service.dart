enum FocusCompletionAdResult { shown, retry, unsupported }

abstract interface class FocusCompletionAdService {
  Future<void> initialize();

  Future<void> showAfterFocusCompletion();

  Future<FocusCompletionAdResult> showAfterFocusCompletionResult();

  Future<void> dispose();
}
