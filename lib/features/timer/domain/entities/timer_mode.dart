import '../../../../core/constants/timer_constants.dart';

enum TimerMode {
  focus,
  rest;

  int get defaultMinutes {
    return switch (this) {
      TimerMode.focus => TimerConstants.defaultFocusMinutes,
      TimerMode.rest => TimerConstants.defaultRestMinutes,
    };
  }

  String get title {
    return switch (this) {
      TimerMode.focus => 'CONCENTRACIÓN',
      TimerMode.rest => 'DESCANSO',
    };
  }
}
