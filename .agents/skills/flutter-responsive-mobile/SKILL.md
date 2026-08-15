# Flutter Responsive Mobile Skill

## Purpose

Esta skill define un proceso reutilizable para adaptar interfaces Flutter a teléfonos móviles con diferentes tamaños, relaciones de aspecto, densidades y orientaciones.

Debe funcionar en proyectos Flutter diferentes sin asumir:

- arquitectura específica;
- gestor de estado específico;
- sistema de diseño específico;
- dispositivo concreto;
- resolución fija;
- orientación fija;
- paquete externo de responsive design.

El objetivo es conseguir que la interfaz se mantenga usable, legible y visualmente coherente en:

- teléfonos pequeños;
- teléfonos medianos;
- teléfonos grandes;
- orientación vertical;
- orientación horizontal;
- diferentes densidades de píxeles;
- dispositivos con notch o áreas seguras;
- distintos tamaños de texto del sistema.

Esta skill está enfocada principalmente en **aplicaciones móviles Flutter para Android e iOS**.

---

# 1. Regla principal

Nunca diseñar una pantalla Flutter basándose exclusivamente en una resolución concreta.

Evitar código como:

```dart
Container(
  width: 390,
  height: 844,
)
```

si esas dimensiones representan la pantalla completa de un dispositivo de referencia.

Preferir interfaces que respondan a:

```text
espacio disponible
↓
constraints
↓
orientación
↓
contenido
↓
breakpoints
```

La interfaz debe adaptarse al espacio real y no intentar reproducir exactamente un dispositivo determinado.

---

# 2. Principios de responsive design

Al adaptar una interfaz:

1. Diseñar según constraints, no según dispositivos específicos.
2. Evitar tamaños absolutos innecesarios.
3. Permitir que el contenido crezca o se comprima de forma razonable.
4. Usar scroll cuando el contenido pueda exceder el espacio.
5. Evitar overflows.
6. Mantener áreas táctiles suficientemente grandes.
7. Preservar jerarquía visual.
8. Mantener texto legible.
9. Adaptar la composición cuando la orientación cambie.
10. Validar en múltiples tamaños antes de declarar la pantalla terminada.

---

# 3. Descubrimiento inicial

Antes de modificar la interfaz:

1. inspeccionar la pantalla afectada;
2. identificar widgets principales;
3. identificar tamaños fijos;
4. localizar `width`, `height`, `padding`, `margin` y `fontSize`;
5. identificar `Row`, `Column`, `Stack`, `Positioned`, `GridView` y listas;
6. comprobar si ya existe un sistema responsive;
7. comprobar temas y estilos globales;
8. identificar si existen pruebas de widgets.

Buscar especialmente:

```dart
MediaQuery
LayoutBuilder
OrientationBuilder
Expanded
Flexible
Spacer
FittedBox
AspectRatio
FractionallySizedBox
SafeArea
Wrap
GridView
SingleChildScrollView
```

No introducir un segundo sistema responsive si el proyecto ya dispone de uno consistente.

---

# 4. Establecer una línea base

Antes de modificar:

```bash
flutter analyze
flutter test
```

Cuando sea posible, ejecutar la pantalla en al menos:

```text
teléfono pequeño - portrait
teléfono mediano - portrait
teléfono grande - portrait
teléfono pequeño - landscape
teléfono grande - landscape
```

Registrar:

- overflows;
- contenido cortado;
- botones inaccesibles;
- textos truncados;
- espacios excesivos;
- elementos superpuestos;
- widgets desproporcionados;
- problemas al abrir el teclado.

---

# 5. Pensar en espacio lógico, no píxeles físicos

Flutter trabaja principalmente con píxeles lógicos.

No construir decisiones responsive basándose en resoluciones físicas como:

```text
1080x2400
1440x3200
```

Preferir el ancho lógico disponible:

```dart
final size = MediaQuery.sizeOf(context);
final width = size.width;
final height = size.height;
```

O, mejor aún, utilizar constraints locales:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;

    return ...;
  },
)
```

`LayoutBuilder` debe preferirse cuando la adaptación depende del espacio disponible del widget y no necesariamente de toda la pantalla.

---

# 6. Usar `LayoutBuilder` para decisiones de composición

Ejemplo:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 360) {
      return const CompactLayout();
    }

    return const RegularLayout();
  },
)
```

Utilizar breakpoints para cambios estructurales.

