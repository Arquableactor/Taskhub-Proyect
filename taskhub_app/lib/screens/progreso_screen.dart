import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/me.dart';
import '../services/me_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text_styles.dart';
import '../widgets/block.dart';
import '../widgets/hero_strip.dart';

class ProgresoScreen extends StatelessWidget {
  const ProgresoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = context.watch<MeService>();
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.of(context).cyan,
        backgroundColor: AppColors.of(context).surface,
        onRefresh: () => me.cargarTodo(),
        child: ListView(
          padding: AppDimens.pagePadding,
          children: [
            const Eyebrow('TU PROGRESO'),
            const SizedBox(height: 6),
            Text('Estadísticas', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 20),
            _HeroNivel(prog: me.progreso),
            const SizedBox(height: 14),
            _TilesRacha(prog: me.progreso),
            const SizedBox(height: 22),
            _BarrasSemana(semana: me.semana, meta: me.progreso?.metaDiaria ?? 5),
            const SizedBox(height: 22),
            _Heatmap(dias: me.actividad),
            const SizedBox(height: 22),
            _Logros(logros: me.logros),
          ],
        ),
      ),
    );
  }
}

class _HeroNivel extends StatelessWidget {
  final Progreso? prog;
  const _HeroNivel({required this.prog});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final nivel = prog?.nivel ?? 1;
    final xp = prog?.xp ?? 0;
    final xpSig = prog?.xpSiguiente ?? 100;
    return HeroCard(
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: c.xpGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.bolt, color: c.onAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nivel $nivel',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('Productividad en marcha',
                    style: TextStyle(color: c.textDim, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GradientBar(
                          progreso: xpSig == 0 ? 0 : xp / xpSig, gradiente: c.xpGradient),
                    ),
                    const SizedBox(width: 10),
                    Text('$xp/$xpSig',
                        style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TilesRacha extends StatelessWidget {
  final Progreso? prog;
  const _TilesRacha({required this.prog});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      children: [
        _tile(c, '🔥', '${prog?.rachaActual ?? 0}', 'Racha actual', c.pink),
        const SizedBox(width: 10),
        _tile(c, '🏆', '${prog?.mejorRacha ?? 0}', 'Mejor racha', c.amber),
        const SizedBox(width: 10),
        _tile(c, '✓', '${prog?.completadasTotal ?? 0}', 'Completadas', c.lime),
      ],
    );
  }

  Widget _tile(Palette c, String emoji, String valor, String label, Color color) {
    return Expanded(
      child: BlockCard(
        radius: AppDimens.radiusSm,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(emoji, style: TextStyle(fontSize: 16, color: color)),
            const SizedBox(height: 8),
            Text(valor, style: AppText.number(color, size: 22)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _BarrasSemana extends StatelessWidget {
  final List<int> semana;
  final int meta;
  const _BarrasSemana({required this.semana, required this.meta});
  static const dias = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final maxV = semana.fold<int>(1, (m, v) => v > m ? v : m);
    return BlockCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('ÚLTIMA SEMANA'),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final v = i < semana.length ? semana[i] : 0;
                final cumpleMeta = v >= meta && v > 0;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('$v',
                          style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0)),
                      const SizedBox(height: 6),
                      Container(
                        height: (v / maxV) * 70 + 6,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          gradient: cumpleMeta
                              ? LinearGradient(
                                  begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                  colors: [c.lime, c.cyan])
                              : null,
                          color: cumpleMeta ? null : c.surface2,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: cumpleMeta ? AppDimens.neonGlow(c.lime, opacity: 0.4) : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(dias[i],
                          style: TextStyle(color: c.textFaint, fontSize: 11)),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Heatmap de constancia: últimas ~12 semanas en cuadrícula (7 filas x semanas).
class _Heatmap extends StatelessWidget {
  final List<DiaActividad> dias;
  const _Heatmap({required this.dias});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final maxV = dias.fold<int>(1, (m, d) => d.completadas > m ? d.completadas : m);

    // Agrupar en columnas de 7 (semanas).
    final columnas = <List<DiaActividad>>[];
    for (var i = 0; i < dias.length; i += 7) {
      columnas.add(dias.sublist(i, (i + 7).clamp(0, dias.length)));
    }

    Color celda(int v) {
      if (v == 0) return c.surface2;
      final t = (v / maxV).clamp(0.0, 1.0);
      return Color.lerp(c.cyan.withValues(alpha: 0.25), c.cyan, t)!;
    }

    return BlockCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Eyebrow('CONSTANCIA'),
              const Spacer(),
              Text('menos → más',
                  style: AppText.eyebrow(c.textFaint).copyWith(letterSpacing: 0, fontSize: 9)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: columnas.map((semana) {
              return Expanded(
                child: Column(
                  children: List.generate(7, (fila) {
                    final v = fila < semana.length ? semana[fila].completadas : 0;
                    return Container(
                      margin: const EdgeInsets.all(1.5),
                      height: 13,
                      decoration: BoxDecoration(
                        color: celda(v),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Logros extends StatelessWidget {
  final List<LogroVM> logros;
  const _Logros({required this.logros});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          titulo: 'Logros',
          contador: logros.where((l) => l.desbloqueado).length,
        ),
        if (logros.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text('Completa tareas para desbloquear logros',
                  style: TextStyle(color: c.textDim)),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
            children: logros.map((l) {
              return Opacity(
                opacity: l.desbloqueado ? 1 : 0.4,
                child: BlockCard(
                  radius: AppDimens.radiusSm,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Text(l.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.nombre,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: c.text, fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(l.desbloqueado ? 'Desbloqueado' : 'Bloqueado',
                                style: AppText.eyebrow(c.textFaint)
                                    .copyWith(letterSpacing: 0, fontSize: 9)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
