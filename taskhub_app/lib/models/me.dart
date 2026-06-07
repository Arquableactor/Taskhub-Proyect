// Modelos de los endpoints /me/* (gamificación y perfil).

class Progreso {
  final int nivel;
  final int xp;
  final int xpSiguiente;
  final int rachaActual;
  final int mejorRacha;
  final int metaDiaria;
  final int completadasHoy;
  final int completadasTotal;

  Progreso({
    required this.nivel,
    required this.xp,
    required this.xpSiguiente,
    required this.rachaActual,
    required this.mejorRacha,
    required this.metaDiaria,
    required this.completadasHoy,
    required this.completadasTotal,
  });

  factory Progreso.fromJson(Map<String, dynamic> j) => Progreso(
        nivel: j['nivel'] ?? 1,
        xp: j['xp'] ?? 0,
        xpSiguiente: j['xpSiguiente'] ?? 100,
        rachaActual: j['rachaActual'] ?? 0,
        mejorRacha: j['mejorRacha'] ?? 0,
        metaDiaria: j['metaDiaria'] ?? 5,
        completadasHoy: j['completadasHoy'] ?? 0,
        completadasTotal: j['completadasTotal'] ?? 0,
      );

  double get progresoXp => xpSiguiente == 0 ? 0 : xp / xpSiguiente;
  int get xpRestante => xpSiguiente - xp;
}

class DiaActividad {
  final DateTime fecha;
  final int completadas;
  DiaActividad({required this.fecha, required this.completadas});

  factory DiaActividad.fromJson(Map<String, dynamic> j) => DiaActividad(
        fecha: DateTime.parse(j['fecha'] as String),
        completadas: j['completadas'] ?? 0,
      );
}

class LogroVM {
  final String clave;
  final String nombre;
  final String descripcion;
  final String emoji;
  final bool desbloqueado;

  LogroVM({
    required this.clave,
    required this.nombre,
    required this.descripcion,
    required this.emoji,
    required this.desbloqueado,
  });

  factory LogroVM.fromJson(Map<String, dynamic> j) => LogroVM(
        clave: j['clave'] as String,
        nombre: j['nombre'] as String,
        descripcion: j['descripcion'] as String? ?? '',
        emoji: j['emoji'] as String? ?? '🏆',
        desbloqueado: j['desbloqueado'] as bool? ?? false,
      );
}

class Perfil {
  final String nombre;
  final String email;
  final String? telefono;
  Perfil({required this.nombre, required this.email, this.telefono});

  factory Perfil.fromJson(Map<String, dynamic> j) => Perfil(
        nombre: j['nombre'] as String? ?? '',
        email: j['email'] as String? ?? '',
        telefono: j['telefono'] as String?,
      );
}
