# Estado

Los planes para limitar el footer, clasificar las tareas recurrentes por fecha y confirmar el reinicio del temporizador fueron implementados por completo el 15 de agosto de 2026. No se añadieron dependencias, migraciones ni cambios de arquitectura fuera del alcance. La validación específica cubre 10 pruebas de agrupación/recurrencia, 31 pruebas de widgets y 19 pruebas del controlador del temporizador. La validación final terminó con `flutter analyze` sin observaciones, 108 pruebas aprobadas y `git diff --check` limpio; el detalle también queda registrado en `todo.md`.

# Plan implementado: footer y resumen del usuario solo en Tareas y Concentración

## Objetivo

Mostrar el footer, el nombre del usuario, las gemas y el tiempo acumulado de concentración únicamente cuando el destino activo sea `Tareas` o `Concentración`.

En `Ajustes` y `Estadísticas` se conservarán el botón de menú y el título contextual del encabezado para que la navegación siga siendo clara y accesible, pero no se construirán la tarjeta de perfil ni las cápsulas de progreso. La vista `Estadísticas` mantendrá sus propias tarjetas de datos: el alcance solo oculta el resumen compartido del encabezado.

## Resultado esperado por destino

| Destino | Menú y título | Nombre, gemas y tiempo | Footer |
| --- | --- | --- | --- |
| Tareas | Visible | Visible | Visible, con Tareas seleccionada |
| Concentración | Visible | Visible | Visible, con Concentración seleccionada |
| Ajustes | Visible | Oculto | Oculto |
| Estadísticas | Visible | Oculto | Oculto |

Al entrar en `Ajustes` o `Estadísticas`, los controles ocultos también deberán desaparecer del árbol semántico y de interacción; no bastará con volverlos transparentes o colocarlos fuera de pantalla.

## Decisiones de implementación

- Calcular una sola condición derivada en `HomeShellPage` a partir de `_selectedDestination`, enumerando explícitamente `HomeDestination.tasks` y `HomeDestination.focus` para no depender del orden del enum.
- Reutilizar esa condición para controlar el resumen del encabezado, el `bottomNavigationBar` y el Safe Area inferior, evitando estados booleanos duplicados que puedan desincronizarse de la navegación.
- Mantener un único `Scaffold` y el `IndexedStack` actual, de modo que cambiar de vista no reinicie formularios, listas ni el temporizador.
- Añadir a `HomeAppBar` una propiedad explícita, por ejemplo `showUserSummary`, que controle conjuntamente la tarjeta de perfil y la fila de métricas.
- Cuando `showUserSummary` sea `false`, construir únicamente la fila de menú y título, aprovechar el ancho liberado para el título y eliminar la altura y separación reservadas para las métricas.
- Asignar `null` a `Scaffold.bottomNavigationBar` en `Ajustes` y `Estadísticas`; `HomeBottomNavigation` no necesita conocer destinos que no representa ni cambiar su API.
- Activar la protección inferior del `SafeArea` del cuerpo cuando el footer esté ausente. En `Tareas` y `Concentración`, el footer seguirá siendo quien gestione el inset inferior.
- Conservar el drawer como ruta para volver desde `Ajustes` o `Estadísticas` a `Tareas` o `Concentración`.
- No modificar controladores, persistencia, reglas de tareas/temporizador, esquema Drift, dependencias ni los contenidos internos de las cuatro vistas.

## Pasos de implementación

1. Registrar la línea base con `git status`, `flutter analyze` y las pruebas actuales, diferenciando cualquier cambio o fallo preexistente.
2. Introducir en `HomeShellPage` la condición derivada que identifique los dos destinos principales.
3. Pasar esa condición a `HomeAppBar`, renderizar condicionalmente el footer y ajustar el `SafeArea` inferior según exista o no la barra.
4. Adaptar `HomeAppBar` para omitir por completo `profileButton`, `profileName`, `focusTimeStat`, `gemsStat` y la segunda fila cuando el resumen no deba mostrarse.
5. Ajustar restricciones, altura, paddings y claves del encabezado secundario para que `Ajustes` y `Estadísticas` no conserven un hueco vacío y sus títulos funcionen en tamaños compactos y amplios.
6. Actualizar las pruebas existentes que actualmente esperan el footer y el resumen en los cuatro destinos; al no existir el footer en destinos secundarios, el retorno se probará mediante el drawer.
7. Añadir cobertura específica de visibilidad, semántica, navegación y Safe Area para cada destino.
8. Al implementar, actualizar `agents.md` y `todo.md` para sustituir las reglas actuales que describen el header compartido y el footer como visibles en las cuatro vistas.
9. Formatear únicamente los archivos Dart modificados, ejecutar análisis y pruebas, y revisar el diff final para descartar cambios ajenos al alcance.

## Pruebas que deben añadirse o ajustarse

- En `Tareas`, encontrar exactamente un `homeBottomNavigation`, `profileButton`, `profileName`, `focusTimeStat` y `gemsStat`.
- En `Concentración`, encontrar los mismos elementos y comprobar que `focusTab` expone semántica seleccionada.
- En `Ajustes`, no encontrar el footer ni los cuatro elementos del resumen, pero sí `homeMenuButton`, el título `Ajustes` y `settingsView`.
- En `Estadísticas`, no encontrar el footer ni el resumen del encabezado, pero sí `homeMenuButton`, el título `Estadísticas`, `statisticsView` y sus tarjetas estadísticas internas.
- Verificar la secuencia `Tareas → Ajustes → Estadísticas → Concentración → Tareas` usando el perfil o el drawer según corresponda, sin depender de pestañas ocultas.
- Confirmar que al regresar a un destino principal reaparecen los valores actuales del nombre, tiempo y gemas y que sus callbacks continúan abriendo Ajustes o los paneles de detalle.
- Confirmar que una sesión restaurable abre `Concentración` con footer y resumen visibles.
- Repetir la matriz responsiva existente, incluidos 320 × 568, 568 × 320, el breakpoint de 520 px y escala de texto 1.3, sin overflow ni espacio vertical reservado para el resumen oculto.
- Verificar que `Ajustes` y `Estadísticas` respetan el inset inferior del sistema cuando no existe `HomeBottomNavigation`.
- Confirmar que el footer y los controles del resumen ausentes tampoco son enfocables, pulsables ni anunciados por accesibilidad.

