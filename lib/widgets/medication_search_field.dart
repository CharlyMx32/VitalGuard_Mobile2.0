import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../services/medication_service.dart';
import '../models/medication.dart';
import '../routes/app_routes.dart';

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
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.helpSupport),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(LucideIcons.info, size: 14, color: AppColors.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text.rich(
                const TextSpan(
                  text: 'No encontramos ese medicamento. ',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  children: [
                    TextSpan(
                      text:
                          'Contacta a tu medico o soporte para que lo agreguen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
