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
