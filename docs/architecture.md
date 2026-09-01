# Arquitectura de Atomic Task

Este documento recoge las decisiones arquitectónicas vigentes y los límites
que deben conservarse. No es una hoja de ruta: una evolución arquitectónica
concreta requiere una spec aprobada.

## Principios

- Organizar el código por funcionalidad y mantener cada capacidad como dueña de
  su dominio, aplicación, datos y presentación.
- Dirigir las dependencias hacia dentro:

  ```text
  presentation → application → domain
  data ──────────────────────→ domain
  app/bootstrap → implementaciones concretas
  ```

- Mantener una única fuente de estado para cada concepto: tareas, sesión de
  temporizador, progreso y destino de Home.
- Promover un componente al design system solo cuando sea visual, neutral al
  negocio y tenga reutilización comprobable en al menos dos funcionalidades.
- Evolucionar de forma incremental, con pruebas de caracterización cuando se
  extraigan responsabilidades existentes.

## Estado actual

`AtomicTimerBootstrap` compone la base de datos, repositorios, servicios,
casos de uso y controladores. `HomeShellPage` conserva las cinco vistas de la
Home mediante `IndexedStack`, mientras que Tareas y Temporizador conservan la
propiedad de sus reglas y presentación. El audio transversal se ensambla como
un servicio inyectable y la selección de alarma se persiste mediante un
adaptador de preferencias.

La inyección manual por constructor y `ChangeNotifier` son suficientes para el
tamaño actual. No se introduce un router declarativo, un contenedor DI ni una
biblioteca de estado sin una necesidad demostrada y una spec aprobada.

## Límites de responsabilidad

- `app/` ensambla dependencias y coordina flujos globales; no contiene reglas
  internas de una funcionalidad.
- `features/home` es dueño del shell, drawer y selección del destino, no del
  dominio de tareas ni temporizador.
- `features/tasks` es dueño del ciclo de tareas, recurrencias y persistencia
  asociada; no controla directamente el temporizador.
- `features/timer` es dueño de sesiones, reloj, recompensas, costes y sus
  adaptadores; no completa tareas desde un widget.
- `features/alarm` es dueño de la vista y el controlador de selección y
  previsualización de alarmas; no programa recordatorios directamente.
- `core/audio` define el catálogo y los contratos de audio compartidos; las
  implementaciones concretas de reproducción y preferencias se ensamblan en
  `app/`.
- `core/` solo aloja infraestructura transversal. No es un depósito de reglas
  o componentes sin dueño.
- La coordinación entre funcionalidades vive en contratos de aplicación o
  coordinadores con dependencias explícitas, no en callbacks entre widgets o
  controladores ajenos.

## Datos y compatibilidad

Drift usa actualmente el esquema versión 9. `AppDatabase` centraliza la
conexión y migraciones mientras las consultas evolucionan hacia dueños de
funcionalidad. Toda migración debe preservar instalaciones existentes, evitar
renombrados o eliminaciones destructivas y regenerar el código con las
herramientas oficiales.

Las sesiones activas y los resúmenes pendientes son persistibles y consumibles
una sola vez por la interfaz. Las reglas recurrentes se almacenan separadas de
sus ocurrencias y sus operaciones críticas son transaccionales.

## Señales para reevaluar decisiones

Crear una spec arquitectónica antes de cambiar el enfoque cuando exista alguno
de estos indicios:

- navegación anidada, deep links o autenticación;
- más de tres ámbitos con ciclo de vida distinto;
- múltiples fuentes de datos o sincronización remota por funcionalidad;
- conflictos recurrentes al ensamblar dependencias;
- varias funcionalidades que necesiten el mismo componente o contrato estable.
