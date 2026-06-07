import 'prioridad.dart';
import 'subtarea.dart';

/// Una tarea. Mapea 1:1 con el JSON que devuelve el backend.
class Task {
  final int id;
  final String titulo;
  final String? descripcion;
  final bool completada;
  final Prioridad prioridad;
  final DateTime? fechaVencimiento;
  final int orden;
  final int? proyectoId;
  final List<SubTarea> subTareas;

  Task({
    required this.id,
    required this.titulo,
    this.descripcion,
    required this.completada,
    required this.prioridad,
    this.fechaVencimiento,
    required this.orden,
    this.proyectoId,
    this.subTareas = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        descripcion: json['descripcion'] as String?,
        completada: json['completada'] as bool? ?? false,
        prioridad: Prioridad.desdeJson(json['prioridad'] as String?),
        fechaVencimiento: json['fechaVencimiento'] != null
            ? DateTime.parse(json['fechaVencimiento'] as String)
            : null,
        orden: json['orden'] as int? ?? 0,
        proyectoId: json['proyectoId'] as int?,
        subTareas: (json['subTareas'] as List<dynamic>? ?? [])
            .map((e) => SubTarea.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Cuántas subtareas están hechas (para la barra de progreso).
  int get subHechas => subTareas.where((s) => s.completada).length;

  /// XP estimado de la tarea (gamificación; por ahora derivado de la prioridad).
  int get xp {
    switch (prioridad) {
      case Prioridad.alta:
        return 50;
      case Prioridad.media:
        return 30;
      case Prioridad.baja:
        return 20;
      case Prioridad.ninguna:
        return 10;
    }
  }
}
