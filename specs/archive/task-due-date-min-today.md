# Fecha límite sin fechas pasadas

- **Estado:** implementada
- **Área:** tareas (formulario de creación y edición)
- **Última actualización:** 2026-08-31

## Contexto y objetivo

Hoy el selector de fecha límite permite elegir cualquier fecha a partir del
año 2000, incluidas fechas anteriores al día actual, lo que produce tareas
con fecha límite vencida al crearlas. El objetivo es restringir la selección
al día de hoy o posterior.

## Alcance y fuera de alcance

- **Incluye:**
  - El selector de fecha del calendario en la tarjeta «Fecha límite» no
    ofrece días anteriores a hoy (`firstDate: _today`).
  - La edición conserva la fecha límite existente aunque ya haya vencido; el
    usuario puede cambiarla, pero solo a hoy o posterior.
- **No incluye:**
  - Cambios en la fecha de inicio o finalización de la recurrencia.
  - Cambios en la fecha-hora de la alarma ni su validación.
  - Validaciones nuevas al guardar (la restricción ocurre en el selector).

## Requisitos

- Al abrir el calendario de «Fecha límite», el primer día seleccionable es
  hoy; los anteriores no son navegables ni seleccionables.
- El resto del formulario, mensajes y accesibilidad no cambian.

## Impacto técnico y datos

- Cambio de una línea en
  `lib/features/tasks/presentation/widgets/task_form_sheet.dart`
  (`_selectDueDate` pasa `firstDate: _today` a `_selectDate`).
- No hay cambios de esquema, servicios ni dependencias.

## Criterios de aceptación y pruebas

- Prueba widget: al abrir el calendario de fecha límite no es posible
  seleccionar una fecha anterior a hoy (verificación del `firstDate` del
  selector o comportamiento observable equivalente).
- Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test`.

## Decisiones pendientes

Ninguna; queda pendiente la aprobación explícita de esta spec.

## Evidencia de implementación

- `_selectDueDate` en
  `lib/features/tasks/presentation/widgets/task_form_sheet.dart` ahora pasa
  `firstDate: _today` a `_selectDate`; el calendario arranca en hoy y los
  días anteriores no son seleccionables.
- Prueba widget «due date picker does not allow days before today» en
  `test/task_reminder_test.dart`: edita una tarea con fecha límite pasada
  (10/08/2026), abre el calendario (clamp a hoy 20/08/2026), intenta elegir
  el 19 y confirma; el resultado es 20/08/2026, no 19/08/2026.
- Validación ejecutada: `dart format --output=none --set-exit-if-changed .`
  (sin cambios), `flutter analyze` (sin problemas) y `flutter test`
  (135 pruebas aprobadas).
- Sin cambios en esquema, servicios ni dependencias.
