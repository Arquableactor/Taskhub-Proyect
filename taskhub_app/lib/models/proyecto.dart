import 'package:flutter/material.dart';

/// Una lista/proyecto que agrupa tareas (Trabajo, Personal...).
class Proyecto {
  final int id;
  final String nombre;
  final String colorHex; // "#RRGGBB"

  Proyecto({
    required this.id,
    required this.nombre,
    required this.colorHex,
  });

  factory Proyecto.fromJson(Map<String, dynamic> json) => Proyecto(
        id: json['id'] as int,
        nombre: json['nombre'] as String,
        colorHex: json['color'] as String? ?? '#4F46E5',
      );

  /// El color del proyecto como Color de Flutter.
  Color get color {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