## Criterios de aceptación

1. El footer aparece exclusivamente en `Tareas` y `Concentración`.
2. El nombre del usuario, las gemas y el tiempo de concentración del encabezado aparecen exclusivamente en esas dos vistas.
3. `Ajustes` y `Estadísticas` conservan menú, título, contenido, acceso mediante drawer y Safe Area correcto, sin huecos del resumen oculto.
4. Las tarjetas propias de `Estadísticas` siguen mostrando sus datos sin duplicarlos en el encabezado.
5. La navegación no recrea las vistas ni altera el estado del temporizador, las tareas o el progreso.
6. Se conservan las claves, acciones y semántica de los elementos cuando están visibles.
7. No se introducen dependencias, migraciones ni cambios de negocio.
8. `dart format --output=none --set-exit-if-changed` sobre los Dart modificados, `flutter analyze` y `flutter test` finalizan sin errores nuevos.

## Archivos previstos

- `lib/features/home/presentation/pages/home_shell_page.dart`
- `lib/features/home/presentation/widgets/home_app_bar.dart`
- `test/widget_test.dart`
- `agents.md`
- `todo.md`

No se prevén cambios en `home_bottom_navigation.dart`, controladores, modelos, persistencia, archivos generados ni dependencias.

---

# Plan implementado: tareas recurrentes en su sección de fecha correspondiente

## Objetivo

Evitar que una tarea recurrente pendiente aparezca en `Sin fecha` cuando ya tiene una fecha de ocurrencia. Cada ocurrencia deberá mostrarse en `Atrasadas`, `Hoy`, `Mañana` o `Tareas futuras` según el día que le corresponda.

Este cambio organiza la ocurrencia pendiente que ya genera el sistema; no materializa toda la serie por adelantado ni altera la regla que mantiene una sola próxima ocurrencia pendiente. Tampoco añade un bloqueo nuevo para completar, editar, eliminar o asociar concentración antes de la fecha: el alcance solicitado es la clasificación visual por fecha.

## Regla de clasificación

Definir una única fecha efectiva para agrupar cada tarea pendiente:

```text
fecha efectiva = fecha límite
                  o, si no existe y la tarea es recurrente,
                  fecha de la ocurrencia
```

Aplicar después la comparación por día del calendario local, ignorando horas:

| Fecha efectiva | Sección |
| --- | --- |
| Anterior a hoy | Atrasadas |
| Hoy | Hoy |
| Mañana | Mañana |
| Posterior a mañana | Tareas futuras |
| Ausente en una tarea no recurrente | Sin fecha |

Reglas adicionales:

- Una tarea recurrente con `dueDate` utilizará esa fecha límite, igual que ahora.
- Una tarea recurrente sin `dueDate` utilizará `occurrenceDate`, que ya se persiste para cada ocurrencia.
- Una tarea normal sin `dueDate` seguirá en `Sin fecha`.
- Las tareas completadas continuarán excluidas de las secciones pendientes.
- Al completar o eliminar una ocurrencia recurrente, la siguiente se reclasificará automáticamente usando su nueva `occurrenceDate`.
- Una serie pausada conservará su ocurrencia pendiente en la sección que corresponda; pausar seguirá afectando la generación posterior, no la clasificación de la ocurrencia existente.
- Si por datos anómalos una tarea marcada como recurrente no tiene ni `dueDate` ni `occurrenceDate`, se mantendrá el fallback seguro a `Sin fecha` en lugar de ocultarla o provocar un error.
- Cambiar la etiqueta visible de la sección `Futuras` a `Tareas futuras`, conservando el valor interno `TaskDateGroup.future` para evitar cambios innecesarios de API.

## Decisiones de implementación

- Mantener la lógica en `task_date_group.dart`, que ya es la única responsable de agrupar las tareas pendientes por fecha.
- Extraer dentro de ese archivo una función pequeña y determinista que resuelva la fecha efectiva, evitando duplicar condiciones en `TasksView`, `TaskCard` o el controlador.
- No convertir `occurrenceDate` en `dueDate` ni reescribir datos persistidos; ambas fechas conservan su significado actual.
- No cambiar `AtomicTask.isOverdueAt` ni el texto de fecha límite de `TaskCard`: el indicador de vencimiento seguirá dependiendo de una fecha límite real, mientras la fecha de ocurrencia solo decidirá la sección cuando la fecha límite sea nula.
- Conservar el orden actual de los grupos y el comportamiento colapsable; únicamente cambiarán la pertenencia de las recurrencias y la etiqueta del último grupo.
- No modificar el controlador, los casos de uso de recurrencia, Drift ni la generación idempotente de ocurrencias.

## Pasos de implementación

1. Registrar la línea base de las pruebas de agrupación y recurrencia, diferenciando los cambios preexistentes del repositorio.
2. Añadir en `task_date_group.dart` la resolución de fecha efectiva con prioridad para `dueDate` y fallback a `occurrenceDate` solo en tareas recurrentes.
3. Reutilizar la normalización local existente para enviar esa fecha a `Atrasadas`, `Hoy`, `Mañana` o `Tareas futuras`.
4. Actualizar la etiqueta de `TaskDateGroup.future` a `Tareas futuras` sin renombrar el enum ni las claves de estado de las secciones.
5. Ampliar las pruebas unitarias de agrupación con ocurrencias recurrentes sin fecha límite en cada frontera temporal.
6. Ajustar las pruebas de widget que actualmente abren `Sin fecha` para encontrar una recurrencia recién creada y verificar su nueva sección.
7. Añadir una prueba de integración que complete una ocurrencia y confirme que la siguiente aparece en `Mañana` o `Tareas futuras`, según su intervalo.
8. Al implementar, actualizar `agents.md` y `todo.md` para documentar la fecha efectiva y el nuevo nombre visible de la sección.
9. Formatear solo los Dart modificados, ejecutar las pruebas relacionadas, `flutter analyze`, la suite completa y revisar el diff final.

