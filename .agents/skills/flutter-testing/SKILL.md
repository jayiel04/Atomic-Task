# Flutter Testing Skill

## Purpose

Esta skill define una estrategia reutilizable para validar proyectos Flutter mediante análisis estático, pruebas automatizadas y comprobaciones de ejecución.

Debe funcionar en proyectos diferentes sin asumir:

- arquitectura específica;
- gestor de estado específico;
- plataforma objetivo;
- framework adicional de testing;
- estructura exacta de carpetas;
- disponibilidad de todos los tipos de pruebas.

Su objetivo es obtener evidencia fiable de que una modificación funciona y no introduce regresiones.

---

## 1. Principios

Al validar un proyecto Flutter:

1. Descubrir primero qué pruebas existen.
2. Ejecutar primero la prueba más cercana al cambio.
3. Ampliar progresivamente el alcance.
4. No confundir compilación con comportamiento correcto.
5. No borrar o deshabilitar tests para conseguir una ejecución verde.
6. No cambiar expectativas de tests sin justificar el cambio funcional.
7. Diferenciar fallos preexistentes de regresiones nuevas.
8. Crear pruebas de regresión cuando un bug pueda reproducirse de forma estable.
9. Mantener las pruebas deterministas.
10. No declarar éxito sin evidencia.

---

## 2. Descubrimiento

Antes de ejecutar o escribir pruebas, inspeccionar:

```text
pubspec.yaml
analysis_options.yaml
test/
integration_test/
lib/
```

Identificar:

- dependencias de testing;
- mocks o fakes existentes;
- helpers;
- fixtures;
- golden tests;
- widget tests;
- unit tests;
- integration tests;
- convenciones de nombres;
- estructura de carpetas.

Comprobar dependencias como, entre otras:

```text
flutter_test
integration_test
mockito
mocktail
bloc_test
fake_async
golden_toolkit
patrol
```

No añadir nuevas librerías si las herramientas existentes son suficientes.

---

## 3. Línea base

Antes de una modificación importante, ejecutar cuando sea posible:

```bash
flutter pub get
flutter analyze
flutter test
```

Registrar:

- número de tests fallidos;
- errores de análisis;
- warnings relevantes;
- tests ignorados;
- tests flaky conocidos;
- problemas de entorno.

Esto permite distinguir fallos preexistentes de regresiones.

---

## 4. Pirámide de validación

Preferir el nivel más barato que pueda demostrar el comportamiento.

Orden general:

```text
Análisis estático
      ↓
Unit tests
      ↓
Widget tests
      ↓
Integration tests
      ↓
Prueba manual / dispositivo real
```

No usar una prueba de integración si una prueba unitaria puede validar el mismo comportamiento de forma fiable.

---

## 5. Formateo

Después de modificar archivos Dart:

```bash
dart format <archivos_modificados>
```

Cuando el proyecto lo requiera:

```bash
dart format lib test
```

Evitar reformatear todo el repositorio si crea un diff masivo no relacionado.

---

## 6. Análisis estático

Ejecutar:

```bash
flutter analyze
```

Objetivo:

```text
0 errores nuevos
```

Los errores introducidos por el cambio deben corregirse antes de continuar.

Si existen errores preexistentes, documentarlos y comprobar que no aumenten.

---

## 7. Unit tests

Usar unit tests para lógica sin dependencia directa de widgets o plataforma.

Ejemplos:

- modelos;
- validadores;
- servicios;
- repositorios con dependencias simuladas;
- casos de uso;
- cálculos;
- reglas de negocio;
- transformaciones;
- serialización.

Ejecutar una prueba concreta:

```bash
flutter test test/ruta/al_test.dart
```

Ejecutar una carpeta:

```bash
flutter test test/features/tasks/
```

Una buena prueba unitaria debe ser:

- rápida;
- aislada;
- determinista;
- fácil de entender;
- específica.

---

## 8. Widget tests

Usar widget tests para comprobar:

- renderización;
- interacción;
- cambios visuales de estado;
- navegación simple;
- validación de formularios;
- textos;
- botones;
- estados vacíos;
- loading;
- errores de UI.

Ejemplo de estructura:

```dart
testWidgets('muestra el estado vacío cuando no hay tareas', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(
      home: TaskPage(),
    ),
  );

  expect(find.text('No hay tareas'), findsOneWidget);
});
```

No depender de tiempos arbitrarios si puede utilizarse:

```dart
await tester.pump();
await tester.pumpAndSettle();
```

Usar `pumpAndSettle()` sólo cuando realmente exista un estado que termine estabilizándose.

---

## 9. Integration tests

Usar pruebas de integración para flujos que cruzan varias capas o requieren aplicación completa.

Ejemplos:

```text
abrir app
→ crear tarea
→ completar tarea
→ verificar recompensa
→ reiniciar app
→ comprobar persistencia
```

