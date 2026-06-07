import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import '../widgets/block.dart';
import 'login_screen.dart' show AuthField, emailValido;

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _codigo = TextEditingController();
  final _nueva = TextEditingController();
  bool _enviado = false; // paso 1 -> paso 2
  bool _cargando = false;

  @override
  void dispose() {
    _email.dispose();
    _codigo.dispose();
    _nueva.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (!emailValido(_email.text)) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthService>().solicitarReset(_email.text.trim());
      if (mounted) setState(() => _enviado = true);
    } on ApiException catch (e) {
      _error(e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _restablecer() async {
    if (_codigo.text.trim().isEmpty || _nueva.text.length < 6) return;
    setState(() => _cargando = true);
    try {
      await context.read<AuthService>().restablecer(_codigo.text.trim(), _nueva.text);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contraseña restablecida ✅ Inicia sesión'),
            backgroundColor: AppColors.of(context).lime,
          ),
        );
      }
    } on ApiException catch (e) {
      _error(e.mensaje);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.of(context).pink),
    );
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
                  const Eyebrow('RECUPERAR ACCESO'),
                  const SizedBox(height: 8),
                  Text(_enviado ? 'Revisa tu correo' : '¿Olvidaste tu contraseña?',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 6),
                  Text(
                    _enviado
                        ? 'Te enviamos un código. Pégalo aquí y elige una nueva contraseña.'
                        : 'Te enviaremos un código para restablecerla.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  if (!_enviado) ...[
                    AuthField(
                      controller: _email,
                      label: 'Correo',
                      icono: Icons.mail_outline,
                      tipo: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: (_cargando || !emailValido(_email.text)) ? null : _enviarCodigo,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _cargando
                          ? SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: c.onAccent))
                          : const Text('Enviar código'),
                    ),
                  ] else ...[
                    AuthField(
                      controller: _codigo,
                      label: 'Código',
                      icono: Icons.vpn_key_outlined,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 14),
                    AuthField(
                      controller: _nueva,
                      label: 'Nueva contraseña (mín. 6)',
                      icono: Icons.lock_outline,
                      oculto: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: (_cargando ||
                              _codigo.text.trim().isEmpty ||
                              _nueva.text.length < 6)
                          ? null
                          : _restablecer,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                      child: _cargando
                          ? SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: c.onAccent))
                          : const Text('Restablecer contraseña'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
