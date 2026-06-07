import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/auth_user.dart';
import 'api_client.dart';
import 'sesion_storage.dart';

/// Maneja la sesión: registro, login, refresco, logout y persistencia.
/// Los tokens se guardan cifrados en el dispositivo (Keychain/Keystore) en móvil
/// y en SharedPreferences en web (ver [SesionStorage]).
class AuthService extends ChangeNotifier {
  final ApiClient _api;
  final _storage = SesionStorage();

  AuthService(this._api) {
    _api.onRefrescar = refrescar; // el ApiClient nos pide refrescar ante un 401
  }

  AuthUser? _usuario;
  bool _cargando = true;

  AuthUser? get usuario => _usuario;
  bool get autenticado => _usuario != null;
  bool get cargando => _cargando;

  static const _kToken = 'token';
  static const _kRefresh = 'refresh';
  static const _kEmail = 'email';
  static const _kNombre = 'nombre';

  /// Al abrir la app: restaura la sesión guardada (si existe).
  /// Pase lo que pase, al final marcamos cargando=false: el splash nunca se cuelga.
  Future<void> cargarSesion() async {
    try {
      final token = await _storage.read(_kToken);
      final refresh = await _storage.read(_kRefresh);
      if (token != null && refresh != null) {
        _usuario = AuthUser(
          token: token,
          refreshToken: refresh,
          email: await _storage.read(_kEmail) ?? '',
          nombre: await _storage.read(_kNombre) ?? '',
        );
        _api.setToken(token);
      }
    } catch (_) {
      // Si el almacenamiento falla, seguimos sin sesión (a login).
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> registrar(String nombre, String email, String password) async {
    final json = await _api.post('/auth/register', {
      'nombre': nombre,
      'email': email,
      'password': password,
    });
    await _guardar(AuthUser.fromJson(json as Map<String, dynamic>));
  }

  Future<void> iniciarSesion(String email, String password) async {
    final json = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _guardar(AuthUser.fromJson(json as Map<String, dynamic>));
  }

  /// Canjea el refresh token por un par nuevo. Va por http directo (no por el
  /// ApiClient) para no entrar en un bucle de refresco. Si falla, cierra sesión.
  Future<bool> refrescar() async {
    final refresh = _usuario?.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;
    try {
      final res = await http.post(
        Uri.parse('${ApiClient.baseUrl}/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refresh}),
      );
      if (res.statusCode == 200) {
        await _guardar(AuthUser.fromJson(jsonDecode(res.body) as Map<String, dynamic>));
        return true;
      }
    } catch (_) {/* sin red: no cerramos sesión, dejamos reintentar luego */}
    // El refresh ya no vale: cerramos sesión local.
    await _limpiarLocal();
    return false;
  }

  Future<void> cambiarContrasena(String actual, String nueva) async {
    // El backend revoca todas las sesiones y devuelve un par nuevo para esta.
    final json = await _api.post('/auth/password', {'actual': actual, 'nueva': nueva});
    if (json is Map<String, dynamic> && json['token'] != null) {
      await _guardar(AuthUser.fromJson(json));
    }
  }

  /// Pide un código de restablecimiento (siempre responde ok, no revela si existe).
  Future<void> solicitarReset(String email) =>
      _api.post('/auth/forgot-password', {'email': email});

  /// Restablece la contraseña con el código recibido por correo.
  Future<void> restablecer(String token, String nueva) =>
      _api.post('/auth/reset-password', {'token': token, 'nueva': nueva});

  /// Sincroniza el nombre local tras editar el perfil (para saludo y avatar).
  Future<void> actualizarNombreLocal(String nombre) async {
    final u = _usuario;
    if (u == null) return;
    _usuario = AuthUser(
        token: u.token, refreshToken: u.refreshToken, email: u.email, nombre: nombre);
    notifyListeners();
    await _storage.write(_kNombre, nombre);
  }

  Future<void> cerrarSesion() async {
    // Avisamos al servidor para revocar el refresh token (best-effort).
    final refresh = _usuario?.refreshToken;
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${ApiClient.baseUrl}/auth/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refresh}),
        );
      } catch (_) {/* da igual si no llega: igual limpiamos local */}
    }
    await _limpiarLocal();
  }

  /// Solo para previews/capturas: inyecta un usuario sin tocar la red.
  @visibleForTesting
  void seedPreview(AuthUser user) {
    _usuario = user;
    _cargando = false;
    notifyListeners();
  }

  Future<void> _guardar(AuthUser user) async {
    _usuario = user;
    _api.setToken(user.token);
    await _storage.write(_kToken, user.token);
    await _storage.write(_kRefresh, user.refreshToken);
    await _storage.write(_kEmail, user.email);
    await _storage.write(_kNombre, user.nombre);
    notifyListeners();
  }

  Future<void> _limpiarLocal() async {
    await _storage.delete(_kToken);
    await _storage.delete(_kRefresh);
    await _storage.delete(_kEmail);
    await _storage.delete(_kNombre);
    _api.setToken(null);
    _usuario = null;
    notifyListeners();
  }
}
