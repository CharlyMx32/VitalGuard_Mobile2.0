import 'package:flutter/material.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/avatar_data.dart';

class AvatarService extends ChangeNotifier {
  static const _keyStyle = 'avatar_style';
  static const _keySeed = 'avatar_seed';

  AvatarConfig? _config;

  AvatarConfig get config => _config ?? const AvatarConfig(style: AvatarStyle.personas, seed: 'default');
  AvatarStyle get style => config.style;
  String get seed => config.seed;

  AvatarService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStyle = prefs.getString(_keyStyle);
    final savedSeed = prefs.getString(_keySeed);
    if (savedStyle != null && savedSeed != null) {
      final style = AvatarStyle.values.firstWhere(
        (s) => s.name == savedStyle,
        orElse: () => AvatarStyle.personas,
      );
      _config = AvatarConfig(style: style, seed: savedSeed);
    } else {
      final seed = '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(999999)}';
      _config = AvatarConfig(style: AvatarStyle.personas, seed: seed);
      await prefs.setString(_keyStyle, 'personas');
      await prefs.setString(_keySeed, seed);
    }
    notifyListeners();
  }

  Future<void> save(AvatarConfig newConfig) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStyle, newConfig.style.name);
    await prefs.setString(_keySeed, newConfig.seed);
    _config = newConfig;
    notifyListeners();
  }
}
