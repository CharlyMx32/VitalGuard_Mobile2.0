import 'dart:math';
import 'package:flutter/painting.dart';

enum AvatarStyle {
  personas('Personas', 'Avatares realistas y modernos'),
  cartoon('Cartoon', 'Estilo animado y divertido'),
  robots('Robots', 'Avatares robóticos'),
  pixelArt('Pixel Art', 'Estilo retro pixelado'),
  emoji('Emoji', 'Emojis clásicos y coloridos');

  final String label;
  final String description;
  const AvatarStyle(this.label, this.description);
}

class AvatarConfig {
  final AvatarStyle style;
  final String seed;

  const AvatarConfig({required this.style, required this.seed});

  Map<String, dynamic> toJson() => {'style': style.name, 'seed': seed};

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        style: AvatarStyle.values.firstWhere(
          (s) => s.name == json['style'],
          orElse: () => AvatarStyle.personas,
        ),
        seed: json['seed'] as String? ?? _randomSeed(),
      );

  static String _randomSeed() => DateTime.now().microsecondsSinceEpoch.toRadixString(36);
}

int param(String seed, String key, int max) {
  return (seed + key).hashCode.abs() % max;
}

double paramF(String seed, String key, double min, double max) {
  final t = param(seed, key, 10000) / 10000.0;
  return min + t * (max - min);
}

Color paramColor(String seed, String key, List<Color> palette) {
  return palette[param(seed, key, palette.length)];
}

List<String> generateSeeds(int count) {
  final random = Random();
  final seeds = <String>{};
  while (seeds.length < count) {
    seeds.add('${DateTime.now().microsecondsSinceEpoch}_${random.nextInt(999999)}');
  }
  return seeds.toList();
}

const kAvatarSize = 80.0;
