import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

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
                  _buildMessageCard('JG', 'Juan García', '0:15 seg', 'Hoy, 9:30 AM', AppColors.primary, true, true),
                  const SizedBox(height: 8),
                  _buildMessageCard('RG', 'Rosa García', '0:22 seg', 'Ayer, 6:15 PM', AppColors.accent, false, false),
                  const SizedBox(height: 8),
                  _buildMessageCard('JG', 'Juan García', '0:08 seg', 'Lun, 10:00 AM', AppColors.primary, false, false),
                  const SizedBox(height: 8),
                  _buildMessageCard('PM', 'Pedro Martínez', '0:12 seg', 'Dom, 8:45 AM', const Color(0xFF9B59B6), false, false),
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
        const Text('Enviar mensaje a Juan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(height: 4),
        const Text('Mantén presionado para grabar', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 16),
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(
            color: AppColors.dangerDark,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: AppColors.dangerDark.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 4))],
          ),
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
      const Text('4 mensajes', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
    ]);
  }

  Widget _buildMessageCard(String initials, String name, String duration, String time, Color gradientColor, bool unread, bool playing) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
        border: unread ? Border(left: BorderSide(color: AppColors.primary, width: 3)) : null,
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(gradient: LinearGradient(colors: [gradientColor, gradientColor.withValues(alpha: 0.7)]), shape: BoxShape.circle),
          child: Center(child: Text(initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Para: $name', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(duration, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ])),
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: playing ? AppColors.primary : AppColors.accentLight, shape: BoxShape.circle),
          child: Icon(playing ? LucideIcons.pause : LucideIcons.play, size: 16, color: playing ? Colors.white : AppColors.primary),
        ),
      ]),
    );
  }
}