No crear decenas de condiciones específicas como:

```dart
if (width == 360) ...
if (width == 375) ...
if (width == 390) ...
if (width == 412) ...
```

Los breakpoints deben representar categorías de espacio, no modelos de teléfono.

---

# 7. Breakpoints móviles recomendados

Los breakpoints exactos pueden adaptarse al proyecto.

Como punto de partida:

```dart
class MobileBreakpoints {
  static const double compact = 360;
  static const double medium = 430;
  static const double wide = 600;
}
```

Interpretación general:

```text
< 360
móvil muy compacto

360 - 429
móvil estándar

430 - 599
móvil grande

>= 600
layout ancho / tablet pequeña
```

Si la aplicación está limitada exclusivamente a teléfonos, no es obligatorio crear una experiencia tablet completa.

Los breakpoints deben utilizarse solamente cuando la composición realmente necesite cambiar.

---

# 8. No escalar absolutamente todo

Responsive design no significa multiplicar todos los valores según el ancho.

Evitar patrones globales como:

```dart
final scale = MediaQuery.sizeOf(context).width / 390;

fontSize: 16 * scale,
padding: EdgeInsets.all(20 * scale),
height: 70 * scale,
```

Esto puede producir:

- textos demasiado pequeños;
- botones gigantes;
- inconsistencias;
- mala accesibilidad.

Preferir:

- tamaños tipográficos estables;
- spacing adaptativo limitado;
- widgets flexibles;
- breakpoints estructurales.

---

# 9. Anchuras flexibles

Evitar:

```dart
Container(
  width: 320,
)
```

cuando el widget debe ocupar el espacio disponible.

Preferir:

```dart
SizedBox(
  width: double.infinity,
)
```

o:

```dart
Expanded(
  child: ...
)
```

o:

```dart
FractionallySizedBox(
  widthFactor: 0.9,
  child: ...
)
```

cuando la proporción sea parte intencional del diseño.

---

# 10. `Expanded` y `Flexible`

Dentro de un `Row` o `Column`, usar:

```dart
Expanded(
  child: ...
)
```

cuando el widget deba ocupar el espacio restante.

Usar:

```dart
Flexible(
  child: ...
)
```

cuando pueda reducirse sin necesidad de llenar todo el espacio.

Ejemplo:

```dart
Row(
  children: [
    const Icon(Icons.task_alt),
    const SizedBox(width: 12),
    Expanded(
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  ],
)
```

Esto es preferible a asignar una anchura fija al texto.

---

# 11. `Wrap` para contenido horizontal variable

Si varios elementos pueden no caber en una fila:

```dart
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    ...
  ],
)
```

Preferir `Wrap` sobre un `Row` cuando los elementos puedan saltar a una segunda línea.

Útil para:

- chips;
- filtros;
- acciones;
- etiquetas;
- botones secundarios.

---

# 12. Manejo de texto

El texto puede crecer por:

- localización;
- preferencias de accesibilidad;
- contenido dinámico;
- nombres largos.

No asumir que un texto siempre ocupa una línea.

Utilizar cuando corresponda:

```dart
Text(
  title,
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

Pero no truncar información crítica innecesariamente.

Para elementos importantes, preferir permitir varias líneas.

---

# 13. Texto escalado por accesibilidad

No bloquear arbitrariamente el escalado de texto del sistema.

Evitar como solución responsive:

```dart
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaler: TextScaler.noScaling,
  ),
  child: ...
)
```

Diseñar para tolerar tamaños de texto mayores.

Comprobar especialmente:

- botones;
- AppBars;
- tarjetas;
- diálogos;
- formularios;
- barras inferiores.

---

# 14. Orientación

Obtener orientación con:

```dart
final orientation = MediaQuery.orientationOf(context);
```

o usar:

```dart
OrientationBuilder(
  builder: (context, orientation) {
    ...
  },
)
```

No utilizar la orientación solamente para cambiar números.

Preferir cambios estructurales cuando tenga sentido.

Ejemplo:

```dart
if (orientation == Orientation.portrait) {
  return const Column(
    children: [
      TaskSummary(),
      TaskList(),
    ],
  );
}

