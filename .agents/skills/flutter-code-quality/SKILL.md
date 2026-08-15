---
name: flutter-code-quality
description: Revisa y mejora la calidad de código en proyectos Flutter sin alterar el comportamiento funcional. Úsala para detectar código duplicado, widgets demasiado grandes, nombres poco claros, responsabilidades mezcladas, uso incorrecto de const, problemas de mantenibilidad, complejidad innecesaria, deuda técnica y malas prácticas de Dart/Flutter.
---

# Flutter Code Quality Skill

## Purpose

Esta skill define un proceso reutilizable para revisar y mejorar la calidad de código en proyectos Flutter.

Debe funcionar en proyectos distintos sin asumir:

- arquitectura específica;
- gestor de estado específico;
- estructura fija de carpetas;
- librerías concretas;
- versión específica de Flutter;
- estilo visual determinado.

El objetivo es mejorar:

- legibilidad;
- mantenibilidad;
- simplicidad;
- consistencia;
- separación de responsabilidades;
- testabilidad;
- reutilización;
- seguridad de cambios;

sin modificar innecesariamente el comportamiento funcional de la aplicación.

---

# 1. Principios generales

Cuando esta skill sea utilizada:

1. Inspeccionar antes de refactorizar.
2. Respetar la arquitectura existente.
3. No imponer patrones nuevos sin necesidad.
4. No hacer refactors masivos si pueden resolverse problemas localmente.
5. No cambiar comportamiento funcional salvo que el usuario lo solicite.
6. No introducir nuevas dependencias si no aportan valor claro.
7. No cambiar nombres públicos sin revisar sus consumidores.
8. No reestructurar carpetas únicamente por preferencia personal.
9. No reemplazar código entendible por abstracciones innecesarias.
10. Validar después de cada refactor relevante.

---

# 2. Descubrimiento inicial

Antes de modificar código, inspeccionar:

```text
pubspec.yaml
analysis_options.yaml
lib/
test/
integration_test/
```

Identificar:

- arquitectura;
- convenciones de nombres;
- estructura por capas o features;
- gestor de estado;
- patrones existentes;
- utilidades compartidas;
- componentes reutilizables;
- reglas del linter;
- tests;
- código generado;
- dependencias.

Ejecutar cuando sea posible:

```bash
flutter analyze
flutter test
git status
git diff
```

No refactorizar código generado automáticamente salvo que el sistema de generación lo requiera.

---

# 3. Establecer una línea base

Antes de realizar cambios importantes:

```bash
flutter analyze
flutter test
```

Registrar:

- errores;
- warnings;
- tests fallidos;
- problemas preexistentes;
- áreas claramente afectadas.

Esto permite distinguir:

```text
problemas existentes
```

de:

```text
regresiones introducidas por el refactor
```

---

# 4. Alcance

Priorizar primero el código relacionado con la tarea actual.

Orden recomendado:

```text
archivo modificado
↓
feature afectada
↓
dependencias directas
↓
componentes compartidos relacionados
↓
resto del proyecto
```

No convertir una revisión pequeña en una reescritura total del proyecto.

---

# 5. Legibilidad

El código debe poder entenderse sin depender de comentarios extensos.

Revisar:

- nombres;
- tamaño de funciones;
- tamaño de widgets;
- anidación;
- flujo de control;
- condiciones;
- comentarios;
- estructura del archivo.

Preferir:

```dart
final isTaskCompleted = task.status == TaskStatus.completed;
```

sobre:

```dart
final x = task.status == 2;
```

Los nombres deben expresar intención.

---

# 6. Nombres

Usar nombres descriptivos.

Evitar:

```dart
var x;
var data2;
var temp;
var thing;
var obj;
var list1;
```

Preferir:

```dart
final completedTasks;
final selectedTask;
final remainingTime;
final userProfile;
```

Los nombres deben describir qué representa el valor y no sólo su tipo.

---

# 7. Métodos

