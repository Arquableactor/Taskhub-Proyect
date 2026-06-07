import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Tarjeta "hero" con la franja neón de 3px arriba (cyan→violet→pink).
class HeroCard extends StatelessWidget {
  final Widget child;
  const HeroCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radius),
      child: Container(
        decoration: AppDimens.block(dark: c.dark, radius: AppDimens.radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(gradient: c.heroStrip),
            ),
            Padding(padding: const EdgeInsets.all(AppDimens.s18), child: child),
          ],
        ),
      ),
    );
  }
}

/// Anillo de progreso del día. Llega a verde lima al 100%.
class ProgressRing extends StatelessWidget {
  final double progreso; // 0..1
  final double size;
  final double stroke;

  const ProgressRing({
    super.key,
    required this.progreso,
    this.size = AppDimens.progressRing,
    this.stroke = AppDimens.progressRingStroke,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final completo = progreso >= 1.0;
    final color = completo ? c.lime : c.cyan;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progreso.clamp(0, 1)),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (context, valor, _) => CustomPaint(
          painter: _AnilloPainter(valor, color, stroke, c.surface2),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${(valor * 100).round()}%',
                    style: TextStyle(
                        color: color, fontSize: 22, fontWeight: FontWeight.w800)),
                Text('HOY',
                    style: TextStyle(
                        color: c.textFaint, fontSize: 9, letterSpacing: 2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnilloPainter extends CustomPainter {
  final double progreso;
  final Color color;
  final double stroke;
  final Color fondoColor;
  _AnilloPainter(this.progreso, this.color, this.stroke, this.fondoColor);

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final radio = (size.width - stroke) / 2;

    final fondo = Paint()
      ..color = fondoColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(centro, radio, fondo);

    final arco = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(
      Rect.fromCircle(center: centro, radius: radio),
      -math.pi / 2,
      2 * math.pi * progreso,
      false,
      arco,
    );
  }

  @override
  bool shouldRepaint(_AnilloPainter old) =>
      old.progreso != progreso || old.color != color || old.fondoColor != fondoColor;
}

/// Barra de progreso fina con degradado (XP, subtareas...).
class GradientBar extends StatelessWidget {
  final double progreso;
  final Gradient gradiente;
  final double alto;

  const GradientBar({
    super.key,
    required this.progreso,
    required this.gradiente,
    this.alto = 8,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: alto,
        color: c.surface2,
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progreso.clamp(0, 1),
          child: Container(decoration: BoxDecoration(gradient: gradiente)),
        ),
      ),
    );
  }
}
