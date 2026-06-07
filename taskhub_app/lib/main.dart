import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'services/theme_service.dart';
import 'services/me_service.dart';
import 'services/celebracion_service.dart';
import 'screens/entry_flow.dart';
import 'screens/splash_screen.dart';
import 'screens/app_shell.dart';

void main() {
  final api = ApiClient();
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: api),
        ChangeNotifierProvider(create: (_) => AuthService(api)..cargarSesion()),
        ChangeNotifierProvider(create: (_) => TaskService(api)),
        ChangeNotifierProvider(create: (_) => MeService(api)),
        ChangeNotifierProvider(create: (_) => CelebracionService()),
        ChangeNotifierProvider(create: (_) => ThemeService()..cargar()),
      ],
      child: const TaskHubApp(),
    ),
  );
}

class TaskHubApp extends StatelessWidget {
  const TaskHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.watch<ThemeService>();
    return MaterialApp(
      title: 'TaskHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: tema.modo, // arranca en claro; el usuario lo cambia en Ajustes.
      home: const _AuthGate(),
    );
  }
}

/// Decide qué mostrar según la sesión: splash → login → app.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.cargando) {
      return const SplashView();
    }

    return auth.autenticado ? const AppShell() : const EntryFlow();
  }
}
