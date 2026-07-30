import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _enabled = false;

  final _commands = [
    '"Alexa, toma mis medicamentos"',
    '"Alexa, ¿qué debo tomar ahora?"',
    '"Alexa, reportar que tomé mi pastilla"',
    '"Alexa, llamar a mi cuidador"',
  ];

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
                  _buildVoiceCard(),
                  const SizedBox(height: 16),
                  _buildToggleRow(),
                  const SizedBox(height: 20),
                  _buildSectionHeader(),
                  const SizedBox(height: 8),
                  ..._commands.map((cmd) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCommandCard(cmd),
                  )),
                  const SizedBox(height: 20),
                  _buildLinkButton(),
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
            child: Text('Asistente de Voz', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildVoiceCard() {
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
            width: 80, height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.mic, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('Amazon Alexa', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('No vinculado', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          const Text('El mensaje se reproducirá por el altavoz del pastillero',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildToggleRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          const Expanded(child: Text('Activar asistente de voz', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark))),
          GestureDetector(
            onTap: () => setState(() => _enabled = !_enabled),
            child: Container(
              width: 48, height: 28,
              decoration: BoxDecoration(color: _enabled ? AppColors.primary : AppColors.borderLight, borderRadius: BorderRadius.circular(14)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: _enabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text('Comandos disponibles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
    );
  }

  Widget _buildCommandCard(String cmd) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(LucideIcons.mic, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(cmd, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildLinkButton() {
    return Container(
      width: double.infinity, height: 44,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
      child: const Center(child: Text('Vincular dispositivo Alexa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
    );
  }
}
