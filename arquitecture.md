# Arquitectura escalable de Atomic Task

Última actualización: 15 de agosto de 2026 (resúmenes posteriores al anuncio y Drift v7).

Este documento define la arquitectura objetivo y una ruta incremental para alcanzarla. La Home y la persistencia de sesiones descritas en `plan.md` ya están implementadas; la extracción arquitectónica amplia continúa como trabajo futuro.

## 1. Objetivos arquitectónicos

La estructura debe permitir:

- añadir funcionalidades sin aumentar indefinidamente `app.dart`;
- reutilizar componentes visuales sin mezclar reglas de negocio;
- probar dominio, aplicación, datos y UI por separado;
- sustituir persistencia o servicios externos mediante contratos;
- coordinar tareas y temporizador sin acoplar sus pantallas/controladores;
- conservar estado al cambiar entre Tareas y Concentración;
- evolucionar la base de datos sin perder información;
- mantener Flutter y plugins fuera del dominio.

## 2. Arquitectura actual

El flujo principal existente es:

```text
main.dart
  → AtomicTimerBootstrap (app.dart)
    → crea AppDatabase y servicios
    → crea data sources
    → crea repositorios
    → crea casos de uso
    → crea TaskController y TimerController
    → presenta HomeShellPage
      ├── HomeAppBar compartido
      ├── IndexedStack (TasksView, FocusView, SettingsView, StatisticsView)
      └── HomeBottomNavigation
```

El flujo de datos habitual ya respeta una dirección útil:

```text
Widget
  → Controller (ChangeNotifier)
    → Caso de uso
      → Contrato de repositorio
        → Repositorio concreto
          → Data source
            → Drift / plugin
```

### Fortalezas existentes

- separación por funcionalidades;
- capas `data`, `domain` y `presentation`;
- repositorios y servicios con interfaces;
- inyección por constructor;
- fuentes de datos reemplazables en pruebas;
- lectura reactiva de tareas mediante `Stream`;
- pruebas de migración y comportamiento;
- reglas recurrentes separadas de sus ocurrencias y finalización transaccional;
- widgets del temporizador y tareas parcialmente extraídos.

### Deuda principal

- `app.dart` compone dependencias, coordina lifecycle, navegación e integración entre funcionalidades;
- `TimerController` administra reloj, reglas de gemas, persistencia, efectos externos, perfil y estado visual;
- `HeaderSection` depende del controlador completo y no se puede compartir limpiamente;
- tareas y temporizador se comunican mediante callbacks y navegación;
- `UserProgress` mezcla perfil, estadísticas y saldo;
- `AppDatabase` concentra tablas y consultas de todas las funcionalidades;
- el dominio de tareas conoce `TimerConstants`;
- `app.dart` todavía concentra composición y lifecycle; se mantiene así por alcance de esta entrega;
- el cierre de recursos debe seguir esperando escrituras pendientes.

## 3. Principios

### 3.1 Organización por funcionalidad

Cada capacidad de negocio es dueña de su dominio, aplicación, datos y presentación. Las carpetas técnicas globales solo alojan infraestructura realmente transversal.

### 3.2 Dependencias hacia adentro

```text
presentation ──→ application ──→ domain
data ──────────────────────────→ domain
app/bootstrap ──→ implementaciones concretas
```

- Dominio no conoce Flutter, Drift, plataforma ni UI.
- Aplicación orquesta casos de uso y depende de contratos.
- Datos implementa contratos definidos hacia adentro.
- Presentación adapta estado y eventos para widgets.
- Bootstrap es el único lugar que conoce todas las implementaciones.

### 3.3 Un solo dueño por estado

- Tareas: estado administrado por la aplicación de tareas.
- Sesión de temporizador: estado administrado por la aplicación del temporizador.
- Perfil/progreso: una fuente única, aunque temporalmente siga dentro de `TimerController`.
- Pestaña seleccionada: estado local de Home.

La UI puede observar, pero no duplicar estas fuentes.

### 3.4 Reutilización por evidencia

No anticipar componentes genéricos sin consumidores reales. Un componente se promueve al design system cuando es visual, neutral y reutilizado por al menos dos funcionalidades.

### 3.5 Migración incremental

Cada fase debe compilar y mantener pruebas verdes. Primero se extraen responsabilidades; después se cambian contratos o almacenamiento.

