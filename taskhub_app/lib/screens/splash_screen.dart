import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Splash con el wordmark animado. Se muestra mientras la app resuelve la sesión.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: c.progressGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppDimens.neonGlow(c.cyan, opacity: c.dark ? 0.5 : 0.3),
              ),
              alignment: Alignment.center,
              child: Text('T',
                  style: TextStyle(
                      color: c.onAccent, fontSize: 30, fontWeight: FontWeight.w800)),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.easeOutBack)
                .fadeIn(duration: 300.ms),
            const SizedBox(width: 14),
            Text('TaskHub', style: Theme.of(context).textTheme.displaySmall)
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms)
                .slideX(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
