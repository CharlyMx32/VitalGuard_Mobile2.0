import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/patient_current_service.dart';

class PatientSelectorHeader extends StatelessWidget {
  final bool showSelector;
  const PatientSelectorHeader({super.key, this.showSelector = true});

  @override
  Widget build(BuildContext context) {
    final svc = context.watch<PatientCurrentService>();
    final current = svc.current;
    if (current == null) return const SizedBox.shrink();
    if (!showSelector || !svc.hasMultiple) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(current.initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(current.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => _showPatientPicker(context, svc),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(current.initials, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(current.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  Text('${svc.patients.length} pacientes', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  void _showPatientPicker(BuildContext context, PatientCurrentService svc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Seleccionar paciente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            ),
            const SizedBox(height: 8),
            ...svc.patients.map((p) => ListTile(
              leading: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Color.lerp(AppColors.primary, AppColors.accent, p.id % 5 / 5)!,
                    Color.lerp(AppColors.accent, AppColors.primary, p.id % 5 / 5)!,
                  ]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(p.initials, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              title: Text(p.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              trailing: svc.current?.id == p.id
                  ? const Icon(LucideIcons.check, size: 18, color: AppColors.primary)
                  : null,
              onTap: () {
                svc.selectPatient(p);
                Navigator.pop(ctx);
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