## 4. Estructura objetivo

```text
lib/
├── main.dart
├── app/
│   ├── atomic_task_app.dart
│   ├── bootstrap/
│   │   └── app_dependencies.dart
│   ├── coordinators/
│   │   └── task_focus_coordinator.dart
│   ├── lifecycle/
│   │   └── app_lifecycle_coordinator.dart
│   └── navigation/
│       └── app_router.dart
├── core/
│   ├── database/
│   │   ├── app_database.dart
│   │   └── migrations/
│   ├── errors/
│   ├── time/
│   │   └── clock.dart
│   └── utils/
├── design_system/
│   ├── theme/
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── tokens/
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   └── app_durations.dart
│   └── components/
│       ├── app_background.dart
│       ├── app_surface_card.dart
│       ├── app_empty_state.dart
│       ├── app_error_card.dart
│       └── app_stat_item.dart
├── shared/
│   └── domain/
│       └── focus_duration.dart
└── features/
    ├── home/
    │   └── presentation/
    │       ├── controllers/
    │       │   └── home_navigation_controller.dart
    │       ├── pages/
    │       │   └── home_shell_page.dart
    │       └── widgets/
    │           ├── home_app_bar.dart
    │           └── home_bottom_navigation.dart
    ├── profile/
    │   ├── domain/
    │   │   ├── entities/
    │   │   └── repositories/
    │   ├── application/
    │   │   └── use_cases/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       └── widgets/
    │           └── user_summary.dart
    ├── tasks/
    │   ├── domain/
    │   │   ├── entities/
    │   │   └── repositories/
    │   ├── application/
    │   │   ├── controllers/
    │   │   └── use_cases/
    │   ├── data/
    │   │   ├── local/
    │   │   │   ├── tasks_table.dart
    │   │   │   └── tasks_dao.dart
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   └── presentation/
    │       ├── views/
    │       │   └── tasks_view.dart
    │       └── widgets/
    └── timer/
        ├── domain/
        │   ├── entities/
        │   ├── policies/
        │   │   ├── focus_reward_policy.dart
        │   │   └── rest_cost_policy.dart
        │   ├── repositories/
        │   └── services/
        ├── application/
        │   ├── controllers/
        │   │   └── timer_controller.dart
        │   ├── engine/
        │   │   └── timer_engine.dart
        │   └── use_cases/
        ├── data/
        │   ├── local/
        │   │   ├── timer_progress_table.dart
        │   │   └── timer_progress_dao.dart
        │   ├── datasources/
        │   ├── models/
        │   ├── repositories/
        │   └── services/
        └── presentation/
            ├── views/
            │   └── focus_view.dart
            ├── layout/
            └── widgets/
```

Esta es una dirección de crecimiento, no una obligación de crear carpetas vacías. Cada carpeta aparece cuando tiene una responsabilidad real.

## 5. Responsabilidad de cada zona

### `app/`

Contiene composición y coordinación global, no reglas internas de una funcionalidad.

- `atomic_task_app.dart`: configura `MaterialApp`, tema y entrada principal.
- `bootstrap/app_dependencies.dart`: construye y conserva DB, servicios, repositorios, casos de uso y controladores.
- `lifecycle/`: traduce eventos de Flutter a operaciones de aplicación.
- `coordinators/`: conecta flujos que abarcan más de una funcionalidad.
- `navigation/`: rutas secundarias como formularios/pantallas futuras; cambiar entre las dos vistas de Home no requiere ruta.

### `core/`

Infraestructura transversal sin semántica específica de tareas o temporizador:

- base compartida de Drift y migraciones;
- reloj inyectable;
- errores base y utilidades generales.

Una regla de gemas o una duración de concentración no es una utilidad genérica.

### `design_system/`

Tokens y componentes visuales neutrales. No importa controladores, repositorios ni casos de uso.

### `shared/domain/`

Solo contiene conceptos de negocio compartidos y estables. `FocusDuration` es candidato porque Tareas almacena una duración y Temporizador la ejecuta. Evitar convertir `shared` en un depósito general.

### `features/home/`

Es dueño del shell y de la selección de pestaña. No es dueño de tareas, temporizador ni progreso.

### `features/profile/`

