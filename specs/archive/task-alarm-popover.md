# Popover de alarma por tarea con sonido particular

- **Estado:** implementada
- **Área:** tareas (formulario), audio y notificaciones, persistencia Drift
- **Última actualización:** 2026-08-31

## Contexto y objetivo

Al activar «Fecha límite» o «Repetir» en el formulario de tarea, la alarma se
configura hoy mediante una sub-opción embebida dentro de la tarjeta y el
sonido de alarma es únicamente el global de la vista «Alarma». El objetivo es
reemplazar esa sub-opción por un ícono de alarma que despliega un widget
flotante (popover anclado) desde el que se asigna a la tarea una hora, el modo
de aviso y una alarma (sonido) en particular, distinta del sonido global si se
desea. La hora de la alarma no puede ser menor o igual a la hora actual.

## Alcance y fuera de alcance

- **Incluye:**
  - Ícono de alarma en las tarjetas «Fecha límite» y «Repetir» del formulario
    (creación y edición), visible solo cuando la opción correspondiente está
    activa, con estado visual que refleja si hay alarma configurada y su hora.
  - Popover flotante anclado al ícono (`MenuAnchor`) que contiene: activación
    y eliminación de la alarma, selector de hora, selector de modo
    (Alarma/Notificación), selector de sonido (las cinco alarmas del catálogo
    más la opción «Predeterminada», que usa el sonido global vigente) y, solo
    en recurrentes configurables, el alcance «Siempre» / «Solo la primera
    vez».
  - Eliminación de la sub-opción de alarma embebida actual (`_AlarmSubOption`);
    el popover pasa a ser la única vía de configurar la alarma en el
    formulario.
  - Persistencia del sonido por tarea: columna aditiva `reminder_sound_key`
    (texto, nullable) en `tasks`, migración Drift del esquema v9 a v10 con
    pruebas. `NULL` equivale a «Predeterminada».
  - `LocalTaskReminderService` usa el sonido propio de la tarea en modo
    Alarma, con fallback al sonido global cuando no existe. El modo
    Notificación conserva el chime fijo actual.
  - Propagación del sonido a la siguiente ocurrencia recurrente, igual que se
    propaga hoy `reminderMode`.
  - Reprogramación de recordatorios pendientes al cambiar el sonido global que
    respeta los sonidos propios por tarea.
  - Validación que exige que la fecha-hora de la alarma sea estrictamente
    futura respecto al momento actual, conservando el mensaje existente.
- **No incluye:**
  - Ícono de alarma ni edición de alarma desde la lista de tareas
    (`TaskCard`); la configuración ocurre solo en el formulario.
  - Previsualización de sonidos dentro del popover.
  - Sonido por tarea para el modo Notificación (se mantiene el chime fijo).
  - Cambios en la vista «Alarma», en el catálogo de sonidos ni en los canales
    Android existentes.
  - Nuevas dependencias externas (`MenuAnchor` pertenece al SDK de Flutter).

## Requisitos

- Las tarjetas «Fecha límite» y «Repetir» muestran el ícono de alarma solo
  cuando su opción está activa. El ícono distingue el estado «sin alarma» de
  «con alarma» y la tarjeta muestra la hora configurada como resumen.
- El popover se ancla al ícono y edita el estado del formulario; los cambios
  se conservan al cerrarlo y solo se persisten al guardar la tarea, como hoy.
- El selector de hora abre el selector de tiempo de la plataforma con la hora
  ya configurada o, en su defecto, una hora futura sugerida (comportamiento
  actual).
- La opción «Predeterminada» del selector de sonido identifica el sonido
  global vigente. Las cinco alarmas conservan sus etiquetas del catálogo.
- El selector de sonido aplica únicamente al modo Alarma. El valor elegido se
  conserva aunque el usuario cambie temporalmente al modo Notificación, cuyo
  aviso sigue usando el chime fijo.
- Al elegir una hora cuya fecha-hora resultante no sea estrictamente futura se
  muestra el mensaje existente «La alarma debe programarse para una fecha y
  hora futuras.» y no se permite guardar mientras persista.
- Quitar la alarma desde el popover limpia hora, modo y sonido. Desactivar
  «Fecha límite» o «Repetir» limpia la alarma asociada como hoy. Fecha límite
  y recurrencia continúan siendo excluyentes.
- Al editar una tarea sin sonido propio el selector muestra «Predeterminada»;
  con sonido propio lo muestra preseleccionado. Al editar una ocurrencia de
  una serie, la alarma de la ocurrencia se sigue gestionando desde la tarjeta
  «Fecha límite», como ocurre hoy; el alcance solo aparece al configurar la
  serie.
- Se conservan permisos y mensajes de error actuales de notificaciones y
  alarmas exactas; los fallos de audio o programación muestran mensajes
  seguros sin diagnósticos.
