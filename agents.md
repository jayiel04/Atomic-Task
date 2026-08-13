# Guía de trabajo para Atomic Task

Este archivo es la referencia para cualquier persona o agente que modifique el repositorio. Antes de implementar, leer también [todo.md](todo.md) y [arquitecture.md](arquitecture.md).

## 1. Objetivo innegociable

Atomic Task une tareas, concentración, descanso y progreso local. Una mejora visual no puede romper reglas de negocio, datos guardados, notificaciones, asociación tarea–sesión ni soporte responsivo.

Trabajar de forma incremental. Primero conservar comportamiento; después reducir acoplamiento. No hacer una reescritura completa para implementar la nueva Home.

## Estado implementado del plan

- `HomeShellPage` es la Home real de `AtomicTimerBootstrap`; `TaskPage` y `TimerPage` se conservan únicamente como wrappers compatibles con pruebas y rutas heredadas.
- La Home usa un único `Scaffold`, `IndexedStack`, `HomeAppBar` y `HomeBottomNavigation`.
- El inicio normal es Tareas; una sesión persistida preparada, pausada o activa abre Concentración.
- La persistencia Drift está en versión 4 con `active_timer_sessions` y `pending_timer_summaries`.
- Los resúmenes de finalización se entregan por notificación del sistema y SnackBar flotante; el texto nunca usa `Ganaste`.
- La Fase 7 de extracción arquitectónica sigue fuera de esta entrega para respetar el alcance del plan.

## 2. Fuente de verdad de la nueva Home

La nueva navegación es un único shell con dos vistas internas:

```text
HomeShellPage
├── HomeAppBar
├── IndexedStack
│   ├── TasksView
│   └── FocusView
└── HomeBottomNavigation
    ├── Tareas
    └── Concentración
```

### 2.1 AppBar compartido

El AppBar aparece en ambas vistas y tiene dos zonas:

- izquierda: título de la vista o marca;
- derecha: resumen compacto del usuario.

La geometría del resumen derecho es obligatoria:

```text
┌──────────────────────────────────────────┐
│ TÍTULO              (perfil)  JAVIER    │
│                               ◷ 120m ◆ 8 │
└──────────────────────────────────────────┘
```

Interpretación estructural exacta:

```text
Row
├── título
├── espacio flexible
└── Row de usuario
    ├── ícono de perfil
    ├── espacio horizontal pequeño
    └── Column
        ├── nombre del usuario
        └── Row de estadísticas
            ├── ícono de tiempo + tiempo acumulado
            └── ícono de gema + cantidad de gemas
```

Reglas:

- el nombre está arriba del tiempo y las gemas;
- el ícono de perfil está a la izquierda del bloque de dos líneas;
- debe existir un espacio pequeño, visible y consistente entre perfil y datos;
- usar los íconos equivalentes a `person_rounded`, `schedule_rounded` y `diamond_rounded`;
- no mostrar “Hola” ni otro saludo;
- el nombre admite hasta 18 caracteres y debe usar `Flexible`, ajuste o elipsis para no desbordar;
- el perfil y las estadísticas usan la misma fuente de estado en ambas pestañas;
- tocar el ícono de perfil abre el panel lateral derecho con edición del nombre, progreso y restablecimiento.

### 2.2 Barra inferior

La barra inferior:

- contiene exactamente dos destinos;
- conserva este orden: Tareas, Concentración;
- muestra ícono y etiqueta en ambos destinos;
- permanece visible en ambas vistas;
- usa el color/indicador morado únicamente en el destino activo;
- expone semántica seleccionada y blancos táctiles de al menos 48 × 48;
- respeta el Safe Area inferior;
- cambia el contenido de Home sin `Navigator.push` ni `Navigator.pop`.

Claves sugeridas para pruebas:

```text
homeBottomNavigation
tasksTab
focusTab
profileButton
profileName
focusTimeStat
gemsStat
createTaskButton
```

No cambiar las claves existentes de formularios, tarjetas o controles sin actualizar primero sus pruebas.

### 2.3 Vista Tareas

Debe conservar:

- resumen de pendientes y completadas;
- estados loading, error y vacío;
- secciones Pendientes y Completadas;
- crear, editar, completar, reabrir y eliminar;
- fechas límite y estado vencido;
- minutos de concentración asociados;
- confirmación antes de eliminar;
- elección entre completar ahora o usar concentración;
- formulario y selector de duración adaptables al teclado.

