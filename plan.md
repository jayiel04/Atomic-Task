# Plan: alarmas para tareas

## Objetivo

Agregar al panel desplegable de creación y edición de tareas una opción para
configurar una alarma local que notifique al usuario cuando deba realizar la
tarea. La alarma debe persistir, sobrevivir al cierre y reinicio de la
aplicación, y mantenerse sincronizada con el estado de la tarea.

## Estado de ejecución

- [x] Persistencia nullable, migración Drift a esquema 8 y generación de
      `app_database.g.dart`.
- [x] Formulario con agregar, cambiar y quitar alarma; validación de fecha
      futura y soporte para tareas recurrentes.
- [x] Servicio local con ids independientes, zona horaria, permisos,
      fallback de alarma exacta y reconciliación al iniciar.
- [x] Sincronización al crear, editar, completar, reabrir, eliminar y pausar
      tareas o series sin bloquear la mutación si falla la notificación.
- [x] `flutter analyze` sin incidencias y 114 pruebas automatizadas exitosas.
- [ ] Verificación manual de entrega de la notificación con la aplicación
      cerrada: no hay dispositivo Android/iOS ni emulador disponible en este
      entorno; queda como paso de aceptación en un dispositivo real.

## Alcance funcional

- Incorporar en `TaskFormSheet` un botón o sección claramente identificada
  como `Agregar alarma`.
- Permitir seleccionar fecha y hora exactas para la alarma usando controles
  nativos de Flutter.
- Mostrar la fecha y hora seleccionadas y permitir cambiarlas o quitarlas.
- Permitir guardar una tarea sin alarma.
- Persistir la alarma al crear una tarea nueva.
- Editar, reprogramar o eliminar la alarma al modificar una tarea existente.
- Cancelar la alarma cuando la tarea se complete o se elimine.
- Si una tarea completada vuelve a quedar pendiente, reprogramar su alarma
  únicamente si la fecha y hora configuradas siguen siendo futuras.
- Mantener el comportamiento actual de título, fecha límite, recurrencia y
  foco.
- Mostrar mensajes comprensibles si no se conceden permisos o si el sistema
  no puede programar la alarma; la tarea no debe perderse por ese motivo.

## Decisiones funcionales que deben respetarse

- La alarma será opcional y su valor persistido será nullable.
- La fecha y hora se interpretarán en la zona horaria local del dispositivo.
- No se permitirá guardar una alarma en el pasado; el formulario debe indicar
  claramente cómo corregirla.
- Una alarma no reemplaza la fecha límite: ambas configuraciones son
  independientes.
- La notificación debe incluir el título de la tarea y una acción o texto que
  indique que se trata de un recordatorio.
- Las alarmas de tareas deben usar identificadores propios y no reutilizar el
  identificador reservado para las notificaciones del temporizador.

## Tratamiento de tareas recurrentes

- Definir y documentar la regla de recurrencia antes de implementar la UI:
  la propuesta es configurar una hora de recordatorio para la serie y
  materializar la fecha de alarma en cada ocurrencia generada.
- Al crear o editar una serie, aplicar la configuración a las ocurrencias
  futuras que correspondan.
- Al editar una ocurrencia individual, permitir cambiar o quitar únicamente
  su alarma sin modificar el resto de la serie.
- Al completar o eliminar una ocurrencia, cancelar solo su notificación.
- Al desactivar o eliminar una serie, cancelar las notificaciones de sus
  ocurrencias futuras.
- No programar alarmas para ocurrencias completadas, vencidas o que no tengan
  una configuración de alarma válida.

## Acciones de implementación

### 1. Modelo de dominio y persistencia

- [ ] Agregar a `AtomicTask` un campo nullable para la alarma absoluta de la
      tarea/ocurrencia, por ejemplo `reminderAt`.
- [ ] Agregar al modelo de recurrencia el dato necesario para repetir la hora
      de alarma en futuras ocurrencias, si se confirma la regla propuesta.
- [ ] Actualizar `TaskModel`, sus constructores y los mapeos desde Drift.
- [ ] Agregar la columna nullable correspondiente a `Tasks` en
      `lib/core/database/app_database.dart`.
