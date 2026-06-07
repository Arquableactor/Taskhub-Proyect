import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';

/// Decide la entrada de un usuario SIN sesión:
/// primera vez → onboarding; después → login directo.
class EntryFlow extends StatefulWidget {
  const EntryFlow({super.key});

  @override
  State<EntryFlow> createState() => _EntryFlowState();
}

class _EntryFlowState extends State<EntryFlow> {
  static const _kOnboarding = 'onboarding_visto';
  bool? _visto; // null mientras carga la preferencia

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _visto = prefs.getBool(_kOnboarding) ?? false);
  }

  Future<void> _marcarVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kOnboarding, true);
    if (mounted) setState(() => _visto = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_visto == null) return const SplashView();
    if (_visto!) return const LoginScreen();

    return OnboardingScreen(
      onEntrar: () async {
        await _marcarVisto(); // build mostrará LoginScreen
      },
      onCrearCuenta: () async {
        final navigator = Navigator.of(context);
        await _marcarVisto();
        navigator.push(
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
    );
  }
}
