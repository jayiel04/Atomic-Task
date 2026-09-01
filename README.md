# Atomic Task

Aplicación Flutter de productividad local para organizar tareas y alternar
sesiones de concentración y descanso. Combina tareas, recurrencias, progreso,
notificaciones y una experiencia de concentración que conserva su estado.

El proyecto cuenta con destinos para Android, iOS, web, Windows, macOS y
Linux. La implementación y la documentación están en español.

## Inicio rápido

```text
flutter pub get
flutter run
```

Comprobaciones habituales:

```text
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

Si cambia el esquema de Drift, generar el código desde sus fuentes:

```text
dart run build_runner build --delete-conflicting-outputs
```

No se edita manualmente `lib/core/database/app_database.g.dart`.

## Documentación

- [Guía de trabajo](AGENTS.md): reglas del repositorio y flujo spec-first.
- [Línea base del producto](docs/product-baseline.md): comportamiento aceptado
  de la aplicación.
- [Arquitectura](docs/architecture.md): límites, decisiones y señales de
  evolución técnica.
- [Plantilla de especificación](specs/template.md): formato obligatorio para
  cambios con impacto.
- [Especificación activa de recordatorios](specs/active/task-reminders.md):
  trabajo en curso que aún no forma parte de la línea base.

Las especificaciones aprobadas se implementan desde `specs/active/` y, tras
validarse, pasan a `specs/archive/`.