Será dueño del nombre y, si el producto crece, preferencias. Las estadísticas de concentración y el saldo de gemas pueden exponerse como un resumen de solo lectura, aunque su extracción se haga en una fase posterior.

### `features/tasks/`

Es dueño del ciclo de vida de tareas, reglas de recurrencia, ocurrencias y su persistencia. No controla el temporizador ni navega directamente a su pantalla.

### `features/timer/`

Es dueño de sesiones, reloj, modos, recompensas/costos y adaptadores de notificaciones/anuncios. No completa tareas directamente.

## 6. Diseño de la Home

Debe existir un único `Scaffold`:

```text
HomeShellPage
├── appBar: HomeAppBar
├── body: IndexedStack
│   ├── TasksView
│   ├── FocusView
│   ├── SettingsView
│   └── StatisticsView
└── bottomNavigationBar: HomeBottomNavigation
```

### Razón para usar `IndexedStack`

- conserva el árbol y estado local de ambas vistas;
- evita reconstruir el temporizador al cambiar de pestaña;
- conserva scroll, formularios y controles cuando sigan montados;
- hace que la navegación sea estado local y no historial de rutas.

Los controladores se crean por encima del shell y viven durante toda la sesión. Las vistas no contienen `Scaffold` anidados. El drawer de Home es propiedad del shell; `ProgressDrawer` se conserva únicamente para el wrapper heredado de `TimerPage`.

### Contrato del AppBar

`HomeAppBar` recibe valores simples o un modelo de presentación inmutable:

```text
UserSummaryViewModel
├── displayName
├── formattedFocusTime
└── gems
```

También recibe callbacks como `onProfilePressed`. No recibe `TimerController`, `TaskController`, repositorios ni servicios.

## 7. Coordinación entre Tareas y Temporizador

La coordinación debe salir gradualmente de callbacks incrustados en `app.dart`.

### Preparar concentración

```text
TasksView
  → TaskFocusCoordinator.prepare(taskId, title, duration)
    → AssignTaskFocus
    → PrepareFocusSession
    → HomeNavigationController.select(Concentración)
```

### Completar la sesión

```text
TimerEngine termina
  → evento FocusSessionCompleted(taskId?)
    → TaskFocusCoordinator
      → CompleteTaskById
```

El coordinador puede comenzar como una clase pequeña con dependencias por constructor. No hace falta introducir un bus de eventos global.

Ventajas:

- ninguna pantalla conoce el controlador de otra funcionalidad;
- el flujo puede probarse sin widgets;
- Home decide la pestaña, no el repositorio ni el temporizador;
- completar una sesión sin tarea sigue siendo válido.

## 8. Descomposición del temporizador

`TimerController` debe evolucionar hacia un adaptador de estado de presentación. Sus responsabilidades internas se separan así:

### `TimerEngine`

- estado temporal de la sesión;
- inicio, pausa, reanudación, sincronización y finalización;
- cálculo basado en un `Clock` inyectable;
- emisión de cambios/eventos tipados.

### Políticas de dominio

- `FocusRewardPolicy`: gemas ganadas por bloques completos;
- `RestCostPolicy`: gemas requeridas y consumidas;
- `FocusDuration`: límites y validación.

### Casos de uso/aplicación

- cargar y guardar progreso;
- preparar sesión para una tarea;
- iniciar/pausar/reiniciar;
- procesar finalización;
- coordinar notificaciones y anuncio.

### `TimerController`

- transforma el estado anterior en propiedades consumibles por UI;
- procesa intenciones de widgets;
- notifica cambios;
- no contiene cálculos duplicados de negocio.

La separación debe realizarse con pruebas de caracterización antes de mover reglas.

## 9. Perfil, estadísticas y gemas

Actualmente `UserProgress` reúne tres conceptos:

- nombre de perfil;
- tiempo total de concentración;
- gemas.

La extracción futura recomendada es:

```text
UserProfile     → displayName
FocusStatistics → totalFocusSeconds
GemBalance      → amount
```

La Home usa contratos/modelos separados para sesiones. Drift está en versión 7 y conserva las tablas existentes mientras añade recurrencias y datos de finalización fuera de la aplicación de forma aditiva:

