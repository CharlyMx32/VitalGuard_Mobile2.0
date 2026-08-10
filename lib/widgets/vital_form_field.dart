import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

typedef ValidatorFn = String? Function(String? value);

enum VitalInputType { text, phone, dropdown, date }

class VitalFormField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final ValidatorFn? validator;
  final ValueChanged<String>? onChanged;
  final String? hint;
  final VitalInputType inputType;
  final bool required;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? displayValue;
  final Widget? dropdownIcon;

  const VitalFormField({
    super.key,
    required this.label,
    this.controller,
    this.validator,
    this.onChanged,
    this.hint,
    this.inputType = VitalInputType.text,
    this.required = false,
    this.maxLength,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.displayValue,
    this.dropdownIcon,
  });

  @override
  State<VitalFormField> createState() => _VitalFormFieldState();
}

class _VitalFormFieldState extends State<VitalFormField> {
  final FocusNode _focusNode = FocusNode();
  String? _errorText;
  bool _hasInteracted = false;

  // ══════════════════════════════════════════════════════════════
  //  GLOW — Personaliza aquí los valores del efecto de iluminación
  // ══════════════════════════════════════════════════════════════
  static const double _glowBlur = 8.0;
  static const double _glowSpread = 0.0;
  static const double _glowOpacity = 0.35;
  // ══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    if (widget.controller != null && widget.controller!.text.isNotEmpty) {
      _hasInteracted = true;
      _validate();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VitalFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.displayValue != oldWidget.displayValue &&
        widget.inputType == VitalInputType.dropdown) {
      _hasInteracted = true;
      _validate();
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && !_hasInteracted) {
      _hasInteracted = true;
      _validate();
    }
    if (mounted) setState(() {});
  }

  String? get _currentValue {
    if (widget.inputType == VitalInputType.dropdown) return widget.displayValue;
    return widget.controller?.text;
  }

  bool get _isEmpty {
    final v = _currentValue;
    return v == null || v.trim().isEmpty;
  }

  bool get _isValid {
    if (widget.validator == null) return false;
    return widget.validator!(_currentValue) == null;
  }

  bool get _showSuccess => _hasInteracted && !_isEmpty && _isValid;
  bool get _showError => _hasInteracted && !_isEmpty && !_isValid;
  bool get _isFocused => _focusNode.hasFocus;

  Color get _borderColor {
    if (_showError) return AppColors.danger;
    if (_showSuccess) return AppColors.accent;
    if (_isFocused) return AppColors.primary;
    return AppColors.borderLight;
  }

  Color get _glowColor => _borderColor.withValues(alpha: _glowOpacity);

  void _validate() {
    if (widget.validator == null) return;
    final error = widget.validator!(_currentValue);
    if (mounted) {
      setState(() {
        _hasInteracted = true;
        _errorText = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(),
        const SizedBox(height: 5),
        _buildInput(),
        if (_showError && _errorText != null) _buildError(),
      ],
    );
  }

  Widget _buildLabel() {
    return Row(
      children: [
        Text(
          widget.label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
            letterSpacing: 0.5,
          ),
        ),
        if (_showSuccess) ...[
          const SizedBox(width: 6),
          const Icon(LucideIcons.check, size: 12, color: AppColors.accent),
        ],
        if (_showError) ...[
          const SizedBox(width: 6),
          const Icon(LucideIcons.x, size: 12, color: AppColors.danger),
        ],
      ],
    );
  }

  Widget _buildInput() {
    switch (widget.inputType) {
      case VitalInputType.phone:
        return _buildPhoneInput();
      case VitalInputType.dropdown:
        return _buildDropdownInput();
      case VitalInputType.date:
        return _buildDateInput();
      case VitalInputType.text:
        return _buildTextInput();
    }
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _borderColor, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: _glowColor,
          blurRadius: _glowBlur,
          spreadRadius: _glowSpread,
        ),
      ],
    );
  }

  /// Decoration vacía — el TextField NO dibuja ningún borde propio
  static const _noBorder = UnderlineInputBorder(borderSide: BorderSide.none);

  /// Padding vertical exacto para centrar texto en Container de 48px
  /// con font size 14 (~20px de alto de línea). Ajusta si cambias font size.
  static const _centerPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 13);

  Widget _buildTextInput() {
    return Container(
      height: 48,
      decoration: _boxDecoration(),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: (v) {
          widget.onChanged?.call(v);
          _validate();
        },
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        maxLength: widget.maxLength,
        buildCounter: null,
        textAlignVertical: TextAlignVertical.center,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          border: _noBorder,
          enabledBorder: _noBorder,
          focusedBorder: _noBorder,
          disabledBorder: _noBorder,
          errorBorder: _noBorder,
          focusedErrorBorder: _noBorder,
          isDense: true,
          contentPadding: _centerPadding,
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          suffixIcon: _buildSuffixIcon(),
          filled: false,
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    final digits = (_currentValue ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final count = digits.length;
    final complete = count == 10;

    return Container(
      height: 48,
      decoration: _boxDecoration(),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (v) {
                widget.onChanged?.call(v);
                _validate();
              },
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: const InputDecoration(
                border: _noBorder,
                enabledBorder: _noBorder,
                focusedBorder: _noBorder,
                disabledBorder: _noBorder,
                errorBorder: _noBorder,
                focusedErrorBorder: _noBorder,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: '10 dígitos',
                hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
                filled: false,
              ),
            ),
          ),
          if (count > 0) ...[
            Text(
              '$count/10',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: complete ? AppColors.accent : AppColors.danger,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              complete ? LucideIcons.checkCircle : LucideIcons.alertCircle,
              size: 16,
              color: complete ? AppColors.accent : AppColors.danger,
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdownInput() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 48,
        decoration: _boxDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.displayValue ?? widget.hint ?? 'Seleccionar',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.displayValue != null ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ),
            widget.dropdownIcon ??
                const Icon(LucideIcons.chevronDown, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInput() {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 48,
        decoration: _boxDecoration(),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.displayValue ?? widget.hint ?? 'DD/MM/AAAA',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.displayValue != null ? AppColors.textDark : AppColors.textMuted,
                ),
              ),
            ),
            Icon(
              widget.displayValue != null
                  ? (_showSuccess
                      ? LucideIcons.checkCircle
                      : (_showError ? LucideIcons.alertCircle : LucideIcons.calendar))
                  : LucideIcons.calendar,
              size: 16,
              color: widget.displayValue == null
                  ? AppColors.textMuted
                  : (_showSuccess ? AppColors.accent : AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    final v = _currentValue;
    if (v == null || v.isEmpty) return null;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(
        _showSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle,
        size: 16,
        color: _showSuccess ? AppColors.accent : AppColors.danger,
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Text(
        _errorText!,
        style: const TextStyle(fontSize: 10, color: AppColors.danger),
      ),
    );
  }
}
