# Renovación del AppBar y navegación lateral

## Resumen

- Adaptar la Home al diseño aprobado: encabezado integrado con el fondo, menú izquierdo, perfil compacto y estadísticas fuera de la tarjeta.
- Incorporar un sidebar izquierdo con `Tareas`, `Concentración`, `Ajustes`, `Estadísticas` y la acción `Restablecer progreso`.
- Conservar la navegación inferior para el acceso rápido a Tareas y Concentración.
- No modificar persistencia, reglas del temporizador, CRUD, gemas, anuncios ni notificaciones.

## Cambios de implementación

### Home y navegación

- Sustituir el índice numérico por un destino tipado: `tasks`, `focus`, `settings` y `statistics`.
- Mantener las cuatro vistas montadas mediante `IndexedStack`.
- Abrir normalmente en Tareas; una sesión recuperada o preparada seleccionará Concentración.
- Mantener visible la barra inferior en las cuatro vistas. En Ajustes o Estadísticas, ninguno de sus dos destinos aparecerá seleccionado.
- Tocar la tarjeta de avatar y nombre abrirá directamente Ajustes.

### AppBar

- Eliminar la franja lila de ancho completo y usar el fondo compartido de la aplicación.
- Colocar a la izquierda un botón de menú con blanco táctil mínimo de 48 × 48.
- Mostrar el título contextual con capitalización normal: `Tareas`, `Concentración`, `Ajustes` o `Estadísticas`.
- A la derecha, mostrar una tarjeta que contenga únicamente avatar y nombre.
- Debajo de la tarjeta, colocar tiempo y gemas fuera de ella.
- Cada estadística tendrá su ícono seguido por una barra lila clara que contenga el valor.
- Mantener elipsis para nombres largos y adaptación a pantallas pequeñas y texto ampliado.

### Sidebar

- Crear un drawer propiedad de Home que se abra desde la izquierda.
- Encabezarlo con `assets/images/logo_icon.png`, el texto `Atomic Task` y un botón para cerrarlo.
- Mostrar, en este orden, las vistas Tareas, Concentración, Ajustes y Estadísticas, resaltando la activa.
- Cerrar el sidebar después de elegir una vista.
- Colocar `Restablecer progreso` como acción diferenciada en la parte inferior.
- Conservar la confirmación actual antes de restablecer; al aceptar, cerrar el sidebar, limpiar el progreso y activar nuevamente la solicitud obligatoria del nombre.
- No mostrar nombre, tiempo ni gemas dentro del sidebar.
- Mantener el antiguo `ProgressDrawer` únicamente para el wrapper heredado de `TimerPage`; la Home dejará de utilizarlo.

### Nuevas vistas

- Ajustes permitirá editar el nombre con las reglas existentes: obligatorio, recortado y máximo de 18 caracteres.
- Estadísticas mostrará únicamente datos ya disponibles: tiempo total de concentración, gemas, tareas pendientes y tareas completadas.
- Los valores se actualizarán en vivo desde `TimerController` y `TaskController`.
- No se añadirán historial, gráficos, tablas, migraciones ni nuevas dependencias.

## Interfaces afectadas

- Introducir un tipo `HomeDestination` compartido por el shell, sidebar y navegación inferior.
- Ampliar `HomeAppBar` con callbacks separados para abrir el menú y seleccionar Ajustes.
- Cambiar `HomeBottomNavigation` para aceptar el destino actual y permitir que no haya selección cuando la vista sea Ajustes o Estadísticas.
- Crear componentes de presentación para el sidebar, Ajustes y Estadísticas, recibiendo datos y callbacks simples en lugar de controladores completos.

## Pruebas y aceptación

- Verificar apertura y cierre del sidebar mediante menú, botón de cierre y toque exterior.
- Comprobar logo, texto `Atomic Task`, orden de destinos, resaltado activo y ausencia de datos de progreso dentro del sidebar.
- Verificar que la tarjeta del perfil selecciona Ajustes.
- Confirmar que la barra inferior continúa funcionando desde cualquiera de las cuatro vistas.
- Comprobar que cambiar de vista no crea rutas ni reinicia temporizador, formularios o desplazamiento.
- Validar edición y persistencia del nombre desde Ajustes.
- Validar actualización en vivo de tiempo, gemas y conteos en Estadísticas.
- Probar cancelación y confirmación de `Restablecer progreso`.
- Verificar geometría del encabezado: avatar y nombre dentro de la tarjeta; tiempo y gemas debajo y fuera de ella.
- Ejecutar la matriz responsiva existente, escala de texto 1.3, semántica, blancos táctiles, `flutter analyze` y todas las pruebas.

## Supuestos