## Pruebas que deben añadirse o ajustarse

- Una recurrencia sin `dueDate` cuya `occurrenceDate` sea hoy aparece en `Hoy` y no en `Sin fecha`.
- Una recurrencia sin `dueDate` cuya ocurrencia sea mañana aparece en `Mañana`.
- Una recurrencia sin `dueDate` cuya ocurrencia sea posterior a mañana aparece en `Tareas futuras`.
- Una ocurrencia atrasada aparece en `Atrasadas`.
- Una recurrencia que sí tiene `dueDate` se agrupa por esa fecha aunque su `occurrenceDate` sea distinta.
- Una tarea normal sin fecha permanece en `Sin fecha`.
- Una tarea completada no aparece en ningún grupo pendiente.
- Las comparaciones respetan el día local cerca de medianoche y no dependen de la hora guardada.
- Completar una recurrencia diaria mueve la siguiente ocurrencia a `Mañana`; completar una recurrencia con un intervalo mayor la mueve a `Tareas futuras`.
- Pausar una serie no mueve su ocurrencia pendiente a `Sin fecha`.
- La prueba existente de creación y administración de recurrencias deja de buscar la tarea en `Sin fecha` y valida la sección derivada de su fecha de inicio.
- Las secciones vacías siguen sin renderizarse, las no vacías conservan su orden y el estado colapsado continúa siendo independiente.

## Criterios de aceptación

1. Ninguna tarea recurrente válida con `occurrenceDate` aparece en `Sin fecha` por carecer de `dueDate`.
2. Una ocurrencia para mañana aparece en `Mañana` y una posterior aparece en `Tareas futuras`.
3. Las fechas límite explícitas conservan prioridad y las tareas normales sin fecha no cambian de sección.
4. La siguiente ocurrencia creada al completar o eliminar se ubica automáticamente según su fecha.
5. No cambian la persistencia, el esquema Drift, la frecuencia, los intervalos, la pausa, la reactivación ni la idempotencia de las series.
6. El cambio no duplica ocurrencias ni modifica las acciones disponibles en las tarjetas.
7. `dart format --output=none --set-exit-if-changed` sobre los Dart modificados, `flutter analyze` y `flutter test` finalizan sin errores nuevos.

## Archivos previstos

- `lib/features/tasks/presentation/task_date_group.dart`
- `test/task_date_group_test.dart`
- `test/task_grouping_widget_test.dart`
- `test/task_recurrence_widget_test.dart`
- `agents.md`
- `todo.md`

No se prevén cambios en `AtomicTask`, `TaskController`, casos de uso, repositorios, base de datos, archivos generados ni dependencias.

---

# Plan implementado: reinicio destructivo y confirmado del temporizador

## Objetivo

Habilitar `Reiniciar temporizador` únicamente cuando exista una sesión en ejecución o pausada. Mientras esté habilitado, el botón tendrá fondo rojo y contenido blanco para comunicar que cancela la sesión actual. Cada pulsación deberá abrir una confirmación antes de ejecutar el reinicio.

## Estados del botón

| Estado del temporizador | Botón | Apariencia | Al pulsar |
| --- | --- | --- | --- |
| Inicial, sin iniciar | Deshabilitado | Neutra, sin fondo rojo | Sin acción |
| Sesión preparada, pero no iniciada | Deshabilitado | Neutra, sin fondo rojo | Sin acción |
| En ejecución | Habilitado | Fondo rojo y contenido blanco | Abre confirmación |
| Pausado después de iniciar | Habilitado | Fondo rojo y contenido blanco | Abre confirmación |
| Completado o cancelado | Deshabilitado | Neutra, sin fondo rojo | Sin acción |

La misma regla se aplicará a las dos variantes actuales: el botón compacto con ícono usado dentro de Home y el botón ancho con texto usado por `TimerPage`.

## Confirmación requerida

Al pulsar el botón habilitado, mostrar un único `AlertDialog` con una advertencia clara:

```text
Cancelar temporizador

¿Estás seguro de que quieres cancelar el temporizador actual?
Se perderá el progreso de esta sesión.

[No, conservar] [Sí, cancelar]
```

Reglas del diálogo:

- `No, conservar`, el botón atrás y tocar fuera del diálogo cerrarán la confirmación sin modificar el temporizador.
- `Sí, cancelar` será la única acción que invoque `TimerController.resetTimer()`.
- La acción destructiva usará el rojo `AppColors.destructive`; la acción de conservación será visualmente secundaria.
- Abrir el diálogo no pausará automáticamente una sesión en ejecución. Si el usuario conserva la sesión, el reloj continuará con el tiempo real transcurrido.
- Antes de ejecutar el reinicio, volver a comprobar que la vista siga montada y que la sesión continúe siendo reiniciable. Si terminó mientras el diálogo estaba abierto, no se borrarán el estado completado ni su resumen.
- No cancelar notificaciones, limpiar la tarea vinculada ni borrar la sesión persistida hasta recibir una confirmación afirmativa.
- Añadir claves estables sugeridas: `cancelTimerConfirmationDialog`, `keepTimerButton` y `confirmCancelTimerButton`.

## Decisiones de implementación

- Reutilizar `TimerController.controlsLocked` como fuente de verdad del estado habilitado, porque ya representa una sesión ejecutándose o una sesión iniciada que quedó pausada.
- No duplicar ese estado con un booleano local dentro de `FocusView`.
- Envolver la acción de reinicio en `_ControllerSelector` para que habilitación, colores y semántica se actualicen al iniciar, pausar, continuar, completar o reiniciar, sin reconstruir toda la vista.
- Centralizar en `FocusView` un único método asíncrono de confirmación compartido por las variantes compacta y ancha.
- Mantener `resetTimer()` libre de dependencias de Flutter y de diálogos; la confirmación pertenece a presentación y las llamadas internas o pruebas del controlador conservarán una API directa.
- Reutilizar `AppColors.destructive` para el fondo habilitado y `Colors.white` para ícono o texto. No añadir otro color hardcodeado ni una dependencia nueva.
- Mantener el alto y área táctil actuales, incluido el mínimo de 48 × 48 del botón compacto.
- Asignar la clave `resetTimerButton` a ambas variantes para que compartan cobertura y semántica.