`TasksView` será contenido embebible. No debe crear otro `Scaffold`, AppBar, navegación inferior, fondo o Safe Area exterior.

La acción “Nueva tarea” debe permanecer visible y accesible dentro de esta vista. La lista continúa siendo desplazable y mantiene un ancho máximo razonable en pantallas grandes.

### 2.4 Vista Concentración

Debe conservar:

- modos Concentración y Descanso;
- dial, reloj y selector de minutos;
- mensaje de estado;
- iniciar, pausar, continuar y reiniciar;
- tarea vinculada cuando corresponda;
- bloqueo de modo/duración tras comenzar;
- reglas de gemas y validación de descanso;
- sincronización con el reloj y ciclo de vida;
- persistencia, notificaciones y anuncio de finalización.

`FocusView` será contenido embebible. No debe crear otro `Scaffold`, AppBar, barra inferior ni Safe Area exterior.

Al cambiar a Tareas, un temporizador activo sigue ejecutándose. Al volver, conserva modo, duración, segundos restantes, estado y tarea vinculada.

### 2.5 Flujo Tareas → Concentración

El flujo esperado es:

```text
Tarea pendiente
  → Usar modo concentración
  → elegir duración
  → guardar focusMinutes
  → preparar el temporizador
  → seleccionar la pestaña Concentración
  → iniciar y terminar sesión
  → completar la tarea vinculada
```

La tarea no se completa al seleccionar la duración. Si el temporizador está bloqueado, no se reemplaza la sesión actual y se conserva el mensaje de error existente.

## 3. Reglas funcionales que no deben cambiar accidentalmente

- Concentración predeterminada: 25 minutos.
- Descanso predeterminado: 5 minutos.
- Máximo configurable: 120 minutos.
- Concentración: 1 gema por cada 3 minutos completos.
- Descanso: 1 gema por cada minuto completo.
- Un descanso exige gemas suficientes antes de iniciar.
- La primera ejecución solicita un nombre obligatorio.
- El progreso se guarda localmente.
- Terminar concentración vinculada completa la tarea correspondiente.
- Reiniciar progreso borra nombre, gemas y tiempo, con confirmación.
- Drift se mantiene compatible con esquemas anteriores.

## 4. Límites de arquitectura

Seguir estas dependencias:

```text
presentation → application → domain
data ──────────────────────→ domain
app/bootstrap → todas las implementaciones para ensamblarlas
```

Reglas obligatorias:

- `domain` no importa Flutter, Drift ni plugins de plataforma;
- una funcionalidad no importa `data`, widgets o controladores de otra;
- la coordinación entre funcionalidades vive en `app/coordinators` o en contratos de aplicación tipados;
- los repositorios se consumen mediante interfaces;
- las dependencias se reciben por constructor;
- no crear singletons globales mutables;
- no añadir un paquete de estado, DI o navegación sin una necesidad comprobable;
- no usar `core` como depósito de código sin dueño;
- no colocar reglas de negocio dentro de widgets;
- no duplicar el estado del perfil, gemas o tiempo en Home.

## 5. Reutilización de componentes

Mantener un componente dentro de su funcionalidad mientras solo tenga un consumidor.

Moverlo a `design_system/components` únicamente cuando:

- sea puramente visual;
- tenga una API neutral respecto al negocio;
- se use en dos o más funcionalidades, o exista una segunda reutilización inmediata y comprobable.

Ejemplos compartibles:

- fondo de la aplicación;
- tarjeta/superficie visual;
- estado vacío;
- tarjeta de error;
- indicador visual de estadística.

Ejemplos que conservan dueño:

- `HomeAppBar` y `HomeBottomNavigation`: `features/home`;
- `TaskCard`: `features/tasks`;
- `TimerDial`, `ModeSelector` y selector de tiempo: `features/timer`;
- resumen semántico del usuario: `features/profile` o `features/home`, no el design system genérico.

Preferir widgets pequeños que reciban datos y callbacks simples. Un widget compartido no debe recibir `TimerController` o `TaskController` completos.

## 6. Datos y migraciones

