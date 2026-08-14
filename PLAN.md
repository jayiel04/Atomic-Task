# Plan de mejora del header y footer de la Home

## Objetivo

Garantizar que el nombre de la vista activa (`Tareas`, `Concentración`,
`Ajustes` o `Estadísticas`) se muestre completo en el header, sin elipsis,
recortes ni desbordamientos, incluso en pantallas angostas y con texto
ampliado. La solución debe conservar el acceso al menú, al perfil y a las
estadísticas, así como los blancos táctiles y la semántica existentes.

Además, renovar el footer para que deje de percibirse como una franja plana y
genérica. La nueva navegación inferior debe integrarse con la identidad visual
morada de Atomic Task, comunicar con claridad la vista activa y conservar una
interacción sencilla, accesible y responsiva.

## Diagnóstico inicial

- Revisar el espacio que consume cada zona de `HomeAppBar`: botón de menú,
  separadores, título y bloque de perfil/estadísticas.
- Confirmar el problema en cada destino de `HomeDestination`, priorizando
  `Concentración` por ser el título más largo.
- Medir el comportamiento en los anchos de 320, 360, 390, 412 y 430 px, y en
  landscape, tanto con escala de texto normal como con escala 1.3.
- Tomar como causa principal la competencia horizontal actual: el título usa
  el espacio restante entre un botón de 48 px y un bloque derecho de ancho
  fijo, y además permite `TextOverflow.ellipsis`.

## Estrategia de implementación

### 1. Definir distribuciones responsivas del header

- Mantener la distribución actual en una sola fila únicamente cuando el ancho
  disponible permita renderizar el título completo junto al bloque derecho.
- En anchos compactos, separar el header en dos zonas verticales:
  - primera fila: botón de menú y título completo;
  - segunda zona: perfil y estadísticas, alineados sin competir por el ancho
    del título.
- Calcular el cambio de distribución con `LayoutBuilder` y el ancho real
  disponible, evitando depender solo de un dispositivo concreto.
- Conservar `SafeArea`, el fondo integrado y una altura flexible; no fijar una
  altura que pueda cortar contenido cuando aumente la escala de texto.

### 2. Dar prioridad al nombre de la vista

- Eliminar la elipsis del widget identificado por `homeTitle`.
- Permitir que el título ocupe el ancho de su fila y, cuando sea necesario,
  use hasta dos líneas con ajuste natural en límites de palabra.
- Mantener un tamaño tipográfico legible y estable. Cualquier reducción para
  el modo compacto tendrá un límite explícito y no será el mecanismo principal
  para hacer caber el texto.
- Evitar `FittedBox` con escalado ilimitado, cortes por caracteres o
  abreviaturas como `Conce...` o `Concentr.`.

### 3. Preservar el resto del header

- Mantener el botón de menú con un blanco táctil mínimo de 48 × 48 y su
  tooltip/etiqueta semántica.
- Conservar avatar y nombre dentro de la tarjeta de perfil, y tiempo y gemas
  debajo o junto a ella según la distribución disponible.
- Permitir que el nombre del perfil y los valores estadísticos sigan usando
  elipsis de manera independiente: nunca deben volver a quitarle al título el
  ancho mínimo necesario.
- Mantener las claves públicas actuales (`homeMenuButton`, `homeTitle`,
  `profileCard`, `profileName`, `focusTimeStat` y `gemsStat`) para no romper
  pruebas ni consumidores.
- Verificar que el aumento de altura del header se descuente correctamente del
  contenido de la vista y no provoque overflow en el temporizador o las tareas.

## Plan de pruebas

### Pruebas de widget

- Ampliar las pruebas de `HomeAppBar` para recorrer los cuatro títulos y
  comprobar que el `Text` conserva el valor completo y no configura
  `TextOverflow.ellipsis`.
- Añadir casos parametrizados para 320, 360, 390, 412 y 430 px con escalas de
  texto 1.0 y 1.3.
