# Atomic Task: contexto y hoja de ruta

Última actualización: 15 de agosto de 2026 (PLAN.md implementado y Drift v7).

Este documento resume el estado real del proyecto y separa lo implementado de la evolución futura. La especificación visual está en [agents.md](agents.md) y la arquitectura objetivo en [arquitecture.md](arquitecture.md).

## Estado de la entrega actual

- [x] Home única con `HomeShellPage`, AppBar compartido y navegación inferior.
- [x] Vistas embebibles `TasksView` y `FocusView` conservadas en un `IndexedStack`.
- [x] Encabezado responsivo con el perfil junto al título completo y las cápsulas de tiempo y gemas debajo.
- [x] Drawer lateral izquierdo con Tareas, Concentración, Ajustes, Estadísticas y restablecimiento.
- [x] Footer flotante centrado con cápsula de selección y header responsivo de dos filas.
- [x] Tareas recurrentes diarias, semanales y mensuales con edición por ocurrencia o serie.
- [x] Accesos rápidos `Mañana`, `Una semana` y `Un mes` al crear una tarea, más equis roja para quitar la fecha límite.
- [x] Panel de cada concentración después de la publicidad con gemas, duración, tarea y tiempo fuera cuando aplican; los descansos conservan el aviso flotante.
- [x] Persistencia Drift versión 7 para recurrencias, sesión activa y resumen pendiente recuperable.
- [x] Pruebas de Home, geometría, fechas, migraciones v1–v6, CRUD, recurrencias, temporizador, publicidad y responsividad.
- [x] `flutter analyze`, `flutter test` y `git diff --check` sin errores.

## 1. Propósito del producto

Atomic Task es una aplicación Flutter de productividad que combina:

- administración de tareas;
- sesiones de concentración y descanso;
- progreso local mediante tiempo acumulado y gemas;
- asociación de una tarea con una sesión de concentración;
- notificaciones del temporizador;
- un anuncio intersticial de prueba al finalizar una sesión de concentración.

La experiencia debe permitir pasar rápidamente entre planificar una tarea y concentrarse en ella, sin perder el estado de ninguna de las dos vistas.

## 2. Estado actual verificado

### 2.1 Plataforma y dependencias

- Flutter con Material 3 y Dart `^3.12.2`.
- Aplicación preparada para Android, iOS, web, Windows, macOS y Linux.
- Drift/SQLite para persistencia local.
- `shared_preferences` únicamente para migrar progreso heredado.
- `flutter_local_notifications` y `timezone` para notificaciones.
- `google_mobile_ads` para anuncios intersticiales de prueba.
- Estado administrado con `ChangeNotifier` e inyección manual por constructor.

### 2.2 Organización actual

El código ya está organizado por funcionalidades y capas:

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── database/
│   ├── theme/
│   └── utils/
└── features/
    ├── tasks/
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    └── timer/
        ├── data/
        ├── domain/
        └── presentation/
