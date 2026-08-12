import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../services/sos_alarm_audio.dart';
import '../../services/sos_service.dart';
import '../../services/auth_service.dart';
import '../../services/patient_current_service.dart';
import '../../services/patient_service.dart';
import '../../models/patient.dart';

class SosAlarmScreen extends StatefulWidget {
  const SosAlarmScreen({super.key});

  @override
  State<SosAlarmScreen> createState() => _SosAlarmScreenState();
}

class _SosAlarmScreenState extends State<SosAlarmScreen>
    with TickerProviderStateMixin {
  int _seconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;
  bool _badgeVisible = true;
  Timer? _badgeTimer;
  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _seconds++);
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _badgeTimer = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      if (mounted) setState(() => _badgeVisible = !_badgeVisible);
    });

    SosAlarmAudio.start();
    HapticFeedback.heavyImpact();
    _loadPatientAndTrigger();
  }

  Future<void> _loadPatientAndTrigger() async {
    if (!mounted) return;
    final patientCurrent = context.read<PatientCurrentService>();
    final auth = context.read<AuthService>();
    final patientId = patientCurrent.patientId ?? auth.patientId ?? 0;
    if (patientId == 0) return;

    try {
      final patientService = context.read<PatientService>();
      final patient = await patientService.getPatient(patientId);
      if (mounted) setState(() => _patient = patient);
    } catch (_) {}

    if (!mounted) return;
    final sosService = context.read<SosService>();
    await sosService.createSosEvent(patientId);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _badgeTimer?.cancel();
    _pulseController.dispose();
    SosAlarmAudio.stop();
    super.dispose();
  }

  void _dismiss() {
    SosAlarmAudio.stop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: Dismissible(
        key: const Key('sos_alarm'),
        direction: DismissDirection.up,
        onDismissed: (_) => _dismiss(),
        resizeDuration: null,
        background: const SizedBox.expand(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.5,
              colors: [Color(0x4DEB5757), Color(0xFF1A0000)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _buildPulseIcon(),
                const SizedBox(height: 24),
                _buildBadge(),
                const SizedBox(height: 12),
                const Text('SOS',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 6),
                Text('Emergencia reportada',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 32),
                _buildPatientCard(),
                const SizedBox(height: 16),
                _buildLocationCard(),
                const SizedBox(height: 32),
                Text('Tiempo transcurrido',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.4))),
                const SizedBox(height: 4),
                Text('$min:$sec',
                    style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: AppColors.dangerDark,
                        fontFeatures: [FontFeature.tabularFigures()])),
                const Spacer(flex: 3),
                _buildSwipeHint(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPulseIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseController.value * 0.05),
          child: child,
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.dangerDark.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.dangerDark.withValues(alpha: 0.4), width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.dangerDark.withValues(alpha: 0.2),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Icon(LucideIcons.alertTriangle,
            size: 56, color: AppColors.dangerDark),
      ),
    );
  }

  Widget _buildBadge() {
    return AnimatedOpacity(
      opacity: _badgeVisible ? 1.0 : 0.4,
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.dangerDark.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.dangerDark.withValues(alpha: 0.4)),
        ),
        child: const Text('ALARMA ACTIVA',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF6B6B),
                letterSpacing: 1)),
      ),
    );
  }

  Widget _buildPatientCard() {
    final p = _patient;
    String name = 'Paciente';
    String initials = '?';
    if (p != null) {
      name = '${p.firstName} ${p.paternalLastName ?? ''}'.trim();
      final fn = p.firstName.isNotEmpty ? p.firstName[0] : '';
      final ln = (p.paternalLastName ?? '').isNotEmpty ? (p.paternalLastName ?? '')[0] : '';
      initials = '$fn$ln';
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF3A7BD5)]),
            shape: BoxShape.circle,
          ),
          child: Center(
              child: Text(initials.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white))),
        ),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(name.trim(),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
              const SizedBox(height: 2),
              Text(_patient != null ? 'Paciente' : 'Cargando...',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0x80FFFFFF))),
            ])),
      ]),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: AppColors.dangerDark.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(LucideIcons.mapPin,
              size: 18, color: AppColors.dangerDark),
        ),
        const SizedBox(width: 12),
        const Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text('Ubicacion actual',
                  style:
                      TextStyle(fontSize: 11, color: Color(0x66FFFFFF))),
              SizedBox(height: 1),
              Text('Enviando ubicacion del dispositivo...',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white)),
            ])),
      ]),
    );
  }

  Widget _buildSwipeHint() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Text('Deslizar hacia arriba para cerrar',
            style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.3))),
      ],
    );
  }
}
