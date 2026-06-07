import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/proyecto.dart';
import '../models/prioridad.dart';
import 'api_client.dart';

/// Estado y operaciones de tareas + proyectos.
class TaskService extends ChangeNotifier {
  final ApiClient _api;
  TaskService(this._api);

  List<Task> _tareas = [];
  List<Proyecto> _proyectos = [];
  bool _cargando = false;
  String? _error;

  List<Task> get tareas => _tareas;
  List<Proyecto> get proyectos => _proyectos;
  bool get cargando => _cargando;
  String? get error => _error;

  List<Task> get pendientes => _tareas.where((t) => !t.completada).toList();
  List<Task> get completadas => _tareas.where((t) => t.completada).toList();

  Proyecto? proyectoPorId(int? id) {
    if (id == null) return null;
    for (final p in _proyectos) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Solo para previews/capturas: siembra datos sin tocar la red.
  @visibleForTesting
  void seedPreview(List<Task> tareas, List<Proyecto> proyectos) {
    _tareas = tareas;
    _proyectos = proyectos;
    _cargando = false;
    notifyListeners();
  }

  /// Carga inicial: proyectos + todas las tareas.
  Future<void> cargarTodo() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final proyJson = await _api.get('/proyectos') as List<dynamic>;
      _proyectos = proyJson
          .map((e) => Proyecto.fromJson(e as Map<String, dynamic>))
          .toList();

      final tareasJson = await _api.get('/tasks') as List<dynamic>;
      _tareas =
          tareasJson.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Marca/desmarca completada con actualización optimista.
  Future<void> alternarCompletada(Task tarea) async {
    final i = _tareas.indexWhere((t) => t.id == tarea.id);
    if (i == -1) return;
    final nuevoValor = !tarea.completada;

    // 1) Cambio local inmediato (la UI responde al instante).
    _tareas[i] = _copiarCon(_tareas[i], completada: nuevoValor);
    notifyListeners();

    // 2) Sincroniza con el servidor; si falla, revierte.
    try {
      await _api.patch('/tasks/${tarea.id}', {'completada': nuevoValor});
    } on ApiException {
      _tareas[i] = _copiarCon(_tareas[i], completada: !nuevoValor);
      notifyListeners();
      rethrow;
    }
  }

  Future<Task> crearTarea({
    required String titulo,
    String? descripcion,
    Prioridad prioridad = Prioridad.ninguna,
    DateTime? fechaVencimiento,
    int? proyectoId,
  }) async {
    final json = await _api.post('/tasks', {
      'titulo': titulo,
      if (descripcion != null && descripcion.isNotEmpty) 'descripcion': descripcion,
      'prioridad': prioridad.json,
      if (fechaVencimiento != null)
        'fechaVencimiento': fechaVencimiento.toUtc().toIso8601String(),
      if (proyectoId != null) 'proyectoId': proyectoId,
    });
    final tarea = Task.fromJson(json as Map<String, dynamic>);
    _tareas.add(tarea);
    notifyListeners();
    return tarea;
  }

  Future<void> crearProyecto(String nombre, String colorHex) async {
    final json = await _api.post('/proyectos', {'nombre': nombre, 'color': colorHex});
    _proyectos.add(Proyecto.fromJson(json as Map<String, dynamic>));
    notifyListeners();
  }

  /// Cuántas tareas tiene un proyecto y cuántas están hechas.
  (int hechas, int total) conteoProyecto(int proyectoId) {
    final delProyecto = _tareas.where((t) => t.proyectoId == proyectoId);
    return (delProyecto.where((t) => t.completada).length, delProyecto.length);
  }

  Future<void> eliminar(Task tarea) async {
    _tareas.removeWhere((t) => t.id == tarea.id);
    notifyListeners();
    await _api.delete('/tasks/${tarea.id}');
  }

  // Como Task es inmutable, recreamos la instancia al cambiar un campo.
  Task _copiarCon(Task t, {bool? completada}) => Task(
        id: t.id,
        titulo: t.titulo,
        descripcion: t.descripcion,
        completada: completada ?? t.completada,
        prioridad: t.prioridad,
        fechaVencimiento: t.fechaVencimiento,
        orden: t.orden,
        proyectoId: t.proyectoId,
        subTareas: t.subTareas,
      );
}
