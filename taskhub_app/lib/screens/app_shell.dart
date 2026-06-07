import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import '../services/task_service.dart';
import '../services/me_service.dart';
import '../services/celebracion_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';
import 'proyectos_screen.dart';
import 'progreso_screen.dart';
import 'create_task_screen.dart';

/// Contenedor principal: 4 pestañas + barra flotante con FAB central.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    // Carga tareas y proyectos al entrar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskService>().cargarTodo();
      context.read<MeService>().cargarTodo();
    });
  }

  void _abrirCrear() {
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const CreateTaskScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pantallas = const [
      HomeScreen(),
      TasksScreen(),
      ProyectosScreen(),
      ProgresoScreen(),
    ];

    final celebra = context.read<CelebracionService>();
    final c = AppColors.of(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _tab, children: pantallas),
          // Confeti de celebración (se dispara desde el CelebracionService).
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: celebra.pequeno,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 12,
              maxBlastForce: 18,
              minBlastForce: 6,
              gravity: 0.25,
              colors: [c.cyan, c.violet, c.pink, c.lime, c.amber],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: celebra.grande,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 26,
              minBlastForce: 10,
              gravity: 0.3,
              emissionFrequency: 0.04,
              colors: [c.cyan, c.violet, c.pink, c.lime, c.amber],
            ),
          ),
        ],
      ),
      floatingActionButton: _Fab(onTap: _abrirCrear),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BarraInferior(
        actual: _tab,
        onSelect: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _Fab extends StatelessWidget {
  final VoidCallback onTap;
  const _Fab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppDimens.fab,
        height: AppDimens.fab,
        decoration: BoxDecoration(
          color: c.cyan,
          borderRadius: BorderRadius.circular(AppDimens.radiusFab),
          boxShadow: AppDimens.fabShadow,
        ),
        child: const Icon(Icons.add, color: AppColors.onNeon, size: 30),
      ),
    );
  }
}

class _BarraInferior extends StatelessWidget {
  final int actual;
  final ValueChanged<int> onSelect;
  const _BarraInferior({required this.actual, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Container(
        height: AppDimens.navHeight,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusNav),
          border: Border(top: BorderSide(color: c.border)),
          boxShadow: (c.dark ? AppDimens.blockShadowDark : AppDimens.blockShadowLight),
        ),
        child: Row(
          children: [
            _item(c, 0, Icons.today_outlined, Icons.today, 'Hoy'),
            _item(c, 1, Icons.check_circle_outline, Icons.check_circle, 'Tareas'),
            const Spacer(), // hueco del FAB central
            _item(c, 2, Icons.folder_outlined, Icons.folder, 'Proyectos'),
            _item(c, 3, Icons.bar_chart_outlined, Icons.bar_chart, 'Progreso'),
          ],
        ),
      ),
    );
  }

  Widget _item(Palette c, int i, IconData icono, IconData iconoActivo, String label) {
    final activo = actual == i;
    final color = activo ? c.cyan : c.textFaint;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(i),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(activo ? iconoActivo : icono, color: color, size: 22),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
