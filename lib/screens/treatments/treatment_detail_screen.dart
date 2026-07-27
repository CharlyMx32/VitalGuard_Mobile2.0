import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';


class TreatmentDetailScreen extends StatelessWidget {
  const TreatmentDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingHorizontal,
              ) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildProgressCard(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Medicamentos (3)'),
                  const SizedBox(height: 8),
                  _buildMedCard(
                    iconBg: AppColors.primaryLight,
                    iconFg: AppColors.primary,
                    name: 'Losartan 50mg',
                    subtitle: 'Potásico - En pastillero',
                    status: 'Activo',
                    statusType: _MedStatus.active,
                    details: [
                      ('Compartimento', '#1 - Mañana'),
                      ('Fecha fin', '7 Jul 2026'),
                      ('Frecuencia', 'Diario'),
                      ('Horario', '8:00 AM'),
                    ],
                    progress: '6 / 14 días',
                    progressPercent: 0.43,
                  ),
                  const SizedBox(height: 8),
                  _buildMedCard(
                    iconBg: AppColors.primaryLight,
                    iconFg: AppColors.primary,
                    name: 'Metformina 850mg',
                    subtitle: 'Clorhidrato - En pastillero',
                    status: 'Activo',
                    statusType: _MedStatus.active,
                    details: [
                      ('Compartimento', '#2 - Almuerzo'),
                      ('Fecha fin', '14 Jul 2026'),
                      ('Frecuencia', '2 veces al día'),
                      ('Horarios', '12PM, 8PM'),
                    ],
                    progress: '6 / 21 días',
                    progressPercent: 0.29,
                  ),
                  const SizedBox(height: 8),
                  _buildMedCard(
                    iconBg: AppColors.warningBg,
                    iconFg: AppColors.warning,
                    name: 'Vitamina D 5000UI',
                    subtitle: 'Colecalciferol - Manual',
                    status: 'Activo',
                    statusType: _MedStatus.active,
                    details: [
                      ('Tipo', 'Fuera del dispositivo'),
                      ('Fecha fin', '30 Jun 2026'),
                      ('Frecuencia', 'Diario'),
                      ('Horario', '9:00 AM'),
                    ],
                    progress: '13 / 14 días',
                    progressPercent: 0.93,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tratamiento pausado'), backgroundColor: AppColors.warning),
                              );
                            },
                            icon: const Icon(LucideIcons.pause, size: 14),
                            label: const Text('Pausar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textDark,
                              side: const BorderSide(color: AppColors.borderLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tratamiento finalizado'), backgroundColor: AppColors.dangerDark),
                              );
                            },
                            icon: const Icon(LucideIcons.x, size: 14),
                            label: const Text('Finalizar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.dangerBg,
                              foregroundColor: AppColors.dangerDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ),
                    ],
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(
            child: Text('Detalle del Tratamiento', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.87, -0.50),
          end: Alignment(-0.87, 0.50),
          colors: [Color(0xFF4A90E2), Color(0xFF6FCF97)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tratamiento 10 Jun 2026', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  SizedBox(height: 4),
                  Text('Inicio: 10 Junio 2026', style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('Activo', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _HeroStat(value: '3', label: 'Medicamentos'),
              _HeroStat(value: '6', label: 'Días transcurridos'),
              _HeroStat(value: '8', label: 'Días restantes'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progreso general', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
              const Text('6 / 14 días', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: 0.43,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10 Jun 2026', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
              Text('24 Jun 2026', style: TextStyle(fontSize: 10, color: AppColors.textLight)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const Text('+ Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primary)),
      ],
    );
  }

  Widget _buildMedCard({
    required Color iconBg,
    required Color iconFg,
    required String name,
    required String subtitle,
    required String status,
    required _MedStatus statusType,
    required List<(String, String)> details,
    required String progress,
    required double progressPercent,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.pill, size: 20, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusType == _MedStatus.active ? AppColors.accentLight : AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: statusType == _MedStatus.active ? AppColors.accent : AppColors.textMuted,
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
            children: details.map((d) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1, style: const TextStyle(fontSize: 9, color: AppColors.textLight)),
                  const SizedBox(height: 2),
                  Text(d.$2, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progreso', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(progress, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progressPercent,
                  minHeight: 3,
                  backgroundColor: AppColors.borderLight,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _MedStatus { active }

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ],
      ),
    );
  }
}
