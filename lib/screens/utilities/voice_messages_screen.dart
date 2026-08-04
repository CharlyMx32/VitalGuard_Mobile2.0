import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';
import '../../services/voice_service.dart';
import '../../services/auth_service.dart';
import '../../models/voice_message.dart';

class VoiceMessagesScreen extends StatefulWidget {
  const VoiceMessagesScreen({super.key});

  @override
  State<VoiceMessagesScreen> createState() => _VoiceMessagesScreenState();
}

class _VoiceMessagesScreenState extends State<VoiceMessagesScreen> {
  List<VoiceMessage> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final voiceService = context.read<VoiceService>();
    final auth = context.read<AuthService>();
    final messages = await voiceService.getVoiceMessages(auth.patientId);
    if (mounted) setState(() { _messages = messages; _loading = false; });
  }

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
                  _buildMessagesList(),
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
      Text(_loading ? '...' : '${_messages.length} mensajes', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
    ]);
  }

  Widget _buildMessagesList() {
    if (_loading) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_messages.isEmpty) {
      return const VitalEmptyState(
        icon: LucideIcons.micOff,
        title: 'Sin mensajes',
        description: 'No hay mensajes de voz grabados.\nGraba un mensaje para enviarlo al dispositivo.',
      );
    }
    return Column(
      children: _messages.map((msg) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: AppDimensions.cardShadow),
          child: Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: msg.isPlayed ?? false ? AppColors.accentLight : AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
              child: Icon(msg.isPlayed ?? false ? LucideIcons.check : LucideIcons.volume2, size: 18, color: msg.isPlayed ?? false ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(msg.isPlayed ?? false ? 'Reproducido' : 'Pendiente', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const SizedBox(height: 2),
              Text(_formatDate(msg.createdAt ?? DateTime.now()), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ])),
          ]),
        ),
      )).toList(),
    );
  }

  String _formatDate(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} $h:$m';
  }
}
