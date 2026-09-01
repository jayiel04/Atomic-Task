# Subagentes reutilizables

Estos perfiles definen responsabilidades reutilizables para futuras
implementaciones de Atomic Task. Antes de delegar una tarea, se debe indicar la
spec aprobada, los archivos permitidos, las restricciones y el resultado
esperado.

## Perfiles

- [Planificador técnico](planificador-tecnico.md): convierte requisitos en un
  plan ejecutable.
- [Flutter UI/UX](flutter-ui-ux.md): implementa interfaces responsivas y
  accesibles.
- [Dominio y estado](dominio-estado.md): trabaja con entidades, casos de uso y
  controladores.
- [Drift y persistencia](drift-persistencia.md): gestiona datos locales y
  migraciones.
- [Notificaciones y plataformas](notificaciones-plataformas.md): integra
  capacidades nativas y notificaciones.
- [QA Flutter](qa-flutter.md): diseña y ejecuta verificaciones automatizadas.
- [Revisor de código](revisor-codigo.md): realiza la revisión final de calidad.

## Flujo recomendado

1. Usar `planificador-tecnico` para redactar o enmendar la spec en
   `specs/active/` y resolver sus decisiones pendientes.
2. Obtener la aprobación explícita de la spec antes de delegar implementación.
3. Delegar en paralelo las áreas con conjuntos de archivos no solapados:
   UI/UX, dominio/estado, persistencia y plataformas.
4. Pasar los cambios a `qa-flutter` con los criterios de aceptación de la
   spec y una lista explícita de escenarios.
5. Cerrar con `revisor-codigo`, que debe revisar la diferencia completa y los
   resultados de las pruebas.
6. Registrar la evidencia en la spec y archivarla solo cuando todos los
   criterios estén cumplidos.

## Reglas comunes

- Leer las instrucciones del repositorio y conservar cambios existentes.
- Tratar la spec aprobada como contrato de alcance; solicitar una enmienda si
  una decisión o requisito cambia.
- No modificar archivos fuera del alcance indicado.
- No ocultar errores ni debilitar pruebas para hacerlas pasar.
- Usar `apply_patch` para cambios manuales y regenerar archivos generados con
  las herramientas oficiales.
- Entregar rutas modificadas, comandos ejecutados, resultados y riesgos
  pendientes.
