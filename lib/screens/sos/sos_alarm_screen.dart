import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';

class SosAlarmScreen extends StatefulWidget {
  const SosAlarmScreen({super.key});

  @override
  State<SosAlarmScreen> createState() => _SosAlarmScreenState();
}

class _SosAlarmScreenState extends State<SosAlarmScreen> {
  int _seconds = 12;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = (_seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      body: Container(
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
              const SizedBox(height: 40),
              _buildPulseIcon(),
              const SizedBox(height: 24),
              _buildBadge(),
              const SizedBox(height: 12),
              const Text('SOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Text('Emergencia reportada', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
              const SizedBox(height: 32),
              _buildPatientCard(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 32),
              Text('Tiempo transcurrido', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
              const SizedBox(height: 4),
              Text('$min:$sec', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppColors.dangerDark, fontFeatures: [FontFeature.tabularFigures()])),
              const Spacer(),
              _buildRespondButton(),
              const SizedBox(height: 12),
              _buildCallButton(),
              const SizedBox(height: 24),
              _buildSwipeHint(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPulseIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.05),
      duration: const Duration(milliseconds: 1500),
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(
          color: AppColors.dangerDark.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.dangerDark.withValues(alpha: 0.4), width: 3),
        ),
        child: const Icon(LucideIcons.alertTriangle, size: 56, color: AppColors.dangerDark),
      ),
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.dangerDark.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dangerDark.withValues(alpha: 0.4)),
      ),
      child: const Text('ALARMA ACTIVA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFFF6B6B), letterSpacing: 1)),
    );
  }

  Widget _buildPatientCard() {
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
          width: 56, height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3A7BD5)]),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('JG', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
        const SizedBox(width: 14),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Juan García', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          SizedBox(height: 2),
          Text('Padre · 68 años', style: TextStyle(fontSize: 13, color: Color(0x80FFFFFF))),
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
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.dangerDark.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
          child: const Icon(LucideIcons.mapPin, size: 18, color: AppColors.dangerDark),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ubicación actual', style: TextStyle(fontSize: 11, color: Color(0x66FFFFFF))),
          SizedBox(height: 1),
          Text('Calle Principal 123, San José', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
        ])),
      ]),
    );
  }

  Widget _buildRespondButton() {
    return Container(
      width: double.infinity, height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.phone, size: 22, color: Colors.white),
        SizedBox(width: 10),
        Text('Responder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      ]),
    );
  }

  Widget _buildCallButton() {
    return Container(
      width: double.infinity, height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.dangerDark.withValues(alpha: 0.4), width: 1.5),
      ),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.phoneCall, size: 20, color: AppColors.dangerDark),
        SizedBox(width: 10),
        Text('Llamar ahora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.dangerDark)),
      ]),
    );
  }

  Widget _buildSwipeHint() {
    return Column(children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 8),
      Text('Deslizar para cerrar', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.3))),
      const SizedBox(height: 8),
    ]);
  }
}