return const Row(
  children: [
    Expanded(child: TaskSummary()),
    Expanded(child: TaskList()),
  ],
);
```

---

# 15. Portrait

En orientación vertical priorizar normalmente:

```text
contenido principal
↓
acciones
↓
contenido secundario
```

Usar:

- `Column`;
- `ListView`;
- `CustomScrollView`;
- tarjetas apiladas;
- navegación inferior cuando sea adecuada.

Evitar que componentes verticales dependan de una altura fija.

---

# 16. Landscape

Landscape tiene menos altura disponible.

Problemas frecuentes:

- botones fuera de pantalla;
- teclado que cubre formularios;
- columnas demasiado altas;
- cabeceras excesivamente grandes;
- navegación inferior ocupando espacio crítico.

En landscape considerar:

- convertir `Column` en `Row`;
- reducir espacios verticales;
- permitir scroll;
- reorganizar paneles;
- mover acciones lateralmente;
- usar una composición más horizontal.

No simplemente reducir todo el contenido para hacerlo caber.

---

# 17. `SafeArea`

Las interfaces deben respetar:

- notch;
- cámara frontal;
- barras del sistema;
- esquinas especiales;
- zonas de gestos.

Usar cuando corresponda:

```dart
SafeArea(
  child: ...
)
```

No añadir `SafeArea` indiscriminadamente dentro de múltiples niveles si produce padding duplicado.

Comprobar si `Scaffold`, `AppBar`, `NavigationBar` u otros widgets ya gestionan parte del área segura.

---

# 18. Altura disponible

Evitar asumir:

```dart
height: MediaQuery.sizeOf(context).height
```

dentro de un contenido que ya está dentro de:

- `Scaffold`;
- `SafeArea`;
- AppBar;
- BottomNavigationBar.

Esto puede provocar overflow.

Preferir constraints recibidos por el padre.

---

# 19. Scroll

Si una pantalla puede superar la altura disponible, debe existir una estrategia de scroll.

Para contenido simple:

```dart
SingleChildScrollView(
  child: ...
)
```

Para listas:

```dart
ListView(...)
```

Para composiciones complejas:

```dart
CustomScrollView(
  slivers: [
    ...
  ],
)
```

No envolver indiscriminadamente `ListView` dentro de `SingleChildScrollView`.

Evitar scrollables anidados sin una razón clara.

---

# 20. Formularios y teclado

Los formularios deben seguir siendo utilizables con el teclado abierto.

Comprobar:

```dart
Scaffold(
  resizeToAvoidBottomInset: true,
  ...
)
```

Normalmente mantener el comportamiento predeterminado salvo que exista una razón para cambiarlo.

Usar scroll para formularios extensos.

Ejemplo:

```dart
SafeArea(
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Form(
      child: Column(
        children: [
          ...
        ],
      ),
    ),
  ),
)
```

Probar:

- teclado abierto;
- último campo;
- botones de confirmar;
- portrait;
- landscape.

---

# 21. Evitar `Positioned` rígido

Los layouts basados excesivamente en:

```dart
Stack(
  children: [
    Positioned(
      left: 220,
      top: 480,
      child: ...
    ),
  ],
)
```

son muy sensibles a cambios de resolución.

Usar `Positioned` solamente cuando la relación espacial sea realmente absoluta dentro del `Stack`.

Para interfaces normales, preferir:

- `Row`;
- `Column`;
- `Align`;
- `Padding`;
- `Expanded`;
- `Flexible`.

---

# 22. Uso correcto de `Stack`

`Stack` es apropiado para:

- overlays;
- badges;
- decoraciones;
- elementos flotantes;
- composiciones superpuestas intencionales.

El contenedor base debe responder a constraints.

Ejemplo:

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: Stack(
    fit: StackFit.expand,
    children: [
      ...
    ],
  ),
)
```

---

# 23. `AspectRatio`

Cuando un elemento debe mantener proporción:

```dart
AspectRatio(
  aspectRatio: 16 / 9,
  child: ...
)
```

Útil para:

- imágenes;
- reproductores;
- cards visuales;
- banners;
- previews.

Preferir esto a calcular manualmente width y height en múltiples lugares.

---

# 24. Imágenes

Configurar imágenes según su función.

Ejemplo:

```dart
Image.asset(
  'assets/image.png',
  fit: BoxFit.cover,
)
```

Opciones comunes:

```text
BoxFit.cover
BoxFit.contain
BoxFit.fill
BoxFit.fitWidth
BoxFit.fitHeight
```

No deformar imágenes para llenar contenedores.

Mantener proporciones cuando el diseño lo requiera.