```text
active_timer_sessions   → instantánea única de sesión preparada/pausada/activa
pending_timer_summaries → resumen, trabajos pendientes y tiempo fuera tras finalizar
task_recurrence_rules    → regla independiente de la serie
tasks                    → relación y fecha opcionales de ocurrencia
```

La restauración usa `endsAt` y segundos guardados, evita duplicar recompensas y conserva pendientes de anuncio, tarea o panel. Si la sesión vence en segundo plano, el resumen registra los segundos desde `endsAt` hasta la primera reanudación; el tiempo del anuncio queda excluido.

Home puede consumir inicialmente un `UserSummaryViewModel` derivado de la fuente existente.

La implementación vigente mantiene `UserProgress` como fuente única para nombre, tiempo y gemas. `SettingsView` edita el nombre obligatorio, recortado y limitado a 18 caracteres; `StatisticsView` recibe los conteos de tareas y el progreso actual mediante propiedades simples y se actualiza con los listeners de los controladores.

## 10. Persistencia y DAOs

`AppDatabase` continúa como conexión y registro central de tablas. Las operaciones específicas migran a DAOs:

```text
AppDatabase
├── TasksDao
└── TimerProgressDao
```

Reglas:

- una funcionalidad usa su DAO mediante un data source;
- el repositorio convierte modelos de datos a entidades;
- ninguna entidad hereda obligatoriamente de una fila Drift;
- cada incremento de `schemaVersion` incluye migración y pruebas;
- conservar pruebas desde versiones 1, 2 y 3;
- esperar escrituras pendientes antes de cerrar la DB.

Las migraciones v1, v2, v3, v4, v5 y v6 hacia v7 están cubiertas por pruebas. La v7 añade `completed_while_app_was_away` y `away_seconds_after_completion` a los resúmenes pendientes. La unicidad serie/fecha evita ocurrencias duplicadas y completar una ocurrencia junto con crear la siguiente ocurre en una transacción.

## 11. Estado e inyección de dependencias

La inyección manual por constructor es suficiente para el tamaño actual.

`AppDependencies` debe:

- crear una sola instancia de `AppDatabase`;
- construir adaptadores y repositorios;
- construir casos de uso/controladores;
- exponer únicamente dependencias necesarias para la raíz;
- liberar recursos en orden.

No introducir Provider, Riverpod, GetIt u otro contenedor solo para mover código. Evaluarlo cuando el grafo sea difícil de construir/probar o haya scopes reales adicionales.

El mismo criterio aplica a un router declarativo: la navegación inferior no lo necesita. Adoptarlo cuando existan deep links, autenticación o navegación anidada compleja.

## 12. Componentes reutilizables

### Componentes del design system

Reciben propiedades visuales, contenido y callbacks simples:

- `AppBackground`;
- `AppSurfaceCard`;
- `AppEmptyState`;
- `AppErrorCard`;
- `AppStatItem`.

### Componentes con dueño funcional

- Home: `HomeAppBar`, `HomeBottomNavigation`;
- Perfil: `UserSummary`;
- Tareas: `TaskCard`, secciones y formularios;
- Temporizador: `TimerDial`, `TimeSelector`, `ModeSelector`, acciones.

### Regla de API

Preferir:

```text
AppStatItem(icon, value, semanticLabel)
```

Evitar:

```text
AppStatItem(timerController)
```

Esto reduce reconstrucciones, mejora pruebas y evita dependencias circulares.

## 13. Estrategia de pruebas

### Dominio

- límites de duración;
- recompensas de concentración;
- costo y saldo de descanso;
- vencimiento de tareas.

### Aplicación

- transiciones del motor de temporizador con reloj falso;
- carga/guardado y manejo de errores;
- coordinación tarea–sesión;
- eventos de finalización.

### Datos

- mapeos y repositorios;
- orden y operaciones de DAOs;
- migraciones desde todas las versiones soportadas;
- migración heredada desde SharedPreferences.

### Presentación

- estados loading/content/error/empty;
- AppBar y navegación inferior;
- controles y semántica;
- preservación de estado al cambiar de pestaña.

### Integración

- crear tarea → preparar concentración → terminar → completar tarea;
- temporizador activo entre pestañas;
- actualización visible de gemas/tiempo;
- primer inicio y restablecimiento;
- matriz responsiva existente.
- crear recurrencia → completar o Concentración → siguiente ocurrencia;
- reconciliación idempotente después de fechas omitidas.

