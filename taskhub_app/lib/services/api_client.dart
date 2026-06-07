import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Error de API con un mensaje legible para mostrar al usuario.
class ApiException implements Exception {
  final int statusCode;
  final String mensaje;
  ApiException(this.statusCode, this.mensaje);
  @override
  String toString() => mensaje;
}

/// Cliente HTTP central. Sabe la URL base, adjunta el token y parsea JSON.
class ApiClient {
  /// La URL base cambia según dónde corre la app:
  /// - Android emulador: 10.0.2.2 es el "localhost" de la máquina host.
  /// - Web / desktop / iOS simulador: localhost directo.
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:5176';
    }
    return 'http://localhost:5176';
  }

  String? _token;

  void setToken(String? token) => _token = token;

  /// Lo provee AuthService: intenta refrescar el access token. Devuelve true si
  /// lo logró (para reintentar la petición que dio 401).
  Future<bool> Function()? onRefrescar;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path) =>
      _enviar(() => http.get(_uri(path), headers: _headers));

  Future<dynamic> post(String path, Object body) =>
      _enviar(() => http.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> patch(String path, Object body) =>
      _enviar(() => http.patch(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<dynamic> delete(String path) =>
      _enviar(() => http.delete(_uri(path), headers: _headers));

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Ejecuta la petición, valida el código y devuelve el JSON ya parseado.
  /// Si recibe 401, intenta refrescar el token una vez y reintenta.
  Future<dynamic> _enviar(Future<http.Response> Function() peticion,
      {bool reintentar = true}) async {
    late http.Response res;
    try {
      res = await peticion();
    } catch (_) {
      throw ApiException(0, 'No se pudo conectar con el servidor. ¿Está encendido?');
    }

    // Access token vencido: refrescamos y reintentamos una sola vez.
    if (res.statusCode == 401 && reintentar && onRefrescar != null) {
      final ok = await onRefrescar!();
      if (ok) return _enviar(peticion, reintentar: false); // el thunk relee el token nuevo
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    throw ApiException(res.statusCode, _mensajeDeError(res));
  }

  String _mensajeDeError(http.Response res) {
    try {
      final json = jsonDecode(res.body);
      if (json is Map && json['mensaje'] != null) return json['mensaje'] as String;
      if (json is Map && json['errors'] != null) {
        // Errores de validación del backend: tomamos el primero.
        final errores = (json['errors'] as Map).values.first;
        if (errores is List && errores.isNotEmpty) return errores.first.toString();
      }
    } catch (_) {}
    if (res.statusCode == 401) return 'Sesión no válida. Inicia sesión de nuevo.';
    return 'Ocurrió un error (${res.statusCode}).';
  }
}