- [ ] Incrementar `schemaVersion` y crear una migración compatible con las
      instalaciones existentes, sin modificar ni perder alarmas o tareas
      actuales.
- [ ] Propagar el dato al insertar y actualizar tareas normales.
- [ ] Propagarlo al crear, actualizar y generar ocurrencias recurrentes.
- [ ] Regenerar `app_database.g.dart` con Drift/build_runner; no editar el
      archivo generado manualmente.
- [ ] Actualizar repositorios, fuentes de datos, casos de uso y dobles de
      prueba para aceptar, devolver y conservar el dato.

### 2. Servicio de notificaciones

- [ ] Crear una abstracción independiente para recordatorios de tareas, sin
      mezclar la lógica del temporizador con la de las tareas.
- [ ] Implementar el servicio local usando `flutter_local_notifications` y
      reutilizar la inicialización de zona horaria y permisos cuando sea
      conveniente.
- [ ] Definir métodos para inicializar, programar, reprogramar, cancelar una
      alarma y cancelar todas las alarmas asociadas a una tarea o serie.
- [ ] Usar un identificador estable derivado del id de tarea y, para
      recurrencias, de la fecha de ocurrencia; evitar colisiones entre alarmas.
- [ ] Crear un canal de notificaciones específico para recordatorios de
      tareas, con importancia y sonido adecuados.
- [ ] Programar con fecha/hora zonificada y usar el mismo fallback exacto a
      inexacto que ya contempla el servicio existente cuando el sistema no
      permita alarmas exactas.
- [ ] Solicitar permisos de notificaciones en el momento apropiado y tratar
      explícitamente la respuesta denegada.
- [ ] Mantener la configuración compatible con Android, iOS, macOS, Windows y
      las plataformas que no soporten programación.
- [ ] Revisar permisos, receptores de arranque y configuración nativa; no
      duplicar ni romper los permisos actuales del temporizador.
- [ ] Definir una estrategia de reconciliación al iniciar la aplicación para
      volver a programar alarmas persistidas y cancelar notificaciones
      obsoletas.

### 3. Casos de uso y controlador

- [ ] Extender las operaciones de crear, actualizar, completar, descompletar y
      eliminar para coordinar persistencia y notificaciones.
- [ ] Después de crear una tarea, usar el id devuelto para programar su alarma.
- [ ] Al editar, comparar la alarma anterior con la nueva y cancelar,
      reprogramar o mantener la notificación según corresponda.
- [ ] Al completar o borrar una tarea, cancelar la alarma antes o durante la
      operación de forma segura e idempotente.
- [ ] Evitar que un fallo de notificación deje el controlador en un estado de
      mutación permanente.
- [ ] Exponer errores de programación con mensajes de usuario sin ocultar los
      errores técnicos en modo debug.
- [ ] Inyectar una interfaz falsa del servicio en pruebas para no depender de
      un dispositivo real.

### 4. Formulario desplegable

- [ ] Añadir una sección visual consistente con `_DateField` para la alarma.
- [ ] Incluir una acción `Agregar alarma` cuando no exista una configuración.
- [ ] Abrir primero un selector de fecha y después un selector de hora, o usar
      una interacción equivalente que sea clara en pantallas pequeñas.
- [ ] Mostrar la fecha y hora local resultantes con un formato legible.
- [ ] Añadir acciones `Cambiar alarma` y `Quitar alarma`.
- [ ] Deshabilitar controles mientras se guarda, igual que los controles
      actuales del formulario.
- [ ] Validar que la alarma sea futura y mostrar el error junto al control.
- [ ] Conservar la configuración existente al editar una tarea.
- [ ] Aplicar las restricciones de edición de ocurrencia/serie ya existentes.
- [ ] Añadir keys semánticas estables para pruebas, por ejemplo:
      `taskReminderSection`, `addTaskReminderButton`,
      `selectTaskReminderDateButton`, `selectTaskReminderTimeButton` y
      `clearTaskReminderButton`.
- [ ] Mantener objetivos táctiles de al menos 48 px y revisar el formulario con
      teclado abierto, texto ampliado y orientación horizontal.

### 5. Recurrencias y ciclo de vida

