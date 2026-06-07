/// Un ítem de checklist dentro de una tarea.
class SubTarea {
  final int id;
  final String titulo;
  final bool completada;

  SubTarea({
    required this.id,
    required this.titulo,
    required this.completada,
  });

  factory SubTarea.fromJson(Map<String, dynamic> json) => SubTarea(
        id: json['id'] as int,
        titulo: json['titulo'] as String,
        completada: json['completada'] as bool? ?? false,
      );
}
