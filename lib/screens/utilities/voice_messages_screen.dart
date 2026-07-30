import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';

class VoiceMessagesScreen extends StatelessWidget {
  const VoiceMessagesScreen({super.key});

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
                  _buildRecordSection(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(),
                  const SizedBox(height: 12),
                  const VitalEmptyState(
                    icon: LucideIcons.micOff,
                    title: 'Sin mensajes',
                    description: 'No hay mensajes de voz grabados.\nGraba un mensaje para enviarlo al dispositivo.',
                  ),
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
        const Expanded(child: Text('Mensajes de Voz', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildRecordSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppDimensions.cardShadow),
      child: Column(children: [
        const Text('Enviar mensaje de voz', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Mantén presionado para grabar', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))]),
          child: const Icon(LucideIcons.mic, size: 28, color: Colors.white),
        ),
        const SizedBox(height: 12),
        const Text('El mensaje se reproducirá por el altavoz del dispositivo',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ]),
    );
  }

  Widget _buildSectionHeader() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('Mensajes recientes', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      const Text('0 mensajes', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
    ]);
  }
}
