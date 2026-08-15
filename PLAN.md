# Estado

Implementado por completo el 15 de agosto de 2026. La validación final queda registrada en `todo.md`.

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
