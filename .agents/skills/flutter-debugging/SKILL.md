# Flutter Debugging Skill

## Purpose

Esta skill define un proceso sistemático y reutilizable para diagnosticar y corregir errores en proyectos Flutter.

Debe funcionar en proyectos diferentes sin asumir:

- arquitectura específica;
- gestor de estado específico;
- plataforma objetivo;
- dependencias concretas;
- estructura fija de carpetas;
- versión específica de Flutter.

Su objetivo es encontrar la causa raíz de un problema, aplicar la corrección mínima necesaria y dejar el proyecto en un estado verificable.

---

## 1. Principios

Al depurar un proyecto Flutter:

1. Inspeccionar antes de modificar.
2. Reproducir el problema cuando sea posible.
3. No asumir la causa antes de obtener evidencia.
4. Corregir la causa raíz, no solamente el síntoma.
5. Respetar la arquitectura y convenciones existentes.
6. Preferir cambios pequeños, localizados y reversibles.
7. No eliminar funcionalidades para hacer desaparecer un error.
8. No actualizar dependencias indiscriminadamente.
9. No introducir refactors no relacionados.
10. No declarar éxito sin validación.

---

## 2. Descubrimiento inicial

Antes de modificar código, inspeccionar el proyecto.

Determinar:

- versión de Flutter y Dart;
- plataformas habilitadas;
- arquitectura;
- gestor de estado;
- dependencias relevantes;
- archivos relacionados con el error;
- configuración específica de plataforma;
- pruebas existentes;
- cambios locales del usuario.

Ejecutar cuando sea posible:

```bash
flutter --version
flutter doctor -v
flutter pub get
flutter analyze
git status
git diff
```

Inspeccionar cuando existan:

```text
pubspec.yaml
pubspec.lock
analysis_options.yaml
lib/
test/
integration_test/
android/
ios/
linux/
windows/
macos/
web/
```

No asumir que todas las carpetas están presentes.

---

## 3. Establecer una línea base

Antes de aplicar una corrección, identificar el estado actual.

Registrar:

- errores de compilación;
- warnings relevantes;
- excepciones;
- stack traces;
- comportamiento esperado;
- comportamiento observado;
- plataforma donde ocurre;
- pasos para reproducirlo;
- errores preexistentes.

Si existen pruebas, usar la skill `flutter-testing` para establecer el estado inicial y posteriormente validar la corrección.

---

## 4. Reproducir el problema

Siempre que sea razonablemente posible:

1. identificar los pasos exactos;
2. ejecutar la aplicación o prueba afectada;
3. confirmar el fallo;
4. capturar la evidencia relevante;
5. reducir el problema a la mínima secuencia reproducible.

No modificar código al azar si todavía no se comprende qué está fallando.

Si el problema no puede reproducirse, continuar únicamente con evidencia suficiente como:

- stack trace;
- logs;
- mensajes del compilador;
- tests fallidos;
- comportamiento observable;
- cambios recientes.

---

## 5. Clasificar el problema

Clasificar el fallo antes de decidir cómo investigarlo.

### Compilación

Ejemplos:

- símbolos no encontrados;
- tipos incompatibles;
- imports incorrectos;
- argumentos faltantes;
- APIs eliminadas;
- errores del compilador Dart.

Priorizar:

```bash
flutter analyze
```

### Dependencias

Ejemplos:

- conflictos de versiones;
- paquetes no encontrados;
- APIs incompatibles;
- plugins no registrados;
- resolución fallida.

Inspeccionar:

```text
pubspec.yaml
pubspec.lock
```

Usar cuando sea útil:

```bash
flutter pub get
flutter pub deps
flutter pub outdated
```

No ejecutar automáticamente:

```bash
flutter pub upgrade --major-versions
```

### Runtime

Ejemplos:

- null errors;
- `RangeError`;
- `StateError`;
- errores de navegación;
- errores de inicialización;
- excepciones de plugins.