- Se conservan Safe Areas, accesibilidad (tooltips y objetivos táctiles),
  comportamiento responsivo y la dirección de dependencias
  `presentation → application → domain`.

## Impacto técnico y datos

- Drift pasa al esquema versión 10: `Tasks` gana
  `TextColumn get reminderSoundKey => text().nullable()()` y la migración
  aditiva usa `migrator.addColumn`. Se regenera `app_database.g.dart` con las
  herramientas oficiales y las instalaciones existentes conservan sus datos
  con la columna en `NULL`.
- `AtomicTask` gana `reminderSoundKey` (`String?`). La resolución del
  `storageKey` a `AlarmSound` se realiza fuera de la entidad mediante
  `alarmSoundFromStorageKey`, sin introducir Flutter en el dominio.
- El patrón de persistencia sigue al de `reminderMode`: el sonido se guarda
  solo cuando existe alarma activa y queda en `NULL` al limpiarla. La
  generación de la siguiente ocurrencia copia el valor desde la plantilla.
- `TaskController` y los casos de uso de creación y edición (simple,
  recurrente, ocurrencia y serie) reciben el nuevo parámetro nullable.
- `LocalTaskReminderService._notificationDetailsFor` resuelve el sonido del
  modo Alarma como: `reminderSoundKey` de la tarea si existe, o el sonido
  global de `AlarmSoundSettings` en caso contrario. Los canales Android
  `task_alarms_v3_<storageKey>` ya existen por sonido y no cambian; la
  cancelación previa a la reprogramación existente aplica el canal nuevo.
- El cambio de sonido global desde la vista «Alarma» reprograma los
  recordatorios pendientes: las tareas con sonido propio conservan su canal y
  las de sonido «Predeterminada» adoptan el nuevo global.
- El formulario reemplaza `_AlarmSubOption` por el ícono y el popover; la
  validación de hora futura y la combinación fecha + hora existentes se
  reutilizan. Los widgets no ganan reglas de negocio.
- No hay nuevas dependencias ni cambios de navegación. El audio transversal y
  el ensamblaje en `app/` se extienden solo para inyectar lo necesario.

## Criterios de aceptación y pruebas

- La migración v9 → v10 conserva las tareas existentes y deja
  `reminder_sound_key` en `NULL` (prueba de datos).
- Crear o editar una tarea con alarma y sonido propio persiste el valor y
  programa la notificación con el canal de ese sonido; una tarea sin sonido
  propio usa el canal del sonido global (pruebas de servicio y controlador).
- Una tarea en modo Notificación usa siempre el chime fijo, tenga o no sonido
  propio (prueba de servicio).
- Cambiar el sonido global reprograma las tareas «Predeterminada» al nuevo
  canal y no altera las de sonido propio (prueba de servicio/controlador).
- Completar una ocurrencia recurrente genera la siguiente con el mismo
  sonido (prueba de datos o controlador).
- Pruebas widget: activar «Fecha límite» o «Repetir» muestra el ícono; el
  popover ofrece hora, modo, sonidos con «Predeterminada» y, en recurrentes,
  el alcance; una hora no futura muestra el mensaje y bloquea el guardado;
  quitar la alarma limpia hora, modo y sonido; la sub-opción embebida ya no
  existe.
- Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test`.

## Decisiones pendientes

Ninguna. El alcance se acordó con el solicitante en la conversación previa a
esta spec; queda pendiente únicamente su aprobación explícita.

## Evidencia de implementación

- Esquema Drift v10: columna aditiva `reminder_sound_key` en `tasks`,
  migración con `migrator.addColumn` y regeneración con `build_runner`
  (el `.g.dart` solo recibió adiciones).
- Resolución de sonido en `LocalTaskReminderService._resolveAlarmSound`:
  sonido propio de la tarea; `NULL` o clave desconocida caen al sonido
  global vigente (decisión registrada durante la revisión).
- Popover `MenuAnchor` en el formulario con ícono por tarjeta (`_AlarmPopover`);
  la sub-opción `_AlarmSubOption` fue eliminada.
- Sonido propagado a la siguiente ocurrencia desde `_insertNextOccurrence`
  y `updateRecurringSeries`, siguiendo el patrón de `reminderMode`.
- Pruebas: migración v9 → v10 con datos (`app_database_test.dart`), sonido
  propio/global/fallback y reprogramación al cambiar el global
  (`local_notification_sound_test.dart`), propagación en recurrentes y
  popover widget (`task_reminder_test.dart`), paso del parámetro por el
  controlador (`task_controller_test.dart`).
- Validación ejecutada: `dart format --output=none --set-exit-if-changed .`
  (sin cambios), `flutter analyze` (sin problemas) y `flutter test`
  (133 pruebas aprobadas).
