import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  _buildSupportCard(LucideIcons.mail, AppColors.warningBg, AppColors.warning, 'Enviar mensaje', 'soporte@vitalguard.com'),
                  const SizedBox(height: 12),
                  _buildSupportCard(LucideIcons.helpCircle, AppColors.accentLight, AppColors.primary, 'Preguntas frecuentes', 'Próximamente'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16, right: 16, bottom: 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Ayuda y Soporte', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSupportCard(IconData icon, Color bg, Color fg, String title, String? subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, size: 28, color: fg),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ],
      ),
    );
  }

}
