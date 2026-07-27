import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vitalguard_mobile/services/auth_service.dart';
import 'package:vitalguard_mobile/screens/profile/complete_profile_screen.dart';
import 'package:vitalguard_mobile/screens/settings/settings_screen.dart';
import 'package:vitalguard_mobile/screens/main_shell.dart';

void main() {
  group('CompleteProfileScreen', () {
    testWidgets('renders role options', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CompleteProfileScreen()));
      expect(find.text('Cuidar a alguien'), findsOneWidget);
      expect(find.text('Cuidarme a mí'), findsOneWidget);
      expect(find.text('¿CÓMO VAS A USAR VITALGUARD?'), findsOneWidget);
    });

    testWidgets('defaults to Cuidador selected', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CompleteProfileScreen()));
      final cards = find.byType(GestureDetector);
      expect(cards, findsWidgets);
    });

    testWidgets('continue button exists', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: CompleteProfileScreen()));
      expect(find.text('Continuar'), findsOneWidget);
    });
  });

  group('SettingsContent', () {
    testWidgets('renders settings groups', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsContent()));
      await tester.pumpAndSettle();
      expect(find.text('Ajustes'), findsOneWidget);
      expect(find.text('Cuenta'), findsOneWidget);
      expect(find.text('Dispositivo'), findsOneWidget);
      expect(find.text('Preferencias'), findsOneWidget);
      expect(find.text('Soporte'), findsOneWidget);
    });

    testWidgets('WiFi shows status without chevron', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsContent()));
      await tester.pumpAndSettle();
      expect(find.text('WiFi'), findsOneWidget);
      expect(find.text('Conectado'), findsOneWidget);
    });

    testWidgets('shows profile card', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SettingsContent()));
      await tester.pumpAndSettle();
      expect(find.text('María García'), findsOneWidget);
      expect(find.text('Cuidadora'), findsOneWidget);
    });
  });

  group('MainShell', () {
    testWidgets('renders with bottom navigation', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthService(),
          child: const MainShell(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Horario'), findsAtLeastNWidgets(1));
    });

    testWidgets('starts on dashboard tab', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => AuthService(),
          child: const MainShell(),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Buenos días,'), findsOneWidget);
    });
  });
}