- La navegación inferior permanece visible porque forma parte del diseño aprobado.
- `Restablecer progreso` es una acción del sidebar, no una quinta vista.
- Se usa la ortografía `Restablecer progreso`.
- Esta fase no requiere cambios de base de datos ni de lógica de negocio.

---

# Plan futuro: tareas cíclicas

## Objetivo

Permitir crear tareas que vuelvan a aparecer automáticamente según una periodicidad, por ejemplo cada día, cada semana o cada mes, sin romper las tareas actuales, la asociación con Concentración ni la persistencia local.

Esta sección define el trabajo futuro. No implica implementar la funcionalidad hasta confirmar las decisiones de producto indicadas al final.

## 1. Reglas de negocio

- Mantener las tareas actuales sin recurrencia sin cambios de comportamiento.
- Permitir recurrencias diarias, semanales y mensuales.
- Permitir un intervalo configurable: cada 1, 2, 3, etc. días, semanas o meses.
- Una tarea recurrente tendrá una fecha de inicio.
- La fecha de finalización será opcional.
- Al completar una ocurrencia, crear la siguiente ocurrencia pendiente cuando corresponda.
- La tarea vinculada a una sesión de Concentración se completará mediante el mismo flujo existente y generará la siguiente ocurrencia de su serie.
- No crear ocurrencias duplicadas si la operación se repite o la aplicación se cierra durante el proceso.

## 2. Modelo de dominio

Crear los siguientes conceptos dentro de la funcionalidad de tareas:

- `RecurrenceFrequency` para representar día, semana y mes.
- `RecurrenceRule` para representar frecuencia, intervalo, fechas de inicio y fin, y estado activo.
- `RecurrenceCalculator` para calcular la siguiente ocurrencia usando fechas locales.
- Una política de generación que determine cuándo una serie puede crear otra ocurrencia.

Ampliar `AtomicTask` con los datos necesarios para identificar una ocurrencia recurrente:

- identificador opcional de la regla o serie;
- fecha de ocurrencia;
- indicador de recurrencia;
- datos de presentación de la periodicidad cuando sean necesarios.

La regla debe permanecer separada de la ocurrencia para permitir conservar el historial de tareas completadas y controlar la serie de forma independiente.

## 3. Persistencia Drift versión 5

Añadir la tabla `task_recurrence_rules` con:

- frecuencia;
- intervalo;
- fecha de inicio;
- fecha de finalización opcional;
- estado activo o pausado;
- fechas de creación y actualización.

Ampliar `tasks` con:

- relación opcional con `task_recurrence_rules`;
- fecha única de ocurrencia.

La migración v4 → v5 debe ser ascendente y aditiva:

- conservar todas las tareas existentes;
- dejar las tareas actuales sin regla de recurrencia;
- no renombrar ni eliminar columnas existentes;
- garantizar que una regla no genere dos veces la misma ocurrencia.

Después de cambiar el esquema, ejecutar:

```text
dart run build_runner build --delete-conflicting-outputs
```

El archivo `app_database.g.dart` no se editará manualmente.

## 4. Casos de uso y coordinación

Añadir casos de uso para:

- crear una tarea recurrente;
- calcular la siguiente ocurrencia;
- completar una ocurrencia y generar la siguiente;
- pausar y reactivar una serie;
- editar una ocurrencia o una serie;
- eliminar una ocurrencia;
- eliminar una serie completa.

La finalización de una ocurrencia debe ser transaccional:

1. marcar la ocurrencia actual como completada;
2. calcular la fecha siguiente;
3. crear la nueva tarea pendiente si la serie continúa activa;
4. impedir duplicados mediante la regla de persistencia correspondiente.

El callback actual de finalización desde `TimerController` debe delegar en el caso de uso de tareas, sin duplicar reglas dentro del temporizador.

## 5. Formulario y presentación

Ampliar `TaskFormSheet` con una sección `Repetir` que permita:

- activar o desactivar la recurrencia;
- elegir frecuencia;
- elegir intervalo;
- seleccionar fecha de inicio;
- seleccionar fecha de finalización opcional.

Las tareas sin recurrencia conservarán el formulario actual.

En `TaskCard` mostrar, cuando corresponda:

- una etiqueta como `Cada día`, `Cada semana` o `Cada 2 meses`;
- la próxima fecha de ocurrencia;
- si la serie está activa o pausada.

Las acciones de serie deben distinguir entre:

- completar la ocurrencia actual;
- pausar o reactivar futuras ocurrencias;
- eliminar solo la ocurrencia actual;
- eliminar toda la serie.

## 6. Recuperación al abrir la aplicación

Durante la inicialización de tareas:

