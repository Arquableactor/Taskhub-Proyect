import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maneja el tema (claro/oscuro/sistema) y lo recuerda entre sesiones.
/// Por defecto arranca en CLARO (preferencia del usuario).
class ThemeService extends ChangeNotifier {
  ThemeMode _modo = ThemeMode.light;
  ThemeMode get modo => _modo;

  bool get esOscuro => _modo == ThemeMode.dark;

  static const _kModo = 'theme_mode';

  /// Restaura la preferencia guardada al abrir la app.
  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final guardado = prefs.getString(_kModo);
    _modo = switch (guardado) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light, // por defecto: claro
    };
    notifyListeners();
  }

  Future<void> cambiar(ThemeMode modo) async {
    _modo = modo;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kModo, modo.name);
  }

  /// Alterna entre claro y oscuro (para un switch simple).
  Future<void> alternar() =>
      cambiar(esOscuro ? ThemeMode.light : ThemeMode.dark);
}