---

# 25. Grid responsive

No fijar siempre:

```dart
crossAxisCount: 2
```

si el ancho puede variar significativamente.

Puede usarse:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final columns = constraints.maxWidth < 360 ? 1 : 2;

    return GridView.count(
      crossAxisCount: columns,
      children: [...],
    );
  },
)
```

O:

```dart
SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 220,
)
```

Esto permite que Flutter determine el número de columnas según el espacio disponible.

---

# 26. Navegación inferior

Para `BottomNavigationBar` o `NavigationBar` comprobar:

- textos largos;
- landscape;
- dispositivos pequeños;
- iconos;
- safe area;
- teclado.

No fijar alturas personalizadas excesivas sin necesidad.

Si landscape tiene muy poca altura, evaluar si la estructura del proyecto admite otra composición.

---

# 27. Botones y objetivos táctiles

Los botones no deben volverse demasiado pequeños en dispositivos compactos.

No reducir controles táctiles indiscriminadamente.

Mantener espacio suficiente para interacción.

Preferir que el layout se reorganice antes de comprimir excesivamente:

```text
reorganizar
↓
permitir wrap
↓
permitir scroll
↓
reducir spacing moderadamente
```

antes que:

```text
hacer botones diminutos
```

---

# 28. Padding adaptativo

Es razonable adaptar spacing dentro de límites.

Ejemplo:

```dart
double horizontalPadding(double width) {
  if (width < 360) return 12;
  if (width < 430) return 16;
  return 20;
}
```

Evitar crear escalas continuas excesivamente complejas si unos pocos breakpoints son suficientes.

---

# 29. Límites máximos

En teléfonos grandes, algunos elementos no deben crecer indefinidamente.

Usar:

```dart
ConstrainedBox(
  constraints: const BoxConstraints(
    maxWidth: 500,
  ),
  child: ...
)
```

Ejemplo:

```dart
Center(
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 500),
    child: Form(...),
  ),
)
```

Esto evita formularios excesivamente anchos en landscape o dispositivos grandes.

---

# 30. `FittedBox`

`FittedBox` puede ayudar en contenido visual limitado.

Ejemplo:

```dart
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text(...),
)
```

No usarlo como solución general para toda la interfaz.

Si todo debe escalar para caber, probablemente la estructura necesita rediseño responsive.

---

# 31. Componentes reutilizables

Si varios widgets necesitan la misma lógica responsive, centralizarla.

Ejemplo:

```dart
class ResponsivePadding {
  static EdgeInsets screen(double width) {
    if (width < 360) {
      return const EdgeInsets.symmetric(horizontal: 12);
    }

    if (width < 430) {
      return const EdgeInsets.symmetric(horizontal: 16);
    }

    return const EdgeInsets.symmetric(horizontal: 20);
  }
}
```

No duplicar breakpoints en decenas de pantallas.

---

# 32. Crear utilidades sólo cuando aporten valor

No crear una mega-clase global de responsive design antes de comprender las necesidades reales.

Preferir primero APIs nativas:

```text
LayoutBuilder
MediaQuery
Expanded
Flexible
Wrap
SafeArea
AspectRatio
ConstrainedBox
```

Añadir helpers cuando haya reglas repetidas.

---

# 33. No añadir paquetes externos innecesariamente

No instalar automáticamente paquetes como:

```text
flutter_screenutil
responsive_framework
sizer
```

si Flutter nativo es suficiente.

Si el proyecto ya utiliza uno, respetar su sistema.

No mezclar varios enfoques responsive sin una razón clara.

---

# 34. Dispositivos objetivo

Como mínimo validar categorías equivalentes a:

```text
320-359 dp de ancho
360-399 dp
400-429 dp
430+ dp
```

En:

```text
portrait
landscape
```

No es necesario disponer físicamente de todos esos dispositivos si las herramientas de desarrollo permiten simular los tamaños.

---

# 35. Casos extremos

Probar especialmente:

## Pantalla muy estrecha

Comprobar:

- `Row`;
- textos;
- botones;
- AppBar;
- chips;
- formularios.

## Landscape con poca altura

Comprobar:

- scroll;
- headers;
- navegación;
- teclado;
- modales.

## Texto grande

Comprobar:

- botones;
- cards;
- formularios;
- navegación.

## Contenido largo

Probar:

- nombres largos;
- títulos largos;
- listas vacías;
- listas grandes;
- valores máximos.

---

# 36. Diálogos y modales

Los diálogos no deben depender de anchuras fijas rígidas.

Usar constraints.

Comprobar landscape y teclado.

Para bottom sheets:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: ...,
)
```