Un método debe tener una responsabilidad clara.

Revisar métodos que:

- hacen demasiadas cosas;
- modifican múltiples estados;
- realizan UI + persistencia + lógica;
- superan una complejidad razonable;
- tienen muchos niveles de anidación.

Ejemplo problemático:

```dart
void completeTask() {
  // cambia estado
  // actualiza base de datos
  // suma gemas
  // navega
  // muestra snackbar
  // registra analytics
}
```

Considerar separar responsabilidades cuando mejore claridad y testabilidad.

No dividir métodos pequeños de forma artificial.

---

# 8. Early returns

Preferir early returns cuando reduzcan anidación.

Evitar:

```dart
if (task != null) {
  if (task.isActive) {
    if (!task.isCompleted) {
      complete(task);
    }
  }
}
```

Preferir:

```dart
if (task == null) return;
if (!task.isActive) return;
if (task.isCompleted) return;

complete(task);
```

Usar este patrón sólo cuando mejore legibilidad.

---

# 9. Widgets demasiado grandes

Identificar widgets cuyo `build()`:

- tenga demasiadas responsabilidades;
- contenga múltiples secciones independientes;
- sea difícil de leer;
- tenga demasiados niveles de anidación;
- repita componentes.

Extraer subwidgets cuando tengan identidad propia.

Ejemplo:

```dart
class TaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        TaskHeader(),
        TaskSummary(),
        TaskList(),
        TaskActions(),
      ],
    );
  }
}
```

No extraer cada `Padding`, `Text` o `SizedBox` a una clase separada.

---

# 10. Widgets privados

Para componentes exclusivos de un archivo, preferir widgets privados:

```dart
class _TaskHeader extends StatelessWidget {
  const _TaskHeader();

  @override
  Widget build(BuildContext context) {
    return ...;
  }
}
```

Esto evita contaminar innecesariamente la API pública.

---

# 11. Métodos que retornan widgets

Evaluar métodos como:

```dart
Widget buildHeader() { ... }
```

Si el componente:

- tiene lógica propia;
- necesita parámetros;
- tiene estado;
- se reutiliza;
- merece identidad;

preferir un widget separado.

Para fragmentos pequeños y simples, un método puede ser suficiente.

No convertirlo en una regla absoluta.

---

# 12. `const`

Usar `const` cuando sea válido y mejore claridad.

Ejemplo:

```dart
const SizedBox(height: 16)
```

Preferir:

```dart
const Text('Tareas')
```

cuando el contenido sea estático.

No introducir `const` a costa de reestructuraciones innecesarias.

---

# 13. `final`

Preferir `final` cuando una referencia no deba cambiar.

Ejemplo:

```dart
final task = repository.getTask(id);
```

Evitar `var` cuando el valor no se reasigna y el tipo o intención se beneficia de mayor claridad.

No reemplazar todos los `var` automáticamente si no mejora legibilidad.

---

# 14. Mutabilidad

Reducir mutabilidad innecesaria.

Preferir colecciones y modelos inmutables cuando encajen con la arquitectura existente.

Evitar modificar estado compartido desde múltiples lugares.

No imponer inmutabilidad total si el patrón actual depende legítimamente de mutabilidad controlada.

---

# 15. Código duplicado

Buscar duplicación en:

- validaciones;
- estilos;
- widgets;
- llamadas a servicios;
- transformaciones;
- strings;
- constantes;
- lógica de negocio.

Antes de extraer una abstracción, comprobar que la duplicación representa realmente el mismo concepto.

No aplicar DRY de forma extrema.

Dos fragmentos similares no siempre deben compartir una abstracción.

---

# 16. Abstracciones

Crear abstracciones sólo cuando:

- exista repetición real;
- exista un concepto común;
- mejore la claridad;
- reduzca riesgo;
- facilite cambios futuros.

Evitar:

```text
abstracción
sobre abstracción
sobre abstracción
```

para lógica simple.

