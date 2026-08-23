import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/alexa_service.dart';
import '../../services/auth_service.dart';
import '../../config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_modal.dart';
import '../../widgets/vital_header.dart';
import '../../widgets/vital_button.dart';

class VoiceAssistantScreen extends StatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen> {
  bool _enabled = false;
  bool _loading = true;
  bool _loadError = false;
  bool _isLinked = false;
  AlexaLinkStatus? _status;

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
    final auth = context.read<AuthService>();
    final token = auth.token;

    if (token == null) {
      if (mounted) {
        setState(() {
          _status = const AlexaLinkStatus(linked: false);
          _isLinked = false;
          _loading = false;
        });
      }
      return;
    }

    try {
      final status = await AlexaService.fetchLinkStatus(
        accessToken: token,
        onRefresh: () => auth.refreshAccessToken(),
      );
      if (mounted) {
        setState(() {
          _status = status;
          _isLinked = status.linked;
          _loadError = false;
          _loading = false;
        });
      }
    } on DioException catch (e) {
      // No se pudo verificar (red, token no refrescable, etc.). No mostrar
      // "No vinculado" como si fuera un estado real: mostrar error.
      debugPrint('[Alexa] fetchLinkStatus error: ${e.response?.statusCode} ${e.message}');
      if (mounted) {
        setState(() {
          _status = const AlexaLinkStatus(linked: false);
          _isLinked = false;
          _loading = false;
          _loadError = true;
        });
      }
    }
  }

  Future<void> _refresh() => _loadLinkStatus();

  Future<void> _onVinculateAlexa() async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Conectar con Alexa'),
        content: const Text(
          'Para vincular tu cuenta con Alexa:\n\n'
          '1. Abre la aplicación de Alexa o alexa.amazon.com\n'
          '2. Ahí habilita la skill "VitalGuard"\n'
          '3. Inicia sesión con tu cuenta Vital ID\n'
          '4. Autoriza el acceso\n\n'
          'Una vez vinculado, podrás usar comandos como '
          '"Alexa, pregunta a VitalGuard cuándo debo tomar mi medicina".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Abrir Alexa'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final launched = await _openAlexaLink();
      if (!mounted) return;
      if (!launched) {
        VitalFeedback.info(
          context,
          code: 'ALEXA_LINK_MANUAL',
          title: 'Vincula desde la app de Alexa',
          message:
            'No se pudo abrir automáticamente. Abre la app de Alexa o alexa.amazon.com y habilita la skill "VitalGuard".',
        );
      }
    }
  }

  Future<bool> _openAlexaLink() async {
    const url = AppConfig.alexaAppUrl;
    try {
      return await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> _onDesvincularAlexa() async {
    final auth = context.read<AuthService>();
    final token = auth.token;

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
      if (token != null) {
        await AlexaService.unlink(
          accessToken: token,
          onRefresh: () => auth.refreshAccessToken(),
        );
      } else {
        await AlexaService.setAlexaLinked(false);
      }
      setState(() {
        _isLinked = false;
        _status = null;
        _loadError = false;
        _enabled = false;
      });
      await _refresh();
      if (!mounted) return;
      VitalFeedback.info(
        context,
        code: 'ALEXA_UNLINKED',
        title: 'Alexa desvinculada',
        message: 'Alexa ha sido desvinculada de tu cuenta.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(
            title: 'Asistente de Voz',
            actions: [
              IconButton(
                onPressed: _loading ? null : _refresh,
                icon: const Icon(LucideIcons.refreshCcw, size: 20, color: AppColors.textDark),
              ),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppColors.primary,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 24),
                      child: Column(
                        children: [
                          _buildAlexaHeroCard(),
                          const SizedBox(height: 16),
                          if (_isLinked) ..._buildLinkedPanel(),
                          if (!_isLinked && !_loadError) _buildHowItWorksCard(),
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
          ),
        ],
      ),
    );
  }

  // ── Tarjeta principal con el estado de Alexa ─────────────────────────
  Widget _buildAlexaHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A7CFF), Color(0xFF6C5CE7)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.audioLines, size: 32, color: Color(0xFF4A7CFF)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amazon Alexa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 2),
                    Text('Skill VitalGuard', style: TextStyle(fontSize: 12, color: Colors.white70)),
                  ],
                ),
              ),
              _buildHeroStatusChip(),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.volume2, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Las indicaciones se reproducirán por el altavoz del pastillero',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatusChip() {
    if (_loadError) {
      return GestureDetector(
        onTap: _refresh,
        child: Container(
          padding: AppDimensions.badgePadding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.wifiOff, size: 14, color: AppColors.warning),
              SizedBox(width: 4),
              Text('Reintentar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
            ],
          ),
        ),
      );
    }
    return Container(
      padding: AppDimensions.badgePadding,
      decoration: BoxDecoration(
        color: _isLinked ? Colors.white : Colors.white24,
        borderRadius: BorderRadius.circular(AppDimensions.radiusBadge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isLinked ? LucideIcons.badgeCheck : LucideIcons.alertCircle,
            size: 14,
            color: _isLinked ? AppColors.accent : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            _isLinked ? 'Vinculado' : 'Sin vincular',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _isLinked ? AppColors.accent : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Panel de detalle cuando está vinculado ───────────────────────────
  List<Widget> _buildLinkedPanel() {
    final auth = context.read<AuthService>();
    final status = _status;
    final email = (auth.email != null && auth.email!.isNotEmpty)
        ? auth.email!
        : null;
    final linkedDate = status?.linkedAt != null
        ? '${_twoDigits(status!.linkedAt!.day)}/${_twoDigits(status.linkedAt!.month)}/${status.linkedAt!.year}'
        : null;
    final vitalId = status?.vitalId;
    final vitalShort = vitalId != null && vitalId.length >= 8
        ? '${vitalId.substring(0, 8)}…'
        : vitalId;

    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          children: [
            _buildDetailRow(LucideIcons.mail, 'Cuenta', email ?? '—'),
            if (vitalShort != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(LucideIcons.keyRound, 'ID de cuenta', vitalShort),
            ],
            if (linkedDate != null) ...[
              const SizedBox(height: 10),
              _buildDetailRow(LucideIcons.calendar, 'Vinculado desde', linkedDate),
            ],
          ],
        ),
      ),
    ];
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark),
          ),
        ),
      ],
    );
  }

  // ── Cómo funciona cuando NO está vinculado ───────────────────────────
  Widget _buildHowItWorksCard() {
    final steps = [
      (LucideIcons.smartphone, 'Abre la app de Alexa o alexa.amazon.com'),
      (LucideIcons.search, 'Habilita la skill "VitalGuard"'),
      (LucideIcons.logIn, 'Inicia sesión con tu Vital ID y autoriza'),
      (LucideIcons.checkCheck, 'Listo, podrás usar tus comandos de voz'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cómo vincular', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 12),
          ...steps.asMap().entries.map((entry) {
            final idx = entry.key;
            final (icon, text) = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Text('${idx + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.3)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

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
      return VitalButton.danger(
        label: 'Desvincular Alexa',
        icon: LucideIcons.unlink,
        onPressed: _onDesvincularAlexa,
      );
    }
    return VitalButton(
      label: 'Vincular dispositivo Alexa',
      icon: LucideIcons.wifi,
      onPressed: _onVinculateAlexa,
    );
  }
}