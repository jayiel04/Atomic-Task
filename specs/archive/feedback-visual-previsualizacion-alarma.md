# Retroalimentación visual al previsualizar una alarma

- **Estado:** implementada
- **Área:** features/alarm (vista de Alarma) y core/audio
- **Última actualización:** 2026-08-31

## Contexto y objetivo

Hoy el botón de previsualización de cada sonido de alarma muestra siempre el
mismo ícono de play (`Icons.play_circle_outline_rounded`,
`lib/features/alarm/presentation/pages/alarm_view.dart:179`) y la fila de la
lista no refleja de ninguna forma que ese sonido se está reproduciendo. El
usuario no distingue qué alarma está sonando ni puede detener la
previsualización desde la interfaz (solo se detiene al previsualizar otra
sonido o al salir de la vista, `alarm_controller.dart:149-155`).

Objetivo observable: al tocar el botón de previsualización, el ícono pasa a
pausa y la fila del sonido que suena se pinta con el color de acento de la
aplicación; tocar de nuevo el botón (o el botón de otro sonido) detiene o
cambia la reproducción.

## Alcance y fuera de alcance

- **Incluye:**
  - Estado `previewingSound` en `AlarmController` con lógica de alternancia
    (toggle) y cambio de sonido.
  - Ícono play ↔ pausa y tooltip contextual en el botón de previsualización.
  - Fondo de color (`AppColors.primary`) en la fila del sonido que está
    sonando, con primer plano en blanco para mantener el contraste.
  - Notificación de fin de reproducción natural para restaurar el ícono de
    play sin intervención del usuario (extensión aditiva del contrato
    `AppAudioService`).
  - Pruebas unitarias (controlador), de widget (vista) y del servicio de
    audio.
- **No incluye:**
  - Cambios de esquema, migraciones ni persistencia nueva.
  - Cambios a la alarma real (avisos programados, notificaciones) ni a los
    efectos de sonido de tareas.
  - Nuevos sonidos, volumen o configuración adicional.

## Requisitos

1. `AlarmController` expone `previewingSound` (`AlarmSound?`); solo un sonido
   puede estar sonando a la vez.
2. `previewAlarm(sound)`:
   - Si `sound` ya está sonando: detiene la reproducción y limpia el estado
     (comportamiento de pausa).
   - Si otro sonido está sonando o nada suena: limpia el estado previo,
     marca `sound` como sonando, notifica y reproduce.
   - Si la reproducción falla: limpia el estado, notifica y conserva el
     mensaje de error existente.
3. Al terminar la reproducción de forma natural, el estado `previewingSound`
   se limpia automáticamente (ícono vuelve a play).
4. `stopPreview()` también limpia el estado (se mantiene para `dispose`).
5. En `_AlarmOption`:
   - Ícono: `pause_circle_outline_rounded` cuando el sonido suena;
     `play_circle_outline_rounded` en caso contrario.
   - Tooltip: "Detener previsualización de \<sonido\>" cuando suena;
     "Previsualizar \<sonido\>" en caso contrario.
   - La fila del sonido que suena se pinta con `AppColors.primary` de fondo y
     título, subtítulo e ícono en blanco/blanco translúcido para contraste; el
     resto conserva el fondo actual.
6. Accesibilidad: se conservan las `Semantics` y `Key`s existentes
   (`previewAlarm-<storageKey>`, `alarmOption-<storageKey>`); la fila sonando
   sigue anunciando su selección mediante el radio.
7. Compatibilidad: la extensión de `AppAudioService.previewAlarm` es aditiva
   (parámetro con nombre opcional), por lo que los fakes actuales no se rompen.

## Impacto técnico y datos

- `lib/features/alarm/presentation/controllers/alarm_controller.dart`: nuevo
  estado `previewingSound`, lógica de toggle/cambio/fin y `notifyListeners`.
- `lib/features/alarm/presentation/pages/alarm_view.dart`: ícono, tooltip y
  color condicionales en `_AlarmOption` (solo presentación, sin reglas de
  negocio en widgets).
- `lib/core/audio/alarm_sound.dart`: firma de `AppAudioService.previewAlarm`
  gana parámetro opcional `onCompleted`.
- `lib/core/audio/local_app_audio_service.dart`: suscripción al
  `onPlayerComplete` del `AudioPlayer` para invocar el callback de fin; los
  efectos de UI (`playEffect`) no disparan el callback.
- Dirección de dependencias sin cambios (`presentation → application/domain`,
  contratos en `core/audio`). Sin migraciones ni cambios de datos.
- Pruebas afectadas: `test/alarm_controller_test.dart`,
  `test/local_app_audio_service_test.dart`.

## Criterios de aceptación y pruebas

1. **Alternancia y cambio** — Prueba unitaria: al previsualizar A,
   `previewingSound == A`; previsualizar B lo cambia a B; volver a
   previsualizar B lo detiene y deja el estado en `null`.
2. **Fin natural** — Prueba unitaria y de servicio: cuando la reproducción
   termina (se emite `onPlayerComplete`), el callback limpia
   `previewingSound`.
3. **Widget: ícono y color** — Prueba de widget: tras tocar
   `previewAlarm-secuencia_digital`, la fila correspondiente muestra el ícono
   de pausa y las demás siguen en play; tras detenerla, vuelve el play. La
   fila sonando usa `AppColors.primary` como fondo.
4. **Widget: flujo existente intacto** — Las pruebas actuales de
   `alarm_controller_test.dart` siguen pasando sin cambios de comportamiento.
5. **Errores** — Prueba unitaria: si `previewAlarm` del servicio lanza, el
   estado vuelve a `null` y se muestra el mensaje de error existente.
6. **Comandos de validación:** `flutter analyze` y `flutter test`.

## Decisiones pendientes

Ninguna. Resuelto en la aprobación: la fila sonando se pinta con
`AppColors.primary` y primer plano blanco.

## Evidencia de implementación

- `lib/features/alarm/presentation/controllers/alarm_controller.dart`:
  `previewingSound` con getter, toggle en `previewAlarm`, limpieza de estado
  en `stopPreview` y en el callback de fin (`_handlePreviewCompleted`).
- `lib/features/alarm/presentation/pages/alarm_view.dart`: en `_AlarmOption`,
  ícono play/pausa, tooltip contextual y `Material` con `AppColors.primary`
  cuando el sonido suena (texto e ícono en blanco para contraste).
- `lib/core/audio/alarm_sound.dart`: parámetro opcional `onCompleted` en
  `AppAudioService.previewAlarm` (extensión aditiva).
- `lib/core/audio/local_app_audio_service.dart`: suscripción a
  `onPlayerComplete` que invoca el callback una única vez; los efectos de UI
  descartan un callback pendiente.
- Pruebas: `test/alarm_controller_test.dart` (toggle, fin natural, error y
  verificaciones de ícono/color en widget), `test/local_app_audio_service_test.dart`
  (callback de fin y descarte por efecto), `test/task_controller_test.dart`
  (firma del fake actualizada).
- Comandos ejecutados: `flutter analyze` (sin problemas) y `flutter test`
  (140 pruebas, todas superadas).
- Riesgo residual aceptado: si el usuario cambia de sonido en el instante
  exacto en que el anterior termina de forma natural, el evento de fin podría
  limpiar el estado del sonido nuevo; la ventana es de milisegundos y no deja
  estado inconsistente persistente.
