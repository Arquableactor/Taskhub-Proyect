import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Calcula y muestra la fuerza de una contraseña con una barra segmentada,
/// estilo "FUERTE · BUENA ELECCIÓN".
class PasswordStrength extends StatelessWidget {
  final String password;
  const PasswordStrength({super.key, required this.password});

  /// Puntaje 0–4 según longitud y variedad de caracteres.
  static int nivel(String p) {
    if (p.isEmpty) return 0;
    var score = 0;
    if (p.length >= 6) score++;
    if (p.length >= 10) score++;
    if (RegExp(r'\d').hasMatch(p) && RegExp(r'[a-zA-Z]').hasMatch(p)) score++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(p)) score++;
    return score.clamp(0, 4);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final n = nivel(password);

    final (etiqueta, color) = switch (n) {
      0 => ('', c.textFaint),
      1 => ('Débil', c.pink),
      2 => ('Aceptable', c.amber),
      3 => ('Fuerte · buena elección', c.cyan),
      _ => ('Excelente', c.lime),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final activo = i < n;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                decoration: BoxDecoration(
                  color: activo ? color : c.surface2,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            );
          }),
        ),
        if (etiqueta.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(etiqueta.toUpperCase(),
              style: AppText.eyebrow(color).copyWith(fontSize: 10)),
        ],
      ],
    );
  }
}