cuando necesiten responder al teclado o tener contenido extenso.

No asumir que un bottom sheet siempre cabe sin scroll.

---

# 37. Teclado + landscape

Es uno de los escenarios más restrictivos.

Siempre que exista entrada de texto comprobar:

```text
landscape
+
teclado abierto
```

Los campos y la acción principal deben seguir siendo alcanzables.

---

# 38. Adaptación estructural

Una pantalla responsive puede requerir dos composiciones diferentes.

Ejemplo conceptual:

```text
PORTRAIT

[ Header ]

[ Estadísticas ]

[ Lista          ]
[                ]
[                ]

[ Navegación     ]
```

```text
LANDSCAPE

[ Header ]

[ Estadísticas ] [ Lista                ]
[              ] [                      ]
[              ] [                      ]
```

No intentar conservar exactamente la misma distribución si produce una experiencia deficiente.

---

# 39. Separar contenido de layout

Cuando sea posible, no duplicar lógica de negocio al crear layouts portrait y landscape.

Ejemplo:

```dart
Widget buildTaskList() {
  return TaskList(...);
}
```

y utilizar el mismo componente en:

```dart
PortraitLayout(...)
LandscapeLayout(...)
```

La adaptación debe afectar principalmente la composición.

---

# 40. Patrón recomendado

Para pantallas complejas:

```dart
class ExamplePage extends StatelessWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final orientation = MediaQuery.orientationOf(context);

          if (orientation == Orientation.landscape) {
            return ExampleLandscapeLayout(
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
            );
          }

          return ExamplePortraitLayout(
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          );
        },
      ),
    );
  }
}
```

No es obligatorio crear clases separadas para pantallas simples.

---

# 41. Orden de adaptación de una pantalla existente

Seguir este orden:

```text
1. Identificar tamaños rígidos problemáticos.
2. Eliminar dependencias de una resolución concreta.
3. Corregir overflows.
4. Introducir Expanded/Flexible/Wrap.
5. Añadir scroll donde sea necesario.
6. Añadir SafeArea.
7. Revisar imágenes y AspectRatio.
8. Definir breakpoints sólo si hacen falta.
9. Adaptar portrait/landscape.
10. Probar texto grande.
11. Probar teclado.
12. Validar múltiples tamaños.
```

---

# 42. No modificar comportamiento funcional

Esta skill debe centrarse en responsive design.

No cambiar innecesariamente:

- lógica de negocio;
- persistencia;
- navegación;
- modelos;
- APIs;
- gestión de estado.

Si un cambio funcional es imprescindible, documentarlo.

---

# 43. Preservar identidad visual

Responsive no significa rediseñar completamente la aplicación.

Mantener:

- colores;
- tipografías;
- iconografía;
- estilo de tarjetas;
- jerarquía visual;
- identidad de marca.

Cambiar solamente lo necesario para que la composición se adapte correctamente.

---

# 44. Testing visual manual

Para cada pantalla modificada, comprobar como mínimo:

```text
[ ] móvil compacto portrait
[ ] móvil estándar portrait
[ ] móvil grande portrait
[ ] móvil compacto landscape
[ ] móvil grande landscape
[ ] texto aumentado
[ ] teclado abierto, si aplica
[ ] contenido largo
```

Buscar:

```text
[ ] sin overflow
[ ] sin contenido cortado
[ ] sin elementos superpuestos
[ ] acciones accesibles
[ ] texto legible
[ ] navegación accesible
[ ] proporciones visuales coherentes
```

---

# 45. Widget tests para resoluciones

Cuando el proyecto tenga tests de widgets, probar varios tamaños.

Ejemplo:

```dart
Future<void> setScreenSize(
  WidgetTester tester,
  Size size,
) async {
  await tester.binding.setSurfaceSize(size);

  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });
}
```

Ejemplo:

```dart
testWidgets('renderiza correctamente en móvil compacto', (tester) async {
  await tester.binding.setSurfaceSize(
    const Size(320, 640),
  );

  addTearDown(() async {
    await tester.binding.setSurfaceSize(null);
  });

  await tester.pumpWidget(
    const MaterialApp(
      home: ExamplePage(),
    ),
  );

  expect(tester.takeException(), isNull);
});
```

