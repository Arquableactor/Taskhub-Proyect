// Harness SOLO para capturas/visualización. No es parte de la app de producción.
// Elige pantalla y tema por el fragmento de la URL, p.ej.:
//   #home-dark, #settings-light, #onboarding-dark, #register-light, #progreso-dark
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';

import 'models/auth_user.dart';
import 'models/task.dart';
import 'models/subtarea.dart';
import 'models/proyecto.dart';
import 'models/prioridad.dart';
import 'models/me.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/task_service.dart';
import 'services/me_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progreso_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_screen.dart';

void main() {
  final frag = Uri.base.fragment; // p.ej. "home-dark"
  final dark = frag.contains('dark');

  final api = ApiClient();
  final demoUser = AuthUser(token: 'x', refreshToken: 'x', email: 'josia@taskhub.app', nombre: 'Josia');
  // ignore: invalid_use_of_visible_for_testing_member
  final auth = AuthService(api)..seedPreview(demoUser);
  // ignore: invalid_use_of_visible_for_testing_member
  final tasks = TaskService(api)..seedPreview(_tareasDemo, _proyectosDemo);
  // ignore: invalid_use_of_visible_for_testing_member
  final me = MeService(api)..seedPreview(
      progreso: _progresoDemo, actividad: _actividadDemo, logros: _logrosDemo, perfil: _perfilDemo);
  final theme = ThemeService();

  Widget pantalla() {
    if (frag.contains('celebrar')) return const _CelebrarDemo();
    if (frag.contains('settings')) return const SettingsScreen();
    if (frag.contains('progreso')) return const ProgresoScreen();
    if (frag.contains('register')) return const RegisterScreen();
    if (frag.contains('onboarding')) {
      return OnboardingScreen(onCrearCuenta: () {}, onEntrar: () {});
    }
    return const HomeScreen();
  }

  runApp(MultiProvider(
    providers: [
      Provider<ApiClient>.value(value: api),
      ChangeNotifierProvider.value(value: auth),
      ChangeNotifierProvider.value(value: tasks),
      ChangeNotifierProvider.value(value: me),
      ChangeNotifierProvider.value(value: theme),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: pantalla(),
    ),
  ));
}

/// Demo que dispara el confeti al cargar (solo para capturarlo).
class _CelebrarDemo extends StatefulWidget {
  const _CelebrarDemo();
  @override
  State<_CelebrarDemo> createState() => _CelebrarDemoState();
}

class _CelebrarDemoState extends State<_CelebrarDemo> {
  final _ctrl = ConfettiController(duration: const Duration(seconds: 3));
  @override
  void initState() {
    super.initState();
    _ctrl.play();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text('¡Día completado! 🎉',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _ctrl,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 26,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [
                Color(0xFF00F0FF), Color(0xFFB14BFF), Color(0xFFFF2D95),
                Color(0xFF2BFF88), Color(0xFFFF9F1C),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final _proyectosDemo = [
  Proyecto.fromJson({'id': 1, 'nombre': 'Trabajo', 'color': '#FF2D95'}),
  Proyecto.fromJson({'id': 2, 'nombre': 'Aprendizaje', 'color': '#B14BFF'}),
  Proyecto.fromJson({'id': 3, 'nombre': 'Salud', 'color': '#2BFF88'}),
];

final _tareasDemo = [
  Task(
    id: 1,
    titulo: 'Terminar el modelo de datos de la API',
    completada: false,
    prioridad: Prioridad.alta,
    fechaVencimiento: DateTime.now().copyWith(hour: 10, minute: 0),
    orden: 0,
    proyectoId: 1,
    subTareas: [
      SubTarea.fromJson({'id': 1, 'titulo': 'Diseñar tablas', 'completada': true}),
      SubTarea.fromJson({'id': 2, 'titulo': 'Escribir endpoints', 'completada': false}),
      SubTarea.fromJson({'id': 3, 'titulo': 'Probar con curl', 'completada': false}),
    ],
  ),
  Task(
    id: 2,
    titulo: 'Diseñar pantalla de estadísticas',
    completada: false,
    prioridad: Prioridad.media,
    fechaVencimiento: DateTime.now().copyWith(hour: 13, minute: 30),
    orden: 1,
    proyectoId: 2,
  ),
  Task(
    id: 3,
    titulo: 'Salir a correr 5 km',
    completada: false,
    prioridad: Prioridad.baja,
    fechaVencimiento: DateTime.now().copyWith(hour: 18, minute: 0),
    orden: 2,
    proyectoId: 3,
  ),
  Task(
    id: 4,
    titulo: 'Leer documentación de Flutter',
    completada: true,
    prioridad: Prioridad.ninguna,
    orden: 3,
    proyectoId: 2,
  ),
];

final _progresoDemo = Progreso(
  nivel: 7,
  xp: 540,
  xpSiguiente: 1000,
  rachaActual: 12,
  mejorRacha: 21,
  metaDiaria: 5,
  completadasHoy: 2,
  completadasTotal: 147,
);

final _perfilDemo = Perfil(nombre: 'Josia', email: 'josia@taskhub.app', telefono: '+1 (809) 555-1234');

final _logrosDemo = [
  LogroVM(clave: 'primer_paso', nombre: 'Primer paso', descripcion: '', emoji: '🎯', desbloqueado: true),
  LogroVM(clave: 'racha_7', nombre: 'Racha de 7', descripcion: '', emoji: '🔥', desbloqueado: true),
  LogroVM(clave: 'completadas_100', nombre: 'Centenario', descripcion: '', emoji: '💯', desbloqueado: true),
  LogroVM(clave: 'nivel_5', nombre: 'Subiendo', descripcion: '', emoji: '🌟', desbloqueado: true),
  LogroVM(clave: 'racha_30', nombre: 'Imparable', descripcion: '', emoji: '⚡', desbloqueado: false),
  LogroVM(clave: 'nivel_10', nombre: 'Veterano', descripcion: '', emoji: '🏆', desbloqueado: false),
];

final _actividadDemo = List.generate(84, (i) {
  final fecha = DateTime.now().subtract(Duration(days: 83 - i));
  // Patrón pseudo-variado para que el heatmap/barras se vean vivos.
  final v = [(i * 7) % 9, (i * 3) % 6, (i % 5), (i * 2) % 8][i % 4];
  return DiaActividad(fecha: fecha, completadas: i > 75 ? (i % 6) + 1 : v);
});
