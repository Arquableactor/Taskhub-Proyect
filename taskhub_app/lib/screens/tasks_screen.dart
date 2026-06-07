import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../util/completar.dart';
import '../widgets/block.dart';
import '../widgets/task_tile.dart';
import 'task_detail_screen.dart';

enum _Vista { hoy, proximas, atrasadas }

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  _Vista _vista = _Vista.hoy;

  bool _esHoy(DateTime f) {
    final hoy = DateTime.now();
    final l = f.toLocal();
    return l.year == hoy.year && l.month == hoy.month && l.day == hoy.day;
  }

  List<Task> _filtrar(List<Task> tareas) {
    final inicioHoy = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    switch (_vista) {
      case _Vista.hoy:
        return tareas.where((t) =>
            !t.completada && t.fechaVencimiento != null && _esHoy(t.fechaVencimiento!)).toList();
      case _Vista.proximas:
        return tareas.where((t) =>
            !t.completada &&
            t.fechaVencimiento != null &&
            t.fechaVencimiento!.toLocal().isAfter(inicioHoy.add(const Duration(days: 1)))).toList();
      case _Vista.atrasadas:
        return tareas.where((t) =>
            !t.completada &&
            t.fechaVencimiento != null &&
            t.fechaVencimiento!.toLocal().isBefore(inicioHoy)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskService>();
    final lista = _filtrar(tasks.tareas);

    return Scaffold(
      body: ListView(
        padding: AppDimens.pagePadding,
        children: [
          const Eyebrow('ORGANIZA TU TIEMPO'),
          const SizedBox(height: 6),
          Text('Tareas', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          _Segmentado(
            actual: _vista,
            conteos: {
              _Vista.hoy: _filtrar(tasks.tareas).length,
            },
            onSelect: (v) => setState(() => _vista = v),
            tareas: tasks.tareas,
            filtrador: _filtrarPara,
          ),
          const SizedBox(height: 18),
          if (_vista == _Vista.atrasadas && lista.isNotEmpty) ...[
            _BannerAtrasadas(cantidad: lista.length),
            const SizedBox(height: 14),
          ],
          if (lista.isEmpty)
            _VacioPestania(vista: _vista)
          else
            ...lista.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TaskTile(
                    tarea: t,
                    proyecto: tasks.proyectoPorId(t.proyectoId),
                    onToggle: () => completarTarea(context, t),
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => TaskDetailScreen(tareaId: t.id),
                    )),
                  ),
                )),
        ],
      ),
    );
  }

  // Para que el segmentado calcule conteos de cada pestaña.
  List<Task> _filtrarPara(_Vista v, List<Task> tareas) {
    final guardado = _vista;
    _vista = v;
    final r = _filtrar(tareas);
    _vista = guardado;
    return r;
  }
}

class _Segmentado extends StatelessWidget {
  final _Vista actual;
  final Map<_Vista, int> conteos;
  final ValueChanged<_Vista> onSelect;
  final List<Task> tareas;
  final List<Task> Function(_Vista, List<Task>) filtrador;

  const _Segmentado({
    required this.actual,
    required this.conteos,
    required this.onSelect,
    required this.tareas,
    required this.filtrador,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          _seg(c, _Vista.hoy, 'Hoy'),
          _seg(c, _Vista.proximas, 'Próximas'),
          _seg(c, _Vista.atrasadas, 'Atrasadas'),
        ],
      ),
    );
  }

  Widget _seg(Palette c, _Vista v, String label) {
    final activo = actual == v;
    final n = filtrador(v, tareas).length;
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: activo ? c.cyan : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            n > 0 ? '$label  $n' : label,
            style: TextStyle(
              color: activo ? AppColors.onNeon : c.textDim,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerAtrasadas extends StatelessWidget {
  final int cantidad;
  const _BannerAtrasadas({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.pink.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: c.pink.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: c.pink, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Tienes $cantidad tarea(s) atrasada(s)',
                style: TextStyle(color: c.pink, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _VacioPestania extends StatelessWidget {
  final _Vista vista;
  const _VacioPestania({required this.vista});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final txt = switch (vista) {
      _Vista.hoy => 'Nada para hoy. ¡Disfruta!',
      _Vista.proximas => 'No tienes tareas próximas',
      _Vista.atrasadas => 'Sin atrasos. ¡Al día! ✨',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Text(txt, style: TextStyle(color: c.textDim)),
      ),
    );
  }
}