Priorizar código directo y entendible.

---

# 17. Responsabilidad única

Una clase no debería encargarse simultáneamente de demasiadas áreas.

Revisar clases que mezclen:

```text
UI
+
persistencia
+
red
+
navegación
+
lógica de negocio
```

Separar cuando el proyecto ya tenga límites arquitectónicos claros.

No introducir nuevas capas completas sólo por cumplir una interpretación rígida de SOLID.

---

# 18. Separación UI / lógica

Evitar lógica de negocio compleja dentro de `build()`.

Problemático:

```dart
@override
Widget build(BuildContext context) {
  final reward = tasks
      .where((task) => task.completed)
      .map((task) => task.points * multiplier)
      .fold(0, (a, b) => a + b);

  ...
}
```

Mover la lógica cuando tenga sentido a:

- modelo;
- controlador;
- provider;
- cubit;
- view model;
- use case;
- helper puro;

según la arquitectura existente.

---

# 19. `build()` sin efectos secundarios

No realizar efectos secundarios directamente en `build()`.

Evitar:

```dart
@override
Widget build(BuildContext context) {
  repository.save();
  analytics.logEvent();
  controller.loadData();

  return ...;
}
```

`build()` puede ejecutarse muchas veces.

Los efectos deben ocurrir en mecanismos apropiados del lifecycle o estado.

---

# 20. Complejidad condicional

Revisar expresiones difíciles de leer.

Evitar:

```dart
if ((a && b || c && !d) && (x == 2 || y != null)) {
```

Preferir variables con intención:

```dart
final canCompleteTask = task.isActive && !task.isCompleted;
final hasValidReward = reward != null && reward > 0;

if (canCompleteTask && hasValidReward) {
  ...
}
```

---

# 21. Ternarios

Los ternarios son adecuados para condiciones simples.

Correcto:

```dart
final icon = isCompleted ? Icons.check : Icons.circle_outlined;
```

Evitar ternarios anidados difíciles de leer.

---

# 22. Null safety

No usar `!` indiscriminadamente.

Evitar:

```dart
user!.profile!.name!
```

Comprobar por qué el valor puede ser nulo.

Preferir:

- validación;
- early return;
- modelado correcto;
- estados explícitos.

El operador `!` debe reflejar una garantía real.

---

# 23. Manejo de errores

No silenciar errores.

Evitar:

```dart
try {
  await repository.save();
} catch (_) {}
```

Capturar errores cuando exista una estrategia real:

```dart
try {
  await repository.save();
} on StorageException catch (error) {
  ...
}
```

No usar `catch (e)` sin decidir qué hacer con el error.

---

# 24. Excepciones específicas

Preferir excepciones específicas cuando el dominio o infraestructura lo permita.

Esto mejora:

- debugging;
- manejo de estados;
- testabilidad;
- mensajes de error.

No crear jerarquías complejas de excepciones para casos triviales.

---

# 25. Strings mágicos

Evitar strings repetidos que representen conceptos de dominio.

Problemático:

```dart
if (status == 'completed') { ... }
```

Preferir:

```dart
if (status == TaskStatus.completed) { ... }
```

cuando el modelo lo permita.

---

# 26. Números mágicos

Evitar:

```dart
if (attempts > 3) { ... }
```

si `3` tiene significado de negocio.

Preferir:

```dart
const maxRetryAttempts = 3;
```

No extraer números triviales de layout sin necesidad.

---

# 27. Constantes de UI

Centralizar cuando se repitan consistentemente:

- spacing;
- radios;
- tamaños;
- duraciones;
- breakpoints;
- colores.

Ejemplo:

```dart
class AppSpacing {
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
}
```

No crear sistemas de diseño enormes si el proyecto no los necesita.

---

# 28. Colores y temas

Evitar colores hardcodeados repetidos si el proyecto usa `ThemeData`.

Preferir:

```dart
Theme.of(context).colorScheme.primary
```

