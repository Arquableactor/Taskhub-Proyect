import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

class _Slide {
  final String emoji;
  final String titulo;
  final String cuerpo;
  final Color Function(Palette) color;
  const _Slide(this.emoji, this.titulo, this.cuerpo, this.color);
}

const _slides = [
  _Slide('📝', 'Captura todo',
      'Anota tus tareas, ponles prioridad y fecha. Tu cabeza, despejada.',
      _cyan),
  _Slide('🔥', 'Construye rachas',
      'Completa algo cada día y mira crecer tu racha. Cumplir engancha.',
      _pink),
  _Slide('⚡', 'Sube de nivel',
      'Gana XP con cada tarea, sube de nivel y desbloquea logros.',
      _violet),
];

Color _cyan(Palette p) => p.cyan;
Color _pink(Palette p) => p.pink;
Color _violet(Palette p) => p.violet;

/// Carrusel de bienvenida (primer arranque). Lleva a registro o login.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onCrearCuenta;
  final VoidCallback onEntrar;
  const OnboardingScreen({
    super.key,
    required this.onCrearCuenta,
    required this.onEntrar,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pager = PageController();
  int _pagina = 0;

  @override
  void dispose() {
    _pager.dispose();
    super.dispose();
  }

  void _siguiente() {
    if (_pagina < _slides.length - 1) {
      _pager.nextPage(
          duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      widget.onCrearCuenta();
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final ultima = _pagina == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // "Saltar"
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 4),
                child: TextButton(
                  onPressed: widget.onEntrar,
                  child: Text('Saltar', style: TextStyle(color: c.textDim)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pager,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _pagina = i),
                itemBuilder: (_, i) => _SlideVista(slide: _slides[i]),
              ),
            ),
            // Indicadores de página
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                final activo = i == _pagina;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: activo ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: activo ? c.cyan : c.surface2,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: [
                  FilledButton(
                    onPressed: _siguiente,
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    child: Text(ultima ? 'Crear cuenta' : 'Siguiente'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: widget.onEntrar,
                    child: Text('¿Ya tienes cuenta? Entrar',
                        style: TextStyle(color: c.cyan)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideVista extends StatelessWidget {
  final _Slide slide;
  const _SlideVista({required this.slide});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final color = slide.color(c);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(34),
              boxShadow: AppDimens.neonGlow(color, opacity: c.dark ? 0.35 : 0.25),
            ),
            alignment: Alignment.center,
            child: Text(slide.emoji, style: const TextStyle(fontSize: 56)),
          ),
          const SizedBox(height: 36),
          Text(slide.titulo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 14),
          Text(slide.cuerpo,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}
