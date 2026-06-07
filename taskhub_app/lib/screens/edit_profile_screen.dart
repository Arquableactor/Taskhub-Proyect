import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/me_service.dart';
import '../theme/app_colors.dart';
import 'login_screen.dart' show AuthField;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nombre;
  late final TextEditingController _telefono;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final perfil = context.read<MeService>().perfil;
    final auth = context.read<AuthService>().usuario;
    _nombre = TextEditingController(text: perfil?.nombre ?? auth?.nombre ?? '');
    _telefono = TextEditingController(text: perfil?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombre.dispose();
    _telefono.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombre.text.trim().length < 2) return;
    setState(() => _guardando = true);
    try {
      await context.read<MeService>().actualizarPerfil(
            nombre: _nombre.text.trim(),
            telefono: _telefono.text.trim(),
          );
      await context.read<AuthService>().actualizarNombreLocal(_nombre.text.trim());
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Perfil actualizado ✅'),
            backgroundColor: AppColors.of(context).lime,
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _guardando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.mensaje), backgroundColor: AppColors.of(context).pink),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final email = context.read<MeService>().perfil?.email ??
        context.read<AuthService>().usuario?.email ??
        '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Editar perfil', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          AuthField(
            controller: _nombre,
            label: 'Nombre',
            icono: Icons.person_outline,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          AuthField(
            controller: _telefono,
            label: 'Teléfono (opcional)',
            icono: Icons.phone_outlined,
            tipo: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          // El correo no se edita por ahora.
          Opacity(
            opacity: 0.6,
            child: AuthField(
              controller: TextEditingController(text: email),
              label: 'Correo (no editable)',
              icono: Icons.mail_outline,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _guardando ? null : _guardar,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
            child: _guardando
                ? SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: c.onAccent))
                : const Text('Guardar cambios'),
          ),
        ],
      ),
    );
  }
}
