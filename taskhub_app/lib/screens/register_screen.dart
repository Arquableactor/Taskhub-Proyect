import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/block.dart';
import '../widgets/password_strength.dart';
import 'login_screen.dart' show AuthField, emailValido;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _cargando = false;
  bool _aceptaTerminos = false;
  bool _tocado = false;

  bool get _nombreOk => _nombre.text.trim().length >= 2;
  bool get _emailOk => emailValido(_email.text);
  bool get _passOk => _password.text.length >= 6;
  bool get _valido => _nombreOk && _emailOk && _passOk && _aceptaTerminos;

  @override
  void dispose() {
    _nombre.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    setState(() => _cargando = true);
    try {
      await context.read<AuthService>().registrar(
            _nombre.text.trim(),
            _email.text.trim(),
            _password.text,
          );
      // Al registrarse queda con sesión: el AuthGate entra a la app solo.
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
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Eyebrow('EMPECEMOS POR LO BÁSICO'),
                  const SizedBox(height: 8),
                  Text('Crea tu cuenta',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 6),
                  Text('Tres datos y estás dentro.',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),
                  AuthField(
                    controller: _nombre,
                    label: 'Nombre',
                    icono: Icons.person_outline,
                    onChanged: (_) => setState(() => _tocado = true),
                    errorText: _tocado && !_nombreOk && _nombre.text.isNotEmpty
                        ? 'Mínimo 2 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 14),
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
                    label: 'Contraseña (mín. 6)',
                    icono: Icons.lock_outline,
                    oculto: true,
                    onChanged: (_) => setState(() => _tocado = true),
                  ),
                  if (_password.text.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    PasswordStrength(password: _password.text),
                  ],
                  const SizedBox(height: 18),
                  _Terminos(
                    valor: _aceptaTerminos,
                    onChanged: (v) => setState(() => _aceptaTerminos = v),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: (_cargando || !_valido) ? null : _registrar,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: _cargando
                        ? SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: c.onAccent))
                        : const Text('Crear mi cuenta'),
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

class _Terminos extends StatelessWidget {
  final bool valor;
  final ValueChanged<bool> onChanged;
  const _Terminos({required this.valor, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: () => onChanged(!valor),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: valor ? c.cyan : Colors.transparent,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: valor ? c.cyan : c.borderStrong, width: 2),
            ),
            child: valor ? Icon(Icons.check, size: 15, color: c.onAccent) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: c.textDim, fontSize: 13, height: 1.4),
                  children: [
                    const TextSpan(text: 'Acepto los '),
                    TextSpan(text: 'términos', style: TextStyle(color: c.cyan)),
                    const TextSpan(text: ' y la '),
                    TextSpan(text: 'política de privacidad', style: TextStyle(color: c.cyan)),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