Leer el stack trace desde el primer frame relevante que pertenezca al proyecto.

### UI y layout

Ejemplos:

- `RenderFlex overflow`;
- widgets invisibles;
- tamaños incorrectos;
- scroll roto;
- superposición;
- problemas responsive.

Inspeccionar:

- constraints;
- `Expanded`;
- `Flexible`;
- `SizedBox`;
- `MediaQuery`;
- `LayoutBuilder`;
- scrollables;
- árbol padre-hijo.

No ocultar contenido como solución de un overflow sin entender el layout.

### Estado

Identificar primero el mecanismo usado:

- `setState`;
- `ChangeNotifier`;
- Provider;
- Riverpod;
- Bloc/Cubit;
- GetX;
- MobX;
- Redux;
- otro.

Buscar:

- estado recreado;
- listeners duplicados;
- providers fuera de alcance;
- rebuilds incorrectos;
- mutaciones no notificadas;
- lifecycle incorrecto.

Mantener el patrón existente salvo que sea la causa directa del bug.

### Asincronía

Buscar:

- `Future` sin esperar;
- race conditions;
- `setState` después de `dispose`;
- uso de `BuildContext` después de `await`;
- streams no cancelados;
- timers activos;
- datos usados antes de terminar su carga.

Cuando corresponda:

```dart
if (!context.mounted) return;
```

No añadir comprobaciones sin evidencia de que resuelven la causa.

### Persistencia y datos

Para SQLite, SharedPreferences, Hive, Isar, Firebase, Supabase, APIs u otros sistemas comprobar:

1. entrada;
2. escritura;
3. lectura;
4. serialización;
5. deserialización;
6. valores nulos;
7. estados vacíos;
8. migraciones;
9. errores de red;
10. manejo de errores.

No borrar datos del usuario como estrategia predeterminada.

### Plataforma

Si el error ocurre sólo en una plataforma, investigar primero su configuración.

Distinguir entre:

```text
Error Dart/Flutter
```

y:

```text
Error del toolchain o plataforma nativa
```

---

## 6. Localizar la causa raíz

Reducir progresivamente el área de búsqueda:

```text
Síntoma
  ↓
Error / stack trace
  ↓
Archivo
  ↓
Función / Widget
  ↓
Estado / entrada
  ↓
Origen del dato
  ↓
Causa raíz
```

Preguntarse:

- ¿qué condición concreta produce el fallo?;
- ¿qué valor es inesperado?;
- ¿quién genera ese valor?;
- ¿cuándo cambia?;
- ¿ocurre siempre o sólo bajo ciertas condiciones?;
- ¿es específico de plataforma?;
- ¿apareció después de un cambio reciente?;
- ¿hay una precondición que no se cumple?

---

## 7. Buscar referencias antes de modificar

Antes de cambiar una clase, función, modelo, servicio, provider, ruta o API interna, localizar sus usos.

Comprobar:

- quién la llama;
- qué datos recibe;
- qué datos devuelve;
- qué tests dependen de ella;
- qué otros componentes podrían romperse.

No cambiar una interfaz interna sin revisar sus consumidores.

---

## 8. Formular una hipótesis comprobable

Antes de una corrección significativa, definir una hipótesis concreta.

Ejemplo correcto:

```text
La pantalla falla porque `task` puede ser null durante la primera
renderización, pero se intenta acceder a `task.title` antes de finalizar
la carga asíncrona.
```

Evitar hipótesis vagas como:

```text
Flutter parece estar fallando.
```

La hipótesis debe poder confirmarse o descartarse mediante código, logs, pruebas o reproducción.

---

## 9. Aplicar la corrección mínima

Preferir:

```text
1 problema
→ 1 causa
→ 1 corrección
→ 1 validación
```

Evitar durante la depuración:

- refactors masivos;
- cambios de arquitectura;
- renombrados no relacionados;
- actualización general de dependencias;
- cambios visuales ajenos al bug;
- modificaciones de varias plataformas sin necesidad.

