import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class MyVitalGuardScreen extends StatelessWidget {
  const MyVitalGuardScreen({super.key});

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
                children: [
                  _buildDeviceVisual(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Información del dispositivo'),
                  const SizedBox(height: 8),
                  _buildInfoGroup(),
                  const SizedBox(height: 20),
                  _buildWiFiStatus(context),
                  const SizedBox(height: 20),
                  _buildButton('Sincronizar ahora', AppColors.primary, Colors.white),
                  const SizedBox(height: 12),
                  _buildButton('Desconectar dispositivo', Colors.white, AppColors.textDark, border: true),
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
          const Expanded(child: Text('Mi VitalGuard', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildDeviceVisual() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.accentLight, AppColors.bg]), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, Color(0xFF3A7BD5)]), borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 8))]),
            child: const Icon(LucideIcons.box, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              const Text('Sin dispositivo vinculado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Conecta tu VitalGuard para ver la información', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildInfoGroup() {
    final items = [
      ('Estado', '---', null),
      ('Firmware', '---', null),
      ('Número de serie', '---', null),
      ('Última sincronización', '---', null),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 16, color: AppColors.borderLight);
          final item = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                const Spacer(),
                Text(item.$2, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w400)),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWiFiStatus(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10)), child: const Icon(LucideIcons.wifi, size: 18, color: AppColors.textMuted)),
          const SizedBox(width: 12),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('WiFi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
            SizedBox(height: 2),
            Text('No conectado', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ])),
          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.textMuted, shape: BoxShape.circle)),
        ],
      ),
    );
  }

  Widget _buildButton(String label, Color bg, Color fg, {bool border = false}) {
    return Container(
      width: double.infinity, height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border ? Border.all(color: AppColors.borderLight) : null),
      child: Center(child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg))),
    );
  }
}
