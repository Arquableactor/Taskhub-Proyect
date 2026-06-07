import 'package:flutter/material.dart';

/// TaskHub — Paleta de color.
/// - Tema OSCURO: acentos NEÓN sobre casi-negro ("Solid").
/// - Tema CLARO: acentos PASTEL sobre fondo claro suave.
///
/// Para usar colores que cambian con el tema, pide la paleta del contexto:
///   final c = AppColors.of(context);
///   color: c.text, c.surface, c.cyan, ...
class AppColors {
  AppColors._();

  // ───────────────────────────── ACENTOS NEÓN (oscuro) ──────────────────────
  static const Color cyan = Color(0xFF00F0FF); // primario · foco · "Hoy"
  static const Color violet = Color(0xFFB14BFF); // secundario · nivel/XP
  static const Color pink = Color(0xFFFF2D95); // acento · prioridad · racha
  static const Color lime = Color(0xFF2BFF88); // éxito · completado
  static const Color amber = Color(0xFFFF9F1C); // prioridad media

  // ───────────────────────────── ACENTOS PASTEL (claro) ─────────────────────
  // Versiones suaves de los mismos hues, agradables sobre fondo claro.
  static const Color cyanPastel = Color(0xFF4FC3D4);
  static const Color violetPastel = Color(0xFFB79CF0);
  static const Color pinkPastel = Color(0xFFF58FB8);
  static const Color limePastel = Color(0xFF5FCB97);
  static const Color amberPastel = Color(0xFFF4C16B);

  // ───────────────────────────── TEMA OSCURO (Solid) ────────────────────────
  static const Color darkBg = Color(0xFF060609);
  static const Color darkSurface = Color(0xFF16161F);
  static const Color darkSurface2 = Color(0x12FFFFFF); // white 7%
  static const Color darkBorder = Color(0x0DFFFFFF); // white 5%
  static const Color darkBorderStrong = Color(0x29FFFFFF); // white 16%
  static const Color darkText = Color(0xFFF3F3F9);
  static const Color darkTextDim = Color(0xFF9A9AB2);
  static const Color darkTextFaint = Color(0xFF5D5D74);
  static const Color darkShadow = Color(0x80000000);

  // ───────────────────────────── TEMA CLARO (Pastel) ────────────────────────
  static const Color lightBg = Color(0xFFF2F1FA); // lavanda muy claro
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0x0A14141F); // dark 4%
  static const Color lightBorder = Color(0x14141414); // dark 8%
  static const Color lightBorderStrong = Color(0x24141414); // dark 14%
  static const Color lightText = Color(0xFF1B1B27);
  static const Color lightTextDim = Color(0xFF5B5B6E);
  static const Color lightTextFaint = Color(0xFF9A9AAE);
  static const Color lightShadow = Color(0x1F503C78);

  /// Texto/íconos ENCIMA de un fill de acento. En ambos temas el acento es
  /// suficientemente vivo como para llevar texto oscuro.
  static const Color onAccent = Color(0xFF07070B);
  // Compatibilidad con tokens del handoff:
  static const Color onNeon = onAccent;

  // Variantes "Light" del handoff (se mantienen por compatibilidad de imports).
  static const Color cyanLight = cyanPastel;
  static const Color violetLight = violetPastel;
  static const Color pinkLight = pinkPastel;
  static const Color limeLight = limePastel;
  static const Color amberLight = amberPastel;

  // ───────────────────────────── PALETA SEGÚN CONTEXTO ──────────────────────
  static const Palette darkPalette = Palette(
    dark: true,
    bg: darkBg, surface: darkSurface, surface2: darkSurface2,
    border: darkBorder, borderStrong: darkBorderStrong, shadow: darkShadow,
    text: darkText, textDim: darkTextDim, textFaint: darkTextFaint,
    cyan: cyan, violet: violet, pink: pink, lime: lime, amber: amber,
  );

  static const Palette lightPalette = Palette(
    dark: false,
    bg: lightBg, surface: lightSurface, surface2: lightSurface2,
    border: lightBorder, borderStrong: lightBorderStrong, shadow: lightShadow,
    text: lightText, textDim: lightTextDim, textFaint: lightTextFaint,
    cyan: cyanPastel, violet: violetPastel, pink: pinkPastel,
    lime: limePastel, amber: amberPastel,
  );

  /// La paleta correcta según el brillo del tema actual.
  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkPalette : lightPalette;

  // ───────────────────────────── PRIORIDADES ────────────────────────────────
  // P1 = pink, P2 = amber, P3 = cyan, P4 = faint
  static Color priority(int p, {bool dark = true}) {
    final pal = dark ? darkPalette : lightPalette;
    switch (p) {
      case 1:
        return pal.pink;
      case 2:
        return pal.amber;
      case 3:
        return pal.cyan;
      default:
        return pal.textFaint;
    }
  }

  // ───────────────────────────── GRADIENTES ─────────────────────────────────
  static const LinearGradient xpGradient = LinearGradient(colors: [violet, pink]);
  static const LinearGradient progressGradient = LinearGradient(colors: [cyan, violet]);
  static const LinearGradient heroStrip = LinearGradient(colors: [cyan, violet, pink]);

  // Gradientes pastel (para el modo claro).
  static const LinearGradient xpGradientPastel = LinearGradient(colors: [violetPastel, pinkPastel]);
  static const LinearGradient progressGradientPastel = LinearGradient(colors: [cyanPastel, violetPastel]);
  static const LinearGradient heroStripPastel = LinearGradient(colors: [cyanPastel, violetPastel, pinkPastel]);
}

/// Conjunto de colores semánticos de un tema (claro u oscuro).
class Palette {
  final bool dark;
  final Color bg, surface, surface2, border, borderStrong, shadow;
  final Color text, textDim, textFaint;
  final Color cyan, violet, pink, lime, amber;

  const Palette({
    required this.dark,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.borderStrong,
    required this.shadow,
    required this.text,
    required this.textDim,
    required this.textFaint,
    required this.cyan,
    required this.violet,
    required this.pink,
    required this.lime,
    required this.amber,
  });

  Color get onAccent => AppColors.onAccent;

  LinearGradient get xpGradient =>
      dark ? AppColors.xpGradient : AppColors.xpGradientPastel;
  LinearGradient get progressGradient =>
      dark ? AppColors.progressGradient : AppColors.progressGradientPastel;
  LinearGradient get heroStrip =>
      dark ? AppColors.heroStrip : AppColors.heroStripPastel;

  /// Color de prioridad P1–P4 en este tema.
  Color priority(int p) {
    switch (p) {
      case 1:
        return pink;
      case 2:
        return amber;
      case 3:
        return cyan;
      default:
        return textFaint;
    }
  }
}
