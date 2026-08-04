import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/theme_provider.dart';
import 'screens/main_shell.dart';
import 'widgets/vital_shimmer.dart';

class VitalGuardApp extends StatelessWidget {
  const VitalGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'VitalGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: Consumer<AuthService>(
            builder: (context, auth, _) {
              if (auth.isLoading) {
                return _buildSplashSkeleton();
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
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
    );
  }

  Widget _buildSplashSkeleton() {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SkeletonCircle(size: 72),
            const SizedBox(height: 20),
            const SkeletonLine(width: 180, height: 16),
            const SizedBox(height: 8),
            const SkeletonLine(width: 120, height: 12),
          ],
        ),
      ),
    );
  }
}

class LoginRedirect extends StatefulWidget {
  const LoginRedirect({super.key});

  @override
  State<LoginRedirect> createState() => _LoginRedirectState();
}

class _LoginRedirectState extends State<LoginRedirect> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('onboarding_seen') ?? false;
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        seen ? AppRoutes.login : AppRoutes.splash,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SkeletonLine(width: 180, height: 16),
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
        child: SkeletonLine(width: 180, height: 16),
      ),
    );
  }
}
