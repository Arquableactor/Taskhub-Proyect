import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Una "tarjeta Solid": superficie elevada con sombra y borde de luz superior.
class BlockCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const BlockCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.s16),
    this.radius = AppDimens.radius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final card = Container(
      padding: padding,
      decoration: AppDimens.block(dark: c.dark, radius: radius),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: card,
    );
  }
}

/// Encabezado de sección: título grande + contador opcional + acción a la derecha.
class SectionHeader extends StatelessWidget {
  final String titulo;
  final int? contador;
  final Widget? accion;

  const SectionHeader({
    super.key,
    required this.titulo,
    this.contador,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.s12, top: AppDimens.s8),
      child: Row(
        children: [
          Text(titulo, style: Theme.of(context).textTheme.headlineSmall),
          if (contador != null) ...[
            const SizedBox(width: 8),
            Text('$contador', style: AppText.number(c.textFaint, size: 18)),
          ],
          const Spacer(),
          if (accion != null) accion!,
        ],
      ),
    );
  }
}

/// Etiqueta mono en mayúsculas ("BUENAS TARDES", "TU PROGRESO").
class Eyebrow extends StatelessWidget {
  final String texto;
  const Eyebrow(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Text(texto.toUpperCase(), style: AppText.eyebrow(c.textDim));
  }
}
