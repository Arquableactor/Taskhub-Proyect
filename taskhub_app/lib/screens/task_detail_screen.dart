import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prioridad.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../util/completar.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/block.dart';
import '../widgets/hero_strip.dart';

class TaskDetailScreen extends StatelessWidget {
  final int tareaId;
  const TaskDetailScreen({super.key, required this.tareaId});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tasks = context.watch<TaskService>();
    final tarea = tasks.tareas.where((t) => t.id == tareaId).firstOrNull;

    // Si la tarea fue eliminada, cerramos la pantalla.
    if (tarea == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final proyecto = tasks.proyectoPorId(tarea.proyectoId);
    final color = tarea.prioridad.colorDe(c);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: c.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: c.textDim),
                    onPressed: () async {
                      await context.read<TaskService>().eliminar(tarea);
                      if (context.mounted) Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  Row(
                    children: [
                      _Chip(texto: tarea.prioridad.etiqueta, color: color, icono: Icons.flag),
                      if (proyecto != null) ...[
                        const SizedBox(width: 8),
                        _Chip(texto: proyecto.nombre, color: proyecto.color, icono: Icons.folder),
                      ],
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CasillaGrande(
                        marcada: tarea.completada,
                        color: color,
                        onTap: () => completarTarea(context, tarea),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          tarea.titulo,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                decoration: tarea.completada ? TextDecoration.lineThrough : null,
                                color: tarea.completada ? c.textDim : c.text,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (tarea.fechaVencimiento != null)
                        _Pildora(icono: Icons.event, texto: _fecha(tarea.fechaVencimiento!)),
                      const SizedBox(width: 10),
                      _Pildora(icono: Icons.bolt, texto: '+${tarea.xp} XP', color: c.violet),
                    ],
                  ),
                  if (tarea.descripcion != null && tarea.descripcion!.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    BlockCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Eyebrow('NOTAS'),
                          const SizedBox(height: 8),
                          Text(tarea.descripcion!,
                              style: TextStyle(color: c.textDim, height: 1.5)),
                        ],
                      ),
                    ),
                  ],
                  if (tarea.subTareas.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _Subtareas(tarea: tarea),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => completarTarea(context, tarea),
                    style: FilledButton.styleFrom(
                      backgroundColor: tarea.completada ? c.surface2 : c.lime,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      tarea.completada ? 'Marcar como pendiente' : 'Completar tarea',
                      style: TextStyle(
                          color: tarea.completada ? c.text : AppColors.onNeon,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fecha(DateTime f) {
    final l = f.toLocal();
    return '${l.day}/${l.month} · ${l.hour.toString().padLeft(2, '0')}:${l.minute.toString().padLeft(2, '0')}';
  }
}

class _Subtareas extends StatelessWidget {
  final Task tarea;
  const _Subtareas({required this.tarea});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final total = tarea.subTareas.length;
    final hechas = tarea.subHechas;
    return BlockCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Eyebrow('SUBTAREAS'),
              const Spacer(),
              Text('$hechas / $total',
                  style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0)),
            ],
          ),
          const SizedBox(height: 12),
          GradientBar(
            progreso: total == 0 ? 0 : hechas / total,
            gradiente: c.progressGradient,
            alto: 6,
          ),
          const SizedBox(height: 14),
          ...tarea.subTareas.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Icon(
                      s.completada ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: s.completada ? c.lime : c.textFaint,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(s.titulo,
                        style: TextStyle(
                          color: s.completada ? c.textFaint : c.text,
                          decoration: s.completada ? TextDecoration.lineThrough : null,
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final Color color;
  final IconData icono;
  const _Chip({required this.texto, required this.color, required this.icono});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 13, color: color),
          const SizedBox(width: 6),
          Text(texto, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Pildora extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Color? color;
  const _Pildora({required this.icono, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final col = color ?? c.textDim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: col),
          const SizedBox(width: 7),
          Text(texto, style: TextStyle(color: col, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}

class _CasillaGrande extends StatelessWidget {
  final bool marcada;
  final Color color;
  final VoidCallback onTap;
  const _CasillaGrande({required this.marcada, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 34, height: 34,
        decoration: BoxDecoration(
          color: marcada ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: marcada ? color : c.borderStrong, width: 2),
          boxShadow: marcada ? AppDimens.neonGlow(color, opacity: 0.5) : null,
        ),
        child: marcada ? const Icon(Icons.check, size: 20, color: AppColors.onNeon) : null,
      ),
    );
  }
}
