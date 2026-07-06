import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SendRequestsScreen extends StatelessWidget {
  const SendRequestsScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona el tipo de solicitud que deseas enviar. Se compartirá un enlace seguro por el medio que elijas.',
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                  const SizedBox(height: 20),
                  _buildRequestCard(LucideIcons.users, AppColors.accentLight, AppColors.primary, 'Solicitud de Cuidador',
                    'Invita a otro cuidador a unirse y compartir la responsabilidad del paciente'),
                  const SizedBox(height: 12),
                  _buildRequestCard(LucideIcons.userCheck, AppColors.accentLight, AppColors.accent, 'Autocuidado',
                    'Envía el enlace al paciente para que gestione sus propios medicamentos'),
                  const SizedBox(height: 12),
                  _buildRequestCard(LucideIcons.activity, const Color(0xFFF3E8FF), const Color(0xFF9B59B6), 'Vincular Médico',
                    'Invita a tu médico tratante para que acceda a los reportes de salud'),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
        const Expanded(child: Text('Enviar Solicitudes', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildRequestCard(IconData icon, Color bg, Color fg, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)), child: Icon(icon, size: 28, color: fg)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.4)),
        ])),
        const Icon(LucideIcons.chevronRight, size: 20, color: AppColors.textMuted),
      ]),
    );
  }
}
