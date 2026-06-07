import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/block.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;
  bool _tocado = false; // empezamos a mostrar errores tras el primer intento/edición

  bool get _emailOk => emailValido(_email.text);
  bool get _passOk => _password.text.isNotEmpty;
  bool get _valido => _emailOk && _passOk;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    setState(() => _cargando = true);
    try {
      await context.read<AuthService>().iniciarSesion(
            _email.text.trim(),
            _password.text,
          );
      // El AuthGate cambia de pantalla solo al detectar la sesión.
    } on ApiException catch (e) {
      if (mounted) {
        final c = AppColors.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje), backgroundColor: c.pink),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Logo(),
                  const SizedBox(height: 40),
                  const Eyebrow('BIENVENIDO DE VUELTA'),
                  const SizedBox(height: 8),
                  Text('Inicia sesión',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 28),
                  AuthField(
                    controller: _email,
                    label: 'Correo',
                    icono: Icons.mail_outline,
                    tipo: TextInputType.emailAddress,
                    onChanged: (_) => setState(() => _tocado = true),
                    errorText: _tocado && !_emailOk && _email.text.isNotEmpty
                        ? 'Correo no válido'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  AuthField(
                    controller: _password,
                    label: 'Contraseña',
                    icono: Icons.lock_outline,
                    oculto: true,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: (_cargando || !_valido) ? null : _entrar,
                    child: _cargando
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onNeon))
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _cargando
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                    child: Text('¿No tienes cuenta? Crea una',
                        style: TextStyle(color: c.cyan)),
                  ),
                  TextButton(
                    onPressed: _cargando
                        ? null
                        : () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                            ),
                    child: Text('¿Olvidaste tu contraseña?',
                        style: TextStyle(color: c.textDim)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52, height: 52,
          decoration: BoxDecoration(
            gradient: c.progressGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppDimens.neonGlow(c.cyan, opacity: 0.4),
          ),
          alignment: Alignment.center,
          child: const Text('T',
              style: TextStyle(color: AppColors.onNeon, fontSize: 26, fontWeight: FontWeight.w800)),
        ),
        const SizedBox(width: 12),
        Text('TaskHub', style: Theme.of(context).textTheme.displaySmall),
      ],
    );
  }
}

/// ¿El correo tiene forma válida? (validación ligera, no exhaustiva)
bool emailValido(String email) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email.trim());

/// Campo de texto reutilizable para las pantallas de auth, con error inline.
class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icono;
  final bool oculto;
  final TextInputType? tipo;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    required this.icono,
    this.oculto = false,
    this.tipo,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return TextField(
      controller: controller,
      obscureText: oculto,
      keyboardType: tipo,
      onChanged: onChanged,
      style: TextStyle(color: c.text),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icono, color: c.textFaint, size: 20),
      ),
    );
  }
}