## 14. Plan de migración recomendado

### Etapa 1: shell y recuperación (completada)

1. Extraer `TasksView` y `FocusView`.
2. Crear `HomeShellPage`.
3. Crear AppBar y barra inferior compartidos.
4. Mantener los controladores actuales vivos sobre `IndexedStack`.
5. Adaptar pruebas de navegación y responsividad.
6. Añadir Drift v4, repositorio de ejecución y reconciliación al reabrir.
7. Entregar resúmenes tipados, aviso interno y estado del anuncio.

El cierre de `AtomicTimerBootstrap` espera `TimerController.flushPersistence()` antes de cerrar `AppDatabase`. Una sesión por defecto o reiniciada no se persiste como sesión recuperable; solo se guardan sesiones preparadas explícitamente, pausadas o activas.

### Etapa 2: composición y lifecycle (futura)

1. Extraer `AppDependencies` de `app.dart`.
2. Extraer `AppLifecycleCoordinator`.
3. Definir cierre ordenado de servicios y DB.

### Recurrencias de tareas (completada)

1. Añadir frecuencia, regla, calculador y política de generación en dominio.
2. Migrar Drift de v4 a v5 de forma aditiva.
3. Completar ocurrencias y crear la siguiente dentro de una transacción.
4. Reconciliar una sola próxima ocurrencia al abrir la aplicación.
5. Añadir formulario, acciones de ocurrencia/serie, pausa y reactivación.

### Resumen posterior a concentración (completada)

1. Persistir si la sesión terminó fuera de la aplicación y los segundos hasta la primera reanudación.
2. Mantener `TimerController` como coordinador único de tarea, publicidad y publicación del resumen.
3. Esperar el cierre del intersticial antes de exponer el panel de concentración.
4. Consumir el resumen solo al cerrar el panel y recuperarlo si la aplicación se reinicia antes.
5. Migrar Drift de v6 a v7 de forma aditiva y conservar todas las rutas soportadas.

### Etapa 3: coordinación entre funcionalidades

1. Crear contratos para preparar/finalizar una sesión vinculada.
2. Crear `TaskFocusCoordinator`.
3. Eliminar callbacks directos entre controladores.
4. Probar el flujo sin widgets.

### Etapa 4: motor y políticas

1. Añadir pruebas de caracterización al `TimerController` actual.
2. Extraer `Clock`, `TimerEngine` y eventos.
3. Extraer políticas de recompensa y costo.
4. Reducir el controlador a estado de presentación.

### Etapa 5: perfil y persistencia modular (futura)

1. Separar modelos lógicos de perfil/estadísticas/gemas.
2. Crear DAOs por funcionalidad.
3. Mantener tablas actuales hasta que exista razón para migrarlas.
4. Extraer la restauración de sesión a un servicio especializado si el dominio crece.

## 15. Decisiones arquitectónicas vigentes

- Un solo `Scaffold` para Home.
- `IndexedStack` para conservar las cuatro vistas de Home.
- Inyección manual por constructor.
- `ChangeNotifier` puede mantenerse durante la primera migración.
- Sin paquete nuevo de router/DI/estado por ahora.
- Drift versión 7 con recurrencias y metadatos de tiempo fuera aditivos, sin renombrar ni eliminar tablas existentes.
- Resúmenes de finalización como eventos persistibles y consumibles una sola vez por la UI.
- Componentes compartidos basados en reutilización real.
- Coordinación entre funcionalidades fuera de sus widgets.
- Migración en pasos pequeños con pruebas verdes.

## 16. Señales para reevaluar la arquitectura

Revisar estas decisiones cuando ocurra alguna de las siguientes condiciones:

- más de tres shells/scopes con ciclos de vida distintos;
- deep links o navegación anidada compleja;
- sincronización remota y autenticación;
- colaboración o múltiples perfiles;
- conflictos frecuentes al ensamblar dependencias;
- estado compartido con demasiados adaptadores manuales;
- varias fuentes de datos por funcionalidad;
- necesidad real de recuperar sesiones después de terminar el proceso.

Hasta entonces, la solución preferida es la más pequeña que mantenga límites claros, datos seguros y pruebas rápidas.
