import 'package:flutter/material.dart';
import '../models/task.dart';
import '../models/prioridad.dart';
import '../models/proyecto.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';

/// Fila de una tarea, estilo "Solid": barra de prioridad a la izquierda,
/// casilla, título, y meta (hora · prioridad · proyecto · subtareas).
class TaskTile extends StatelessWidget {
  final Task tarea;
  final Proyecto? proyecto;
  final VoidCallback onToggle;
  final VoidCallback? onTap;

  const TaskTile({
    super.key,
    required this.tarea,
    required this.onToggle,
    this.proyecto,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final hecha = tarea.completada;
    final colorPrioridad = tarea.prioridad.colorDe(c);

    return Opacity(
      opacity: hecha ? 0.5 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        child: Container(
          decoration: AppDimens.block(dark: c.dark, radius: AppDimens.radiusSm),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Barra sólida de prioridad (5px) en el borde izquierdo.
                Container(width: AppDimens.priorityBarWidth, color: colorPrioridad),
                Expanded(
                  child: InkWell(
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
                      child: Row(
                        children: [
                          _Casilla(marcada: hecha, color: colorPrioridad, onTap: onToggle),
                          const SizedBox(width: 12),
                          Expanded(child: _contenido(context, c, hecha)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido(BuildContext context, Palette c, bool hecha) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          tarea.titulo,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                decoration: hecha ? TextDecoration.lineThrough : null,
                color: hecha ? c.textDim : c.text,
              ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (tarea.fechaVencimiento != null)
              _meta(c, Icons.schedule, _hora(tarea.fechaVencimiento!)),
            _metaTexto(tarea.prioridad.etiqueta, tarea.prioridad.colorDe(c)),
            if (proyecto != null) _puntoProyecto(c, proyecto!),
            if (tarea.subTareas.isNotEmpty)
              _meta(c, Icons.checklist, '${tarea.subHechas} / ${tarea.subTareas.length}'),
          ],
        ),
      ],
    );
  }

  Widget _meta(Palette c, IconData icono, String texto) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: c.textFaint),
          const SizedBox(width: 4),
          Text(texto, style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0)),
        ],
      );

  Widget _metaTexto(String texto, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag, size: 13, color: color),
          const SizedBox(width: 4),
          Text(texto,
              style: AppText.eyebrow(color).copyWith(letterSpacing: 0, fontSize: 12)),
        ],
      );

  Widget _puntoProyecto(Palette c, Proyecto p) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: p.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(p.nombre,
              style: AppText.eyebrow(c.textDim).copyWith(letterSpacing: 0, fontSize: 12)),
        ],
      );

  String _hora(DateTime fecha) {
    final l = fecha.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// La casilla redonda que se rellena con el color de la prioridad al marcar.
class _Casilla extends StatelessWidget {
  final bool marcada;
  final Color color;
  final VoidCallback onTap;

  const _Casilla({required this.marcada, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: AppDimens.checkbox,
        height: AppDimens.checkbox,
        decoration: BoxDecoration(
          color: marcada ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: marcada ? color : c.borderStrong,
            width: 2,
          ),
          boxShadow: marcada ? AppDimens.neonGlow(color, opacity: 0.5) : null,
        ),
        child: marcada
            ? const Icon(Icons.check, size: 17, color: AppColors.onNeon)
            : null,
      ),
    );
  }
}
