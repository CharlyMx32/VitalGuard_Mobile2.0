import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/alexa_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_modal.dart';
import '../../widgets/vital_header.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _enabled = false;
  bool _isLinked = false;
  bool _isLoading = false;

  final _commands = [
    '"Alexa, toma mis medicamentos"',
    '"Alexa, ¿qué debo tomar ahora?"',
    '"Alexa, reportar que tomé mi pastilla"',
    '"Alexa, llamar a mi cuidador"',
  ];

  @override
  void initState() {
    super.initState();
    _loadLinkStatus();
  }

  Future<void> _loadLinkStatus() async {
    final linked = await AlexaService.isAlexaLinked();
    if (mounted) {
      setState(() => _isLinked = linked);
    }
  }

  Future<void> _onVinculateAlexa() async {
    final auth = context.read<AuthService>();
    final token = auth.token;

    if (token == null) {
      if (!mounted) return;
      VitalFeedback.info(
        context,
        code: 'ALEXA_NO_TOKEN',
        title: 'Sesión requerida',
        message: 'Inicia sesión para vincular Alexa.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AlexaService.startLinking(accessToken: token);

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isLinked = true;
          _enabled = true;
        });
        VitalFeedback.info(
          context,
          code: 'ALEXA_LINK_SUCCESS',
          title: 'Alexa vinculada',
          message: 'Tu cuenta de Alexa ha sido vinculada exitosamente.',
        );
      } else if (result.error == 'user_cancelled') {
        VitalFeedback.info(
          context,
          code: 'ALEXA_LINK_CANCELLED',
          title: 'Vinculación cancelada',
          message: 'No se completó la vinculación con Alexa.',
        );
      } else {
        VitalFeedback.info(
          context,
          code: 'ALEXA_LINK_ERROR',
          title: 'Error de vinculación',
          message: 'No se pudo vincular Alexa. Intenta de nuevo.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      VitalFeedback.info(
        context,
        code: 'ALEXA_LINK_ERROR',
        title: 'Error inesperado',
        message: 'Ocurrió un error al vincular Alexa.',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Asistente de Voz'),
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
          Text(
            _isLinked ? 'Vinculado' : 'No vinculado',
            style: TextStyle(
              fontSize: 12,
              color: _isLinked ? AppColors.accent : AppColors.textMuted,
              fontWeight: _isLinked ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
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
    if (_isLinked) {
      return GestureDetector(
        onTap: _onDesvincularAlexa,
        child: Container(
          width: double.infinity, height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.danger, width: 1.5),
          ),
          child: const Center(
            child: Text('Desvincular Alexa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _isLoading ? null : _onVinculateAlexa,
      child: Container(
        width: double.infinity, height: 44,
        decoration: BoxDecoration(
          color: _isLoading ? AppColors.primary.withValues(alpha: 0.6) : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: _isLoading
            ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Text('Vincular dispositivo Alexa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Future<void> _onDesvincularAlexa() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Desvincular Alexa'),
        content: const Text('¿Estás seguro de que deseas desvincular Alexa?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Desvincular', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await AlexaService.setAlexaLinked(false);
      setState(() {
        _isLinked = false;
        _enabled = false;
      });
      if (!mounted) return;
      VitalFeedback.info(
        context,
        code: 'ALEXA_UNLINKED',
        title: 'Alexa desvinculada',
        message: 'Alexa ha sido desvinculada de tu cuenta.',
      );
    }
  }
}