Si un refactor es imprescindible para corregir el error correctamente, limitarlo al área afectada.

---

## 10. Uso de logs

Añadir logs temporales sólo cuando ayuden a observar:

- flujo de ejecución;
- cambios de estado;
- valores;
- respuestas externas;
- secuencias async.

Nunca registrar:

- contraseñas;
- tokens;
- claves API;
- secretos;
- datos sensibles innecesarios.

Eliminar los logs temporales cuando ya no aporten valor.

---

## 11. No ocultar excepciones

Evitar:

```dart
try {
  // ...
} catch (_) {}
```

si únicamente silencia el problema.

Una excepción debe:

- corregirse;
- manejarse correctamente;
- convertirse en un estado esperado;
- o propagarse de forma intencional.

---

## 12. No abusar de valores por defecto

Evitar soluciones arbitrarias como:

```dart
value ?? 0
```

sin comprobar si `null` es realmente un estado válido.

Primero determinar por qué el valor puede ser nulo.

---

## 13. `flutter clean`

No usar `flutter clean` como primera solución.

Considerarlo sólo si existe evidencia de:

- caché inconsistente;
- artefactos nativos obsoletos;
- cambios de plugins;
- build generado corrupto;
- cambios importantes de configuración de plataforma.

Cuando corresponda:

```bash
flutter clean
flutter pub get
```

`flutter clean` no sustituye una corrección de código.

---

## 14. Problemas Android

Revisar, cuando sea relevante:

```text
android/app/build.gradle
android/app/build.gradle.kts
android/build.gradle
android/settings.gradle
android/gradle.properties
android/gradle/wrapper/gradle-wrapper.properties
AndroidManifest.xml
```

Comprobar:

- `minSdk`;
- `compileSdk`;
- `targetSdk`;
- Gradle;
- Android Gradle Plugin;
- Kotlin;
- Java;
- permisos;
- configuración de plugins.

No cambiar versiones arbitrariamente.

---

## 15. Problemas iOS

Revisar cuando corresponda:

```text
ios/Podfile
ios/Runner/
Info.plist
```

Distinguir errores CocoaPods o Xcode de errores Dart.

No modificar iOS si la plataforma no forma parte del problema.

---

## 16. Problemas Web

Comprobar:

- uso de APIs no compatibles con navegador;
- `dart:io`;
- CORS;
- rutas;
- inicialización;
- plugins sin soporte web;
- almacenamiento;
- service workers.

---

## 17. Problemas Windows, Linux y macOS

Comprobar:

- soporte real del plugin;
- dependencias nativas;
- CMake;
- toolchain;
- paquetes del sistema;
- configuración del runner.

No modificar código Dart si el fallo pertenece claramente al toolchain nativo.

---

## 18. Seguridad del repositorio

Antes de operaciones potencialmente destructivas:

```bash
git status
git diff
```

No ejecutar sin necesidad:

```bash
git reset --hard
git clean -fd
git checkout -- .
git restore .
```

No sobrescribir ni eliminar cambios del usuario que no formen parte del problema.

---

## 19. Uso de Git para diagnóstico

Cuando exista historial útil:

```bash
git log --oneline
git diff
```

Utilizarlo para detectar:

- cambios recientes;
- regresiones;
- archivos modificados;
- diferencias entre una versión funcional y la actual.

No revertir commits completos si una corrección localizada es suficiente.

---

## 20. Validación

Después de modificar el código, delegar la validación sistemática a la skill `flutter-testing`.

Como mínimo, cuando sea aplicable:

```bash
dart format <archivos_modificados>
flutter analyze
```

Luego ejecutar las pruebas relevantes y la suite necesaria según `flutter-testing`.

Si el bug depende de interacción real, volver a ejecutar exactamente el flujo que lo provocaba.

No considerar corregido un bug únicamente porque el proyecto compile.

---

## 21. Prueba de regresión

