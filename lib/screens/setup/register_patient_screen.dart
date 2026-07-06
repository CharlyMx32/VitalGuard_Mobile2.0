import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_colors.dart';


class RegisterPatientScreen extends StatelessWidget {
  const RegisterPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24) + const EdgeInsets.only(top: 24),
              child: Column(
                children: [
                  _buildAvatar(),
                  const SizedBox(height: 16),
                  const Text('Datos del paciente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  const Text('Completa la información médica del paciente',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  const SizedBox(height: 24),
                  _buildForm(),
                ],
              ),
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 12, left: 16, right: 16, bottom: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.of(context).pop(), child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.primary))),
        const SizedBox(width: 32),
      ]),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 72, height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.accentLight,
        border: Border.all(color: AppColors.primary, width: 3),
      ),
      child: const Icon(LucideIcons.user, size: 36, color: AppColors.primary),
    );
  }

  Widget _buildForm() {
    return Column(children: [
      _buildField('Nombre completo', 'Nombre y apellidos'),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _buildField('Fecha nacimiento', 'DD/MM/AAAA')),
        const SizedBox(width: 12),
        Expanded(child: _buildSelectField('Género', ['Masculino', 'Femenino', 'Otro'])),
      ]),
      const SizedBox(height: 14),
      _buildSelectField('Tipo de sangre (opcional)', ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']),
      const SizedBox(height: 14),
      _buildField('Alergias conocidas (opcional)', 'Ej: Penicilina, Ibuprofeno'),
      const SizedBox(height: 14),
      _buildTextArea('Notas médicas (opcional)', 'Enfermedades crónicas, tratamientos actuales, notas importantes...'),
    ]);
  }

  Widget _buildField(String label, String placeholder) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: TextField(decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(horizontal: 14), hintText: placeholder, hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14))),
      ),
    ]);
  }

  Widget _buildSelectField(String label, List<String> options) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 48,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: const Row(children: [
          SizedBox(width: 14),
          Expanded(child: Text('Seleccionar', style: TextStyle(fontSize: 14, color: AppColors.textMuted))),
          Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
          SizedBox(width: 14),
        ]),
      ),
    ]);
  }

  Widget _buildTextArea(String label, String placeholder) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5)),
      const SizedBox(height: 5),
      Container(
        height: 80,
        decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
        child: Padding(padding: const EdgeInsets.all(12), child: Text(placeholder, style: const TextStyle(fontSize: 14, color: AppColors.textMuted))),
      ),
    ]);
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(children: [
        Container(
          width: double.infinity, height: 48,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Text('Guardar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white))),
        ),
        const SizedBox(height: 12),
        const Text('Completar después', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ]),
    );
  }
}
