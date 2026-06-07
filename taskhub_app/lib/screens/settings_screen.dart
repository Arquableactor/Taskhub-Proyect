import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/me_service.dart';
import '../services/theme_service.dart';
import '../services/celebracion_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../widgets/block.dart';
import 'edit_profile_screen.dart';

const _kVersion = 'v0.1.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final auth = context.watch<AuthService>();
    final me = context.watch<MeService>();
    final tema = context.watch<ThemeService>();

    final nombre = me.perfil?.nombre ?? auth.usuario?.nombre ?? '';
    final email = me.perfil?.email ?? auth.usuario?.email ?? '';
    final telefono = me.perfil?.telefono;
    final inicial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Perfil', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
        children: [
          // ── Tarjeta de cuenta (toca para editar) ──
          BlockCard(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: c.progressGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(inicial,
                      style: TextStyle(
                          color: c.onAccent, fontSize: 24, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nombre, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(color: c.textDim, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: c.textFaint),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _Seccion('CUENTA', [
            _Opcion(
              icono: Icons.person_outline,
              titulo: 'Editar perfil',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _Opcion(
              icono: Icons.phone_outlined,
              titulo: 'Teléfono',
              valor: telefono == null || telefono.isEmpty ? 'Agregar' : telefono,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ),
            ),
            _Opcion(
              icono: Icons.lock_outline,
              titulo: 'Cambiar contraseña',
              onTap: () => _cambiarPassword(context),
            ),
          ]),

          _Seccion('APARIENCIA', [
            _SelectorTema(actual: tema.modo, onCambiar: tema.cambiar),
          ]),

          _Seccion('FEEDBACK', [
            _FilaSwitch(
              icono: Icons.celebration_outlined,
              titulo: 'Sonido y confeti al completar',
              valor: context.watch<CelebracionService>().sonidoActivo,
              onChanged: (_) => context.read<CelebracionService>().alternarSonido(),
            ),
          ]),

          _Seccion('SOPORTE', [
            _Opcion(
              icono: Icons.help_outline,
              titulo: 'Ayuda',
              onTap: () => _proximamente(context),
            ),
            _Opcion(
              icono: Icons.description_outlined,
              titulo: 'Términos y privacidad',
              onTap: () => _proximamente(context),
            ),
            _Opcion(
              icono: Icons.info_outline,
              titulo: 'Acerca de',
              valor: _kVersion,
              onTap: () => _proximamente(context),
            ),
          ]),

          const SizedBox(height: 8),
          _Opcion(
            icono: Icons.logout,
            titulo: 'Cerrar sesión',
            color: c.pink,
            onTap: () {
              // Vaciamos la pila (Ajustes/Editar perfil) antes de cerrar sesión,
              // para que el AuthGate muestre el login y no quede esta pantalla encima.
              final nav = Navigator.of(context);
              final me = context.read<MeService>();
              final auth = context.read<AuthService>();
              nav.popUntil((r) => r.isFirst);
              me.limpiar();
              auth.cerrarSesion();
            },
          ),
        ],
      ),
    );
  }

  void _proximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Próximamente')),
    );
  }

  Future<void> _cambiarPassword(BuildContext context) async {
    final actual = TextEditingController();
    final nueva = TextEditingController();
    final c = AppColors.of(context);
    bool guardando = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cambiar contraseña',
                  style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: actual,
                obscureText: true,
                style: TextStyle(color: c.text),
                decoration: const InputDecoration(labelText: 'Contraseña actual'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nueva,
                obscureText: true,
                style: TextStyle(color: c.text),
                decoration: const InputDecoration(labelText: 'Nueva contraseña (mín. 6)'),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: guardando
                    ? null
                    : () async {
                        setSheet(() => guardando = true);
                        try {
                          await ctx.read<AuthService>().cambiarContrasena(
                                actual.text, nueva.text);
                          if (ctx.mounted) {
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: const Text('Contraseña actualizada ✅'),
                                backgroundColor: c.lime,
                              ),
                            );
                          }
                        } on ApiException catch (e) {
                          setSheet(() => guardando = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(e.mensaje), backgroundColor: c.pink),
                            );
                          }
                        }
                      },
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: guardando
                    ? SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: c.onAccent))
                    : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final List<Widget> hijos;
  const _Seccion(this.titulo, this.hijos);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Eyebrow(titulo),
          const SizedBox(height: 12),
          for (final h in hijos) ...[h, const SizedBox(height: 10)],
        ],
      ),
    );
  }
}

/// Selector de tema: Claro / Oscuro / Sistema.
class _SelectorTema extends StatelessWidget {
  final ThemeMode actual;
  final ValueChanged<ThemeMode> onCambiar;
  const _SelectorTema({required this.actual, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final opciones = [
      (ThemeMode.light, Icons.light_mode, 'Claro'),
      (ThemeMode.dark, Icons.dark_mode, 'Oscuro'),
      (ThemeMode.system, Icons.brightness_auto, 'Sistema'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: AppDimens.block(dark: c.dark, radius: AppDimens.radiusSm),
      child: Row(
        children: opciones.map((o) {
          final sel = actual == o.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => onCambiar(o.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: sel ? c.cyan : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(o.$2, size: 20, color: sel ? c.onAccent : c.textDim),
                    const SizedBox(height: 4),
                    Text(o.$3,
                        style: TextStyle(
                            color: sel ? c.onAccent : c.textDim,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FilaSwitch extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final bool valor;
  final ValueChanged<bool> onChanged;
  const _FilaSwitch({
    required this.icono,
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return BlockCard(
      radius: AppDimens.radiusSm,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icono, size: 20, color: c.text),
          const SizedBox(width: 14),
          Expanded(
            child: Text(titulo, style: TextStyle(color: c.text, fontWeight: FontWeight.w600)),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeTrackColor: c.cyan,
            activeColor: c.onAccent,
          ),
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String? valor;
  final VoidCallback onTap;
  final Color? color;
  const _Opcion({
    required this.icono,
    required this.titulo,
    required this.onTap,
    this.valor,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final col = color ?? c.text;
    return BlockCard(
      radius: AppDimens.radiusSm,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icono, size: 20, color: col),
            const SizedBox(width: 14),
            Text(titulo, style: TextStyle(color: col, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (valor != null)
              Text(valor!, style: TextStyle(color: c.textFaint, fontSize: 13)),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 20, color: c.textFaint),
          ],
        ),
      ),
    );
  }
}
