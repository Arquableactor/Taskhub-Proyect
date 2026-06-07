import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';

/// Orquesta la "dopamina" al completar tareas: confeti, sonido y haptics.
/// Los ConfettiController viven aquí; el ConfettiWidget (en AppShell) los usa.
class CelebracionService extends ChangeNotifier {
  final ConfettiController pequeno =
      ConfettiController(duration: const Duration(milliseconds: 400));
  final ConfettiController grande =
      ConfettiController(duration: const Duration(seconds: 2));

  final AudioPlayer _player = AudioPlayer();
  bool sonidoActivo = true;

  /// Celebra una tarea completada. Si [diaCompleto], lanza la celebración grande.
  /// El haptic se da siempre; el confeti y el sonido respetan [sonidoActivo].
  void celebrar({required bool diaCompleto}) {
    HapticFeedback.lightImpact();
    if (!sonidoActivo) return;
    if (diaCompleto) {
      grande.play();
      HapticFeedback.heavyImpact();
      _sonar('sounds/celebrate.wav');
    } else {
      pequeno.play();
      _sonar('sounds/complete.wav');
    }
  }

  void alternarSonido() {
    sonidoActivo = !sonidoActivo;
    notifyListeners();
  }

  Future<void> _sonar(String asset) async {
    if (!sonidoActivo) return;
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {/* el audio en web requiere un gesto previo; se ignora si falla */}
  }

  @override
  void dispose() {
    pequeno.dispose();
    grande.dispose();
    _player.dispose();
    super.dispose();
  }
}