Cuando sea razonable, añadir una prueba que reproduzca el bug.

La prueba debe:

1. representar la condición que generaba el fallo;
2. fallar con la implementación defectuosa;
3. pasar con la corrección;
4. proteger contra futuras regresiones.

Ejemplo:

```text
Bug:
Completar una tarea dos veces otorgaba dos recompensas.

Regresión:
Una tarea ya completada no puede volver a generar una recompensa.
```

La implementación y ejecución de estas pruebas debe seguir `flutter-testing`.

---

## 22. Ciclo de depuración

Seguir este ciclo:

```text
REPRODUCIR
   ↓
OBSERVAR
   ↓
LOCALIZAR
   ↓
FORMULAR HIPÓTESIS
   ↓
CORREGIR
   ↓
VALIDAR
   ↓
REPRODUCIR NUEVAMENTE
```

Si la validación falla, regresar a `LOCALIZAR`.

No acumular parches sobre una hipótesis ya descartada.

---

## 23. Escalamiento

Si la primera hipótesis falla:

### Nivel 1
Revisar el archivo y stack trace inmediato.

### Nivel 2
Revisar dependencias directas del componente.

### Nivel 3
Seguir el flujo de datos y estado.

### Nivel 4
Revisar configuración del proyecto.

### Nivel 5
Revisar plugins y plataforma nativa.

### Nivel 6
Construir una reproducción mínima si es necesario.

Empezar por la opción de menor impacto.

---

## 24. Errores preexistentes

Distinguir claramente:

```text
Errores existentes antes de la intervención
```

de:

```text
Errores introducidos por la corrección
```

No ocultar errores preexistentes.

Si bloquean la validación, documentarlos explícitamente.

---

## 25. Condiciones de cierre

No declarar el problema resuelto hasta comprobar, cuando corresponda:

```text
[ ] El fallo fue reproducido o existe evidencia suficiente.
[ ] La causa raíz puede explicarse.
[ ] La corrección es localizada y justificada.
[ ] No se eliminaron funcionalidades para ocultar el error.
[ ] El código modificado está formateado.
[ ] flutter analyze no presenta errores nuevos.
[ ] Las pruebas relevantes pasan.
[ ] Se volvió a ejecutar el flujo que fallaba.
[ ] No existen regresiones evidentes.
```

---

## 26. Informe final

Al terminar, informar:

### Problema
Qué comportamiento era incorrecto.

### Causa raíz
Qué condición técnica lo provocaba.

### Corrección
Qué archivos se modificaron y por qué.

### Validación
Qué comandos, pruebas o flujos se ejecutaron.

### Estado restante
Errores preexistentes, limitaciones o bloqueos, si existen.

Ejemplo:

```text
Problema:
Completar una tarea causaba RangeError cuando la lista estaba vacía.

Causa raíz:
La vista accedía a tasks[0] sin verificar si la colección contenía elementos.

Corrección:
Se modificó task_list.dart para manejar explícitamente el estado vacío.

Validación:
- flutter analyze: correcto
- prueba de regresión: correcta
- flutter test: correcto
- flujo manual reproducido nuevamente: correcto
```

---

## 27. Regla de autonomía

Cuando se solicite explícitamente resolver un bug, continuar con:

```text
diagnosticar
→ corregir
→ validar
→ volver a probar
```

hasta que:

1. el problema esté resuelto; o
2. exista un bloqueo externo real que impida continuar.

Los errores nuevos introducidos por una corrección forman parte del mismo proceso y deben investigarse.

---

## 28. Regla principal

```text
INSPECCIONAR ANTES DE MODIFICAR

REPRODUCIR ANTES DE CORREGIR

CORREGIR LA CAUSA, NO EL SÍNTOMA

CAMBIAR LO MÍNIMO NECESARIO

VALIDAR DESPUÉS DE MODIFICAR

NO DECLARAR ÉXITO SIN EVIDENCIA
```
