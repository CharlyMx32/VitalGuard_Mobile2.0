import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../data/avatar_data.dart';
import '../../services/avatar_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../widgets/vital_avatar.dart';
import '../../widgets/vital_tap.dart';

class AvatarPickerScreen extends StatefulWidget {
  const AvatarPickerScreen({super.key});

  @override
  State<AvatarPickerScreen> createState() => _AvatarPickerScreenState();
}

class _AvatarPickerScreenState extends State<AvatarPickerScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  AvatarStyle _selectedStyle = AvatarStyle.personas;
  String? _selectedSeed;
  final Map<AvatarStyle, List<String>> _seedsByStyle = {};
  bool _isSaving = false;
  final TextEditingController _devSeedController = TextEditingController();
  String _devSeed = '';
  late AvatarConfig _savedConfig;

  @override
  void initState() {
    super.initState();
    final avatarService = context.read<AvatarService>();
    _savedConfig = avatarService.config;
    final currentStyle = avatarService.style;
    final currentIndex = AvatarStyle.values.indexOf(currentStyle);
    _selectedStyle = currentStyle;
    _selectedSeed = avatarService.seed;
    _tabController = TabController(length: AvatarStyle.values.length, vsync: this, initialIndex: currentIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {
          _selectedStyle = AvatarStyle.values[_tabController.index];
        });
        _ensureSeeds(_selectedStyle);
      }
    });
    for (final style in AvatarStyle.values) {
      _ensureSeeds(style);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _devSeedController.dispose();
    super.dispose();
  }

  void _ensureSeeds(AvatarStyle style) {
    if (!_seedsByStyle.containsKey(style)) {
      _seedsByStyle[style] = generateSeeds(12);
    }
  }

  void _generateMore() {
    final current = _seedsByStyle[_selectedStyle]!;
    final additional = generateSeeds(12);
    setState(() {
      _seedsByStyle[_selectedStyle] = [...current, ...additional];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          _buildDebugInput(),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildGrid(),
            ),
          ),
          _buildBottomBar(context),
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
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(width: 32, height: 32, child: Icon(LucideIcons.chevronLeft, size: 18, color: AppColors.textDark)),
          ),
          const Expanded(child: Text('Selecciona tu avatar', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark))),
          Hero(
            tag: 'avatar_hero',
            child: VitalAvatar(style: _savedConfig.style, seed: _savedConfig.seed, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onTap: (i) => setState(() => _selectedStyle = AvatarStyle.values[i]),
        tabs: AvatarStyle.values.map((s) => Tab(text: s.label)).toList(),
      ),
    );
  }

  Widget _buildDebugInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: _devSeedController,
                onChanged: (v) => setState(() => _devSeed = v),
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                decoration: InputDecoration(
                  hintText: 'Seed manual (debug)',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  filled: true, fillColor: AppColors.bg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                  isDense: true,
                ),
              ),
            ),
          ),
          if (_devSeed.isNotEmpty) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedSeed = _devSeed);
              },
              child: VitalAvatar(style: _selectedStyle, seed: _devSeed, size: 32),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final seeds = _seedsByStyle[_selectedStyle];
    if (seeds == null || seeds.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      key: ValueKey('grid_${_selectedStyle.name}_${seeds.length}'),
      padding: const EdgeInsets.all(AppDimensions.paddingHorizontal) + const EdgeInsets.only(bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: seeds.length,
      itemBuilder: (context, index) => _AvatarGridItem(
        style: _selectedStyle,
        seed: seeds[index],
        isSelected: seeds[index] == _selectedSeed,
        isSaved: _savedConfig.style == _selectedStyle && _savedConfig.seed == seeds[index],
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedSeed = seeds[index]);
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: AppDimensions.cardShadow),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: _generateMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.borderLight),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Generar más', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _selectedSeed != null ? () => _save(context) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Guardar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (_selectedSeed == null) return;
    setState(() => _isSaving = true);
    final avatarService = context.read<AvatarService>();
    await avatarService.save(AvatarConfig(style: _selectedStyle, seed: _selectedSeed!));
    setState(() => _isSaving = false);
    if (mounted) Navigator.of(context).pop();
  }
}

class _AvatarGridItem extends StatefulWidget {
  final AvatarStyle style;
  final String seed;
  final bool isSelected;
  final bool isSaved;
  final VoidCallback onTap;

  const _AvatarGridItem({
    required this.style,
    required this.seed,
    required this.isSelected,
    required this.isSaved,
    required this.onTap,
  });

  @override
  State<_AvatarGridItem> createState() => _AvatarGridItemState();
}

class _AvatarGridItemState extends State<_AvatarGridItem> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack);
    if (widget.isSelected) _scaleController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _AvatarGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _scaleController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(scale: _scaleAnimation.value, child: child),
          child: VitalTap(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? AppColors.primary : Colors.transparent,
                  width: widget.isSelected ? 3 : 0,
                ),
                boxShadow: widget.isSelected
                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8)]
                    : null,
              ),
              padding: EdgeInsets.all(widget.isSelected ? 2 : 0),
              child: VitalAvatar(style: widget.style, seed: widget.seed, size: 80),
            ),
          ),
        ),
        const SizedBox(height: 4),
        if (widget.isSaved)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(8)),
            child: const Text('Actual', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
          )
        else
          const SizedBox(height: 18),
      ],
    );
  }
}
