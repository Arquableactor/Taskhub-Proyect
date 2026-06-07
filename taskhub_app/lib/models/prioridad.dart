import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

extension PrioridadColor on Prioridad {
  /// Color de la prioridad según la paleta del tema activo.
  Color colorDe(Palette p) {
    switch (this) {
      case Prioridad.alta:
        return p.pink;
      case Prioridad.media:
        return p.amber;
      case Prioridad.baja:
        return p.cyan;
      case Prioridad.ninguna:
        return p.textFaint;
    }
  }
}

/// Prioridad de una tarea. Coincide con el enum del backend,
/// que viaja como texto ("Alta", "Media"...).
enum Prioridad {
  ninguna,
  baja,
  media,
  alta;

  /// Convierte el texto del backend en el enum.
  static Prioridad desdeJson(String? valor) {
    switch (valor) {
      case 'Alta':
        return Prioridad.alta;
      case 'Media':
        return Prioridad.media;
      case 'Baja':
        return Prioridad.baja;
      default:
        return Prioridad.ninguna;
    }
  }

  /// El texto que espera el backend.
  String get json {
    switch (this) {
      case Prioridad.alta:
        return 'Alta';
      case Prioridad.media:
        return 'Media';
      case Prioridad.baja:
        return 'Baja';
      case Prioridad.ninguna:
        return 'Ninguna';
    }
  }

  /// Etiqueta corta estilo P1–P4 (como en el diseño).
  String get etiqueta {
    switch (this) {
      case Prioridad.alta:
        return 'P1';
      case Prioridad.media:
        return 'P2';
      case Prioridad.baja:
        return 'P3';
      case Prioridad.ninguna:
        return 'P4';
    }
  }

  /// Color de la prioridad (P1 pink, P2 amber, P3 cyan, P4 faint).
  Color color({bool dark = true}) {
    switch (this) {
      case Prioridad.alta:
        return dark ? AppColors.pink : AppColors.pinkLight;
      case Prioridad.media:
        return dark ? AppColors.amber : AppColors.amberLight;
      case Prioridad.baja:
        return dark ? AppColors.cyan : AppColors.cyanLight;
      case Prioridad.ninguna:
        return dark ? AppColors.darkTextFaint : AppColors.lightTextFaint;
    }
  }
}