- revisar las series activas;
- comprobar si existe la siguiente ocurrencia esperada;
- generar la ocurrencia faltante de forma idempotente;
- conservar el estado de las tareas existentes;
- no generar duplicados después de cierres inesperados.

La reconciliación debe usar fechas locales, igual que la detección actual de vencimiento.

## 7. Pruebas

### Dominio

- cálculo diario;
- cálculo semanal;
- cálculo mensual;
- intervalos mayores que uno;
- fechas de inicio y fin;
- reglas pausadas;
- meses con distinta cantidad de días;
- prevención de fechas duplicadas.

### Datos

- migración Drift v4 → v5;
- persistencia y lectura de reglas;
- asociación entre regla y ocurrencia;
- finalización transaccional;
- recuperación después de cerrar y abrir la aplicación;
- idempotencia de la reconciliación.

### Presentación e integración

- creación de una tarea recurrente;
- edición de una ocurrencia;
- edición de una serie;
- pausa y reactivación;
- eliminación de una ocurrencia;
- eliminación de una serie;
- flujo tarea recurrente → Concentración → siguiente ocurrencia;
- responsividad, teclado, Safe Area y escala de texto existentes.

## 8. Verificación final

Ejecutar, después de implementar:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
```

## Decisiones de producto cerradas

1. Si la aplicación estuvo cerrada y se omitieron varias ocurrencias, la recuperación creará únicamente la próxima ocurrencia pendiente.
2. Si una recurrencia mensual está configurada para el día 31 y el mes no tiene 31 días, la ocurrencia se moverá al último día disponible de ese mes.
3. Al editar una tarea recurrente, la interfaz permitirá elegir entre modificar solo la ocurrencia actual o modificar toda la serie.
4. Al eliminar una tarea recurrente, la interfaz permitirá elegir entre eliminar solo la ocurrencia actual o eliminar toda la serie.
5. La primera versión incluirá recurrencias diarias, semanales y mensuales. No incluirá recurrencia anual ni selección de días específicos de la semana.

---

# Plan futuro: rediseño del footer de navegación

## Resumen

Transformar el footer actual, que ocupa todo el ancho y utiliza una línea inferior como indicador, en una píldora flotante centrada sobre el fondo de la aplicación.

Se mantendrán exactamente los destinos `Tareas` y `Concentración`, sus callbacks, claves de prueba y semántica actual.

## Cambios de implementación

### Footer visual

Actualizar `HomeBottomNavigation` para:

- dejar transparente el área exterior del footer;
- centrar una superficie flotante con ancho máximo en pantallas grandes;
- usar bordes redondeados amplios;
- aplicar sombra suave y borde lila tenue;
- conservar el Safe Area inferior;
- mantener márgenes laterales y separación respecto al borde inferior;
- evitar que la superficie vuelva a ocupar todo el ancho en tablets o landscape.

La superficie flotante usará los colores existentes de `AppColors`, sin añadir dependencias ni cambiar el tema global.

### Destinos

Mantener únicamente:

- `Tareas`;
- `Concentración`.

Cada destino conservará:

- icono;
- etiqueta visible;
- objetivo táctil mínimo de 48 × 48;
- callback existente;
- claves `tasksTab` y `focusTab`.

### Estado activo

Sustituir la línea inferior por una cápsula de selección:

- fondo `primarySoft`;
- icono y texto en `primary`;
- destinos inactivos transparentes;
- destinos inactivos con texto e icono `muted`;
- transición animada breve mediante `AnimatedContainer`;
- solo un destino seleccionado en Tareas o Concentración;
- ningún destino seleccionado en Ajustes o Estadísticas.

La semántica `selected` permanecerá sin cambios.

### Responsividad y accesibilidad

- Usar botones con tamaño mínimo de 48 × 48.
- Mantener visibles las etiquetas con escala de texto 1.3.
- Permitir que el contenido interno se adapte en 320 px de ancho.
- Mantener la navegación visible en tablets y landscape.
- Evitar overflow por nombres de destinos o texto ampliado.
- Mantener contraste suficiente entre estados activos e inactivos.
- Conservar el comportamiento de toque, foco y feedback visual.

## Fuera de alcance

- No añadir botón central ni nuevos destinos.
- No modificar `HomeDestination`.
- No cambiar la navegación del `IndexedStack`.
- No modificar AppBar, sidebar, tareas, temporizador o estadísticas.
- No añadir persistencia, migraciones ni dependencias.
- No cambiar reglas de negocio.

## Pruebas

Añadir o adaptar pruebas para verificar:

- el footer aparece como superficie flotante y no como una franja completa;
- la superficie está centrada y respeta sus márgenes;
- existen exactamente Tareas y Concentración;
- iconos y etiquetas permanecen visibles;
- el destino activo usa la cápsula morada;
- Ajustes y Estadísticas no muestran selección;
- la semántica `selected` funciona correctamente;
- cada destino activa la vista correspondiente;
- los objetivos táctiles miden al menos 48 × 48;
- no hay overflow en tamaños compactos, tablets, landscape y escala de texto 1.3;
- el Safe Area inferior se respeta.

## Verificación final

Ejecutar:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
```

