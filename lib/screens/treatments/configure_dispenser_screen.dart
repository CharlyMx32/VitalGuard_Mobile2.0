import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';

class ConfigureDispenserScreen extends StatelessWidget {
  const ConfigureDispenserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDispenserVisual(),
                  const SizedBox(height: 16),
                  _buildSectionHeader('Compartimentos', '4 de 5 asignados'),
                  const SizedBox(height: 8),
                  _buildCompartmentCard(context, 1, 'Losartan 50mg', '1 pastilla - 8:00 AM', true),
                  const SizedBox(height: 8),
                  _buildCompartmentCard(context, 2, 'Metformina 850mg', '1 pastilla - 12:00 PM', true),
                  const SizedBox(height: 8),
                  _buildCompartmentCard(context, 3, 'Atorvastatina 20mg', '1 pastilla - 8:00 PM', true),
                  const SizedBox(height: 8),
                  _buildCompartmentCard(context, 4, 'AAS 100mg', '1 pastilla - 8:00 AM', true),
                  const SizedBox(height: 8),
                  _buildCompartmentCard(context, 5, 'Sin asignar', '', false),
                  const SizedBox(height: 16),
                  _buildTipsCard(),
                  const SizedBox(height: 16),
                  _buildAddButton(context),
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
            child: Text('Configurar Pastillero', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildDispenserVisual() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.87, -0.50),
          end: Alignment(-0.87, 0.50),
          colors: [Color(0xFFE8F0FE), Color(0xFFF8FAFC)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 140, height: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment(-0.5, -0.5),
                end: Alignment(0.5, 0.5),
                colors: [Colors.white, Color(0xFFE8E8E8)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildCompartmentBox(true),
                      const SizedBox(width: 4),
                      _buildCompartmentBox(true),
                      const SizedBox(width: 4),
                      _buildCompartmentBox(true),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Row(
                    children: [
                      _buildCompartmentBox(true),
                      const SizedBox(width: 4),
                      _buildCompartmentBox(false),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ConnectedDot(),
              SizedBox(width: 8),
              Text('VitalGuard conectado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompartmentBox(bool filled) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: filled ? AppColors.primary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            filled ? '' : '',
            style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: filled ? Colors.white : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 2),
        Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildCompartmentCard(BuildContext context, int number, String name, String detail, bool assigned) {
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
            decoration: BoxDecoration(
              color: assigned ? AppColors.primary : AppColors.borderLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text('$number', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: assigned ? Colors.white : AppColors.textMuted,
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: assigned ? AppColors.textDark : AppColors.textMuted,
                )),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(detail, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: assigned ? AppColors.bg : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                assigned ? 'Editar' : 'Asignar',
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: assigned ? AppColors.textMuted : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      'Asigna los medicamentos que se toman en la misma hora al mismo compartimento.',
      'Revisa que la cantidad de pastillas sea suficiente antes de programar.',
      'Puedes cambiar la asignación en cualquier momento.',
    ];

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
                width: 32, height: 32,
                decoration: BoxDecoration(color: const Color(0xFFFEF7E0), borderRadius: BorderRadius.circular(8)),
                child: const Icon(LucideIcons.info, size: 16, color: Color(0xFFB78F00)),
              ),
              const SizedBox(width: 10),
              const Text('Consejos', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4, height: 4,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(color: Color(0xFFB78F00), shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tip, style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return SizedBox(
      width: double.infinity, height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scheduleConfig),
        icon: const Icon(LucideIcons.plus, size: 18),
        label: const Text('Agregar medicamento', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }
}

class _ConnectedDot extends StatelessWidget {
  const _ConnectedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8, height: 8,
      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
    );
  }
}
