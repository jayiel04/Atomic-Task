# Fecha límite predeterminada al crear tareas

- **Estado:** implementada
- **Área:** tareas y formulario de creación/edición
- **Última actualización:** 2026-08-30

## Contexto y objetivo

Al activar “Fecha límite”, el formulario permite actualmente guardar la tarea
sin una fecha asignada. El objetivo es que la opción siempre represente una
fecha válida y que una tarea nueva use automáticamente el día local de hoy.

## Alcance y fuera de alcance

- **Incluye:** inicialización de la fecha límite, eliminación de la fecha desde
  el formulario, validación del formulario y pruebas widget relacionadas.
- **No incluye:** cambios en entidades, repositorios, base de datos,
  migraciones, recordatorios, recurrencias ni APIs públicas.

## Requisitos

- Una tarea nueva que active “Fecha límite” debe recibir la fecha local de hoy
  como valor inicial.
- Una fecha previamente seleccionada debe conservarse al activar la opción.
- El botón “Quitar fecha límite” debe desactivar la opción y limpiar la fecha y
  la alarma asociada.
- No se debe permitir guardar mientras “Fecha límite” esté activa y no exista
  una fecha.
- La fecha límite y la recurrencia deben continuar siendo excluyentes.
- Al editar una tarea con fecha existente, la fecha debe conservarse.

## Impacto técnico y datos

El cambio queda limitado a la presentación de tareas y sus pruebas widget. La
fecha “hoy” se calculará con el proveedor de tiempo local ya inyectable por el
formulario. No hay cambios de esquema, migraciones, dependencias ni contratos
de dominio.

## Criterios de aceptación y pruebas

- Activar la opción en una tarea nueva muestra “Hoy” y marca el acceso rápido
  correspondiente.
- Guardar una tarea nueva sin abrir el calendario persiste la fecha de hoy.
- Elegir mañana reemplaza la fecha predeterminada y se persiste correctamente.
- Quitar la fecha desactiva “Fecha límite” y permite guardar sin fecha.
- La activación de recurrencia continúa apagando la fecha límite y viceversa.
- Editar una tarea con fecha conserva esa fecha después de guardar.
- Ejecutar `flutter test test/task_page_test.dart test/task_reminder_test.dart`.

## Decisiones pendientes

Ninguna. La solicitud del usuario aprobó explícitamente este alcance.

## Evidencia de implementación

- `lib/features/tasks/presentation/widgets/task_form_sheet.dart`: activa hoy
  por defecto, desactiva la opción al quitar la fecha y valida el estado antes
  de guardar.
- `test/task_page_test.dart`: cubre creación, selección de mañana, eliminación,
  recurrencia y edición.
- `flutter test test/task_page_test.dart test/task_reminder_test.dart`: 13
  pruebas pasaron.
- `dart analyze lib/features/tasks/presentation/widgets/task_form_sheet.dart
  test/task_page_test.dart`: sin problemas.
- No hubo cambios de esquema, migraciones ni APIs públicas.