Crear pruebas que detecten excepciones de layout cuando sea útil.

---

# 46. Testing portrait y landscape

Ejemplo de dimensiones lógicas:

```text
Portrait pequeño:
320 x 640

Portrait estándar:
390 x 844

Portrait grande:
430 x 932

Landscape compacto:
640 x 320

Landscape estándar:
844 x 390

Landscape grande:
932 x 430
```

Estas dimensiones son ejemplos de prueba, no resoluciones que deban codificarse en producción.

---

# 47. Validación automatizada

Después de modificar:

```bash
dart format <archivos_modificados>
flutter analyze
flutter test
```

Si existe la skill `flutter-testing`, seguir su procedimiento para ampliar la validación.

Los errores preexistentes deben distinguirse de regresiones introducidas.

---

# 48. Detección de overflow

Durante desarrollo, prestar atención a mensajes como:

```text
A RenderFlex overflowed by ...
```

No solucionar el problema simplemente:

- reduciendo fuente de forma arbitraria;
- ocultando contenido;
- añadiendo `ClipRect`;
- deshabilitando mensajes.

Investigar qué constraint está siendo violado.

---

# 49. Rendimiento

No hacer cálculos responsive innecesariamente complejos en cada frame.

Preferir expresiones simples.

Evitar reconstrucciones globales sólo para adaptar un widget pequeño.

La adaptación debe aprovechar el sistema de layout de Flutter.

---

# 50. Condiciones de cierre

No considerar una pantalla responsive terminada hasta comprobar:

```text
[ ] No depende de una resolución concreta.
[ ] Funciona en portrait.
[ ] Funciona en landscape.
[ ] No tiene overflows.
[ ] Tolera pantallas compactas.
[ ] Tolera teléfonos grandes.
[ ] Respeta SafeArea.
[ ] Tolera contenido largo.
[ ] Tolera texto aumentado razonablemente.
[ ] El teclado no bloquea acciones importantes.
[ ] Los elementos interactivos siguen siendo utilizables.
[ ] flutter analyze no presenta errores nuevos.
[ ] Las pruebas relevantes pasan.
```

---

# 51. Informe final

Al terminar una adaptación responsive, informar:

## Pantallas modificadas

Qué vistas fueron adaptadas.

## Problemas encontrados

Ejemplo:

```text
- anchuras fijas;
- Column sin scroll;
- Row con overflow;
- botones fuera de pantalla en landscape.
```

## Cambios realizados

Ejemplo:

```text
- reemplazo de tamaños fijos por Expanded;
- LayoutBuilder para breakpoints;
- layout alternativo en landscape;
- SafeArea;
- scroll para pantallas pequeñas.
```

## Resoluciones o tamaños probados

Ejemplo:

```text
320x640 portrait
390x844 portrait
430x932 portrait
640x320 landscape
844x390 landscape
932x430 landscape
```

## Validación

```text
flutter analyze: PASS
flutter test: PASS
overflows: no detectados
```

## Limitaciones

Mencionar cualquier dispositivo o flujo que no haya podido comprobarse.

---

# 52. Regla de autonomía

Cuando se solicite adaptar una pantalla o aplicación completa:

```text
inspeccionar
→ detectar puntos rígidos
→ adaptar estructura
→ validar portrait
→ validar landscape
→ corregir overflows
→ validar tamaños extremos
→ ejecutar análisis y tests
```

Continuar hasta que:

1. las pantallas objetivo sean responsivas; o
2. exista un bloqueo externo real.

No detenerse simplemente después de cambiar algunos valores.

---

# 53. Regla de minimalismo

Priorizar:

```text
constraints
↓
widgets flexibles
↓
scroll
↓
adaptación estructural
↓
breakpoints
```

Evitar comenzar con escalado global basado en fórmulas.

---

# 54. Regla final

```text
NO DISEÑAR PARA UN TELÉFONO

DISEÑAR PARA EL ESPACIO DISPONIBLE

NO ESCALAR TODO

ADAPTAR LA COMPOSICIÓN

PROBAR PORTRAIT Y LANDSCAPE

PROBAR TAMAÑOS EXTREMOS

RESPETAR SAFE AREAS Y ACCESIBILIDAD

NO DECLARAR RESPONSIVE SIN VALIDACIÓN
```