## Pasos de implementación

1. Registrar la línea base de análisis y pruebas del temporizador, diferenciando los cambios preexistentes del repositorio.
2. Hacer que `_buildResetAction` observe `controlsLocked` mediante el selector existente y reciba el estado habilitado en cada reconstrucción.
3. Configurar `onPressed` como `null` cuando no exista una sesión ejecutándose o pausada.
4. Aplicar a las variantes compacta y ancha el fondo `AppColors.destructive`, contenido blanco y borde coherente solamente en estado habilitado; conservar un estilo neutro y legible al estar deshabilitadas.
5. Implementar el diálogo de confirmación compartido y sustituir la llamada directa a `controller.resetTimer` por ese flujo.
6. Revalidar el estado después de cerrar el diálogo y llamar a `resetTimer()` únicamente tras `Sí, cancelar`.
7. Añadir pruebas de widget para estados, colores, confirmación, cancelación, finalización durante el diálogo y ambas variantes responsivas.
8. Confirmar mediante las pruebas existentes del controlador que el reinicio aceptado sigue cancelando notificaciones, eliminando la sesión activa y limpiando la tarea vinculada sin crear un resumen.
9. Al implementar, actualizar `agents.md` y `todo.md` con la nueva regla visual y de confirmación.
10. Formatear únicamente los Dart modificados, ejecutar las pruebas relacionadas, `flutter analyze`, la suite completa y revisar el diff final.

## Pruebas que deben añadirse o ajustarse

- En estado inicial, `resetTimerButton` existe pero tiene `onPressed == null`, no usa fondo rojo y no abre un diálogo.
- Una sesión preparada para una tarea, todavía sin iniciar, mantiene el botón deshabilitado.
- Al iniciar Concentración o Descanso, el botón se habilita inmediatamente y su fondo resuelve a `AppColors.destructive` con ícono o texto blanco.
- Al pausar después de que haya transcurrido tiempo, el botón permanece habilitado y rojo.
- Al continuar, conserva el mismo estado habilitado y destructivo.
- Al completar una sesión, vuelve al estado deshabilitado y no permite eliminar el resumen de finalización.
- Pulsar el botón mientras corre o está pausado muestra exactamente un diálogo y no reinicia todavía el controlador.
- Elegir `No, conservar`, usar atrás o tocar fuera mantiene segundos restantes, modo, tarea vinculada, notificación y estado de ejecución/pausa.
- Elegir `Sí, cancelar` cierra el diálogo, reinicia el reloj al tiempo seleccionado, limpia la sesión activa y deja el botón deshabilitado y sin fondo rojo.
- Si el temporizador finaliza mientras la confirmación está abierta, confirmar después no ejecuta un reinicio tardío.
- La variante compacta y la variante ancha comparten textos, comportamiento, color destructivo, claves y resultado.
- El diálogo y los botones no producen overflow a 320 × 568, en landscape ni con escala de texto 1.3.
- La semántica comunica que el botón está deshabilitado cuando corresponde y que la confirmación contiene una acción destructiva distinta de la acción para conservar.

## Criterios de aceptación

1. `Reiniciar temporizador` solo está habilitado durante una sesión en ejecución o pausada.
2. Todo botón de reinicio habilitado tiene fondo rojo `AppColors.destructive` y contenido blanco con contraste suficiente.
3. Ningún reinicio iniciado desde la interfaz ocurre sin confirmar `Sí, cancelar`.
4. Rechazar o cerrar el diálogo conserva íntegramente la sesión.
5. Confirmar reutiliza el flujo actual de `resetTimer()` y mantiene la limpieza de notificación, persistencia y tarea vinculada.
6. Una sesión que termina durante la confirmación no pierde su resultado ni su resumen.
7. El comportamiento es idéntico en Concentración, Descanso, Home, `TimerPage` y todos los perfiles responsivos.
8. No se modifican recompensas, consumo de gemas, finalización, anuncios, esquema Drift ni dependencias.
9. `dart format --output=none --set-exit-if-changed` sobre los Dart modificados, `flutter analyze` y `flutter test` finalizan sin errores nuevos.

## Archivos previstos

- `lib/features/timer/presentation/pages/timer_page.dart`
- `test/widget_test.dart` o un nuevo `test/timer_reset_action_test.dart` enfocado en este flujo
- `test/timer_controller_test.dart`, solo para completar expectativas del reinicio existente si fueran necesarias
- `agents.md`
- `todo.md`

No se prevén cambios en `TimerController`, servicios, repositorios, base de datos, archivos generados ni dependencias.

---

# Plan: nombre de perfil junto al título de la vista

## Objetivo

Mover la tarjeta con el nombre del perfil a la parte más alta del encabezado, junto al título contextual de la vista (`Tareas`, `Concentración`, `Ajustes` o `Estadísticas`), sin truncar ni ocultar ese título.

Se interpreta “nombre” como el nombre del perfil. El tiempo de concentración y las gemas seguirán debajo, fuera de la tarjeta del perfil, y conservarán sus acciones actuales.

## Resultado visual esperado

```text
┌──────────────────────────────────────────────┐
│ [menú] Título de la vista   [(avatar) nombre]│
│                         [◷ tiempo] [◆ gemas] │
└──────────────────────────────────────────────┘
```

En pantallas estrechas se mantendrán esas dos filas. El perfil compartirá la primera fila con el título y las métricas ocuparán la segunda. En pantallas amplias se conservará la misma jerarquía visual para que el nombre permanezca arriba y alineado con el título.

## Reglas de distribución

