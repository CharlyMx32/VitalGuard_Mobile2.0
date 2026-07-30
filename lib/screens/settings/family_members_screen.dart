import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_empty_state.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(),
                  const SizedBox(height: 8),
                  const VitalEmptyState(
                    icon: LucideIcons.users,
                    title: 'Sin cuidadores',
                    description: 'No hay cuidadores vinculados.\nAgrega un cuidador para compartir la gestión.',
                  ),
                  const SizedBox(height: 20),
                  _buildAddButton(),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text('Al agregar un cuidador, se enviará una solicitud de vinculación',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
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
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark))),
          const Expanded(child: Text('Cuidadores', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Text('Vinculados', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
          child: const Text('0', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity, height: 48,
      decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight, width: 1.5), borderRadius: BorderRadius.circular(16)),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
        SizedBox(width: 8),
        Text('Agregar cuidador', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    );
  }
}