```

`app.dart` funciona hoy como punto de composición: crea base de datos, fuentes de datos, repositorios, casos de uso, controladores y servicios. También coordina el ciclo de vida y la comunicación entre tareas y temporizador.

### 2.3 Navegación actual

- `HomeShellPage` es la pantalla inicial normal y abre en Tareas.
- Tareas y Concentración son vistas internas de un único `Scaffold`; cambiar de pestaña no crea rutas.
- Una sesión preparada, pausada o en ejecución recuperada selecciona Concentración automáticamente.
- La tarea vinculada se comunica con el temporizador mediante el callback existente, conservando el estado de ambos controladores.

La navegación se implementa con una sola Home y vistas internas, sin apilar rutas.

### 2.4 Funciones que ya existen y deben conservarse

#### Perfil y progreso

- En el primer inicio se solicita un nombre obligatorio.
- El nombre se recorta, admite hasta 18 caracteres y se guarda localmente.
- Se muestran gemas y tiempo total de concentración.
- Tiempo y gemas abren paneles inferiores explicativos y mantienen sus valores sincronizados en vivo.
- El progreso puede restablecerse con confirmación.

#### Temporizador

- Modos Concentración y Descanso.
- Duraciones de 0 a 120 minutos en el selector general.
- Concentración predeterminada: 25 minutos.
- Descanso predeterminado: 5 minutos.
- Concentración: una gema por cada 3 minutos completos.
- Descanso: cuesta una gema por cada minuto completo.
- Un descanso no inicia si no existe saldo suficiente.
- Estados iniciar, pausar, continuar, completar y reiniciar.
- Sincronización mediante la hora final al volver la aplicación a primer plano.
- Guardado diferido del progreso y guardado inmediato en acciones críticas.
- Notificación de sesión activa y de sesión completada.
- Anuncio intersticial de prueba al terminar concentración en Android/iOS.
- Panel de resumen posterior al anuncio, persistente y consumible una sola vez.
- Medición del tiempo entre una finalización en segundo plano y la primera reanudación, sin contar el tiempo del anuncio.

#### Tareas

- Crear, editar, completar, reabrir y eliminar.
- Fecha límite opcional y detección de vencimiento por día local.
- Al crear, accesos rápidos de fecha límite para mañana, una semana y un mes; al quitarla, equis roja accesible.
- Secciones de pendientes y completadas.
- Resumen de cantidades, estado vacío y error descartable.
- Formulario adaptable al teclado.
- Al completar una tarea se puede:
  - marcarla como completada inmediatamente; o
  - asignarle entre 1 y 120 minutos y preparar una sesión de concentración.
- La tarea asociada permanece pendiente hasta finalizar la sesión.
- Al finalizar la sesión vinculada, la tarea se completa automáticamente.
- Las tareas recurrentes admiten intervalo, inicio, fin opcional, pausa y reactivación.
- Completar una ocurrencia crea la siguiente de forma transaccional e idempotente.
- Editar o eliminar una tarea recurrente permite elegir entre ocurrencia y serie.
- La recuperación salta fechas omitidas y crea únicamente la próxima ocurrencia pendiente.

### 2.5 Persistencia actual

La base Drift usa esquema versión 7:

- `timer_progress`: registro único con nombre, gemas y segundos acumulados;
- `tasks`: título, estado, fecha límite, minutos de concentración y marcas de tiempo;
- `task_recurrence_rules`: frecuencia, intervalo, fechas de inicio/fin y estado activo;
- `tasks` relaciona opcionalmente cada ocurrencia con su regla y fecha única;
- `active_timer_sessions`: instantánea única de una sesión preparada, pausada o en ejecución;
- `pending_timer_summaries`: resumen único con pendientes de aviso, notificación, anuncio y tarea, más finalización fuera de la aplicación y segundos hasta reanudar.

Las migraciones desde las versiones 1, 2, 3, 4, 5 y 6 conservan el progreso, las tareas y los resúmenes anteriores; la v7 añade solo columnas con valores compatibles.

### 2.6 Cobertura existente

Hay pruebas de:

- controladores de tareas y temporizador;
- reglas del temporizador;
- operaciones y migraciones de Drift;
- selector de tiempo;
- flujo de tareas y asociación con concentración;
- primer inicio y persistencia del nombre;
- diseños compactos, regulares, tablet y landscape;
- tareas con Safe Area, texto ampliado y teclado visible.
- cálculo, persistencia, reconciliación e integración con Concentración de recurrencias;
- footer flotante, semántica de selección y títulos completos en el header compacto.

## 3. Home compartida implementada

La Home mantiene cuatro vistas montadas y dos accesos rápidos en el footer:

```text
HomeShellPage
├── HomeAppBar compartido
│   ├── título contextual a la izquierda
│   └── resumen del usuario a la derecha
├── cuerpo que conserva las cuatro vistas
│   ├── TasksView
│   ├── FocusView
│   ├── SettingsView
│   └── StatisticsView
└── HomeBottomNavigation persistente
    ├── Tareas
    └── Concentración
