import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../services/task_service.dart';
import '../services/me_service.dart';
import '../services/celebracion_service.dart';

/// Alterna el estado de completada de una tarea y, si la está COMPLETANDO,
/// dispara la celebración (confeti + sonido + haptic) y refresca la gamificación.
/// Lanza si la sincronización con el servidor falla (el llamador maneja el error).
Future<void> completarTarea(BuildContext context, Task t) async {
  final tasks = context.read<TaskService>();
  final me = context.read<MeService>();
  final celebra = context.read<CelebracionService>();
  final completando = !t.completada;

  await tasks.alternarCompletada(t);

  if (completando) {
    final diaCompleto = tasks.pendientes.isEmpty && tasks.tareas.isNotEmpty;
    celebra.celebrar(diaCompleto: diaCompleto);
    me
      ..cargarProgreso()
      ..cargarActividad();
  }
}