sobre:

```dart
const Color(0xFF7B2CBF)
```

cuando el color represente un token del tema.

No sustituir colores intencionalmente locales si no forman parte del sistema global.

---

# 29. Tipografía

Preferir estilos del tema cuando existan.

Ejemplo:

```dart
Theme.of(context).textTheme.titleMedium
```

Evitar duplicar estilos completos en múltiples pantallas.

---

# 30. Imports

Eliminar imports no utilizados.

Ordenar según las herramientas del proyecto.

No usar imports relativos y `package:` de forma inconsistente sin motivo.

Seguir las convenciones existentes.

---

# 31. Exports y barrels

No crear archivos barrel indiscriminadamente.

Usarlos sólo si:

- el proyecto ya los utiliza;
- reducen complejidad;
- no crean ciclos;
- facilitan APIs de módulos.

---

# 32. Clases utilitarias

Evitar clases como:

```dart
class Utils {
  ...
}
```

que acumulen funciones no relacionadas.

Preferir utilidades cohesionadas:

```text
DateFormatter
TaskValidator
RewardCalculator
```

---

# 33. Funciones puras

Cuando una lógica no necesita estado externo, preferir funciones puras.

Beneficios:

- testabilidad;
- previsibilidad;
- reutilización;
- menor acoplamiento.

---

# 34. Acoplamiento

Detectar componentes que conocen demasiados detalles externos.

Ejemplo problemático:

```text
Widget
→ base de datos
→ API
→ preferencias
→ navegación
```

Reducir acoplamiento de acuerdo con la arquitectura existente.

---

# 35. Dependencias

No introducir nuevas dependencias para resolver problemas pequeños que Dart o Flutter ya pueden manejar.

Antes de agregar un paquete:

1. comprobar si Flutter/Dart ya ofrece la capacidad;
2. evaluar mantenimiento;
3. revisar impacto;
4. verificar compatibilidad;
5. comprobar si el proyecto ya tiene una solución equivalente.

---

# 36. Código muerto

Eliminar cuando haya evidencia clara de que no se utiliza:

- imports;
- variables;
- métodos privados;
- widgets privados;
- ramas imposibles;
- comentarios obsoletos.

No eliminar APIs públicas únicamente porque no se encuentren referencias locales.

Podrían usarse externamente.

---

# 37. Comentarios

Los comentarios deben explicar:

```text
por qué
```

más que:

```text
qué
```

Evitar:

```dart
// Incrementar contador
counter++;
```

Útil:

```dart
// Evita otorgar dos recompensas si la acción se dispara dos veces.
if (task.isCompleted) return;
```

Eliminar comentarios que describan comportamiento ya inexistente.

---

# 38. TODOs

Revisar `TODO`, `FIXME`, `HACK`.

No eliminarlos automáticamente.

Determinar si:

- siguen siendo válidos;
- describen deuda real;
- ya fueron resueltos;
- necesitan contexto adicional.

---

# 39. Async

Evitar `async` innecesario.

Problemático:

```dart
Future<int> getValue() async {
  return 5;
}
```

si no existe operación asíncrona real.

No eliminar `async` si forma parte de una API intencional o interfaz existente.

---

# 40. Futures

No ignorar Futures importantes.

Revisar llamadas como:

```dart
repository.save();
```

si deberían ser:

```dart
await repository.save();
```

Determinar si el comportamiento fire-and-forget es intencional.

---

# 41. Streams y listeners

Comprobar que recursos se liberen cuando corresponda:

```text
StreamSubscription
AnimationController
TextEditingController
FocusNode
Timer
ChangeNotifier
```

En widgets stateful:

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

No disponer objetos que no sean propiedad del widget.

---

# 42. Lifecycle

Comprobar uso correcto de:

```text
initState
didChangeDependencies
didUpdateWidget
dispose
```

Evitar trabajo repetido en `build()` que pertenece al lifecycle.

---

# 43. `setState`

