import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/app_transitions.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'screens/main_shell.dart';

class VitalGuardApp extends StatelessWidget {
  const VitalGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VitalGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Consumer<AuthService>(
        builder: (context, auth, _) {
          if (auth.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4A90E2),
                  strokeWidth: 2.5,
                ),
              ),
            );
          }

          if (auth.isLoggedIn) {
            if (!auth.isProfileComplete) {
              return const _ProfileRedirect();
            }
            return const MainShell();
          }

          return const LoginRedirect();
        },
      ),
      onGenerateRoute: (settings) {
        final builder = AppRoutes.routes[settings.name];
        if (builder == null) return null;
        return AppTransitions.slideUp(settings, builder);
      },
    );
  }
}

class LoginRedirect extends StatelessWidget {
  const LoginRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90E2),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _ProfileRedirect extends StatelessWidget {
  const _ProfileRedirect();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
    });
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4A90E2),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
