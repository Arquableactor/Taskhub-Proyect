import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/proyecto.dart';
import '../services/api_client.dart';
import '../services/task_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/block.dart';
import '../widgets/hero_strip.dart';

class ProyectosScreen extends StatelessWidget {
  const ProyectosScreen({super.key});

  static const _colores = [
    '#00F0FF', '#B14BFF', '#FF2D95', '#2BFF88', '#FF9F1C', '#4F46E5',
  ];

  Future<void> _nuevoProyecto(BuildContext context) async {
    final pal = AppColors.of(context);
    final ctrl = TextEditingController();
    String color = _colores.first;

    await showModalBottomSheet(
      context: context,
      backgroundColor: pal.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nuevo proyecto', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: TextStyle(color: pal.text),
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: 16),
              const Eyebrow('COLOR'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: _colores.map((c) {
                  final sel = c == color;
                  final col = Color(int.parse('FF${c.substring(1)}', radix: 16));
                  return GestureDetector(
                    onTap: () => setSheet(() => color = c),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: col,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: sel ? Colors.white : Colors.transparent, width: 2),
                        boxShadow: sel ? AppDimens.neonGlow(col, opacity: 0.5) : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () async {
                  if (ctrl.text.trim().isEmpty) return;
                  try {
                    await ctx.read<TaskService>().crearProyecto(ctrl.text.trim(), color);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } on ApiException catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(e.mensaje), backgroundColor: pal.pink));
                    }
                  }
                },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: const Text('Crear proyecto'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskService>();
    final proyectos = tasks.proyectos;

    return Scaffold(
      body: ListView(
        padding: AppDimens.pagePadding,
        children: [
          const Eyebrow('TUS ESPACIOS'),
          const SizedBox(height: 6),
          Text('Proyectos', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              ...proyectos.map((p) {
                final (hechas, total) = tasks.conteoProyecto(p.id);
                return _CardProyecto(proyecto: p, hechas: hechas, total: total);
              }),
              _CardNuevo(onTap: () => _nuevoProyecto(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardProyecto extends StatelessWidget {
  final Proyecto proyecto;
  final int hechas;
  final int total;
  const _CardProyecto({required this.proyecto, required this.hechas, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final progreso = total == 0 ? 0.0 : hechas / total;
    return BlockCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: proyecto.color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.folder, color: proyecto.color, size: 20),
          ),
          const Spacer(),
          Text(proyecto.nombre,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text('${total - hechas} pendientes',
              style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0, fontSize: 11)),
          const SizedBox(height: 10),
          GradientBar(
            progreso: progreso,
            gradiente: LinearGradient(colors: [proyecto.color, proyecto.color]),
            alto: 6,
          ),
        ],
      ),
    );
  }
}

class _CardNuevo extends StatelessWidget {
  final VoidCallback onTap;
  const _CardNuevo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radius),
          border: Border.all(color: c.borderStrong),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: c.cyan, size: 28),
            const SizedBox(height: 8),
            Text('Nuevo proyecto', style: TextStyle(color: c.textDim, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
