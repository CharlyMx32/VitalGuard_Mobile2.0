import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../services/device_service.dart';
import '../../widgets/vital_modal.dart';

class LinkDeviceScreen extends StatefulWidget {
  const LinkDeviceScreen({super.key});

  @override
  State<LinkDeviceScreen> createState() => _LinkDeviceScreenState();
}

class _LinkDeviceScreenState extends State<LinkDeviceScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isSaving = false;
  String? _nextRoute;
  int? _patientId;
  Map<String, dynamic>? _profileData;
  bool _argsRead = false;
  bool _fromProfile = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _nextRoute = args['next'] as String?;
      _patientId = args['patientId'] as int?;
      _fromProfile = args['fromProfile'] == true;
      _profileData = Map<String, dynamic>.from(args);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _continue() {
    final profileData = Map<String, dynamic>.from(_profileData ?? {})
      ..remove('next')
      ..remove('patientId');
    Navigator.pushNamedAndRemoveUntil(
      context,
      _nextRoute ?? AppRoutes.dashboard,
      (route) => false,
      arguments: {
        'patientId': _patientId,
        ...profileData,
      },
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 24) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  _buildIllustration(),
                  const SizedBox(height: 28),
                  const Text('Vincular dispositivo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  const Text('Ingresa el codigo de 6 caracteres que aparece en tu VitalGuard',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.5)),
                  const SizedBox(height: 28),
                  _buildCodeInputs(),
                  const SizedBox(height: 20),
                  const Text('El codigo se encuentra en la parte trasera del dispositivo\no en la pantalla LCD al encenderlo',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.6)),
                  const SizedBox(height: 28),
                  _buildVerifyButton(),
                  const SizedBox(height: 16),
                  _buildDeviceInfo(),
                  const SizedBox(height: 24),
                  _buildSimulateButton(),
                  if (!_fromProfile) ...[
                    const SizedBox(height: 16),
                    _buildSkipButton(),
                  ],
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
      width: 120, height: 120,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.accentLight),
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 148, height: 148, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2, strokeAlign: BorderSide.strokeAlignOutside))),
        const Icon(LucideIcons.smartphone, size: 52, color: AppColors.primary),
      ]),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  CODE INPUTS — 6 celdas individuales con estilo limpio
  // ══════════════════════════════════════════════════════════════
  Widget _buildCodeInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...List.generate(3, (i) => _buildSingleInput(i)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Container(
            width: 20, height: 2,
            decoration: BoxDecoration(color: AppColors.textMuted, borderRadius: BorderRadius.circular(1)),
          ),
        ),
        ...List.generate(3, (i) => _buildSingleInput(i + 3)),
      ],
    );
  }

  Widget _buildSingleInput(int index) {
    final hasText = _controllers[index].text.isNotEmpty;
    final isFocused = _focusNodes[index].hasFocus;

    Color borderColor;
    if (hasText) {
      borderColor = AppColors.primary;
    } else if (isFocused) {
      borderColor = AppColors.primary;
    } else {
      borderColor = AppColors.borderLight;
    }

    return Container(
      width: 48, height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: hasText ? AppColors.primaryLight : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: hasText || isFocused ? 1.5 : 1),
        boxShadow: isFocused
            ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 6, spreadRadius: 0)]
            : [],
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          maxLength: 1,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]'))],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textDark, height: 1.0),
          decoration: const InputDecoration(
            counterText: '',
            border: UnderlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide.none),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide.none),
            contentPadding: EdgeInsets.zero,
            isDense: true,
            filled: false,
          ),
          onChanged: (v) {
            setState(() {});
            if (v.isNotEmpty && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (v.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════

  Widget _buildVerifyButton() {
    final isComplete = _code.length == 6;
    return GestureDetector(
      onTap: (_isSaving || !isComplete) ? null : _onVerify,
      child: Container(
        width: double.infinity, height: 48,
        decoration: BoxDecoration(
          color: isComplete ? AppColors.primary : AppColors.textLight,
          borderRadius: BorderRadius.circular(12),
        ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(width: 32, height: 32, decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle), child: const Icon(LucideIcons.info, size: 18, color: AppColors.primary)),
        const SizedBox(width: 10),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Formato del codigo', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          Text('Ejemplo: A1B-2C3', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ])),
      ]),
    );
  }

  /// Botón de simulación para testing sin dispositivo real
  Widget _buildSimulateButton() {
    return GestureDetector(
      onTap: _onSimulate,
      child: Container(
        width: double.infinity, height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent, width: 1.2),
        ),
        child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.play, size: 16, color: AppColors.accent),
          SizedBox(width: 8),
          Text('Simular dispositivo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent)),
        ]),
      ),
    );
  }

  Widget _buildSkipButton() {
    return GestureDetector(
      onTap: _continue,
      child: const Text('Omitir por ahora', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
    );
  }

  Future<void> _onVerify() async {
    if (_code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el codigo completo de 6 caracteres'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isSaving = true);

    final deviceService = context.read<DeviceService>();
    try {
      await deviceService.saveDeviceByCode(_code, patientId: _patientId);

      if (mounted) {
        VitalFeedback.success(
          context,
          code: 'DEVICE_LINKED',
          message: 'Dispositivo verificado correctamente',
          onAction: _continue,
        );
      }
    } on DioException catch (e) {
      // Si el backend no está disponible o el token no funciona, usar mock
      debugPrint('[LinkDevice] Backend error ${e.response?.statusCode}, usando mock');
      await deviceService.saveDeviceMock(_code, patientId: _patientId);

      if (mounted) {
        VitalFeedback.success(
          context,
          code: 'DEVICE_LINKED',
          message: 'Dispositivo vinculado (modo local)',
          onAction: _continue,
        );
      }
    } catch (e) {
      // Cualquier otro error: usar mock también
      debugPrint('[LinkDevice] Unexpected error: $e, usando mock');
      await deviceService.saveDeviceMock(_code, patientId: _patientId);

      if (mounted) {
        VitalFeedback.success(
          context,
          code: 'DEVICE_LINKED',
          message: 'Dispositivo vinculado (modo local)',
          onAction: _continue,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Simula un dispositivo vinculado sin llamar al backend
  void _onSimulate() async {
    final deviceService = context.read<DeviceService>();
    final code = _code.isNotEmpty ? _code : 'SIM001';
    await deviceService.saveDeviceMock(code, patientId: _patientId);

    if (mounted) {
      VitalFeedback.success(
        context,
        code: 'DEVICE_LINKED',
        message: 'Dispositivo simulado vinculado correctamente',
        onAction: _continue,
      );
    }
  }
}
