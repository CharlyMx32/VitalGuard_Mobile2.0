import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';
import '../widgets/vital_button.dart';
import '../widgets/vital_modal.dart';

Future<void> confirmAndLogout(BuildContext context) async {
  final auth = context.read<AuthService>();
  final shouldLogout = await VitalModal.show<bool>(
    context: context,
    title: 'Cerrar sesión',
    description: '¿Seguro que deseas cerrar sesión?',
    iconType: ModalIconType.warning,
    icon: LucideIcons.logOut,
    actions: [
      VitalButton.ghost(
        label: 'Cancelar',
        onPressed: () => Navigator.of(context).pop(false),
      ),
      const SizedBox(height: 8),
      VitalButton(
        label: 'Cerrar sesión',
        onPressed: () => Navigator.of(context).pop(true),
      ),
    ],
  );
  if (shouldLogout == true && context.mounted) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    await auth.logout();
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}
