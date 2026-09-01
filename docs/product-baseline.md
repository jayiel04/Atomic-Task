# Línea base funcional de Atomic Task

Este documento define el comportamiento aceptado de Atomic Task. Describe el
estado del producto que el código y las pruebas deben conservar; no sustituye
las especificaciones activas ni registra planes de implementación.

## Propósito

Atomic Task permite crear y organizar tareas, asociarlas con sesiones de
concentración y descanso, y conservar localmente el progreso del usuario. La
experiencia debe permitir alternar entre planificación y concentración sin
perder el estado de ninguna vista.

## Navegación y estado de la aplicación

- `AtomicTimerBootstrap` compone la aplicación y muestra `HomeShellPage` como
  Home principal.
- La Home usa un único `Scaffold` y un `IndexedStack` para Tareas,
  Concentración, Alarma, Ajustes y Estadísticas. `TaskPage` y `TimerPage` se mantienen
  como envoltorios compatibles con rutas y pruebas heredadas.
- La barra inferior contiene exactamente Tareas y Concentración; solo se
  construye en esos destinos. El drawer permite acceder a los cinco destinos
  y al restablecimiento del progreso.
- El inicio normal abre Tareas. Una sesión preparada, pausada o activa
  recuperada abre Concentración.
- Los controladores de tareas y temporizador viven durante la sesión. Cambiar
  de pestaña no reinicia la lista ni un temporizador en curso.

## Tareas

- Se pueden crear, editar, completar, reabrir y eliminar tareas. Las tareas
  admiten fecha límite opcional y minutos de concentración asociados.
- Una tarea pendiente puede preparar una sesión de concentración; permanece
  pendiente hasta que esa sesión vinculada termine.
- Las tareas recurrentes diarias, semanales y mensuales mantienen una regla
  independiente de sus ocurrencias. Completar una ocurrencia crea de forma
  transaccional e idempotente la siguiente; editar o eliminar permite actuar
  sobre la ocurrencia o la serie.
- La agrupación prioriza `dueDate` y usa `occurrenceDate` en recurrentes sin
  fecha límite. Las tareas se muestran en Atrasadas, Hoy, Mañana, Tareas futuras
  o Sin fecha según corresponda.
- La recurrencia mensual conserva el día original cuando existe y, en meses
  más cortos, utiliza su último día. La reconciliación recupera una única
  próxima ocurrencia pendiente tras fechas omitidas.

## Alarmas y efectos de audio

- La vista Alarma se abre desde el drawer y ofrece las cinco alarmas incluidas.
  La selección se guarda localmente y `Secuencia Digital` es el valor
  predeterminado y el fallback ante valores inválidos.
- Las notificaciones normales de tareas usan el chime fijo. Los recordatorios
  tipo alarma y la finalización del temporizador usan la alarma seleccionada.
- Crear una tarea reproduce el efecto de clic y eliminarla reproduce el efecto
  de eliminación, únicamente después de una operación exitosa.

## Concentración, descanso y progreso

- La concentración predeterminada dura 25 minutos y el descanso 5; la duración
  configurable máxima es 120 minutos.
- Una concentración concede una gema por cada tres minutos completos. Un
  descanso cuesta una gema por minuto completo y solo puede empezar con saldo
  suficiente.
- El temporizador permite preparar, iniciar, pausar, continuar y reiniciar una
  sesión. Reiniciar solo está disponible durante ejecución o pausa, requiere
  confirmación y descarta la sesión sin crear resumen.
- Al terminar una concentración vinculada se completa la tarea. Después del
  cierre o fallo terminal de la publicidad, la UI muestra un resumen consumible
  una sola vez. Los descansos conservan su aviso flotante.
- La primera ejecución solicita un nombre. El progreso local incluye nombre,
  gemas y tiempo de concentración; restablecerlo requiere confirmación.

## Persistencia y ciclo de vida

- Drift usa el esquema versión 9. Las migraciones conservan los datos de
  instalaciones anteriores y los cambios de esquema deben ser aditivos,
  versionados y cubiertos por pruebas.
- Las tareas, reglas de recurrencia, sesión activa y resúmenes pendientes se
  persisten localmente. La sesión usa su hora de finalización para sincronizarse
  al volver a primer plano y evita duplicar recompensas o finalizaciones.
- El cierre de la aplicación espera las escrituras pendientes antes de cerrar
  la base de datos. Streams, temporizadores y listeners se liberan en `dispose`.

## Límites de esta línea base

El trabajo de recordatorios de tareas está en
[su especificación activa](../specs/active/task-reminders.md). No debe
considerarse comportamiento aceptado ni actualizar esta línea base hasta que
la spec esté aprobada, implementada y validada.