- Dar prioridad horizontal al título de la vista.
- Mostrar siempre el título completo, en una sola línea y sin `TextOverflow.ellipsis`; se puede conservar `FittedBox` con `BoxFit.scaleDown` para los casos extremos.
- Mantener la tarjeta del perfil con un ancho máximo razonable, pero permitir que ceda espacio antes que el título.
- Aplicar la elipsis únicamente al nombre del perfil cuando el ancho no alcance.
- Conservar el avatar visible y la tarjeta completa como acceso a Ajustes.
- Mantener tiempo y gemas debajo de la tarjeta, fuera de ella, alineados a la derecha y con blancos táctiles mínimos de 48 × 48.
- Preservar las claves, tooltips, semántica, colores y callbacks existentes siempre que no sea necesario cambiarlos para expresar la nueva geometría.
- No modificar controladores, persistencia, navegación ni reglas de tareas y temporizador.

## Pasos de implementación

1. Registrar una línea base con `git status`, `flutter analyze` y las pruebas actuales del encabezado.
2. Refactorizar `lib/features/home/presentation/widgets/home_app_bar.dart` para poder componer por separado la tarjeta de perfil y la fila de métricas.
3. Cambiar la composición compacta para incluir menú, título y tarjeta de perfil en `compactHomeHeaderFirstRow`, dejando tiempo y gemas en la segunda fila.
4. Ajustar la composición amplia para que el título y el perfil compartan el nivel superior y las métricas permanezcan debajo del perfil.
5. Aplicar restricciones flexibles al perfil: ancho máximo actual de 148 px cuando haya espacio, reducción adaptativa en anchos pequeños y elipsis solo en `profileName`.
6. Revisar paddings, separaciones y alineación vertical para evitar solapamientos y no aumentar innecesariamente la altura del encabezado.
7. Actualizar las pruebas de widgets en `test/widget_test.dart` para reflejar la nueva relación geométrica.
8. Actualizar `agents.md` y `todo.md` al implementar el cambio, sustituyendo la descripción compacta anterior por la nueva decisión visual.
9. Formatear, analizar, ejecutar las pruebas y revisar el diff final.

## Pruebas que deben añadirse o ajustarse

- Verificar que la tarjeta del perfil esté dentro de la primera fila y a la derecha del título.
- Verificar que `homeTitle` termine antes de `profileCard`, sin intersección.
- Verificar que la fila de métricas empiece debajo de la tarjeta del perfil.
- Probar los cuatro títulos contextuales a 320 × 568 con escala de texto 1.3 y un nombre de perfil de 18 caracteres.
- Confirmar que el título conserva su texto completo y no usa elipsis.
- Confirmar que solo el nombre del perfil usa elipsis si falta espacio.
- Cubrir el breakpoint de 520 px, tamaños amplios y los perfiles landscape existentes.
- Confirmar ausencia de overflow y que perfil, tiempo y gemas siguen siendo pulsables y semánticamente accesibles.
- Confirmar que cambiar entre Tareas, Concentración, Ajustes y Estadísticas no altera el encabezado compartido ni su estado.

## Criterios de aceptación

1. El nombre del perfil aparece arriba, junto al título de la vista, en todos los destinos de Home.
2. Ninguno de los cuatro títulos se corta, se oculta ni muestra elipsis.
3. Ante falta de espacio, se comprime primero el nombre del perfil y no el título.
4. Tiempo y gemas permanecen debajo y fuera de la tarjeta del perfil.
5. No hay overflow en la matriz responsiva definida por el proyecto ni con escala de texto 1.3.
6. Se conservan navegación, acciones, semántica, estado compartido y reglas de negocio.
7. `dart format --output=none --set-exit-if-changed .`, `flutter analyze` y `flutter test` finalizan sin errores.

## Archivos previstos

- `lib/features/home/presentation/widgets/home_app_bar.dart`
- `test/widget_test.dart`
- `agents.md`
- `todo.md`

No se prevén cambios de base de datos, archivos generados ni dependencias.

---

# Plan: accesos rápidos para la fecha límite

## Objetivo

Mostrar debajo de la tarjeta `Fecha límite`, al crear una tarea, tres opciones rápidas con este orden:

```text
[Mañana] [Una semana] [Un mes]
```

Estas opciones asignarán una fecha límite sin abrir el calendario. El selector de fecha actual seguirá disponible para elegir cualquier otra fecha.

## Comportamiento esperado

- Mostrar las tres opciones únicamente en el formulario `Nueva tarea`, tal como indica el alcance solicitado para la creación.
- Colocarlas inmediatamente después de `_DateField` y antes de la sección de recurrencia.
- Al pulsar `Mañana`, asignar el día local siguiente.
- Al pulsar `Una semana`, asignar siete días después de la fecha local actual.
- Al pulsar `Un mes`, avanzar un mes calendario conservando el número de día cuando exista.
- Si el mes de destino no contiene ese día, usar su último día válido. Por ejemplo, desde el 31 de enero se elegirá el último día de febrero.
- Normalizar todas las fechas a año, mes y día, sin conservar horas, para respetar el manejo actual de fechas límite.
- Actualizar inmediatamente el texto de la tarjeta `Fecha límite` al elegir una opción.
- Mostrar como seleccionada la opción que coincida con `_dueDate`; una fecha elegida manualmente puede dejar las tres opciones sin selección.
- Al usar `Quitar fecha`, limpiar también la selección visual de las opciones rápidas.
- Desactivar las tres opciones mientras `_isSaving` sea verdadero.
- Mantener intactos el calendario, la edición de tareas, la recurrencia y el guardado mediante `TaskController`.

## Diseño responsivo y accesible

- Implementar las opciones con botones o chips interactivos dentro de un `Wrap`, usando separación horizontal y vertical para que puedan saltar de línea.
- Conservar el orden `Mañana`, `Una semana`, `Un mes` incluso cuando exista más de una fila.
- Asegurar un blanco táctil mínimo de 48 px de alto por opción.
- Usar un estado visual seleccionado coherente con la paleta morada de la aplicación.
- Añadir claves estables sugeridas:
  - `dueDateTomorrowOption`
  - `dueDateOneWeekOption`
  - `dueDateOneMonthOption`
- Exponer semántica de botón y estado seleccionado sin depender únicamente del color.
- Verificar que el formulario siga siendo desplazable y utilizable con teclado visible, texto ampliado y pantallas de 320 px de ancho.