- En cada caso, verificar que no se registra ninguna excepción de layout y que
  el rectángulo visible del título no se superpone con el botón de menú, el
  perfil ni las estadísticas.
- Cubrir también 568 × 320 y 915 × 412 para validar la distribución horizontal.
- Mantener las aserciones de semántica, tooltips y blancos táctiles mínimos.

### Regresión de la Home

- Navegar por Tareas, Concentración, Ajustes y Estadísticas y comprobar que el
  título cambia completo sin crear rutas nuevas.
- Confirmar que abrir el sidebar y el perfil sigue funcionando en ambas
  distribuciones.
- Confirmar que tiempo, gemas y nombre del perfil continúan actualizándose sin
  alterar el estado del temporizador o de las tareas.
- Ejecutar `dart format --output=none --set-exit-if-changed .`,
  `flutter analyze` y `flutter test` al finalizar la implementación.

## Criterios de aceptación

- Se leen completos `Tareas`, `Concentración`, `Ajustes` y `Estadísticas`; el
  header nunca muestra una palabra truncada ni una elipsis para estos títulos.
- No hay overflow ni superposición en la matriz responsiva, con escala de texto
  de hasta 1.3 y respetando las Safe Areas.
- El título mantiene una jerarquía visual clara y un tamaño legible.
- Menú, perfil, tiempo y gemas siguen visibles y operativos.
- Los objetivos táctiles continúan midiendo al menos 48 × 48 y las etiquetas
  semánticas existentes permanecen disponibles.
- La adaptación no cambia navegación, persistencia, reglas de negocio ni estado
  de las vistas.

## Plan para mejorar el footer

### Diagnóstico visual

- Revisar `HomeBottomNavigation` en conjunto con el fondo, las tarjetas y el
  botón principal de cada vista, no como un componente aislado.
- Documentar mediante capturas el estado base en Tareas y Concentración para
  poder comparar jerarquía, contraste, altura y separación respecto del
  contenido.
- Tomar como problemas a resolver la superficie blanca de ancho completo, la
  escasa diferenciación entre los dos destinos y el indicador activo que parece
  un subrayado independiente en vez de formar parte del control seleccionado.
- Verificar si la sombra superior actual aporta profundidad o genera una franja
  visual que compite con la pantalla; ajustar su opacidad y extensión en lugar
  de añadir más efectos decorativos.

### Dirección visual propuesta

- Convertir la navegación en una superficie elevada y redondeada, con margen
  lateral y separación inferior calculada a partir del `SafeArea`, para que se
  perciba como parte del lenguaje de tarjetas de la aplicación y no como una
  barra predeterminada del sistema.
- Usar una base clara ligeramente translúcida o tonal, borde lila sutil y una
  sombra suave. Evitar desenfoques costosos, gradientes intensos o transparencias
  que reduzcan el contraste sobre el fondo ilustrado.
- Representar el destino activo con una cápsula morada suave que agrupe ícono y
  etiqueta. Reservar el morado sólido para el ícono/texto y usar tonos neutros
  con contraste suficiente en el destino inactivo.
- Mantener exactamente los dos destinos actuales, `Tareas` y `Concentración`,
  en el mismo orden. Ajustes, Estadísticas y Restablecer progreso continuarán en
  el sidebar; el rediseño no añadirá acciones ni cambiará la arquitectura de
  navegación.
- Alinear dimensiones, radios y colores con `AppColors` y con los componentes
  existentes, evitando introducir valores visuales duplicados si corresponde
  promoverlos a constantes del tema.

### Interacción y movimiento

- Animar la cápsula, el color y el peso visual al cambiar de destino con una
  transición breve (aproximadamente 180–250 ms) y una curva suave.
- Mantener ambos destinos visibles durante la animación y evitar movimientos
  que cambien el ancho del blanco táctil o desplacen bruscamente las etiquetas.
