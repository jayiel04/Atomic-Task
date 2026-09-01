# Vistas internas para "Tarea con fecha límite" y "Tarea cíclica" en el formulario de tarea

- **Estado:** implementada
- **Área:** features/tasks (presentación: `TaskFormSheet`)
- **Última actualización:** 2026-08-31

## Contexto y objetivo

Hoy el formulario de creación/edición de tarea (`lib/features/tasks/presentation/widgets/task_form_sheet.dart`) muestra dos tarjetas con `Switch.adaptive`: "Fecha límite" (key `dueDateOptionSwitch`) y "Repetir" (key `repeatTaskSwitch`). Al activar el switch se despliega el contenido de configuración dentro de la misma tarjeta.

Se busca:

1. Renombrar las opciones: "Fecha límite" → **"Tarea con fecha límite"** y "Repetir" → **"Tarea cíclica"**.
2. Eliminar el switch de ambas tarjetas. La tarjeta pasa a ser una entrada navegable que muestra un resumen del estado actual (p. ej. fecha elegida, frecuencia, resumen de alarma).
3. Al pulsar cualquiera de las dos tarjetas, el **mismo widget** cambia a una vista de configuración (no se abre otra pantalla ni otro sheet): solo cambia la sección central del formulario.
4. En la vista de configuración aparece un **ícono de flecha hacia atrás en color rojo** (`AppColors.destructive`) en el **lado izquierdo** de la fila superior del widget, que regresa a la vista principal.
5. El campo de título ("Escribe una tarea...") y el botón "Crear tarea" se mantienen **idénticos y visibles** en ambas vistas, con su comportamiento actual (validación, `_submit`, guardado).

## Alcance y fuera de alcance

- **Incluye:**
  - Renombrar títulos y textos de las dos opciones.
  - Sustituir `_OptionCard` + `Switch.adaptive` por tarjetas navegables (sin switch) en la vista principal.
  - Estado interno de navegación: enum privado `_FormView { principal, fechaLimite, ciclica }` dentro del mismo `StatefulWidget`; transición entre vistas dentro del sheet (opcionalmente con `AnimatedSwitcher` para suavidad).
  - Vista "Tarea con fecha límite": contiene la configuración actual (atajos Hoy/Mañana, "Elegir en el calendario", "Quitar fecha límite", error de fecha, ícono de alarma `dueAlarmIcon`).
  - Vista "Tarea cíclica": contiene los campos actuales (frecuencia, intervalo, inicio, fin, ícono de alarma `repeatAlarmIcon`).
  - Flecha atrás roja (`Icons.arrow_back_rounded`, key `formBackButton`) con tooltip, a la izquierda de la fila del título del sheet; en la vista principal esa posición queda vacía (solo "Nueva tarea"/"Editar..." + cerrar).
  - Acción explícita para desactivar "Tarea cíclica" dentro de su vista (equivalente al antiguo switch en off), p. ej. botón "Quitar recurrencia".
  - Preservar contratos vigentes: exclusividad mutua entre fecha límite y recurrencia (activar una limpia la otra y su alarma), fecha por defecto "hoy" al activar fecha límite en tarea nueva, imposibilidad de guardar con fecha límite activa y sin fecha, editor de alarma sin cambios.
- **No incluye:**
  - Cambios en dominio, casos de uso (`create`, `createRecurring`), repositorios, datasource o esquema Drift. Sin migraciones.
  - Cambios al editor de alarma (`_AlarmEditorSheet`), sonidos o programación de notificaciones.
  - Cambios al flujo de edición de ocurrencia/serie más allá de la adaptación visual descrita.
  - Nuevos paquetes o cambios de arquitectura.

## Requisitos

1. **Vista principal:** muestra las dos tarjetas navegables con su ícono (`event_rounded` / `repeat_rounded`), título nuevo y subtítulo resumen (fecha formateada o "Sin fecha límite" / frecuencia o "Crear ocurrencias automáticamente", más resumen de alarma si aplica). No hay switches.
2. **Navegación y descarte:** pulsar una tarjeta toma una instantánea del estado de esa opción (activa/inactiva, fecha/frecuencia/alarma) y hace `setState` hacia su vista. La flecha atrás roja abre un diálogo de confirmación "¿Descartar cambios?" con dos acciones:
   - **Descartar** (acción destructiva, texto rojo): revierte la opción a la instantánea tomada al entrar (si estaba inactiva, queda inactiva y sin datos; si venía activa de una tarea existente, restaura sus valores) y regresa a la vista principal.
   - **Conservar**: mantiene lo configurado y regresa a la vista principal.