Antes de ejecutarlas, identificar dispositivos:

```bash
flutter devices
```

Ejecutar cuando corresponda:

```bash
flutter test integration_test
```

o:

```bash
flutter test integration_test/app_test.dart -d <device>
```

Seguir la configuración real del proyecto si utiliza herramientas adicionales.

---

## 10. Pruebas de regresión

Cuando se corrige un bug reproducible, crear una prueba que proteja específicamente contra su reaparición.

Flujo recomendado:

```text
Bug reproducible
      ↓
Crear test
      ↓
Confirmar que falla
      ↓
Aplicar corrección
      ↓
Confirmar que pasa
```

No es obligatorio forzar un estado rojo si hacerlo requiere revertir trabajo seguro, pero la prueba debe representar fielmente el fallo.

Ejemplo:

```text
Bug:
Una tarea completada podía recompensarse dos veces.

Test:
Completar una tarea ya completada no incrementa nuevamente las gemas.
```

---

## 11. Tests de estado

Cuando el proyecto utilice un gestor de estado, probar el comportamiento público, no detalles internos innecesarios.

Validar:

- estado inicial;
- transición;
- éxito;
- error;
- loading;
- acciones repetidas;
- datos vacíos;
- eventos fuera de orden cuando sean posibles.

Seguir las herramientas ya existentes del proyecto.

---

## 12. Testing async

En código asíncrono comprobar:

- resultado correcto;
- errores;
- timeout;
- cancelación cuando aplique;
- estados intermedios;
- orden de eventos.

Evitar sleeps reales en tests:

```dart
await Future.delayed(const Duration(seconds: 2));
```

si puede usarse:

- mocks;
- fakes;
- `fake_async`;
- `pump`;
- control explícito de Futures.

Las pruebas deben permanecer rápidas y deterministas.

---

## 13. Mocks y fakes

Preferir el enfoque más simple.

Orden recomendado:

```text
Objeto real simple
→ Fake
→ Stub
→ Mock
```

No mockear todo el sistema.

Simular únicamente límites externos como:

- red;
- base de datos;
- almacenamiento;
- reloj;
- servicios externos;
- plataforma.

Evitar verificar interacciones internas si el resultado observable es suficiente.

---

## 14. Datos de prueba

Los datos deben ser:

- mínimos;
- explícitos;
- reproducibles;
- independientes de datos reales del usuario.

No utilizar:

- credenciales reales;
- tokens reales;
- secretos;
- cuentas personales;
- información sensible.

---

## 15. Persistencia

Para almacenamiento local o remoto, validar cuando corresponda:

1. creación;
2. lectura;
3. actualización;
4. eliminación;
5. estado vacío;
6. datos inválidos;
7. migraciones;
8. reinicio de la aplicación.

No borrar datos reales del usuario durante las pruebas.

Usar entornos, fakes o almacenamiento temporal cuando sea posible.

---

## 16. APIs y red

Para código que usa red:

- no depender de servicios externos reales para unit tests;
- simular éxito;
- simular error;
- simular respuesta vacía;
- simular timeout;
- validar parsing.

Las pruebas de integración contra servicios reales deben estar separadas y claramente identificadas.

---

## 17. Golden tests

Usar golden tests sólo si el proyecto ya los utiliza o si la fidelidad visual exacta es un requisito importante.

Antes de actualizar un golden:

1. comprobar que el cambio visual sea intencional;
2. revisar la diferencia;
3. confirmar que no oculta una regresión.

No actualizar goldens automáticamente sólo para conseguir que pasen.

---

## 18. Testing por plataforma

Si una funcionalidad depende de plataforma:

- ejecutar tests independientes cuando sea posible;
- aislar código específico;
- verificar soporte real del plugin;
- ejecutar la aplicación en la plataforma afectada cuando la prueba automatizada no pueda cubrirlo.

No asumir que un test que pasa en Linux garantiza funcionamiento Android, iOS o Web.

---

## 19. Prueba manual

La prueba manual es necesaria cuando el comportamiento no puede validarse suficientemente mediante tests automatizados.

Ejemplos:

- permisos;
- cámara;
- notificaciones;
- teclado;
- lifecycle;
- orientación;
- rendimiento;
- comportamiento nativo;
- UX;
- animaciones;
- interacción física con dispositivo.

Registrar los pasos probados.

No sustituir tests automatizados con pruebas manuales cuando el comportamiento pueda automatizarse fácilmente.

---

## 20. Orden de ejecución después de un cambio

Usar un enfoque incremental.

### Paso 1 — pruebas directamente relacionadas

```bash
flutter test test/ruta/al_test_afectado.dart
```

### Paso 2 — módulo o feature

```bash
flutter test test/features/<feature>/
```

### Paso 3 — análisis estático

```bash
flutter analyze
```

### Paso 4 — suite completa

