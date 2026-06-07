import 'package:flutter/material.dart';
import 'app_colors.dart';

/// TaskHub — Tokens de dimensión (radios, espaciado, sombras, decoraciones)
/// Extraídos del prototipo (taskhub.css), dirección "Solid".
class AppDimens {
  AppDimens._();

  // ── Radios de esquina ──
  static const double radiusXs = 10;   // tags pequeños
  static const double radiusSm = 14;   // tarjetas de tarea, inputs, stat tiles
  static const double radius = 22;     // tarjetas principales
  static const double radiusNav = 26;  // barra de navegación
  static const double radiusFab = 20;  // botón flotante (+)
  static const double radiusPill = 999; // chips, botones, badges

  // ── Espaciado (escala usada en el diseño) ──
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;   // padding estándar de tarjeta
  static const double s18 = 18;   // padding lateral de página
  static const double s24 = 24;

  // Padding de página: 66 arriba (despeja status bar), 18 lados, 124 abajo (nav).
  static const EdgeInsets pagePadding =
      EdgeInsets.fromLTRB(18, 66, 18, 124);

  // ── Tamaños de componentes ──
  static const double checkbox = 26;        // casilla de tarea
  static const double fab = 58;             // botón flotante central
  static const double navHeight = 64;       // barra inferior
  static const double progressRing = 94;    // anillo de progreso "Hoy"
  static const double progressRingStroke = 9;
  static const double priorityBarWidth = 5; // bloque de prioridad (estilo Solid)

  // ── Sombras "Solid" (bloques tácticos con profundidad) ──
  // Tarjetas, tiles y tareas en tema OSCURO.
  static const List<BoxShadow> blockShadowDark = [
    BoxShadow(color: Color(0x73000000), blurRadius: 18, offset: Offset(0, 6)),
    // + un borde superior de luz interno (white 5%): se simula con un
    //   Border(top: BorderSide(color: Color(0x0DFFFFFF))) en la decoración.
  ];

  static const List<BoxShadow> blockShadowLight = [
    BoxShadow(color: Color(0x1F503C78), blurRadius: 20, offset: Offset(0, 6)),
  ];

  // Sombra del FAB (glow cian + profundidad)
  static const List<BoxShadow> fabShadow = [
    BoxShadow(color: Color(0x8C00F0FF), blurRadius: 30), // glow cian 55%
    BoxShadow(color: Color(0x80000000), blurRadius: 22, offset: Offset(0, 10)),
  ];

  /// Glow neón reutilizable (para casilla completada, chips activos, etc.).
  /// En tema CLARO conviene reducir el alpha a ~45%.
  static List<BoxShadow> neonGlow(Color color, {double opacity = 0.6, double blur = 16}) =>
      [BoxShadow(color: color.withValues(alpha: opacity), blurRadius: blur)];

  /// Decoración base de un "bloque" Solid (tarjeta/tile/tarea).
  static BoxDecoration block({
    required bool dark,
    double radius = radiusSm,
  }) =>
      BoxDecoration(
        color: dark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border(
          top: BorderSide(
            color: dark ? const Color(0x0DFFFFFF) : const Color(0xCCFFFFFF),
          ),
        ),
        boxShadow: dark ? blockShadowDark : blockShadowLight,
      );
}