No ejecutar `setState` si el widget ya no está montado.

Cuando sea relevante:

```dart
if (!mounted) return;

setState(() {
  ...
});
```

No añadir `mounted` indiscriminadamente.

Primero entender el flujo async.

---

# 44. Estado derivado

Evitar guardar estado que puede calcularse fácilmente a partir de otro estado.

Problemático:

```dart
bool hasTasks;
List<Task> tasks;
```

si `hasTasks` siempre equivale a:

```dart
tasks.isNotEmpty
```

El estado duplicado puede desincronizarse.

---

# 45. Rebuilds

Detectar rebuilds innecesarios, pero no realizar micro-optimizaciones sin evidencia.

Revisar:

- widgets enormes;
- listeners demasiado amplios;
- objetos recreados;
- providers escuchados en áreas demasiado grandes.

No sacrificar claridad por optimizaciones prematuras.

Para análisis profundo de rendimiento, usar una skill específica de performance.

---

# 46. Listas

Para listas grandes, preferir:

```dart
ListView.builder
```

sobre crear todos los elementos de inmediato.

No reemplazar listas pequeñas estáticas por builders sin necesidad.

---

# 47. Keys

Usar keys cuando realmente ayuden a Flutter a identificar widgets.

Especialmente en:

- listas reordenables;
- elementos con identidad;
- widgets stateful que cambian de posición.

No añadir `GlobalKey` como solución genérica.

---

# 48. `GlobalKey`

Evitar `GlobalKey` si:

- sólo se necesita estado;
- puede pasarse un callback;
- puede usarse un controller;
- puede reorganizarse el flujo.

`GlobalKey` tiene usos legítimos, pero aumenta acoplamiento.

---

# 49. Contexto

No almacenar `BuildContext` a largo plazo.

Evitar pasarlo a capas de dominio o persistencia.

`BuildContext` pertenece a la capa de UI.

---

# 50. Navegación

No mezclar navegación con lógica de dominio si la arquitectura permite separarlas.

No cambiar el sistema de navegación existente durante una revisión de calidad salvo que sea la fuente directa de un problema.

---

# 51. Modelos

Los modelos deben representar datos coherentemente.

Revisar:

- campos redundantes;
- tipos incorrectos;
- nullability innecesaria;
- valores mágicos;
- mutabilidad excesiva.

No rediseñar modelos públicos sin evaluar migraciones y consumidores.

---

# 52. Serialización

Evitar duplicación en:

```text
toJson
fromJson
copyWith
```

si el proyecto ya usa generación de código.

No introducir generadores nuevos sólo para eliminar unas pocas líneas.

---

# 53. Validaciones

Centralizar reglas de negocio que se repiten.

Ejemplo:

```dart
bool isValidTaskTitle(String value) {
  return value.trim().isNotEmpty;
}
```

No duplicar la misma validación en varias pantallas si representa una única regla del dominio.

---

# 54. Métodos booleanos

Preferir nombres que se lean como preguntas:

```dart
isCompleted
hasPermission
canSubmit
shouldRetry
```

Evitar:

```dart
checkTask()
flag()
valid()
```

cuando el significado no sea claro.

---

# 55. APIs internas

Mantener APIs pequeñas.

No exponer miembros públicos sin necesidad.

Usar `_` para detalles privados cuando corresponda.

---

# 56. Parámetros

Si un constructor o método tiene demasiados parámetros:

1. comprobar si tiene demasiadas responsabilidades;
2. considerar agrupar datos cohesivos;
3. usar named parameters;
4. evitar objetos de parámetros sin valor real.

---

# 57. Named parameters

Preferir named parameters cuando mejoren claridad:

```dart
TaskCard(
  task: task,
  isSelected: true,
  onComplete: onComplete,
)
```

sobre argumentos posicionales difíciles de interpretar.

---

# 58. Required

Usar `required` cuando el valor sea esencial para construir correctamente un objeto o widget.