3. **Desactivación:** "Quitar fecha límite" conserva su comportamiento actual (limpia fecha, error y alarma). "Quitar recurrencia" limpia frecuencia/alarmas y desactiva la opción (nuevo botón, mismo efecto que el antiguo switch en off).
4. **Exclusividad:** al activar/configurar una vista, la otra opción se limpia (fecha+alarma o recurrencia+alarma), igual que hoy.
5. **Persistencia del layout:** el `TextFormField` del título (key `taskTitleField`) y el `FilledButton` "Crear tarea" (key `saveTaskButton`) no cambian de lugar, apariencia ni comportamiento entre vistas; el estado del título se conserva al navegar.
6. **Edición:** en edición de ocurrencia no perteneciente a serie, la tarjeta "Tarea cíclica" se muestra como no navegable/informativa ("Esta ocurrencia pertenece a una serie"); en edición de serie, la vista de fecha límite no permite configurar (mismo estado actual).
7. **Accesibilidad:** la flecha atrás mantiene tooltip y área táctil ≥ 48dp; contraste y Safe Areas sin cambios.
8. **Pruebas:** las llaves existentes (`taskDueDateSection`, `taskRecurrenceSection`, `selectTaskDueDateButton`, `clearTaskDueDateButton`, `dueDateOptionSwitch`, `repeatTaskSwitch`, `recurrenceFrequencyField`, `dueAlarmIcon`, `repeatAlarmIcon`) se adaptan: los switches desaparecen (tests actualizados), las llaves funcionales se conservan donde el widget sigue existiendo.

## Impacto técnico y datos

- Solo `lib/features/tasks/presentation/widgets/task_form_sheet.dart` (restructuración de `build` y secciones; `_OptionCard` se simplifica o reemplaza por tarjeta navegable).
- Estado local (`_dueDateEnabled`, `_recurrenceEnabled`, etc.) y `_submit()` sin cambios de contrato.
- **Sin cambios de esquema ni migraciones Drift. Sin cambios en domain/data.**
- Pruebas widget afectadas: `test/task_page_test.dart`, `test/task_reminder_test.dart` (y revisión de `task_recurrence_widget_test.dart`).

## Criterios de aceptación y pruebas

1. Tarea nueva: las tarjetas dicen "Tarea con fecha límite" y "Tarea cíclica" y no contienen `Switch` → prueba widget.
2. Pulsar "Tarea con fecha límite" muestra la vista con atajos, calendario y alarma; aparece flecha roja a la izquierda; el input y "Crear tarea" siguen visibles → prueba widget.
3. La flecha roja abre el diálogo de confirmación; "Descartar" revierte la opción a su estado de entrada (desactivándola si no estaba activa) y "Conservar" regresa manteniendo la configuración → prueba widget.
4. Pulsar "Tarea cíclica" muestra frecuencia/inicio/fin/alarma; "Quitar recurrencia" desactiva la opción y limpia alarmas → prueba widget.
5. Exclusividad: configurar fecha límite limpia recurrencia y viceversa → prueba widget (ya existente, adaptada).
6. Crear tarea con fecha límite y con recurrencia sigue llamando a `create`/`createRecurring` con los mismos datos → pruebas existentes de `task_page_test.dart` adaptadas y en verde.
7. `flutter analyze` y `flutter test` sin errores.

## Decisiones pendientes

1. ~~Flecha atrás~~ **Resuelto:** confirma descarte con diálogo ("Descartar" revierte a la instantánea de entrada; "Conservar" mantiene).
2. ~~Botón quitar recurrencia~~ **Resuelto:** "Quitar recurrencia" (`OutlinedButton` rojo) al final de la vista cíclica.
3. ~~Tarjeta cíclica en edición de ocurrencia simple~~ **Resuelto:** visible pero no navegable ("Esta ocurrencia pertenece a una serie").

## Evidencia de implementación

**Archivos modificados:**
- `lib/features/tasks/presentation/widgets/task_form_sheet.dart`: enum `_FormView`, tarjetas navegables `_OptionEntryCard` (sustituyeron a `_OptionCard` con switch), vistas de detalle `_SectionCard`, flecha atrás roja (`formBackButton`) con diálogo de confirmación (`formKeepChangesButton`/`formDiscardButton`, instantánea `_FormSnapshot`), botón "Quitar recurrencia" (`clearRecurrenceButton`), subtítulo de recurrencia con frecuencia, y errores de fecha/recordatorio visibles también en la vista principal.
- `test/task_page_test.dart`, `test/task_reminder_test.dart`, `test/task_recurrence_widget_test.dart`: adaptados al flujo de vistas (sin switches).

**Validación:** `dart analyze lib test` sin problemas; `flutter test` 140/140 en verde.

**Limitaciones y riesgos residuales:**
- El botón atrás del sistema (gesto Android) cierra el sheet completo, no solo la vista interna; comportamiento igual al resto del sheet, fuera de alcance.
- `docs/product-baseline.md` no requería cambios: describe el concepto (fecha límite opcional, recurrencias), no las etiquetas de UI.

## Enmienda 1 (2026-08-31): se elimina "Quitar recurrencia"

- **Estado:** implementada (aprobada por el solicitante en la misma sesión).
- Se retira el botón "Quitar recurrencia" (`clearRecurrenceButton`) y `_removeRecurrence`. La vista cíclica queda solo con sus campos de configuración.
- **Consecuencia aceptada:** una vez conservada la configuración cíclica, la opción ya no se desactiva desde el formulario; la única vía de reversión es el descarte por flecha atrás antes de conservar (o eliminar la tarea).
- Validación: `dart analyze` sin issues; `flutter test` 140/140. El test de flujo usa ahora flecha atrás → "Descartar" para desactivar la opción cíclica.
