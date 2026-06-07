import 'package:flutter/foundation.dart';
import '../models/me.dart';
import 'api_client.dart';

/// Estado de gamificación y perfil del usuario (endpoints /me/*).
class MeService extends ChangeNotifier {
  final ApiClient _api;
  MeService(this._api);

  Progreso? progreso;
  List<DiaActividad> actividad = [];
  List<LogroVM> logros = [];
  Perfil? perfil;

  /// Solo para previews/capturas: siembra datos sin tocar la red.
  @visibleForTesting
  void seedPreview({
    Progreso? progreso,
    List<DiaActividad>? actividad,
    List<LogroVM>? logros,
    Perfil? perfil,
  }) {
    if (progreso != null) this.progreso = progreso;
    if (actividad != null) this.actividad = actividad;
    if (logros != null) this.logros = logros;
    if (perfil != null) this.perfil = perfil;
    notifyListeners();
  }

  /// Carga todo lo de /me (al entrar a la app o tras refrescar).
  Future<void> cargarTodo() async {
    await Future.wait([cargarProgreso(), cargarActividad(), cargarLogros(), cargarPerfil()]);
  }

  Future<void> cargarProgreso() async {
    try {
      final j = await _api.get('/me/progreso');
      progreso = Progreso.fromJson(j as Map<String, dynamic>);
      notifyListeners();
    } on ApiException {/* silencioso: la UI usa valores por defecto */}
  }

  Future<void> cargarActividad() async {
    try {
      final j = await _api.get('/me/actividad?dias=84') as List<dynamic>;
      actividad = j.map((e) => DiaActividad.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on ApiException {/* silencioso */}
  }

  Future<void> cargarLogros() async {
    try {
      final j = await _api.get('/me/logros') as List<dynamic>;
      logros = j.map((e) => LogroVM.fromJson(e as Map<String, dynamic>)).toList();
      notifyListeners();
    } on ApiException {/* silencioso */}
  }

  Future<void> cargarPerfil() async {
    try {
      final j = await _api.get('/me/perfil');
      perfil = Perfil.fromJson(j as Map<String, dynamic>);
      notifyListeners();
    } on ApiException {/* silencioso */}
  }

  Future<void> actualizarPerfil({String? nombre, String? telefono}) async {
    await _api.patch('/me/perfil', {
      if (nombre != null) 'nombre': nombre,
      if (telefono != null) 'telefono': telefono,
    });
    await cargarPerfil();
  }

  /// Las completadas de la última semana (lun→dom) para las barras.
  List<int> get semana {
    if (actividad.isEmpty) return List.filled(7, 0);
    final ultimos7 = actividad.length >= 7
        ? actividad.sublist(actividad.length - 7)
        : actividad;
    return ultimos7.map((d) => d.completadas).toList();
  }

  void limpiar() {
    progreso = null;
    actividad = [];
    logros = [];
    perfil = null;
    notifyListeners();
  }
}
