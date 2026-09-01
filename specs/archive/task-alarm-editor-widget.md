# Editor de alarma como tarjeta flotante al pie del panel

- **Estado:** implementada
- **Área:** tareas (formulario de creación y edición)
- **Última actualización:** 2026-08-31

## Contexto y objetivo

Tras la spec `task-alarm-popover` (archivada), la alarma por tarea se configura
desde un ícono anclado en la cabecera de las tarjetas «Fecha límite» y
«Repetir» del formulario, que despliega un popover `MenuAnchor` con las
opciones. Se busca dos cambios de experiencia:

1. Mover el ícono de alarma a la **parte inferior del contenido desplegable**
   de ambas tarjetas (fuera de la fila del título/switch).
2. Reemplazar el popover por una **tarjeta flotante** que emerge desde el
   borde inferior de la pantalla y queda centrada, con el contenido detrás
   difuminado, que concentra toda la configuración de la alarma y termina en
   los botones **Guardar** y **Cancelar**.

## Alcance y fuera de alcance

- **Incluye:**
  - Reubicación del ícono de alarma (`<prefix>AlarmIcon`) al final del
    contenido desplegable de las tarjetas «Fecha límite» y «Repetir»,
    visible solo cuando la opción está activa y su panel está desplegado,
    conservando su estado visual (con/sin alarma) y el resumen de hora en el
    subtítulo de la tarjeta.
  - Nuevo widget de edición de alarma en pantalla completa modal: tarjeta
    centrada que entra animada desde el borde inferior; el resto de la
    pantalla se difumina y atenúa mientras está abierta.
  - Toda la configuración actual vive dentro de la tarjeta: quitar alarma
    (cuando hay una activa), selector de hora, modo (Alarma/Notificación),
    sonido (las cinco alarmas del catálogo más «Predeterminada», visible solo
    en modo Alarma) y, en recurrentes configurables, el alcance «Siempre» /
    «Solo la primera vez».
  - Botones **Guardar** y **Cancelar** al pie de la tarjeta. Guardar aplica
    los cambios al estado del formulario (que solo persiste al guardar la
    tarea, como hoy); Cancelar descarta los cambios no guardados. Descartar
    tocando el fondo difuminado o usando atrás equivale a Cancelar.
  - Validación al pulsar Guardar: si la hora resultante no es estrictamente
    futura, la tarjeta permanece abierta, muestra el mensaje existente «La
    alarma debe programarse para una fecha y hora futuras.» y no aplica los
    cambios.
  - Eliminación del popover `MenuAnchor` (`_AlarmPopover`); el nuevo widget
    pasa a ser la única vía de configurar la alarma en el formulario.
  - Actualización de las pruebas widget de `task_reminder_test.dart` al nuevo
    flujo y llaves.
- **No incluye:**
  - Cambios de esquema, migraciones ni persistencia; la lógica de datos y de
    programación de recordatorios queda intacta.
  - Ícono ni edición de alarma desde la lista de tareas (`TaskCard`).
  - Previsualización de sonidos dentro de la tarjeta.
  - Cambios en la vista «Alarma», el catálogo de sonidos ni los canales
    Android existentes.
  - Nuevas dependencias externas (`BackdropFilter`, `ImageFilter` y rutas
    modal pertenecen al SDK de Flutter).

## Requisitos

- El ícono de alarma se muestra al final del contenido desplegable de la
  tarjeta, después de los campos existentes, alineado de forma coherente con
  el diseño actual; conserva tooltip («Configurar alarma» / «Editar alarma»),
  objetivo táctil mínimo de 48 dp y distinción visual entre «sin alarma» y
  «con alarma».
- La tarjeta flotante se compone de: encabezado con título y cierre, sección
  de activación/desactivación (quitar alarma), hora, modo, sonido (solo modo
  Alarma, conservando el valor elegido si se cambia temporalmente de modo) y
  alcance (solo recurrentes configurables), seguidos de los botones Guardar
  y Cancelar.
- Los cambios dentro de la tarjeta son un borrador: no alteran el estado del
  formulario hasta pulsar Guardar. Cancelar (o descartar) restituye el estado
  previo a abrir la tarjeta.
- Guardar aplica el borrador y cierra la tarjeta; si la validación de hora
  futura falla, cierra nada: muestra el mensaje dentro de la tarjeta y
  conserva el borrador editable.
- Quitar la alarma desde la tarjeta limpia hora, modo y sonido al aplicar con
  Guardar. Desactivar «Fecha límite» o «Repetir» sigue limpiando la alarma
  asociada; fecha límite y recurrencia siguen siendo excluyentes.
- Al editar una tarea sin sonido propio, la tarjeta muestra
  «Predeterminada»; con sonido propio lo muestra preseleccionado. El alcance
  solo aparece al configurar la serie; la alarma de una ocurrencia se sigue
  gestionando desde la tarjeta «Fecha límite».
- La tarjeta respeta Safe Areas y el teclado en pantalla, es accesible por
  teclado/lector de pantalla (etiquetas y semántica en cada control) y se
  adapta a pantallas pequeñas sin desbordes.
- Se conservan permisos y mensajes de error actuales de notificaciones y
  alarmas exactas; los fallos de audio o programación muestran mensajes
  seguros sin diagnósticos.
- Se conserva la dirección de dependencias
  `presentation → application → domain`; el widget no gana reglas de negocio,
  solo edición de estado del formulario.

## Impacto técnico y datos