## Pasos de implementación

1. Añadir una función pequeña y comprobable que normalice la fecha local de referencia y calcule los tres destinos rápidos.
2. Resolver `Un mes` mediante aritmética de calendario y ajuste al último día válido, evitando tratar un mes como una cantidad fija de días.
3. Crear el widget de opciones rápidas dentro de `task_form_sheet.dart` y renderizarlo debajo de la tarjeta de fecha límite solo cuando `_isEditing` sea falso.
4. Conectar cada opción a `setState` para actualizar la misma variable `_dueDate` utilizada por el calendario y por `_submit`.
5. Incorporar estados habilitado, deshabilitado y seleccionado, conservando las acciones actuales de elegir y quitar fecha.
6. Añadir pruebas de cálculo para cambios de mes, cambio de año, febrero y año bisiesto.
7. Añadir pruebas de widget para visibilidad, orden, interacción, selección, limpieza y guardado de cada fecha rápida.
8. Ejecutar las pruebas responsivas del formulario con teclado y escala de texto 1.3.
9. Actualizar `agents.md` y `todo.md` al implementar la mejora para registrar la nueva decisión de producto.
10. Formatear, analizar, ejecutar toda la suite y revisar el diff final.

## Pruebas que deben añadirse o ajustarse

- El formulario de creación muestra exactamente las tres opciones debajo de `Fecha límite`.
- Los formularios de edición no muestran esas opciones.
- `Mañana` selecciona y guarda la fecha local siguiente.
- `Una semana` selecciona y guarda la fecha local siete días después.
- `Un mes` selecciona y guarda el mismo día del mes siguiente cuando es válido.
- `Un mes` ajusta correctamente fechas como 31 de enero, 31 de marzo y 29 de febrero.
- Al cambiar de una opción a otra solo queda una seleccionada.
- Elegir una fecha distinta desde el calendario elimina la selección de los accesos rápidos sin alterar la fecha manual.
- `Quitar fecha` deja `_dueDate` en `null` y ninguna opción seleccionada.
- Guardar una tarea normal o recurrente envía la fecha rápida elegida por el flujo existente.
- No aparecen overflows a 320 × 568, en landscape, con escala de texto 1.3 ni con teclado simulado.

## Criterios de aceptación

1. `Mañana`, `Una semana` y `Un mes` aparecen inmediatamente debajo de la tarjeta `Fecha límite` al crear una tarea.
2. Cada opción actualiza la tarjeta y guarda la fecha correcta.
3. El calendario y la acción para quitar la fecha continúan funcionando.
4. El cálculo usa la fecha local y maneja correctamente límites de mes y año.
5. Las opciones son accesibles, responsivas y tienen estado seleccionado perceptible.
6. No cambian el modelo de tarea, el esquema Drift ni las reglas de recurrencia.
7. `dart format --output=none --set-exit-if-changed .`, `flutter analyze` y `flutter test` finalizan sin errores.

## Archivos previstos

- `lib/features/tasks/presentation/widgets/task_form_sheet.dart`
- `test/task_page_test.dart`
- Un archivo de prueba unitario para el cálculo de fechas, si la función se extrae de `task_form_sheet.dart`.
- `agents.md`
- `todo.md`

No se prevén migraciones de datos, cambios en controladores ni dependencias nuevas.

---

# Plan: equis roja para quitar la fecha límite

## Objetivo

Reemplazar el ícono actual que elimina una fecha límite seleccionada por una equis roja claramente reconocible como acción de borrado.

## Resultado esperado

- Cuando `Fecha límite` tenga una fecha, mostrar `Icons.close_rounded` dentro del botón para quitarla.
- Pintar la equis con un rojo semántico visible y con contraste suficiente sobre `AppColors.surfaceVariant`.
- Mantener el botón en su posición actual, antes del botón que abre el calendario.
- Mantener un área táctil mínima de 48 × 48.
- Usar el tooltip y la etiqueta semántica `Quitar fecha límite`.
- Al pulsarlo, establecer `_dueDate` en `null`, actualizar la tarjeta a `Sin fecha límite` y limpiar cualquier acceso rápido seleccionado.

## Alcance

El cambio se aplicará únicamente al control de borrado de `Fecha límite`. La fecha de finalización de una recurrencia reutiliza `_DateField`, pero conservará su ícono actual para evitar alterar una interfaz no solicitada.

Para aislar ambos casos, `_DateField` recibirá propiedades opcionales para el ícono, color y tooltip de limpieza. La instancia de `Fecha límite` proporcionará la equis roja y la instancia de recurrencia mantendrá los valores predeterminados existentes.

No se cambiará globalmente `AppColors.danger` si su tono actual no representa el rojo solicitado; se usará un rojo destructivo específico sin afectar otros componentes de la aplicación.

## Pasos de implementación

1. Ampliar `_DateField` con parámetros opcionales para `clearIcon`, `clearIconColor` y `clearTooltip`.
2. Conservar como valores predeterminados el ícono y estilo actuales para los demás usos de `_DateField`.
3. Configurar la tarjeta `Fecha límite` con `Icons.close_rounded`, un rojo destructivo y el tooltip `Quitar fecha límite`.
4. Conservar la clave `clearTaskDueDateButton` y el callback que asigna `null` a `_dueDate`.
5. Añadir una prueba de widget que compruebe el tipo de ícono, su color y el área táctil.
6. Añadir una prueba de interacción que pulse la equis y verifique que vuelve a mostrarse `Sin fecha límite`.
7. Confirmar que `clearRecurrenceEndDateButton` conserva el ícono existente.
8. Ejecutar formato, análisis, pruebas y revisión final del diff.

## Criterios de aceptación

1. El botón para quitar una fecha límite usa una equis roja.
2. La equis solo aparece cuando existe una fecha límite seleccionada.
3. El botón conserva su clave, accesibilidad y blanco táctil mínimo.
4. Pulsar la equis elimina la fecha y actualiza inmediatamente la tarjeta.
5. El botón de fecha de finalización recurrente no cambia de aspecto.
6. No se modifican el modelo, la persistencia ni las reglas de fechas.
7. `dart format --output=none --set-exit-if-changed .`, `flutter analyze` y `flutter test` finalizan sin errores.

