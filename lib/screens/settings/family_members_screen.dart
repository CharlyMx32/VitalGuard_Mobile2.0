import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

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
                  _buildMemberCard('MG', 'María García', 'Cuidadora principal', AppColors.primary),
                  const SizedBox(height: 12),
                  _buildMemberCard('CG', 'Carlos García', 'Hijo', AppColors.accent),
                  const SizedBox(height: 12),
                  _buildMemberCard('AG', 'Ana García', 'Hija', const Color(0xFF9B59B6)),
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
            child: Text('Cuidadores', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
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
          child: const Text('3', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _buildMemberCard(String initials, String name, String role, Color gradientStart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [gradientStart, AppColors.accent]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(initials, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              ],
            ),
          ),
          const Icon(LucideIcons.moreVertical, size: 20, color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      width: double.infinity, height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(LucideIcons.plus, size: 18, color: AppColors.primary),
        SizedBox(width: 8),
        Text('Agregar cuidador', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
      ]),
    );
  }
}