- [ ] Definir cómo se calcula la próxima alarma cuando se genera una nueva
      ocurrencia.
- [ ] Evitar crear dos notificaciones para la misma ocurrencia.
- [ ] Cancelar alarmas de ocurrencias completadas, eliminadas o desactivadas.
- [ ] Reconciliar tareas recurrentes al iniciar la aplicación y después de
      crear una ocurrencia nueva.
- [ ] Verificar que editar una serie no deje notificaciones con el título,
      fecha o hora anteriores.

### 6. Pruebas

- [ ] Añadir pruebas del dominio para aceptar alarma nula, válida y pasada.
- [ ] Añadir pruebas de repositorio y base de datos para crear, leer,
      actualizar y migrar el campo de alarma.
- [ ] Añadir pruebas de la fuente en memoria para conservar el valor durante
      actualizaciones, completado, descompletado y borrado.
- [ ] Añadir pruebas del servicio con un plugin falso para verificar
      programación, cancelación, reprogramación, ids y fallback.
- [ ] Añadir pruebas del controlador para comprobar la coordinación entre
      persistencia y notificación, incluidos fallos del servicio.
- [ ] Añadir pruebas de widget para abrir el selector, guardar una alarma,
      cambiarla, quitarla y rechazar fechas pasadas.
- [ ] Añadir pruebas para crear y editar tareas recurrentes con alarma.
- [ ] Añadir pruebas de accesibilidad, tamaño mínimo de controles y diseño
      responsivo del panel desplegable.
- [ ] Verificar que completar o eliminar una tarea cancela su alarma.
- [ ] Ejecutar `dart format`, `flutter analyze` y la suite completa de pruebas.
- [ ] Ejecutar pruebas específicas en Android/iOS o una verificación manual en
      dispositivo/emulador para confirmar que la notificación aparece con la
      aplicación cerrada.

## Criterios de aceptación

- [ ] Desde el panel desplegable se puede crear una tarea con o sin alarma.
- [ ] La alarma elegida se muestra correctamente antes de guardar y al volver
      a editar la tarea.
- [ ] Una tarea con alarma genera una sola notificación local en la fecha y
      hora configuradas.
- [ ] La notificación usa el título correcto de la tarea.
- [ ] Cambiar la alarma elimina la programación anterior y conserva solo la
      nueva.
- [ ] Quitar la alarma cancela la notificación y deja la tarea sin alarma.
- [ ] Completar o eliminar la tarea impide que su alarma vuelva a aparecer.
- [ ] Las alarmas futuras permanecen después de cerrar y abrir la aplicación.
- [ ] Las tareas y datos existentes siguen funcionando después de la
      migración.
- [ ] Las tareas recurrentes siguen generando ocurrencias y sus alarmas sin
      duplicados.
- [ ] La interfaz funciona con teclado abierto, áreas seguras, texto ampliado
      y tamaños compactos.
- [ ] El análisis estático no reporta errores y todas las pruebas automatizadas
      pasan.

## Riesgos y controles

- **Permisos denegados:** conservar la tarea, informar al usuario y ofrecer una
  forma de volver a intentarlo desde la edición.
- **Alarmas exactas no disponibles:** usar programación inexacta como respaldo
  y comunicar que la hora puede variar ligeramente.
- **Cambios de zona horaria o DST:** guardar la fecha/hora de forma compatible
  con la zona local y convertirla mediante `timezone` al programar.
- **Ids duplicados:** reservar un rango de ids y probar la función de derivación
  con varias tareas y ocurrencias.
- **Migraciones incompletas:** probar una base de datos de cada versión previa
  soportada antes de subir el esquema.
- **Desincronización entre base de datos y sistema operativo:** ejecutar una
  reconciliación al inicio y hacer las operaciones de cancelación idempotentes.
- **Formulario demasiado largo:** conservar el `SingleChildScrollView` y
  validar el flujo con teclado y pantallas pequeñas.

## Resultado esperado

Una alarma de tarea configurable desde el panel desplegable, persistente y
sincronizada con las operaciones de la tarea, sin afectar las notificaciones
del temporizador ni la funcionalidad existente.
