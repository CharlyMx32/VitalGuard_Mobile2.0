import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_colors.dart';

/// Barra de búsqueda reutilizable con borde reactivo y glow.
///
/// ```dart
/// VitalSearchBar(
///   controller: searchCtrl,
///   hint: 'Buscar paciente...',
///   onChanged: _filter,
/// )
/// ```
class VitalSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const VitalSearchBar({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  State<VitalSearchBar> createState() => _VitalSearchBarState();
}

class _VitalSearchBarState extends State<VitalSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  // ══════════════════════════════════════════════════════════════
  //  GLOW — Mismos valores que VitalFormField (ajusta si quieres)
  // ══════════════════════════════════════════════════════════════
  static const double _glowBlur = 8.0;
  static const double _glowSpread = 0.0;
  static const double _glowOpacity = 0.25;
  // ══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller?.addListener(_onTextChange);
    _hasText = (widget.controller?.text ?? '').isNotEmpty;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller?.removeListener(_onTextChange);
    super.dispose();
  }

  void _onTextChange() {
    final hasNow = (widget.controller?.text ?? '').isNotEmpty;
    if (hasNow != _hasText) setState(() => _hasText = hasNow);
  }

  Color get _borderColor => _focusNode.hasFocus ? AppColors.primary : AppColors.borderLight;
  Color get _glowColor => AppColors.primary.withValues(alpha: _focusNode.hasFocus ? _glowOpacity : 0.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: _focusNode.hasFocus ? 1.2 : 1),
        boxShadow: [
          BoxShadow(
            color: _glowColor,
            blurRadius: _glowBlur,
            spreadRadius: _glowSpread,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            LucideIcons.search,
            size: 18,
            color: _focusNode.hasFocus ? AppColors.primary : AppColors.textLight,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              onChanged: widget.onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: InputDecoration(
                hintText: widget.hint ?? 'Buscar...',
                hintStyle: const TextStyle(fontSize: 14, color: AppColors.textPlaceholder),
                border: const UnderlineInputBorder(borderSide: BorderSide.none),
                enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 13),
                filled: false,
                suffixIcon: _hasText
                    ? GestureDetector(
                        onTap: () {
                          widget.controller?.clear();
                          widget.onChanged?.call('');
                          widget.onClear?.call();
                        },
                        child: const Icon(LucideIcons.x, size: 16, color: AppColors.textMuted),
                      )
                    : null,
              ),
            ),
          ),
          if (_hasText) const SizedBox(width: 4),
        ],
      ),
    );
  }
}
