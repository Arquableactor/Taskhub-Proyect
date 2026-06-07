// Smoke test: la pantalla de login se construye y muestra la marca.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:taskhub_app/services/api_client.dart';
import 'package:taskhub_app/services/auth_service.dart';
import 'package:taskhub_app/theme/app_theme.dart';
import 'package:taskhub_app/screens/login_screen.dart';

void main() {
  testWidgets('La pantalla de login muestra TaskHub y el botón Entrar',
      (WidgetTester tester) async {
    // En tests no descargamos fuentes por red.
    GoogleFonts.config.allowRuntimeFetching = false;

    final api = ApiClient();
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthService(api),
        child: MaterialApp(theme: AppTheme.dark, home: const LoginScreen()),
      ),
    );

    expect(find.text('TaskHub'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