- Respetar `MediaQuery.disableAnimations`; cuando esté activo, aplicar el estado
  final sin una transición perceptible.
- Conservar respuesta táctil mediante `InkWell` o un control Material
  equivalente, incluyendo estado presionado y foco visible para navegación por
  teclado.
- No usar la animación para comunicar información indispensable: color, ícono,
  texto, semántica seleccionada e indicador visual deben expresar por sí solos
  cuál es el destino activo.

### Responsividad y accesibilidad

- Mantener blancos táctiles de al menos 48 × 48 y repartir equitativamente el
  ancho disponible entre ambos destinos.
- Mostrar completas las etiquetas `Tareas` y `Concentración`. En anchos
  compactos, reducir primero el espacio horizontal y el margen exterior antes
  que truncar, ocultar o escalar excesivamente el texto.
- Usar `SafeArea(top: false)` y combinar su inset inferior con el padding del
  componente sin duplicarlo; validar especialmente dispositivos con barra de
  gestos y navegación Android de tres botones.
- Asegurar contraste suficiente en estados activo, inactivo, presionado y foco,
  incluida la escala de texto 1.3 y los temas soportados por la aplicación.
- Conservar las claves `homeBottomNavigation`, `tasksTab` y `focusTab`, las
  etiquetas semánticas y la propiedad `selected` para cada destino.

### Pruebas y validación visual del footer

- Añadir pruebas de widget que validen selección inicial, cambio entre pestañas,
  semántica seleccionada y que el callback se invoque una sola vez por toque.
- Comprobar que Tareas y Concentración muestran ícono y etiqueta completos en
  320, 360, 390, 412 y 430 px, con escalas de texto 1.0 y 1.3, sin overflow.
- Probar los insets inferiores con barra de gestos, navegación de tres botones
  y ausencia de inset, verificando que ningún control quede pegado o escondido
  en el borde de la pantalla.
- Validar que Ajustes y Estadísticas no marquen incorrectamente uno de los dos
  destinos inferiores, conservando el comportamiento actual del shell.
- Realizar golden tests o capturas comparativas, si la infraestructura del
  proyecto lo permite, para los estados activo/inactivo y para ambos destinos.
- Hacer una comprobación manual en un dispositivo compacto y otro alto para
  verificar que el footer mejorado no tape el contenido desplazable ni reduzca
  en exceso el área útil del temporizador.

### Criterios de aceptación del footer

- El footer se reconoce visualmente como un componente de Atomic Task y no como
  una barra de navegación genérica.
- El destino activo se identifica de inmediato por una cápsula integrada,
  contraste suficiente y semántica seleccionada; no depende solo del color.
- Las dos etiquetas permanecen completas y no existe overflow en la matriz
  responsiva ni con texto ampliado a 1.3.
- El componente respeta el área segura inferior, mantiene blancos táctiles de
  al menos 48 × 48 y ofrece estados de toque y foco visibles.
- Cambiar de pestaña sigue usando el `IndexedStack`, no crea rutas y no reinicia
  el temporizador, formularios ni desplazamiento.
- El rediseño no modifica reglas de negocio, persistencia ni los destinos que
  pertenecen al sidebar.

## Archivos previstos para la implementación

- `lib/features/home/presentation/widgets/home_app_bar.dart`: distribución
  responsiva y política de renderizado del título.
- `lib/features/home/presentation/widgets/home_bottom_navigation.dart`:
  superficie elevada, estado seleccionado, animación y adaptación al Safe Area.
- `lib/core/theme/app_colors.dart`: únicamente si el footer requiere nuevos
  tokens reutilizables de superficie, borde o estado; no para guardar medidas
  específicas del componente.
- `test/widget_test.dart`: cobertura de integración del header en cada destino
  y tamaño de pantalla, además de navegación, semántica e insets del footer.
- Si conviene aislar las combinaciones responsivas, un nuevo test específico en
  `test/` para `HomeAppBar`, sin mover lógica de negocio al widget.
