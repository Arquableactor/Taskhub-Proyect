import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/prioridad.dart';
import '../models/proyecto.dart';
import '../services/api_client.dart';
import '../services/task_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/block.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titulo = TextEditingController();
  final _notas = TextEditingController();

  Prioridad _prioridad = Prioridad.ninguna;
  DateTime? _cuando;
  int? _proyectoId;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _titulo.addListener(() => setState(() {})); // habilita "Crear" al escribir
  }

  @override
  void dispose() {
    _titulo.dispose();
    _notas.dispose();
    super.dispose();
  }

  bool get _valido => _titulo.text.trim().isNotEmpty;

  Future<void> _crear() async {
    setState(() => _guardando = true);
    try {
      await context.read<TaskService>().crearTarea(
            titulo: _titulo.text.trim(),
            descripcion: _notas.text.trim(),
            prioridad: _prioridad,
            fechaVencimiento: _cuando,
            proyectoId: _proyectoId,
          );
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) {
        final c = AppColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje), backgroundColor: c.pink),
        );
        setState(() => _guardando = false);
      }
    }
  }

  void _elegirCuando(int diasDesdeHoy) {
    final base = DateTime.now().add(Duration(days: diasDesdeHoy));
    setState(() => _cuando = DateTime(base.year, base.month, base.day, 9, 0));
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final proyectos = context.watch<TaskService>().proyectos;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _BarraSuperior(
              puedeCrear: _valido && !_guardando,
              guardando: _guardando,
              onCancelar: () => Navigator.of(context).pop(),
              onCrear: _crear,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  TextField(
                    controller: _titulo,
                    autofocus: true,
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: const InputDecoration(
                      hintText: '¿Qué hay que hacer?',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  TextField(
                    controller: _notas,
                    maxLines: 3,
                    style: TextStyle(color: c.textDim),
                    decoration: const InputDecoration(
                      hintText: 'Notas (opcional)',
                      border: InputBorder.none,
                      filled: false,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Seccion(
                    titulo: 'Cuándo',
                    child: Wrap(
                      spacing: 8,
                      children: [
                        _chip(c, 'Hoy', _esDia(0), () => _elegirCuando(0)),
                        _chip(c, 'Mañana', _esDia(1), () => _elegirCuando(1)),
                        _chip(c, 'Esta semana', _esDia(3), () => _elegirCuando(3)),
                        if (_cuando != null)
                          _chip(c, 'Quitar', false, () => setState(() => _cuando = null),
                              color: c.pink),
                      ],
                    ),
                  ),
                  _Seccion(
                    titulo: 'Prioridad',
                    child: Row(
                      children: Prioridad.values.reversed.map((p) {
                        final sel = _prioridad == p;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => setState(() => _prioridad = p),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: sel ? p.colorDe(c).withValues(alpha: 0.18) : c.surface,
                                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                                  border: Border.all(
                                    color: sel ? p.colorDe(c) : c.border,
                                    width: sel ? 1.5 : 1,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(p.etiqueta,
                                    style: TextStyle(
                                        color: p.colorDe(c), fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (proyectos.isNotEmpty)
                    _Seccion(
                      titulo: 'Proyecto',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: proyectos.map((p) => _chipProyecto(c, p)).toList(),
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

  bool _esDia(int dias) {
    if (_cuando == null) return false;
    final obj = DateTime.now().add(Duration(days: dias));
    return _cuando!.year == obj.year && _cuando!.month == obj.month && _cuando!.day == obj.day;
  }

  Widget _chip(Palette c, String label, bool sel, VoidCallback onTap, {Color? color}) {
    final col = color ?? c.cyan;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? col.withValues(alpha: 0.18) : c.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: sel ? col : Colors.transparent),
        ),
        child: Text(label,
            style: TextStyle(
                color: sel ? col : c.textDim,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }

  Widget _chipProyecto(Palette c, Proyecto p) {
    final sel = _proyectoId == p.id;
    return GestureDetector(
      onTap: () => setState(() => _proyectoId = sel ? null : p.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? p.color.withValues(alpha: 0.18) : c.surface2,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: sel ? p.color : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Text(p.nombre,
                style: TextStyle(
                    color: sel ? c.text : c.textDim,
                    fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _BarraSuperior extends StatelessWidget {
  final bool puedeCrear;
  final bool guardando;
  final VoidCallback onCancelar;
  final VoidCallback onCrear;

  const _BarraSuperior({
    required this.puedeCrear,
    required this.guardando,
    required this.onCancelar,
    required this.onCrear,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      child: Row(
        children: [
          TextButton(onPressed: onCancelar, child: Text('Cancelar', style: TextStyle(color: c.textDim))),
          const Spacer(),
          Text('Nueva tarea', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          FilledButton(
            onPressed: puedeCrear ? onCrear : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            ),
            child: guardando
                ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onNeon))
                : const Text('Crear'),
          ),
        ],
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(titulo),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