## Archivos previstos

- `lib/features/tasks/presentation/widgets/task_form_sheet.dart`
- `test/task_page_test.dart`

No se prevén cambios de base de datos, controladores, archivos generados ni dependencias.

---

# Plan: panel de resumen después de cada concentración

## Objetivo

Después de finalizar cada sesión de concentración y cerrar la publicidad, mostrar un panel con:

- gemas generadas;
- duración real de la concentración;
- nombre de la tarea finalizada, cuando la sesión estaba vinculada a una tarea;
- tiempo que el usuario permaneció fuera de la aplicación después de terminar la sesión, cuando corresponda.

El panel sustituirá al `SnackBar` actual como resumen dentro de la aplicación para las sesiones de concentración. Los descansos conservarán su comportamiento actual salvo que se acuerde otro cambio.

## Secuencia requerida

```text
Termina la concentración
  → calcular y guardar progreso
  → persistir el resumen pendiente
  → completar la tarea vinculada, si existe
  → enviar la notificación del sistema
  → mostrar la publicidad de finalización
  → esperar a que la publicidad se cierre o falle de forma terminal
  → abrir el panel de resumen
  → marcar el resumen interno como consumido al cerrar el panel
```

El panel nunca debe mostrarse detrás de la publicidad. Si la plataforma no admite anuncios o el anuncio no puede mostrarse definitivamente, el panel aparecerá igualmente para no perder el resumen. Un resultado transitorio `retry` conservará el anuncio y el panel como trabajo pendiente para reintentarlos al volver a primer plano.

## Contenido del panel

El panel será un `ModalBottomSheet` seguro y desplazable, con un ancho máximo razonable en tablet y escritorio. Mostrará:

```text
Resumen de la sesión

◆ Gemas generadas        +8
◷ Concentración          25 min
✓ Tarea finalizada       Preparar propuesta       (opcional)
↗ Tiempo fuera           7 min 24 s                (opcional)

[Cerrar]
```

Reglas de contenido:

- Mostrar siempre gemas y duración, incluso cuando el total de gemas sea cero.
- Usar el texto `Gemas generadas`; no usar `Ganaste`.
- Mostrar `Tarea finalizada` solo cuando exista una tarea vinculada y su finalización se haya confirmado.
- Omitir por completo la fila de tarea en una concentración sin tarea vinculada.
- Mostrar `Tiempo fuera` únicamente si la sesión terminó mientras la aplicación no estaba en primer plano y el usuario regresó después de la hora de finalización.
- Formatear el tiempo fuera con unidades legibles, por ejemplo `45 s`, `7 min 24 s` o `1 h 5 min`.
- Incluir un botón `Cerrar`, gesto de arrastre y semántica accesible para cada dato.
- Usar propiedades simples en el widget; el panel no recibirá controladores completos.

## Definición del tiempo fuera de la aplicación

El valor se calculará así:

```text
tiempo fuera = instante de reanudación − instante real de finalización
```

Condiciones:

- El instante real de finalización será `_endsAt`, no el momento tardío en que `syncWithClock` detecte el cero.
- El resultado nunca será negativo.
- Una finalización detectada normalmente en primer plano no mostrará esta fila, aunque exista un retraso pequeño del ticker.
- Si la aplicación estaba pausada, cerrada o el proceso fue recreado cuando venció el temporizador, se considerará que la sesión terminó fuera de la aplicación.
- El instante de reanudación se capturará antes de iniciar la publicidad.
- El tiempo durante el cual se muestra la publicidad no formará parte de `Tiempo fuera`.
- Las pausas de ciclo de vida provocadas por el anuncio de pantalla completa no modificarán un valor ya calculado.
- El valor quedará congelado para ese resumen; abrir y cerrar la aplicación después no seguirá incrementándolo.

## Modelo y persistencia

Ampliar `CompletionSummary` con datos explícitos y persistibles, por ejemplo:

- `completedWhileAppWasAway`;
- `awaySecondsAfterCompletion` o un instante equivalente de regreso.

La tabla `pending_timer_summaries` deberá guardar esos valores porque el anuncio, el panel o la propia aplicación pueden cerrarse antes de consumir el resumen. Como el esquema actual es versión 6, este cambio requiere:

- subir Drift a versión 7;
- añadir columnas de forma aditiva, con valores predeterminados compatibles;
- migrar desde v6 y mantener las migraciones desde todas las versiones anteriores soportadas;
- regenerar `lib/core/database/app_database.g.dart` mediante `build_runner`, sin editarlo manualmente;
- probar que un resumen pendiente recupera gemas, duración, tarea, orden del anuncio y tiempo fuera.

No se duplicarán recompensas, tiempo acumulado ni finalizaciones de tareas al recuperar un resumen.

## Coordinación con el ciclo de vida

- Hacer que `TimerController` conozca explícitamente cuándo la aplicación sale y vuelve a primer plano mediante métodos de ciclo de vida.
- En pausa, persistir la sesión y registrar el estado necesario sin alterar el temporizador.
- En reanudación, capturar una sola marca temporal, actualizar el tiempo fuera si corresponde y después sincronizar el reloj.
- Al restaurar una sesión activa cuyo `_endsAt` ya pasó, usar `_endsAt` como `completedAt` y la hora de restauración como regreso.
- Si el resumen ya se creó mientras la aplicación estaba pausada, completar y persistir `awaySecondsAfterCompletion` al reanudar.
- Evitar que una pausa causada por el intersticial se confunda con tiempo fuera posterior a la sesión.

## Coordinación con la publicidad

El contrato del anuncio debe indicar cuándo terminó realmente la experiencia de pantalla completa. Actualmente no basta con esperar la llamada que inicia `ad.show()`.

Plan técnico:

