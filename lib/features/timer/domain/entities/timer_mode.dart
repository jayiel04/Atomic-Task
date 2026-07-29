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

  String get notificationName {
    return switch (this) {
      TimerMode.focus => 'Concentración',
      TimerMode.rest => 'Descanso',
    };
  }

  String get completionNotificationTitle {
    return switch (this) {
      TimerMode.focus => 'Trabajo finalizado',
      TimerMode.rest => 'Descanso finalizado',
    };
  }

  String get completionNotificationBody {
    return switch (this) {
      TimerMode.focus => '¡Sesión completada! Tómate un descanso.',
      TimerMode.rest => 'El descanso terminó. ¿Listo para continuar?',
    };
  }
}