```bash
flutter test
```

### Paso 5 — integración

Ejecutar sólo cuando sea relevante para el cambio.

### Paso 6 — flujo manual

Reproducir el flujo real si el comportamiento lo requiere.

---

## 21. Si una prueba falla

No cambiar inmediatamente el test.

Determinar primero si:

```text
A. El código está mal.
B. El test está mal.
C. La especificación cambió.
D. El entorno está mal configurado.
E. El test es flaky.
F. El fallo ya existía.
```

Sólo modificar una expectativa cuando el nuevo comportamiento sea intencional y esté justificado.

---

## 22. Tests flaky

Si un test falla de forma intermitente:

1. repetirlo de forma controlada;
2. buscar dependencia temporal;
3. buscar estado compartido;
4. buscar orden de ejecución;
5. buscar acceso a red;
6. buscar timers;
7. buscar animaciones no estabilizadas;
8. aislar recursos globales.

No marcarlo como `skip` únicamente para obtener una suite verde.

---

## 23. Tests omitidos

Si existen pruebas con `skip`, documentarlas.

No eliminar `skip` sin comprender por qué existe.

No añadir nuevos `skip` para evitar corregir una regresión.

---

## 24. Cobertura

La cobertura es una señal, no un objetivo absoluto.

Cuando sea útil:

```bash
flutter test --coverage
```

Priorizar cobertura de:

- reglas de negocio;
- código crítico;
- bugs corregidos;
- flujos de alto riesgo.

No escribir tests sin valor sólo para aumentar un porcentaje.

---

## 25. Testing de errores

Además del camino feliz, comprobar condiciones relevantes como:

- null;
- colección vacía;
- datos corruptos;
- valores límite;
- doble interacción;
- error de red;
- timeout;
- permiso denegado;
- recurso inexistente;
- operación repetida;
- estados inesperados.

---

## 26. Límites y valores extremos

Para reglas numéricas o colecciones probar, cuando aplique:

```text
mínimo
máximo
cero
uno
vacío
un elemento
muchos elementos
valor inválido
valor duplicado
```

Los bugs suelen aparecer en los límites.

---

## 27. No probar detalles irrelevantes

Las pruebas deben enfocarse en comportamiento observable.

Evitar acoplar tests innecesariamente a:

- nombres de métodos privados;
- estructura interna;
- número exacto de llamadas internas;
- implementación que puede cambiar sin alterar comportamiento.

Esto reduce tests frágiles.

---

## 28. Aislamiento

Cada test debe poder ejecutarse:

- individualmente;
- en cualquier orden;
- sin depender del resultado de otro test.

Restablecer estado compartido entre pruebas.

Evitar globals mutables y recursos persistentes no limpiados.

---

## 29. Criterios de aceptación de una corrección

Una modificación puede considerarse validada cuando, según el alcance:

```text
[ ] Los archivos modificados están formateados.
[ ] flutter analyze no presenta errores nuevos.
[ ] Las pruebas directamente relacionadas pasan.
[ ] La feature afectada pasa sus pruebas.
[ ] La suite completa pasa o los fallos preexistentes están documentados.
[ ] Existe prueba de regresión cuando resulta apropiado.
[ ] El flujo real fue probado cuando la automatización no era suficiente.
[ ] No se deshabilitaron pruebas para obtener éxito artificial.
```

---

## 30. Informe final de testing

Reportar:

### Análisis estático

```text
flutter analyze: PASS / FAIL
```

### Pruebas ejecutadas

Indicar comandos y alcance.

### Resultado

Ejemplo:

```text
Unit tests: 24 passed
Widget tests: 8 passed
Integration tests: 2 passed
```

### Fallos

Distinguir:

- preexistentes;
- introducidos;
- relacionados;
- no relacionados.

### Validación manual

Indicar los flujos comprobados si los hubo.

### Riesgos restantes

Mencionar lo que no pudo probarse.

---

## 31. Relación con `flutter-debugging`

Cuando esta skill sea invocada desde `flutter-debugging`:

1. validar primero el cambio mínimo;
2. ejecutar pruebas directamente relacionadas;
3. crear una prueba de regresión cuando sea apropiado;
4. ampliar progresivamente la suite;
5. devolver evidencia suficiente para decidir si el bug está realmente resuelto.

`flutter-debugging` determina qué corregir.

`flutter-testing` determina cómo demostrar que la corrección funciona.

---

## 32. Regla principal

```text
PROBAR PRIMERO LO MÁS CERCANO AL CAMBIO

AMPLIAR EL ALCANCE PROGRESIVAMENTE

NO CAMBIAR TESTS PARA OCULTAR BUGS

PREFERIR TESTS RÁPIDOS Y DETERMINISTAS

CREAR REGRESIONES PARA BUGS REPRODUCIBLES

NO DECLARAR ÉXITO SIN EVIDENCIA
```
