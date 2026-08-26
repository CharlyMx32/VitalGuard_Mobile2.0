import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_header.dart';

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
  int _selectedDuration = 5;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('sos_enabled') ?? true;
      _vibrate = prefs.getBool('sos_vibrate') ?? true;
      _countdown = prefs.getBool('sos_countdown') ?? true;
      _shareLocation = prefs.getBool('sos_share_location') ?? true;
      _notifyAll = prefs.getBool('sos_notify_all') ?? true;
      _selectedDuration = prefs.getInt('sos_duration') ?? 5;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          VitalHeader.white(title: 'Configurar SOS'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingHorizontal) + const EdgeInsets.only(top: 16, bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildToggleRow('Activar botón SOS', _enabled, (v) { setState(() => _enabled = v); _saveBool('sos_enabled', v); }),
                  const SizedBox(height: 24),

                  _buildSectionHeader(LucideIcons.cpu, 'Dispositivo IoT', 'Configuración del botón físico'),
                  const SizedBox(height: 8),
                  _buildIoTSection(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(LucideIcons.smartphone, 'Pantalla de alarma', 'Comportamiento en tu dispositivo móvil'),
                  const SizedBox(height: 8),
                  _buildAlarmSection(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(LucideIcons.phone, 'Contacto de emergencia', 'Número que se marcará al presionar SOS'),
                  const SizedBox(height: 8),
                  _buildEmergencyPhone(),
                  const SizedBox(height: 24),

                  _buildSectionHeader(LucideIcons.users, 'Contactos de emergencia', 'Personas que recibirán la alerta'),
                  const SizedBox(height: 8),
                  _buildContacts(),
                  const SizedBox(height: 20),

                  _buildSectionHeader(LucideIcons.settings, 'Opciones avanzadas', ''),
                  const SizedBox(height: 8),
                  _buildAdvancedOptions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 16, color: AppColors.dangerDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIoTSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tiempo de pulsación del botón físico', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Cuánto tiempo mantener presionado el botón del VitalGuard para activar la alarma', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          const SizedBox(height: 12),
          _buildDurationOptions(),
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
          onTap: () { setState(() => _selectedDuration = o.value); _saveInt('sos_duration', o.value); },
          child: Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _selectedDuration == o.value ? AppColors.primaryLight : AppColors.bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _selectedDuration == o.value ? AppColors.primary : AppColors.borderLight, width: _selectedDuration == o.value ? 1.5 : 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${o.value}s', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _selectedDuration == o.value ? AppColors.primary : AppColors.textDark)),
                const SizedBox(height: 2),
                Text(o.label, style: const TextStyle(fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildAlarmSection() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          _buildToggleRow('Vibrar al pulsar', _vibrate, (v) { setState(() => _vibrate = v); _saveBool('sos_vibrate', v); }),
          Divider(height: 1, indent: 64, color: AppColors.borderLight),
          _buildToggleRow('Conteo regresivo visual', _countdown, (v) { setState(() => _countdown = v); _saveBool('sos_countdown', v); }),
        ],
      ),
    );
  }

  Widget _buildEmergencyPhone() {
    return GestureDetector(
      onTap: () async {
        final uri = Uri(scheme: 'tel', path: '911');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.dangerBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(LucideIcons.phone, size: 22, color: AppColors.dangerDark),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teléfono de emergencia', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  SizedBox(height: 2),
                  Text('Toca para llamar', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Text('911', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dangerDark)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.phoneCall, size: 18, color: AppColors.dangerDark),
          ],
        ),
      ),
    );
  }

  Widget _buildContacts() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14)),
            child: const Icon(LucideIcons.shield, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text('Sin cuidadores vinculados',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Los cuidadores registrados recibirán alertas SOS automáticamente.\nAgrega cuidadores desde la sección Pacientes.',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppDimensions.cardShadow),
      child: Column(
        children: [
          _buildToggleRow('Compartir ubicación', _shareLocation, (v) { setState(() => _shareLocation = v); _saveBool('sos_share_location', v); }),
          Divider(height: 1, indent: 64, color: AppColors.borderLight),
          _buildToggleRow('Notificar a todos los cuidadores', _notifyAll, (v) { setState(() => _notifyAll = v); _saveBool('sos_notify_all', v); }),
        ],
      ),
    );
  }

  Widget _buildToggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
}
