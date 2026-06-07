import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimens.dart';

/// TaskHub — ThemeData (dirección visual "Solid")
/// Tema principal: oscuro. Se incluye el claro para el toggle dual.
///
/// Uso:
///   MaterialApp(
///     theme: AppTheme.light,
///     darkTheme: AppTheme.dark,
///     themeMode: ThemeMode.dark, // Solid + oscuro es el default elegido
///   );
class AppTheme {
  AppTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppColors.darkBg,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        dim: AppColors.darkTextDim,
        primary: AppColors.cyan,
        secondary: AppColors.violet,
        tertiary: AppColors.pink,
        success: AppColors.lime,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppColors.lightBg,
        surface: AppColors.lightSurface,
        text: AppColors.lightText,
        dim: AppColors.lightTextDim,
        primary: AppColors.cyanLight,
        secondary: AppColors.violetLight,
        tertiary: AppColors.pinkLight,
        success: AppColors.limeLight,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
    required Color dim,
    required Color primary,
    required Color secondary,
    required Color tertiary,
    required Color success,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: AppColors.onNeon, // texto sobre fills neón = fondo oscuro
        secondary: secondary,
        onSecondary: AppColors.onNeon,
        tertiary: tertiary,
        onTertiary: AppColors.onNeon,
        error: tertiary, // usamos pink/magenta para errores y prioridad alta
        onError: AppColors.onNeon,
        surface: surface,
        onSurface: text,
      ),
      textTheme: AppText.textTheme(text, dim),
      // FAB = botón "+" central, sólido cian con glow (ver AppDimens.fabShadow)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: AppColors.onNeon,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusFab),
        ),
        elevation: 0,
      ),
      // Botón primario sólido
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: AppColors.onNeon,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          ),
          textStyle: AppText.textTheme(text, dim).bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        hintStyle: TextStyle(color: isDark ? AppColors.darkTextFaint : AppColors.lightTextFaint),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),
      dividerColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
  }
}