No aceptar null sólo para evitar decisiones de diseño.

---

# 59. Defaults

Los valores por defecto deben ser semánticamente correctos.

Evitar defaults arbitrarios que oculten configuración faltante.

---

# 60. Consistencia

Seguir el estilo dominante del proyecto.

No mezclar innecesariamente:

- diferentes gestores de estado;
- diferentes enfoques de navegación;
- diferentes convenciones de nombres;
- múltiples sistemas de temas;
- varias librerías para el mismo problema.

---

# 61. Lints

Respetar `analysis_options.yaml`.

No desactivar reglas para hacer desaparecer warnings sin comprenderlos.

Evitar:

```dart
// ignore: some_lint
```

salvo que exista una justificación clara.

---

# 62. `ignore`

Antes de añadir un ignore:

1. entender la regla;
2. verificar si el código puede corregirse;
3. comprobar si la excepción es legítima;
4. limitar el ignore al ámbito mínimo.

No desactivar una regla global por un único caso.

---

# 63. Refactor seguro

Seguir:

```text
comprender
↓
establecer línea base
↓
hacer cambio pequeño
↓
formatear
↓
analizar
↓
probar
↓
continuar
```

No acumular muchos cambios sin validación intermedia cuando el refactor sea amplio.

---

# 64. Formateo

Después de modificar Dart:

```bash
dart format <archivos_modificados>
```

No reformatear todo el proyecto si produce ruido innecesario en el diff.

---

# 65. Validación

Después de un refactor relevante:

```bash
flutter analyze
```

Luego ejecutar las pruebas relacionadas.

Si está disponible la skill `flutter-testing`, usarla para validación completa.

---

# 66. Revisar el diff

Antes de finalizar:

```bash
git diff
```

Comprobar:

- cambios accidentales;
- archivos no relacionados;
- formateo masivo;
- lógica modificada sin intención;
- comentarios obsoletos;
- imports innecesarios.

---

# 67. No mezclar refactor y features innecesariamente

Si el usuario pide implementar una feature, evitar reescribir simultáneamente áreas no relacionadas.

Cuando un refactor sea necesario para implementar la feature, mantenerlo acotado.

---

# 68. Prioridad de problemas

Clasificar hallazgos:

## Alta prioridad

- bugs potenciales;
- pérdida de datos;
- crashes;
- null safety peligrosa;
- recursos no liberados;
- lógica duplicada susceptible a inconsistencia.

## Media prioridad

- clases muy acopladas;
- widgets grandes;
- funciones complejas;
- duplicación relevante;
- APIs confusas.

## Baja prioridad

- naming menor;
- pequeñas inconsistencias;
- mejoras estéticas de código.

Resolver primero problemas con impacto real.

---

# 69. Evitar sobreingeniería

No introducir:

- repository;
- use case;
- service;
- manager;
- adapter;
- factory;
- facade;

para una operación trivial si el proyecto no lo necesita.

La arquitectura debe reducir complejidad, no aumentarla.

---

# 70. Regla de tres

Antes de generalizar código duplicado, considerar esperar hasta que exista repetición suficiente para entender el patrón.

No es una regla absoluta.

La abstracción debe representar conocimiento real y estable.

---

# 71. Testabilidad

Cuando sea razonable, preferir estructuras que puedan probarse sin UI o dependencias externas.

Ejemplo:

```dart
int calculateReward(Task task) {
  ...
}
```

es más fácil de probar que lógica embebida directamente en un callback de botón.

---

# 72. Dependencias globales

Reducir acceso directo a singletons globales cuando dificulten testing o creen estado implícito.

No sustituirlos automáticamente si forman parte del diseño existente.

---

# 73. Seguridad de secretos

Revisar que no existan secretos hardcodeados:

```text
API keys privadas
tokens
contraseñas
credenciales
```

No imprimirlos en logs.

No confundir identificadores públicos de cliente con secretos reales.

---

