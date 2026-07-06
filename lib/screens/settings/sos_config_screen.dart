import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';

class SosConfigScreen extends StatefulWidget {
  const SosConfigScreen({super.key});

  @override
  State<SosConfigScreen> createState() => _SosConfigScreenState();
}

class _SosConfigScreenState extends State<SosConfigScreen> {
  bool _enabled = true;
  bool _vibrate = true;
  bool _countdown = true;
  bool _shareLocation = true;
  bool _notifyAll = true;
  int _selectedDuration = 1;

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
                  _buildToggleRow('Activar botón SOS', _enabled, (v) => setState(() => _enabled = v)),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Tiempo de pulsación'),
                  const SizedBox(height: 4),
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('Mantener presionado el botón físico del dispositivo para activar la alarma', style: TextStyle(fontSize: 11, color: AppColors.textMuted))),
                  const SizedBox(height: 8),
                  _buildDurationOptions(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Comportamiento de alarma'),
                  const SizedBox(height: 8),
                  _buildToggleGroup([
                    _SosToggle(LucideIcons.bell, AppColors.warningBg, AppColors.warning, 'Vibrar al mantener', 'Vibración de confirmación al pulsar', _vibrate, (v) => setState(() => _vibrate = v)),
                    _SosToggle(LucideIcons.clock, AppColors.accentLight, AppColors.primary, 'Conteo regresivo', 'Mostrar countdown antes de activar', _countdown, (v) => setState(() => _countdown = v)),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Contactos de emergencia'),
                  const SizedBox(height: 8),
                  _buildContacts(),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Opciones avanzadas'),
                  const SizedBox(height: 8),
                  _buildToggleGroup([
                    _SosToggle(LucideIcons.mapPin, AppColors.accentLight, AppColors.accent, 'Compartir ubicación', 'Enviar ubicación a contactos', _shareLocation, (v) => setState(() => _shareLocation = v)),
                    _SosToggle(LucideIcons.users, AppColors.accentLight, AppColors.primary, 'Notificar a todos los cuidadores', 'Alertar a cada cuidador', _notifyAll, (v) => setState(() => _notifyAll = v)),
                    _SosToggle(LucideIcons.phone, AppColors.dangerBg, AppColors.dangerDark, 'Teléfono de emergencia', '', false, null, valueWidget: const Text('911', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dangerDark))),
                  ]),
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
            child: Text('Configurar SOS', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: const EdgeInsets.only(left: 4), child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)));
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark))),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 48, height: 28,
              decoration: BoxDecoration(color: value ? AppColors.primary : AppColors.borderLight, borderRadius: BorderRadius.circular(14)),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOptions() {
    final options = [
      (value: 3, label: 'Rápido'),
      (value: 5, label: 'Normal'),
      (value: 8, label: 'Largo'),
      (value: 10, label: 'Muy largo'),
    ];
    return Row(
      children: options.map((o) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedDuration = o.value),
          child: Container(
            height: 48,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _selectedDuration == o.value ? AppColors.accentLight : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedDuration == o.value ? AppColors.primary : AppColors.borderLight),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${o.value}s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _selectedDuration == o.value ? AppColors.primary : AppColors.textDark)),
                Text(o.label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildToggleGroup(List<_SosToggle> items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) return const Divider(height: 1, indent: 64, color: AppColors.borderLight);
          final t = items[i ~/ 2];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: t.iconBg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(t.icon, size: 18, color: t.iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: t.desc.isNotEmpty
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(t.desc, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ])
                    : Text(t.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                ),
                if (t.valueWidget != null)
                  t.valueWidget!
                else if (t.onChanged != null)
                  GestureDetector(
                    onTap: () => t.onChanged!(!t.value),
                    child: Container(
                      width: 48, height: 28,
                      decoration: BoxDecoration(color: t.value ? AppColors.primary : AppColors.borderLight, borderRadius: BorderRadius.circular(14)),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: t.value ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(width: 22, height: 22, margin: const EdgeInsets.symmetric(horizontal: 3), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3)])),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContacts() {
    final contacts = [
      (name: 'María García', role: 'Hija - Cuidadora principal', initials: 'MG', color: AppColors.primary),
      (name: 'Carlos García', role: 'Hijo', initials: 'CG', color: AppColors.accent),
      (name: 'Dr. Martínez', role: 'Médico tratante', initials: 'DM', color: const Color(0xFF9B59B6)),
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          ...contacts.map((c) => Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
                  child: Text(c.initials, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                    Text(c.role, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ]),
                ),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.check, size: 16, color: AppColors.accent),
                ),
              ],
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Container(
              width: double.infinity, height: 44,
              decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight, width: 1.5), borderRadius: BorderRadius.circular(16)),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(LucideIcons.plus, size: 16, color: AppColors.textDark),
                SizedBox(width: 8),
                Text('Agregar contacto', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textDark)),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SosToggle {
  final IconData icon;
  final Color iconBg, iconFg;
  final String label, desc;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? valueWidget;
  const _SosToggle(this.icon, this.iconBg, this.iconFg, this.label, this.desc, this.value, this.onChanged, {this.valueWidget});
}
