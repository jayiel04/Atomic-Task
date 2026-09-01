# Sonidos personalizados y vista «Alarma»

- **Estado:** implementada
- **Área:** audio, tareas, temporizador, navegación y notificaciones Android
- **Última actualización:** 2026-08-30

## Contexto y objetivo

La aplicación ya permite programar recordatorios de tareas y notificaciones
de finalización del temporizador, pero todavía usa el sonido predeterminado de
la plataforma y no ofrece una forma de elegir la alarma. El objetivo es
incorporar los recursos de audio disponibles, ofrecer una vista «Alarma» en el
sidebar y conservar la preferencia del usuario en el dispositivo.

## Alcance y fuera de alcance

- **Incluye:** catálogo de cinco alarmas, selección y previsualización,
  persistencia local, sonido chime para notificaciones normales, alarma
  seleccionada para recordatorios tipo alarma y finalizaciones del temporizador,
  efectos al crear/eliminar tareas, navegación desde el sidebar y soporte
  nativo de sonidos personalizados en Android.
- **No incluye:** volumen o repetición configurables, nuevos campos de Drift,
  sincronización remota, notificaciones push ni personalización nativa de
  sonidos en plataformas distintas de Android.

## Requisitos

- La vista «Alarma» debe ser un destino propio del sidebar. No debe añadirse a
  la barra inferior, que conserva únicamente Tareas y Concentración.
- Deben aparecer las alarmas `Amanecer Cósmico`, `Amanecer Suave`,
  `Despertar Rítmico`, `Pulso Electrónico` y `Secuencia Digital`.
- `Secuencia Digital.mp3` es la selección predeterminada. Una selección se
  guarda inmediatamente y se recupera después de reiniciar la aplicación.
  Valores guardados desconocidos deben volver al valor predeterminado.
- El usuario puede previsualizar la alarma seleccionada y detener la
  previsualización anterior antes de iniciar otra.
- Los recordatorios de tarea con modo notificación deben usar
  `notificaci_n_chime_sfx.wav`. Los recordatorios con modo alarma y las
  finalizaciones del temporizador deben usar la alarma elegida.
- Crear una tarea normal o recurrente reproduce `ui_click_sfx.wav` después de
  una persistencia exitosa. Eliminar una tarea, ocurrencia o serie reproduce
  `eliminar_archivo_sfx.wav` después de una eliminación exitosa. Las fallas no
  deben reproducir efectos ni convertir el efecto en causa de fallo.
- Cambiar la alarma debe cancelar y reprogramar los recordatorios pendientes y
  refrescar la notificación del temporizador activo, conservando sus fechas e
  identificadores.
- Los errores de audio o reprogramación deben mostrar un mensaje seguro sin
  exponer diagnósticos; los detalles técnicos solo se registran en debug.
- Deben conservarse Safe Areas, accesibilidad, diseño responsivo y la dirección
  de dependencias `presentation → application → domain`.

## Impacto técnico y datos

- Añadir un catálogo y contratos de audio independientes de Flutter y de los
  plugins. La implementación local de preferencias usará `SharedPreferences`;
  no hay migración ni cambio de esquema Drift.
- Añadir un servicio de reproducción inyectable para previews y efectos, y
  adaptar `TaskController`, `TimerController`,
  `LocalTaskReminderService` y `LocalTimerNotificationService` mediante sus
  contratos existentes o extensiones mínimas.
- Declarar los directorios `assets/audio/efectos/` y `assets/audio/alarmas/` en
  `pubspec.yaml`. Copiar los audios necesarios a recursos Android `res/raw`
  con nombres normalizados, manteniendo los assets originales.
- Usar canales Android versionados o específicos por sonido para que cambiar la
  preferencia no quede bloqueado por un canal previamente creado.
- Las plataformas no Android mantienen su comportamiento de notificaciones
  actual; la reproducción Flutter se intentará mediante el adaptador común
  disponible en cada plataforma.
- La implementación depende de la spec activa de recordatorios y no debe
  contradecir sus reglas de permisos, recurrencias, cancelación o reconciliación.

## Criterios de aceptación y pruebas

- El repositorio de preferencias devuelve `Secuencia Digital` sin datos,
  persiste las cinco opciones y aplica fallback ante valores inválidos.
- La vista muestra las cinco alarmas, marca la selección, permite preview y
  aparece al navegar desde `sidebarAlarmDestination`.
- Las pruebas de controlador verifican los efectos de creación y eliminación
  solo después de operaciones exitosas, incluyendo tareas recurrentes.
- Las pruebas de notificaciones verifican el mapeo de chime, alarma elegida y
  finalización del temporizador, así como la reprogramación tras cambiar la
  selección.
- La verificación manual en Android cubre aplicación cerrada, permisos,
  recordatorios recurrentes, cambio de alarma, temporizador activo y reinicio.
- Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test`.

## Decisiones pendientes

Ninguna. La solicitud explícita de implementar este plan aprueba el alcance.

## Evidencia de implementación

- Catálogo, persistencia y reproducción: `lib/core/audio/` y
  `lib/features/alarm/presentation/`.
- Integración de navegación y composición: `lib/app.dart`,
  `lib/features/home/`, `lib/main.dart`.
- Efectos de tareas y sonidos de notificaciones: controladores y servicios en
  `lib/features/tasks/` y `lib/features/timer/`.
- Recursos declarados en `pubspec.yaml` y recursos Android normalizados en
  `android/app/src/main/res/raw/`.
- `flutter pub get`: correcto.
- `flutter analyze`: correcto, sin incidencias.
- `flutter test`: correcto, 125 pruebas pasaron; las pruebas específicas de
  audio, preferencias, vista, efectos y serialización de notificaciones
  también pasaron.
- `flutter build apk --debug --no-pub`: correcto. El APK contiene los cinco
  assets Flutter de alarma, los efectos y los seis recursos Android `raw`
  nuevos.
- `git diff --check`: correcto.
- `dart format --output=none --set-exit-if-changed .`: dejó código de salida
  1 por dos archivos con cambios locales previos sin formato (`home_sidebar.dart`
  y `task_form_sheet.dart`). Los archivos nuevos y modificados de esta
  funcionalidad fueron formateados.
- Limitación: no fue posible ejecutar la verificación manual en Android
  porque el entorno solo tiene Linux y Chrome conectados y no tiene emuladores
  configurados. El riesgo residual es confirmar en un dispositivo Android el
  comportamiento con la app cerrada, permisos, canales y reproducción real;
  el APK sí fue compilado con todos los recursos.
