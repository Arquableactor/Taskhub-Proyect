import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../models/me.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../services/me_service.dart';
import '../util/completar.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/block.dart';
import '../widgets/hero_strip.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _toggle(BuildContext context, Task t) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await completarTarea(context, t);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar la tarea')),
      );
    }
  }

  void _abrirDetalle(BuildContext context, Task t) {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => TaskDetailScreen(tareaId: t.id),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final tasks = context.watch<TaskService>();
    final auth = context.watch<AuthService>();
    final nombre = auth.usuario?.nombre.split(' ').first ?? '';

    final pendientes = tasks.pendientes;
    final completadas = tasks.completadas;
    final total = tasks.tareas.length;
    final progreso = total == 0 ? 0.0 : completadas.length / total;

    return Scaffold(
      body: RefreshIndicator(
        color: c.cyan,
        backgroundColor: c.surface,
        onRefresh: () async {
          final me = context.read<MeService>();
          await tasks.cargarTodo();
          await me.cargarTodo();
        },
        child: tasks.cargando && total == 0
            ? Center(child: CircularProgressIndicator(color: c.cyan))
            : ListView(
                padding: AppDimens.pagePadding,
                children: [
                  _Header(nombre: nombre),
                  const SizedBox(height: 20),
                  _HeroDia(
                    progreso: progreso,
                    hechas: completadas.length,
                    total: total,
                  ),
                  const SizedBox(height: 14),
                  const _MiniStats(),
                  const SizedBox(height: 8),
                  SectionHeader(
                    titulo: 'Por hacer',
                    contador: pendientes.length,
                    accion: Text('Ver todo',
                        style: AppText.eyebrow(c.cyan).copyWith(letterSpacing: 0)),
                  ),
                  if (pendientes.isEmpty)
                    const _Vacio()
                  else
                    ...pendientes.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskTile(
                            tarea: t,
                            proyecto: tasks.proyectoPorId(t.proyectoId),
                            onToggle: () => _toggle(context, t),
                            onTap: () => _abrirDetalle(context, t),
                          ),
                        )),
                  if (completadas.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SectionHeader(titulo: 'Completadas', contador: completadas.length),
                    ...completadas.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: TaskTile(
                            tarea: t,
                            proyecto: tasks.proyectoPorId(t.proyectoId),
                            onToggle: () => _toggle(context, t),
                            onTap: () => _abrirDetalle(context, t),
                          ),
                        )),
                  ],
                ],
              ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String nombre;
  const _Header({required this.nombre});

  String get _saludo {
    final h = DateTime.now().hour;
    if (h < 12) return 'Buenos días';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(_saludo),
              const SizedBox(height: 6),
              Text('Hola, $nombre',
                  style: Theme.of(context).textTheme.displaySmall),
            ],
          ),
        ),
        const _BadgeRacha(),
        const SizedBox(width: 10),
        _AvatarPerfil(nombre: nombre),
      ],
    );
  }
}

class _AvatarPerfil extends StatelessWidget {
  final String nombre;
  const _AvatarPerfil({required this.nombre});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SettingsScreen()),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: c.progressGradient,
          borderRadius: BorderRadius.circular(13),
        ),
        alignment: Alignment.center,
        child: Text(inicial,
            style: TextStyle(
                color: c.onAccent, fontSize: 17, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _BadgeRacha extends StatelessWidget {
  const _BadgeRacha();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final racha = context.watch<MeService>().progreso?.rachaActual ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.pink.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 5),
          Text('$racha', style: AppText.number(c.pink, size: 15)),
          const SizedBox(width: 4),
          Text('días', style: AppText.eyebrow(c.pink).copyWith(letterSpacing: 0)),
        ],
      ),
    );
  }
}

class _HeroDia extends StatelessWidget {
  final double progreso;
  final int hechas;
  final int total;
  const _HeroDia({required this.progreso, required this.hechas, required this.total});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final Progreso? prog = context.watch<MeService>().progreso;
    final nivel = prog?.nivel ?? 1;
    final xp = prog?.xp ?? 0;
    final xpSig = prog?.xpSiguiente ?? 100;
    final faltan = total - hechas;
    return HeroCard(
      child: Row(
        children: [
          ProgressRing(progreso: progreso),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$hechas de $total tareas',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  total == 0
                      ? 'Crea tu primera tarea'
                      : (faltan == 0 ? '¡Día completado! 🎉' : 'Te faltan $faltan para cerrar el día'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(Icons.bolt, color: c.violet, size: 16),
                    const SizedBox(width: 4),
                    Text('Nivel $nivel',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const Spacer(),
                    Text('$xp/$xpSig XP',
                        style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0)),
                  ],
                ),
                const SizedBox(height: 8),
                GradientBar(
                  progreso: xpSig == 0 ? 0 : xp / xpSig,
                  gradiente: c.xpGradient,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStats extends StatelessWidget {
  const _MiniStats();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final prog = context.watch<MeService>().progreso;
    final racha = prog?.rachaActual ?? 0;
    final nivel = prog?.nivel ?? 1;
    final xpRestante = prog?.xpRestante ?? 100;
    final meta = prog?.metaDiaria ?? 5;
    final hoy = prog?.completadasHoy ?? 0;
    return Row(
      children: [
        _tile(c, '🔥', '$racha', 'Racha', c.pink),
        const SizedBox(width: 10),
        _tile(c, '⚡', 'Nv $nivel', '$xpRestante al subir', c.violet),
        const SizedBox(width: 10),
        _tile(c, '🎯', '$hoy/$meta', 'Meta diaria', c.cyan),
      ],
    );
  }

  Widget _tile(Palette c, String emoji, String valor, String label, Color color) {
    return Expanded(
      child: BlockCard(
        radius: AppDimens.radiusSm,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(valor, style: AppText.number(color, size: 18)),
            const SizedBox(height: 2),
            Text(label,
                style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _Vacio extends StatelessWidget {
  const _Vacio();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radius),
        border: Border.all(color: c.borderStrong, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          const Text('✅', style: TextStyle(fontSize: 30)),
          const SizedBox(height: 10),
          Text('¡Sin pendientes!', style: TextStyle(color: c.textDim)),
        ],
      ),
    );
  }
}