## Supuestos cerrados

- Dirección visual: píldora flotante.
- Contenido: exactamente Tareas y Concentración.
- Indicador activo: fondo de cápsula morado.
- Las etiquetas permanecen visibles siempre para conservar la accesibilidad y el comportamiento actual.
- Se reutilizan `AppColors` y la animación breve existente.

# Plan futuro: rediseño responsivo del header

## Problema

En teléfonos estrechos, el título de la vista compite horizontalmente con el botón de menú, el perfil y las estadísticas. Como resultado, nombres como `Concentración` pueden aparecer cortados con elipsis.

## Objetivo

Garantizar que el nombre completo de la vista sea legible en cualquier tamaño de pantalla y con escala de texto ampliada, manteniendo el perfil, el tiempo, las gemas, la navegación y la información existentes.

## Cambios de implementación

### Estructura responsiva

- Mantener el botón de menú con un área táctil mínima de 48 × 48.
- En pantallas estrechas, separar el header en dos filas:
  - primera fila: botón de menú y título de la vista con todo el ancho restante;
  - segunda fila: tarjeta de perfil y estadísticas de tiempo y gemas.
- En pantallas amplias, conservar una composición horizontal con menú, título y resumen de perfil.
- Usar un breakpoint basado en el ancho disponible, sin depender de un modelo concreto de dispositivo.
- Permitir que el header crezca verticalmente en la variante de dos filas sin producir overflow en el contenido del temporizador.

### Título

- Mantener los títulos actuales: `Tareas`, `Concentración`, `Ajustes` y `Estadísticas`.
- No usar elipsis para el nombre de la vista.
- Ajustar el título al espacio disponible mediante tamaño flexible o reducción proporcional, conservando como prioridad la lectura del texto completo.
- Mantener capitalización, peso visual, color, clave de prueba y semántica actuales.

### Perfil y estadísticas

- Conservar la tarjeta compacta con avatar y nombre.
- Mantener la elipsis únicamente para nombres de perfil largos.
- Mantener tiempo y gemas fuera de la tarjeta, debajo de ella en el resumen del perfil.
- Conservar iconos, valores, callbacks, claves de prueba y semántica actuales.
- No cambiar las reglas de cálculo ni la actualización en vivo del tiempo y las gemas.

## Responsividad y accesibilidad

- Verificar anchos de 320 px, 360 px, 412 px y tamaños amplios.
- Verificar escala de texto 1.3 y nombres de perfil largos.
- Mantener el Safe Area y evitar overflow horizontal o vertical.
- Conservar áreas táctiles mínimas de 48 × 48.
- Mantener contraste y semántica del menú, título, perfil y estadísticas.
- Confirmar que el header ampliado no oculta los controles del temporizador ni el footer.

## Fuera de alcance

- No cambiar los títulos ni agregar nuevas vistas.
- No modificar sidebar, footer, navegación, temporizador, tareas, gemas, notificaciones o AdMob.
- No modificar reglas de negocio, persistencia, migraciones ni dependencias.
- No cambiar el diseño del perfil más allá de reubicarlo dentro de la estructura responsiva necesaria.

## Pruebas y aceptación

Añadir o adaptar pruebas para verificar:

- `Concentración` se muestra completo en anchos compactos y con escala de texto 1.3.
- `Tareas`, `Ajustes` y `Estadísticas` también se muestran completos.
- El header no presenta overflow en teléfonos estrechos, tablets, landscape ni nombres largos.
- En la variante compacta, el título queda en la primera fila y el perfil/estadísticas en la segunda.
- En la variante amplia, menú, título y perfil permanecen alineados sin solaparse.
- Avatar y nombre siguen dentro de la tarjeta; tiempo y gemas siguen debajo y fuera de ella.
- Los callbacks del menú y del perfil continúan funcionando.
- El temporizador, el footer y la navegación siguen siendo accesibles después del aumento de altura del header.
- Se mantienen las claves y la semántica existentes.

## Verificación final

Ejecutar:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
git diff --check
```

## Supuestos cerrados

- La solución principal para teléfonos estrechos es una composición de dos filas.
- En pantallas amplias se conserva la composición horizontal existente.
- El título de la vista tiene prioridad sobre la reducción del tamaño del texto.
- Solo se permite elipsis para el nombre del perfil, no para el nombre de la vista.