# 74. Logs

Eliminar logs temporales de debugging cuando ya no sean necesarios.

Mantener logs útiles si forman parte del sistema de observabilidad del proyecto.

Nunca registrar datos sensibles.

---

# 75. Código generado

Identificar archivos como:

```text
*.g.dart
*.freezed.dart
*.gr.dart
```

No editarlos manualmente salvo que el flujo del proyecto lo requiera.

Modificar la fuente y regenerar.

---

# 76. Comentarios de herramientas

No dejar comentarios como:

```text
// Added by AI
// Fixed by Codex
// Temporary change
```

salvo que tengan valor real para el proyecto.

El código debe hablar por sí mismo.

---

# 77. Deuda técnica

Si se detecta deuda fuera del alcance actual:

- documentarla;
- no convertirla automáticamente en trabajo;
- explicar impacto;
- priorizar sólo si bloquea la tarea actual.

---

# 78. Resultado esperado de una revisión

Una revisión de calidad debe producir mejoras concretas, no una reescritura por estilo.

Idealmente:

```text
menos duplicación
+
menos complejidad
+
mejores nombres
+
responsabilidades claras
+
misma funcionalidad
+
tests pasando
```

---

# 79. Condiciones de cierre

No considerar la revisión terminada hasta comprobar, cuando aplique:

```text
[ ] No se modificó comportamiento funcional sin intención.
[ ] Los cambios respetan la arquitectura existente.
[ ] Se redujo complejidad real.
[ ] No se introdujo sobreingeniería.
[ ] El código modificado está formateado.
[ ] flutter analyze no presenta errores nuevos.
[ ] Las pruebas relevantes pasan.
[ ] Se revisó git diff.
[ ] No se alteraron archivos no relacionados.
[ ] Los errores preexistentes están diferenciados.
```

---

# 80. Informe final

Al finalizar, resumir:

## Problemas encontrados

Ejemplo:

```text
- widget con demasiadas responsabilidades;
- lógica de negocio dentro de build();
- validación duplicada;
- controllers sin dispose;
- nombres poco descriptivos.
```

## Mejoras aplicadas

Indicar:

- archivos;
- refactors;
- simplificaciones;
- extracciones realizadas.

## Comportamiento

Confirmar si se preservó el comportamiento funcional.

## Validación

Ejemplo:

```text
dart format: PASS
flutter analyze: PASS
flutter test: PASS
```

## Deuda restante

Mencionar problemas relevantes que quedaron fuera del alcance.

---

# 81. Relación con otras skills

Cuando estén disponibles:

```text
flutter-debugging
```

usar para investigar bugs reales.

```text
flutter-testing
```

usar para validar cambios y regresiones.

```text
flutter-responsive-mobile
```

usar para problemas de adaptación de interfaz.

`flutter-code-quality` debe centrarse en:

```text
claridad
mantenibilidad
consistencia
simplicidad
estructura
```

y no absorber responsabilidades de las demás skills.

---

# 82. Regla de autonomía

Cuando el usuario solicite mejorar calidad de código:

```text
inspeccionar
→ priorizar problemas
→ aplicar refactors pequeños
→ validar
→ revisar diff
→ repetir si aporta valor
```

Continuar hasta que:

1. los problemas relevantes del alcance estén resueltos; o
2. no existan más mejoras de valor claro sin ampliar innecesariamente el alcance.

---

# 83. Regla principal

```text
NO REFACTORIZAR POR GUSTO

NO IMPONER ARQUITECTURA

NO CAMBIAR COMPORTAMIENTO SIN NECESIDAD

REDUCIR COMPLEJIDAD REAL

PREFERIR CÓDIGO CLARO A CÓDIGO INGENIOSO

HACER CAMBIOS PEQUEÑOS Y VALIDABLES

RESPETAR EL ESTILO DEL PROYECTO

NO DECLARAR ÉXITO SIN ANALIZAR Y PROBAR
```
