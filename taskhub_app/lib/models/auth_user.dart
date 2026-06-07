/// Datos de la sesión que devuelve /auth/login y /auth/register.
class AuthUser {
  final String token; // access token (corto)
  final String refreshToken; // refresh token (rotativo)
  final String email;
  final String nombre;

  AuthUser({
    required this.token,
    required this.refreshToken,
    required this.email,
    required this.nombre,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String? ?? '',
        email: json['email'] as String,
        nombre: json['nombre'] as String,
      );
}
