import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';

class PatientDetailScreen extends StatelessWidget {
  const PatientDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppDimensions.radiusHeaderBottom),
          bottomRight: Radius.circular(AppDimensions.radiusHeaderBottom),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    LucideIcons.chevronLeft,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editPatient);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.pencil,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.moreVertical,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: const Center(
              child: Text(
                'JG',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Juan García',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '68 años - Padre',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.circle,
                  size: 8,
                  color: Color(0xFF6FCF97),
                ),
                SizedBox(width: 6),
                Text(
                  'En línea ahora',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingHorizontal,
      ) + const EdgeInsets.only(top: 20, bottom: 80),
      child: Column(
        children: [
          _buildStatsGrid(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
          const SizedBox(height: 20),
          _buildSectionHeader('Medicamentos'),
          const SizedBox(height: 12),
          _buildMedicationItem(
            iconBg: AppColors.primaryLight,
            iconFg: AppColors.primary,
            name: 'Losartan 50mg',
            dose: '1 pastilla - 8:00 AM',
            status: 'Tomada',
            statusType: _MedStatus.taken,
          ),
          _buildMedicationItem(
            iconBg: AppColors.accentLight,
            iconFg: AppColors.accent,
            name: 'Metformina 850mg',
            dose: '1 pastilla - 8:00 AM',
            status: 'Tomada',
            statusType: _MedStatus.taken,
          ),
          _buildMedicationItem(
            iconBg: AppColors.primaryLight,
            iconFg: AppColors.primary,
            name: 'Atorvastatina 20mg',
            dose: '1 pastilla - 8:00 PM',
            status: 'Pendiente',
            statusType: _MedStatus.pending,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatCard(
          icon: LucideIcons.checkCircle,
          iconBg: AppColors.accentLight,
          iconFg: AppColors.accent,
          value: '92%',
          label: 'Adherencia',
          valueColor: AppColors.accent,
        ),
        _StatCard(
          icon: LucideIcons.plusSquare,
          iconBg: AppColors.primaryLight,
          iconFg: AppColors.primary,
          value: '5',
          label: 'Medicamentos',
        ),
        _StatCard(
          icon: LucideIcons.clock,
          iconBg: AppColors.warningBg,
          iconFg: AppColors.warning,
          value: '3',
          label: 'Dosis hoy',
        ),
        _StatCard(
          icon: LucideIcons.alertTriangle,
          iconBg: AppColors.dangerBg,
          iconFg: AppColors.dangerDark,
          value: '1',
          label: 'Alertas',
          valueColor: AppColors.dangerDark,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _ActionCard(
          icon: LucideIcons.activity,
          iconBg: AppColors.primaryLight,
          iconFg: AppColors.primary,
          label: 'Ver historial',
          onTap: () {},
        ),
        _ActionCard(
          icon: LucideIcons.plus,
          iconBg: AppColors.accentLight,
          iconFg: AppColors.accent,
          label: 'Agregar medicamento',
          onTap: () {},
        ),
        _ActionCard(
          icon: LucideIcons.messageCircle,
          iconBg: AppColors.warningBg,
          iconFg: AppColors.warning,
          label: 'Enviar mensaje',
          onTap: () {},
        ),
        _ActionCard(
          icon: LucideIcons.alertTriangle,
          iconBg: AppColors.dangerBg,
          iconFg: AppColors.dangerDark,
          label: 'Alerta SOS',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const Text(
          'Ver todos',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem({
    required Color iconBg,
    required Color iconFg,
    required String name,
    required String dose,
    required String status,
    required _MedStatus statusType,
  }) {
    final isTaken = statusType == _MedStatus.taken;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(LucideIcons.pill, size: 20, color: iconFg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dose,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isTaken ? AppColors.accentLight : AppColors.warningBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isTaken ? AppColors.accent : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MedStatus { taken, pending }

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: iconFg),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String label;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppDimensions.cardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: iconFg),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
