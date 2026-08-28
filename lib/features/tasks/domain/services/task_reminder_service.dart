import '../entities/atomic_task.dart';

/// Contrato para sincronizar recordatorios asociados a tareas.
///
/// La interfaz no conoce el plugin de notificaciones. Esto permite que el
/// controlador reciba una implementación local, una falsa para pruebas o una
/// implementación distinta sin acoplar el dominio a Flutter.
abstract interface class TaskReminderService {
  Future<void> initialize();

  Future<void> schedule(AtomicTask task);

  Future<void> cancel(AtomicTask task);

  Future<void> reconcile(Iterable<AtomicTask> tasks, {DateTime? now});
}

class TaskReminderPermissionDeniedException implements Exception {
  const TaskReminderPermissionDeniedException();

  @override
  String toString() => 'No se concedieron permisos para las notificaciones.';
}
