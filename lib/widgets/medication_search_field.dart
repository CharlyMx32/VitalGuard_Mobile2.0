import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/medication_service.dart';
import '../services/patient_service.dart';
import '../services/patient_current_service.dart';
import '../services/auth_service.dart';
import '../models/medication.dart';
import '../models/patient.dart';
import '../widgets/vital_modal.dart';
import '../widgets/vital_button.dart';
import '../widgets/vital_form_field.dart';

class MedicationSearchField extends StatefulWidget {
  final ValueChanged<Medication> onSelected;
  const MedicationSearchField({super.key, required this.onSelected});

  @override
  State<MedicationSearchField> createState() => _MedicationSearchFieldState();
}

class _MedicationSearchFieldState extends State<MedicationSearchField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<Medication> _allMedications = [];
  List<Medication> _filtered = [];
  bool _loading = false;
  bool _showAll = false;
  Medication? _selected;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    _loadAll();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && _selected == null) {
      setState(() => _showAll = true);
    }
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    final medicationService = context.read<MedicationService>();
    _allMedications = await medicationService.getMedications();
    _filtered = _allMedications;
    if (mounted) setState(() => _loading = false);
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      final q = value.trim().toLowerCase();
      setState(() {
        _showAll = true;
        if (q.isEmpty) {
          _filtered = _allMedications;
        } else {
          _filtered = _allMedications
              .where(
                (m) =>
                    m.name.toLowerCase().contains(q) ||
                    (m.presentation?.toLowerCase().contains(q) ?? false),
              )
              .toList();
        }
      });
    });
  }

  void _select(Medication med) {
    setState(() {
      _selected = med;
      _controller.text = med.name;
      _showAll = false;
    });
    _focusNode.unfocus();
    widget.onSelected(med);
  }

  void _clearSelection() {
    setState(() {
      _selected = null;
      _controller.clear();
      _filtered = _allMedications;
      _showAll = true;
    });
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onChanged,
          readOnly: _selected != null,
          onTap: () {
            if (_selected == null) setState(() => _showAll = true);
          },
          decoration: InputDecoration(
            hintText: 'Buscar medicamento...',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              LucideIcons.search,
              size: 16,
              color: AppColors.textMuted,
            ),
            suffixIcon: _selected != null
                ? GestureDetector(
                    onTap: _clearSelection,
                    child: const Icon(
                      LucideIcons.x,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        if (_selected != null) ...[
          const SizedBox(height: 8),
          _buildSelectedCard(),
        ],
        if (_loading) ...[
          const SizedBox(height: 12),
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
        if (_showAll && _selected == null && !_loading) ...[
          const SizedBox(height: 8),
          if (_filtered.isNotEmpty) _buildResultsList(),
          if (_filtered.isEmpty && _controller.text.isNotEmpty)
            _buildNotFoundCard(),
        ],
      ],
    );
  }

  Widget _buildSelectedCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.checkCircle,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selected!.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          Text(
            _selected!.presentation ?? '',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _filtered.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 56),
        itemBuilder: (context, index) {
          final med = _filtered[index];
          return InkWell(
            onTap: () => _select(med),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.pill,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        if (med.presentation != null)
                          Text(
                            med.presentation!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const Icon(
                    LucideIcons.chevronRight,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotFoundCard() {
    final query = _controller.text.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.info, size: 14, color: AppColors.warning),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No encontramos "$query" en el catálogo.',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Puedes solicitarlo y se enviará a tu médico vinculado. Si no tienes médico, la solicitud irá al administrador.',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openRequestSheet(query),
              icon: const Icon(LucideIcons.send, size: 14, color: AppColors.warning),
              label: const Text('Solicitar medicamento', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.warning),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openRequestSheet(String initialName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: _MedicationRequestSheet(initialName: initialName),
      ),
    );
  }
}

class _MedicationRequestSheet extends StatefulWidget {
  final String initialName;
  const _MedicationRequestSheet({required this.initialName});

  @override
  State<_MedicationRequestSheet> createState() => _MedicationRequestSheetState();
}

class _MedicationRequestSheetState extends State<_MedicationRequestSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _presentationController;
  Patient? _selectedPatient;
  List<Patient> _patients = [];
  bool _loadingPatients = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _presentationController = TextEditingController();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    try {
      final patientService = context.read<PatientService>();
      final patientCurrent = context.read<PatientCurrentService>();
      final auth = context.read<AuthService>();
      final patients = await patientService.getPatients();
      if (!mounted) return;
      setState(() {
        _patients = patients;
        _loadingPatients = false;
        // Preselecciona el paciente actual si existe
        final pid = patientCurrent.patientId ?? auth.patientId;
        if (pid != null) {
          _selectedPatient = patients.where((p) => p.id == pid).firstOrNull ?? (patients.isNotEmpty ? patients.first : null);
        } else if (patients.isNotEmpty) {
          _selectedPatient = patients.first;
        }
      });
    } catch (_) {
      if (mounted) setState(() => _loadingPatients = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _presentationController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa el nombre del medicamento'), backgroundColor: AppColors.warning));
      return;
    }
    if (_selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un paciente'), backgroundColor: AppColors.warning));
      return;
    }
    setState(() => _sending = true);
    try {
      final svc = context.read<MedicationService>();
      final res = await svc.requestMedication(
        patientId: _selectedPatient!.id,
        medicationName: name,
        presentation: _presentationController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      // Mensaje varía según si se asignó a médico o admin (backend decide)
      final assignedTo = res['assignedTo'] ?? res['recipient'] ?? 'tu médico';
      final isAdmin = res['assignedToRole'] == 'ADMIN' || res['isAdmin'] == true;
      VitalFeedback.success(
        context,
        code: 'MEDICATION_REQUESTED',
        message: isAdmin
            ? 'Solicitud enviada al administrador. Te notificaremos cuando el medicamento esté disponible.'
            : 'Solicitud enviada a $assignedTo. Te avisaremos cuando sea aprobada.',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.danger));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Solicitar medicamento', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 4),
          const Text('Si no lo encuentras en el catálogo, lo solicitamos por ti.', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
          const SizedBox(height: 16),
          if (_loadingPatients)
            const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
          else ...[
            const Text('Paciente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderLight)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _selectedPatient?.id,
                  hint: const Text('Seleccionar paciente', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  items: _patients.map((p) => DropdownMenuItem(value: p.id, child: Text(p.fullName, style: const TextStyle(fontSize: 13, color: AppColors.textDark)))).toList(),
                  onChanged: (id) => setState(() => _selectedPatient = _patients.firstWhere((p) => p.id == id)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          VitalFormField(label: 'Nombre del medicamento', controller: _nameController, hint: 'Ej: Montelukast'),
          const SizedBox(height: 12),
          VitalFormField(label: 'Presentación (opcional)', controller: _presentationController, hint: 'Ej: Tableta 10mg, Jarabe 5ml'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              const Expanded(child: Text('Se enviará a tu médico vinculado. Si no tienes médico, la solicitud irá al administrador.', style: TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 20),
          VitalButton(label: 'Enviar solicitud', isLoading: _sending, onPressed: _sending ? null : _send),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: AppColors.textMuted))),
          ),
        ],
      ),
    );
  }
}
