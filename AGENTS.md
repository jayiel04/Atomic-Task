# Guía de trabajo para Atomic Task

## Fuentes de verdad

Antes de modificar el proyecto, revisar en este orden:

1. El estado de Git y los cambios locales existentes.
2. La [línea base del producto](docs/product-baseline.md).
3. La [arquitectura](docs/architecture.md).
4. La especificación activa o archivada relacionada en `specs/`.

El código y las pruebas verifican la implementación; la línea base describe el
comportamiento aceptado y una spec describe el cambio que pretende alterarlo.
No crear hojas de ruta, planes paralelos ni documentos de estado fuera de esta
estructura.

## Flujo spec-first

Una especificación es obligatoria antes de cambiar código cuando el trabajo
afecta funcionalidad, reglas de negocio, datos, migraciones, arquitectura,
integraciones, plataformas o experiencia de usuario.

1. Crear o actualizar `specs/active/<nombre>.md` desde
   [la plantilla](specs/template.md).
2. Completar objetivo, alcance, requisitos, impactos, criterios de aceptación,
   pruebas y decisiones pendientes.
3. Esperar aprobación explícita del solicitante; solo entonces su estado pasa a
   `aprobada` y puede empezar la implementación.
4. Implementar únicamente lo acordado. Si cambia el alcance o una decisión,
   enmendar la spec y obtener nueva aprobación antes de continuar.
5. Registrar la evidencia de validación. Al cumplir todos los criterios, marcar
   la spec como `implementada` y moverla a `specs/archive/<nombre>.md`.
6. Actualizar la línea base o arquitectura solo si el cambio modifica un
   contrato funcional o una decisión técnica duradera.

Los arreglos estrictamente mecánicos —formato, comentarios, pruebas que no
alteran el comportamiento o correcciones que restauran un contrato ya
documentado— no necesitan una spec. La entrega debe indicar brevemente su
alcance y validación. Ante la duda, crear una spec.

## Límites técnicos obligatorios

- Respetar la dirección `presentation → application → domain`; `data` depende
  de contratos de dominio y el ensamblaje ocurre en el punto de composición de
  la aplicación.
- `domain` no importa Flutter, Drift ni plugins de plataforma. Los widgets no
  contienen reglas de negocio y las funcionalidades no acceden a controladores
  o datos internos de otra funcionalidad.
- Las dependencias se reciben por constructor. No añadir paquetes de estado,
  DI o navegación sin una necesidad comprobable y una spec aprobada.
- Las migraciones de Drift son aditivas y compatibles; no editar manualmente
  `lib/core/database/app_database.g.dart` ni borrar datos locales sin aviso.
- Los cambios conservan accesibilidad, Safe Areas, comportamiento responsivo y
  las pruebas del nivel más pequeño que valide el riesgo.

## Cierre de un cambio

Preservar cambios ajenos del árbol de trabajo. Ejecutar las comprobaciones que
exija la spec, revisar el diff y documentar resultados, limitaciones y riesgos
pendientes. Un cambio no está terminado solo porque compile: debe satisfacer
sus criterios de aceptación y mantener los contratos documentados.