- Cambio exclusivamente de presentación en
  `lib/features/tasks/presentation/widgets/task_form_sheet.dart`:
  - `_OptionCard` pierde la ranura `alarmAction` en cabecera; el ícono pasa a
    renderizarse como parte del `child` desplegable de cada sección (al
    final).
  - `_AlarmPopover` (`MenuAnchor`) se elimina y se sustituye por un widget de
    tarjeta flotante (por ejemplo `_AlarmEditorSheet`) mostrado con
    `showGeneralDialog`/ruta modal propia: transición de entrada desde abajo
    y barrera con `BackdropFilter` (`ImageFilter.blur`) más atenuado.
  - El formulario recibe el resultado de la tarjeta (aplicar/cancelar) por
    callback o valor de retorno de la ruta y muta su propio estado, igual que
    hoy.
- No hay cambios de esquema ni de migraciones: `reminder_sound_key`,
  `reminderMode` y el resto del modelo no varían.
- No hay cambios en `TaskController`, casos de uso ni
  `LocalTaskReminderService`.
- Pruebas widget afectadas: `test/task_reminder_test.dart` (llaves existentes
  de íconos se conservan; se añaden `<prefix>AlarmSaveButton` y
  `<prefix>AlarmCancelButton`; las aserciones sobre ítems de menú pasan a
  buscar los controles dentro de la tarjeta).
- No hay nuevas dependencias ni cambios de navegación entre pantallas.

## Criterios de aceptación y pruebas

- Pruebas widget (`test/task_reminder_test.dart`):
  - Activar «Fecha límite» o «Repetir» muestra el ícono al final del panel
    desplegable; desactivarlas lo oculta junto con la alarma.
  - Pulsar el ícono abre la tarjeta flotante con quitar alarma, hora, modo,
    sonido con «Predeterminada» y, en recurrentes, el alcance; el popover
    `MenuAnchor` ya no existe.
  - Cancelar cierra la tarjeta sin aplicar cambios; Guardar aplica el borrador
    al formulario y la tarjeta se cierra; los cambios solo persisten al
    guardar la tarea.
  - Una hora no futura al pulsar Guardar muestra el mensaje, no aplica
    cambios ni cierra la tarjeta.
  - Quitar la alarma y Guardar limpia hora, modo y sonido.
  - El modo Notificación deshabilita/oculta el selector de sonido conservando
    el valor de Alarma elegido.
- Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test`.

## Decisiones pendientes

Ninguna. La presentación (tarjeta flotante centrada que emerge desde abajo
sobre fondo difuminado) y el contenido (toda la configuración dentro de la
tarjeta, con Guardar/Cancelar) se acordaron con el solicitante; queda
pendiente únicamente su aprobación explícita de esta spec.

## Evidencia de implementación

- `lib/features/tasks/presentation/widgets/task_form_sheet.dart`:
  - `_OptionCard` sin la ranura `alarmAction`; los íconos
    (`dueAlarmIcon`/`repeatAlarmIcon`) se renderizan al final del contenido
    desplegable de cada tarjeta, con tooltip y objetivo táctil de 48 dp.
  - `_AlarmPopover` (`MenuAnchor`) eliminado; nuevo `_showAlarmEditor`
    (`showGeneralDialog`) con barrera propia: `BackdropFilter`
    (`ImageFilter.blur`, sigma animado hasta 10) más atenuado al 35 %, y
    tarjeta centrada que entra desde abajo (translate 35 % de la altura con
    `Curves.easeOutCubic` y reversa `easeInCubic`); tocar el fondo, cerrar o
    atrás equivale a Cancelar.
  - `_AlarmEditorSheet`: borrador local (activación, hora, modo, sonido,
    alcance), selector de hora con la sugerencia de hora futura previa,
    sonido como chips (`Predeterminada` + catálogo, visible solo en modo
    Alarma conservando el valor), validación de hora futura delegada al
    formulario vía callback (`validateTime`) y botones
    `<prefix>AlarmSaveButton` / `<prefix>AlarmCancelButton`. Los ítems del
    popover conservan sus llaves (`<prefix>AlarmToggleItem`,
    `<prefix>AlarmTimeItem`, `<prefix>AlarmModeAlarmItem`,
    `<prefix>AlarmModeNotificationItem`, `<prefix>AlarmSoundItem`,
    `<prefix>AlarmScopeAlwaysItem`, `<prefix>AlarmScopeFirstItem`,
    `<prefix>AlarmSoundDefaultOption`, `<prefix>AlarmSoundOption_<key>`).
  - Sin cambios en controlador, casos de uso, servicio de recordatorios,
    esquema Drift ni dependencias.
- `test/task_reminder_test.dart`: 4 pruebas widget actualizadas/ampliadas —
  apertura y limpieza de alarma (incluye verificación de que Cancelar no
  aplica cambios), exclusividad de tarjetas con cierre por Cancelar,
  selector de sonidos siempre visible con selección persistente y nueva
  prueba de bloqueo de hora vencida dentro de la tarjeta.
- Validación ejecutada: `dart format --output=none --set-exit-if-changed .`
  (sin cambios), `flutter analyze` (sin problemas) y `flutter test`
  (134 pruebas aprobadas).
- Limitaciones: en superficies bajas la tarjeta se desplaza internamente
  (altura máxima 75 % de la pantalla) para respetar Safe Areas; las pruebas
  requieren `ensureVisible` de los botones inferiores. Riesgo residual: la
  postal del borrador no advierte al descartar por el fondo (equivale a
  Cancelar por diseño acordado).