```

El resumen del AppBar respeta esta jerarquía:

```text
[tarjeta: avatar + nombre]
[cápsula dorada: tiempo] [cápsula morada: gemas]
```

Avatar y nombre permanecen dentro de la tarjeta; tiempo y gemas quedan debajo y fuera. En anchos compactos y amplios, menú, título completo y perfil comparten la primera fila, y las métricas ocupan la segunda. Si falta espacio, solo el nombre del perfil usa elipsis. No se muestra la palabra “Hola”.

## 4. Decisiones ya acordadas

- [x] Una sola Home contiene las cuatro vistas montadas.
- [x] La navegación primaria se realiza con dos íconos en la parte inferior.
- [x] Orden de destinos: Tareas y Concentración.
- [x] La barra inferior permanece visible en ambas vistas.
- [x] El AppBar es compartido.
- [x] El nombre se alinea junto al título en la primera fila y está sobre las estadísticas.
- [x] Avatar y nombre aparecen dentro de la tarjeta; las estadísticas quedan debajo y fuera.
- [x] Tiempo de concentración y gemas conservan sus respectivos íconos.
- [x] Tiempo y gemas usan cápsulas interactivas con paneles inferiores de detalle.
- [x] No se usa el saludo “Hola”.
- [x] Cambiar de pestaña no debe reiniciar el temporizador ni la lista.

## 5. Decisiones de producto resueltas

- [x] La pestaña inicial normal es Tareas; una sesión recuperada abre Concentración.
- [x] El título contextual usa `Tareas`, `Concentración`, `Ajustes` y `Estadísticas`.
- [x] El menú abre el drawer izquierdo con restablecimiento; el perfil abre directamente Ajustes.
- [x] El nombre se edita desde Ajustes, no directamente en el encabezado.

Estas decisiones están cerradas en la implementación actual.

## 6. Plan de implementación

### Fase 0: proteger el comportamiento actual

- [x] Ejecutar y registrar la línea base de `flutter analyze` y `flutter test`.
- [x] Conservar dobles de prueba para base de datos, notificaciones y anuncios.
- [x] Mantener las tablas existentes y cubrir la migración Drift v4.

### Fase 1: crear la estructura de Home

- [x] Crear `HomeShellPage` con un único `Scaffold`.
- [x] Crear el estado de pestaña en el shell.
- [x] Crear `HomeAppBar` compartido.
- [x] Crear `HomeBottomNavigation` con Tareas y Concentración.
- [x] Mantener ambos controladores vivos por encima del cambio de pestaña.
- [x] Conservar el estado con `IndexedStack`.

### Fase 2: convertir las páginas en vistas reutilizables

- [x] Extraer el contenido de `TaskPage` a `TasksView` sin `Scaffold` ni AppBar propios.
- [x] Extraer el contenido de `TimerPage` a `FocusView` sin `Scaffold` propio.
- [x] Mantener el fondo compartido en el shell.
- [x] Mantener “Nueva tarea” visible dentro de Tareas, incluso en estado vacío.
- [x] Evitar barras, Safe Areas o fondos duplicados.

### Fase 3: integrar tareas y concentración

- [x] Al preparar concentración desde una tarea, seleccionar automáticamente la pestaña Concentración.
- [x] Mostrar la tarea vinculada y la duración elegida.
- [x] No usar navegación de rutas para cambiar entre vistas de Home.
- [x] Mantener el aviso si una sesión bloqueada impide reemplazar el temporizador.
- [x] Completar la tarea únicamente cuando termine su sesión vinculada.

### Fase 4: perfil y progreso compartidos

- [x] Mostrar el mismo nombre, tiempo y gemas en ambas pestañas.
- [x] Actualizar esos valores en vivo sin duplicar estado.
- [x] Hacer accesible el progreso/restablecimiento desde el ícono de perfil.
- [x] Eliminar del panel de perfil el acceso redundante a Tareas.
- [x] Evitar desbordamiento con nombres de 18 caracteres y escala de texto 1.3.

### Fase 5: responsividad y accesibilidad

- [x] Respetar Safe Area superior e inferior.
- [x] Reservar altura para AppBar y barra inferior antes de calcular el layout del temporizador.
- [x] Mantener la lista de tareas desplazable.
- [x] Mantener visibles los controles principales del temporizador sin overflow.
- [x] Asegurar blancos táctiles de al menos 48 × 48.
- [x] Añadir tooltips y semántica de selección a la navegación.
- [x] Comprobar tamaños móviles, tablet, landscape y escala de texto existentes.

### Fase 6: pruebas de la nueva Home

- [x] Probar que Tareas y Concentración no crean rutas nuevas.
- [x] Probar la selección visual y semántica de ambas pestañas.
- [x] Probar la geometría del resumen de usuario en el AppBar.
- [x] Probar que nombre, tiempo y gemas son iguales en ambas vistas.
- [x] Probar que el temporizador continúa al alternar pestañas.
- [x] Probar que el estado y scroll de Tareas se conservan.
- [x] Adaptar el flujo tarea → duración → concentración a la nueva navegación.
- [x] Mantener las pruebas CRUD, migraciones, reloj, notificaciones y recompensas.

### Fase 7: evolución arquitectónica incremental

- [ ] Extraer la creación de dependencias fuera de `app.dart`.
- [ ] Extraer la coordinación del ciclo de vida.
- [ ] Separar el motor de reloj y las políticas de gemas de `TimerController`.
- [ ] Reemplazar callbacks entre funcionalidades por un coordinador tipado.
- [ ] Modularizar consultas Drift mediante DAOs sin romper migraciones.
- [ ] Separar perfil, estadísticas y saldo de gemas cuando el modelo lo requiera.

## 7. Criterios de aceptación de la Home

La entrega visual se considera completa cuando:

1. Hay un solo `Scaffold` para la Home.
2. AppBar y navegación inferior permanecen visibles al cambiar de vista.
3. La navegación inferior contiene exactamente Tareas y Concentración, en ese orden.
4. El destino activo se distingue con color/indicador morado y semántica seleccionada.
5. El resumen del AppBar contiene avatar y nombre dentro de la tarjeta, con cápsulas de tiempo y gemas debajo y fuera.
6. No aparece “Hola”.
7. El nombre, el tiempo y las gemas provienen de una sola fuente de estado.
8. El temporizador activo no se reinicia al abrir Tareas.
9. La lista y sus operaciones no se reinician al abrir Concentración.
10. Preparar una tarea cambia a Concentración sin apilar ni cerrar rutas.
11. Todas las funciones actuales siguen disponibles.
12. No hay overflow ni contenido oculto por las barras del sistema.
13. `flutter analyze` no reporta errores y todas las pruebas pasan.
14. Las cápsulas tienen áreas táctiles de 48 × 48 y sus paneles reflejan el progreso en vivo.

## 8. Fuera de alcance del primer cambio visual

- Cambiar de biblioteca de estado.
- Añadir una biblioteca de inyección de dependencias o router sin necesidad demostrada.
- Renombrar o eliminar tablas existentes; las migraciones incluidas son aditivas y conservan las rutas históricas.
- Rediseñar las reglas de gemas.
- Sustituir las notificaciones o AdMob.
- Reescribir toda la arquitectura en una sola entrega.

## 9. Comandos de verificación

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Cuando cambie el esquema Drift:

```text
dart run build_runner build --delete-conflicting-outputs
```

El archivo generado `app_database.g.dart` nunca debe editarse manualmente.

## Verificación de esta entrega

- Generación Drift v7 ejecutada con `build_runner`.
- Migraciones desde las versiones 1, 2, 3, 4, 5 y 6 cubiertas por pruebas.
- `PLAN.md` está implementado: encabezado, accesos rápidos, equis roja y panel posterior al anuncio.
- La refactorización arquitectónica amplia de la Fase 7 permanece pendiente; la entrega conserva los controladores y contratos existentes.
