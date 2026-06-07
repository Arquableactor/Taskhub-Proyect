import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// TaskHub — Escala tipográfica
/// Familia: Space Grotesk (títulos + cuerpo). JetBrains Mono para números/datos.
/// Requiere el paquete `google_fonts` en pubspec.yaml.
///
/// Equivalencias con el prototipo (taskhub.css):
///   h1       30 / w700 / lh 1.18 / ls -0.5   (títulos de pantalla)
///   h2       21 / w700 / ls -0.3             (encabezados de sección)
///   h3       16 / w600 / ls -0.2
///   title    15 / w500                       (título de tarea)
///   body     14 / w400-500
///   eyebrow  11 / w700 / ls 2 / UPPERCASE / mono  (etiquetas pequeñas)
///   meta     12 / w500                       (hora, prioridad, proyecto)
///   num      mono, tabularFigures            (cifras: %, XP, racha, contadores)
class AppText {
  AppText._();

  static TextTheme textTheme(Color color, Color dim) => TextTheme(
        displaySmall: GoogleFonts.spaceGrotesk(
          fontSize: 30, fontWeight: FontWeight.w700, height: 1.18,
          letterSpacing: -0.5, color: color,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 21, fontWeight: FontWeight.w700,
          letterSpacing: -0.3, color: color,
        ),
        titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16, fontWeight: FontWeight.w600,
          letterSpacing: -0.2, color: color,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          fontSize: 15, fontWeight: FontWeight.w500, color: color,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          fontSize: 14, fontWeight: FontWeight.w400, color: dim,
        ),
        labelMedium: GoogleFonts.spaceGrotesk(
          fontSize: 12, fontWeight: FontWeight.w500, color: dim,
        ),
      );

  /// Eyebrow: la etiqueta mono en mayúsculas ("BUENAS TARDES", "TU PROGRESO").
  static TextStyle eyebrow(Color dim) => GoogleFonts.jetBrainsMono(
        fontSize: 11, fontWeight: FontWeight.w700,
        letterSpacing: 2, color: dim, height: 1.0,
      );

  /// Números/datos con cifras de ancho fijo (porcentajes, XP, racha, contadores).
  static TextStyle number(Color color, {double size = 26, FontWeight w = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size, fontWeight: w, color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
        height: 1.0,
      );
}