1. Hacer que la operación del anuncio complete su `Future` desde `onAdDismissedFullScreenContent` o `onAdFailedToShowFullScreenContent`.
2. Mantener `TimerController` como único coordinador del trabajo pendiente para evitar una carrera entre su `handleAppResumed` y el observador interno del servicio de anuncios.
3. No exponer el resumen a Home mientras el anuncio de esa sesión siga visible o pendiente de cierre.
4. Tras recibir `shown`, `unsupported` o un fallo terminal, publicar el resumen para abrir el panel.
5. Conservar `adPending` e `inAppPending` de manera independiente y persistente para los reintentos.
6. Impedir que una reconstrucción de widgets, una doble reanudación o un callback repetido abra dos anuncios o dos paneles para el mismo `sessionId`.

## Presentación y consumo único

- Crear un widget dedicado, sugerido como `FocusCompletionSummarySheet`, dentro de la presentación del temporizador.
- Reemplazar `_showCompletionSummary` para sesiones de concentración por una función asíncrona que abra el panel.
- Mantener una protección por `sessionId` mientras el panel esté programado o abierto.
- Marcar `inAppPending` como falso únicamente después de que el panel se haya presentado y cerrado correctamente.
- Si la aplicación termina antes de cerrar el panel, conservar el resumen y volver a mostrarlo en el siguiente inicio.
- Limpiar `pending_timer_summaries` solo cuando notificación, anuncio, tarea y panel hayan terminado sus trabajos pendientes.

## Pasos de implementación

1. Añadir pruebas de caracterización del orden actual entre finalización, tarea, anuncio y resumen.
2. Extender `CompletionSummary`, su `copyWith`, repositorio y tabla Drift con los datos de tiempo fuera.
3. Crear y probar la migración aditiva de esquema v6 a v7 y las rutas desde versiones anteriores.
4. Conservar `_endsAt` antes de limpiar la sesión y usarlo como instante real de finalización.
5. Añadir manejo explícito de pausa/reanudación y cálculo único del tiempo fuera.
6. Ajustar el servicio de anuncios para que su resultado se complete al cerrar o fallar el intersticial.
7. Serializar anuncio y publicación del resumen dentro de `TimerController`.
8. Crear `FocusCompletionSummarySheet` con las filas obligatorias y opcionales.
9. Sustituir el `SnackBar` de concentración en `HomeShellPage` por el panel y consumirlo al cerrarlo.
10. Mantener el resumen actual de descanso sin regresiones.
11. Actualizar `agents.md`, `todo.md` y `arquitecture.md` con la nueva secuencia y el esquema vigente.
12. Ejecutar generación Drift, formato, análisis, pruebas completas y revisión del diff.

## Pruebas requeridas

### Controlador y publicidad

- El panel no queda disponible antes de cerrar el anuncio.
- Cerrar el anuncio habilita exactamente un resumen para Home.
- Un anuncio no soportado o con fallo terminal permite mostrar el panel.
- Un resultado `retry` persiste anuncio y panel y los recupera en la siguiente reanudación.
- Dos callbacks o reanudaciones no duplican anuncio, gemas, tarea ni panel.
- La tarea vinculada se completa antes de presentar su nombre como `Tarea finalizada`.

### Tiempo fuera

- Una sesión que termina en primer plano no muestra `Tiempo fuera`.
- Si termina a las 10:25 y el usuario vuelve a las 10:32, el resumen guarda exactamente 7 minutos.
- El tiempo del anuncio no incrementa el tiempo fuera.
- Restaurar el proceso después de `_endsAt` produce el mismo cálculo.
- Volver a pausar la aplicación después del cálculo no modifica el valor guardado.
- Los resultados negativos o inferiores a la precisión elegida se normalizan correctamente.

### Persistencia

- Migración v6 → v7 con valores compatibles para resúmenes antiguos.
- Migraciones desde todas las versiones soportadas hasta v7.
- Guardar, cargar y consumir los nuevos campos del resumen.
- Recuperar un resumen después de cerrar la aplicación entre el anuncio y el panel.

### Widgets

- El panel muestra gemas y duración en toda sesión de concentración.
- La fila de tarea aparece solo cuando aplica y contiene el título correcto.
- La fila de tiempo fuera aparece solo cuando aplica y usa el formato correcto.
- Cerrar el panel consume el resumen y evita que vuelva a abrirse.
- El panel es accesible y no desborda a 320 × 568, con texto 1.3, Safe Area y landscape.
- Las sesiones de descanso conservan el comportamiento existente.

## Criterios de aceptación

1. Cada concentración completada produce un único panel de resumen.
2. Cuando se muestra publicidad, el panel aparece únicamente después de cerrarla.
3. El panel muestra gemas generadas y duración de la concentración.
4. El nombre de la tarea aparece solo cuando esa tarea fue finalizada por la sesión.
5. El tiempo fuera aparece solo cuando la sesión terminó con la aplicación fuera y no incluye la publicidad.
6. El flujo sobrevive a pausa, cierre, recreación del proceso y reintento del anuncio.
7. No se duplican recompensas, tareas completadas, anuncios ni paneles.
8. El resumen sigue apareciendo si los anuncios no están soportados o fallan definitivamente.
9. Drift migra de forma ascendente sin perder datos.
10. `dart format --output=none --set-exit-if-changed .`, `flutter analyze` y `flutter test` finalizan sin errores.

## Archivos previstos

- `lib/app.dart`
- `lib/core/database/app_database.dart`
- `lib/core/database/app_database.g.dart` — regenerado
- `lib/features/timer/domain/entities/timer_session.dart`
- `lib/features/timer/data/repositories/timer_session_repository_impl.dart`
- `lib/features/timer/data/services/admob_focus_completion_ad_service.dart`
- `lib/features/timer/presentation/controllers/timer_controller.dart`
- `lib/features/timer/presentation/widgets/focus_completion_summary_sheet.dart` — nuevo
- `lib/features/home/presentation/pages/home_shell_page.dart`
- `test/app_database_test.dart`
- `test/timer_controller_test.dart`
- `test/widget_test.dart`
- `agents.md`
- `todo.md`
- `arquitecture.md`

No se prevén dependencias nuevas ni cambios destructivos de tablas existentes.
