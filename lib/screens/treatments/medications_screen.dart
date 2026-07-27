import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../routes/app_routes.dart';

/// Standalone screen with back button (for sub-navigation)
class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: const MedicationsContent(),
    );
  }
}

/// Content-only widget for MainShell (no Scaffold, no back button)
class MedicationsContent extends StatefulWidget {
  const MedicationsContent({super.key});

  @override
  State<MedicationsContent> createState() => _MedicationsContentState();
}

class _MedicationsContentState extends State<MedicationsContent> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bg,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilterTabs(),
                  const SizedBox(height: 12),
                  _buildMedCard(
                    iconBg: AppColors.primaryLight,
                    iconFg: AppColors.primary,
                    icon: LucideIcons.rectangleVertical,
                    name: 'Losartan',
                    generic: 'Potásico 50mg',
                    details: [
                      ('Dosis', '1 pastilla'),
                      ('Frecuencia', 'Cada 2 días'),
                      ('Compartimento', '#1 - Mañana'),
                    ],
                    schedule: ['8:00 AM'],
                  ),
                  const SizedBox(height: 8),
                  _buildMedCard(
                    iconBg: AppColors.accentLight,
                    iconFg: AppColors.accent,
                    icon: LucideIcons.checkCircle,
                    name: 'Metformina',
                    generic: 'Clorhidrato 850mg',
                    details: [
                      ('Dosis', '1 pastilla'),
                      ('Frecuencia', 'Cada 2 días'),
                      ('Compartimento', '#2 - Almuerzo'),
                    ],
                    schedule: ['12:00 PM', '8:00 PM'],
                  ),
                  const SizedBox(height: 8),
                  _buildMedCard(
                    iconBg: const Color(0xFFF3E8FF),
                    iconFg: const Color(0xFF9B59B6),
                    icon: LucideIcons.heart,
                    name: 'Atorvastatina',
                    generic: 'Cálcica 20mg',
                    details: [
                      ('Dosis', '1 pastilla'),
                      ('Frecuencia', 'Cada 2 días'),
                      ('Compartimento', '#3 - Noche'),
                    ],
                    schedule: ['8:00 PM'],
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          // No back button when in main shell - just a spacer
          const SizedBox(width: 32),
          const Expanded(
            child: Text('Mis Medicamentos', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.scheduleConfig),
            child: Container(
              width: 32, height: 32,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['Todos (5)', 'Activos (4)', 'Pausados (1)'];
    return Row(
      children: List.generate(tabs.length, (i) {
        final isActive = _selectedFilter == i;
        return Padding(
          padding: EdgeInsets.only(right: i < tabs.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppColors.primary : AppColors.borderLight),
              ),
              child: Text(tabs[i], style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textSecondary,
              )),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMedCard({
    required Color iconBg,
    required Color iconFg,
    required IconData icon,
    required String name,
    required String generic,
    required List<(String, String)> details,
    required List<String> schedule,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDimensions.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, size: 22, color: iconFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    const SizedBox(height: 2),
                    Text(generic, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(LucideIcons.moreVertical, size: 16, color: AppColors.textMuted),
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
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(d.$1, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text(d.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: schedule.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
              child: Text(s, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5))),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Medicamento pausado'), backgroundColor: AppColors.warning),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: AppColors.bg,
                        foregroundColor: AppColors.textDark,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Pausar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scheduleConfig),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text('Editar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