- El esquema actual de Drift es versión 4.
- `active_timer_sessions` guarda una instantánea única de la sesión y `pending_timer_summaries` guarda los trabajos de finalización pendientes.
- No renombrar ni eliminar columnas para implementar la nueva Home.
- Todo cambio de esquema exige migración ascendente y prueba desde cada versión soportada.
- No editar `lib/core/database/app_database.g.dart` manualmente.
- Las consultas específicas deben evolucionar hacia DAOs con dueño de funcionalidad.
- `shared_preferences` se conserva mientras sea necesaria la migración de datos antiguos.
- No borrar datos locales en pruebas manuales sin avisar.

Si cambia el esquema:

```text
dart run build_runner build --delete-conflicting-outputs
```

## 7. Estado, ciclo de vida y recursos

- Crear `TaskController` y `TimerController` una sola vez por sesión de la aplicación.
- El cambio de pestaña no crea ni destruye controladores.
- Conservar `syncWithClock` al reanudar y el guardado al pausar/separar la aplicación.
- Cancelar streams, timers y listeners en `dispose`.
- Cerrar la base de datos después de terminar escrituras pendientes.
- Tratar notificaciones y anuncios como adaptadores reemplazables y tolerantes a fallos.
- Un fallo de anuncio nunca convierte una sesión completada en fallida.
- El adaptador de anuncios informa `shown`, `retry` o `unsupported`; solo `retry` conserva un anuncio pendiente.
- Reiniciar elimina la sesión activa sin crear resumen; restablecer progreso elimina también resúmenes y pendientes.

## 8. Responsividad y accesibilidad

Verificar al menos:

```text
320 × 568
360 × 640
390 × 844
412 × 915
430 × 932
820 × 1180
568 × 320
915 × 412
```

Además:

- escala de texto 1.3;
- Safe Areas superior e inferior;
- teclado simulado en formularios;
- ausencia de overflow;
- contraste y estados activos visibles;
- tooltips en acciones de solo ícono;
- etiquetas semánticas para perfil, tiempo, gemas y pestañas;
- objetivos táctiles de al menos 48 × 48.

El alto usado por `TimerLayoutSpec` debe ser el alto real del cuerpo después de descontar AppBar, barra inferior y Safe Areas.

## 9. Estrategia de pruebas

Cada cambio debe conservar o añadir pruebas en el nivel más pequeño posible:

- unitarias: entidades, políticas, casos de uso y controladores;
- datos: repositorios, Drift y migraciones;
- widgets: componentes con estados relevantes;
- integración de widgets: shell, navegación y flujo tarea–concentración;
- responsivas: perfiles de pantalla existentes.

Pruebas mínimas de la nueva Home:

1. cambiar de pestaña no crea una ruta;
2. AppBar y barra inferior son únicos y persistentes;
3. perfil queda a la izquierda del bloque de dos líneas;
4. nombre queda encima de tiempo y gemas;
5. los tres valores se actualizan desde una sola fuente;
6. el temporizador continúa entre pestañas;
7. preparar una tarea selecciona Concentración;
8. completar la sesión completa la tarea;
9. las operaciones CRUD siguen funcionando;
10. no existen desbordamientos en la matriz responsiva.

## 10. Secuencia recomendada de trabajo

1. Revisar `git status` y preservar cambios ajenos.
2. Ejecutar pruebas de línea base.
3. Extraer vistas sin cambiar lógica.
4. Introducir el shell y navegación inferior.
5. Integrar el cambio automático Tareas → Concentración.
6. Actualizar pruebas de navegación.
7. Validar responsividad y accesibilidad.
8. Ejecutar formato, análisis y todas las pruebas.
9. Revisar el diff para detectar cambios de esquema o comportamiento no intencionales.

Comandos de calidad:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## 11. Definición de terminado

Un cambio está terminado únicamente si:

- cumple los criterios relevantes de [todo.md](todo.md);
- respeta la arquitectura de [arquitecture.md](arquitecture.md);
- no pierde comportamiento existente;
- incluye pruebas para el comportamiento nuevo o corregido;
- funciona en tamaños compactos y landscape;
- no introduce errores de análisis;
- no modifica datos o archivos generados de forma accidental;
- la documentación se actualiza si cambió una decisión del producto.
