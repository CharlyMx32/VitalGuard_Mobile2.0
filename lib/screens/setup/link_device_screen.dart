import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/device_service.dart';
import '../../widgets/vital_modal.dart';

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  _buildIllustration(),
                  const SizedBox(height: 28),
                  const Text('Vincular dispositivo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text('Ingresa el codigo de 6 digitos que aparece en tu VitalGuard',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                  const SizedBox(height: 24),
                  _buildCodeInputs(),
                  const SizedBox(height: 24),
                  const Text('El codigo se encuentra en la parte trasera del dispositivo\no en la pantalla LCD al encenderlo',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.6)),
                  const SizedBox(height: 24),
                  _buildVerifyButton(),
                  const SizedBox(height: 16),
                  _buildDeviceInfo(),
                  const SizedBox(height: 24),
                  const Text('Necesito ayuda para encontrar mi codigo',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
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
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primary))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 140, height: 140,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentLight),
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside))),
        const Icon(LucideIcons.smartphone, size: 64, color: AppColors.primary),
      ]),
    );
  }

  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (i) => _buildInput(i)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('-', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
        ),
        ...List.generate(3, (i) => _buildInput(i + 3)),
      ],
    );
  }

  Widget _buildInput(int i) {
    return Container(
      width: 48, height: 56, margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: _controllers[i].text.isNotEmpty ? AppColors.accentLight : AppColors.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _controllers[i].text.isNotEmpty ? AppColors.primary : AppColors.borderLight, width: 2),
      ),
      child: TextField(
        controller: _controllers[i],
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textDark),
        decoration: const InputDecoration(counterText: '', border: InputBorder.none),
        onChanged: (v) {
          setState(() {});
          if (v.isNotEmpty && i < 5) { FocusScope.of(context).nextFocus(); }
        },
      ),
    );
  }

  Widget _buildVerifyButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _onVerify,
      child: Container(
        width: 200, height: 48,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Verificar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildDeviceInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle), child: const Icon(LucideIcons.info, size: 18, color: AppColors.primary)),
        const SizedBox(width: 8),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Formato del codigo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('Ejemplo: VG-123-456', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  Future<void> _onVerify() async {
    if (_code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el codigo completo de 6 digitos'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isSaving = true);

    final deviceService = context.read<DeviceService>();
    await deviceService.saveDeviceByCode(_code);

    if (mounted) {
      VitalFeedback.success(
        context,
        code: 'DEVICE_LINKED',
        message: 'Dispositivo verificado correctamente',
        onAction: () => Navigator.pop(context),
      );
    }
  }
}
