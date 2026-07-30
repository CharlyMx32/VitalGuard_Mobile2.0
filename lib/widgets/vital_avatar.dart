import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../data/avatar_data.dart';
import '../theme/app_colors.dart';

class VitalAvatar extends StatelessWidget {
  final AvatarStyle style;
  final String seed;
  final double size;
  final VoidCallback? onTap;

  const VitalAvatar({
    super.key,
    this.style = AvatarStyle.personas,
    this.seed = 'default',
    this.size = kAvatarSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CustomPaint(
            painter: _avatarPainter(style, seed),
            size: Size(size, size),
          ),
        ),
      ),
    );
  }

  CustomPainter _avatarPainter(AvatarStyle style, String seed) {
    switch (style) {
      case AvatarStyle.personas:
        return _PersonasPainter(seed);
      case AvatarStyle.cartoon:
        return _CartoonPainter(seed);
      case AvatarStyle.robots:
        return _RobotsPainter(seed);
      case AvatarStyle.pixelArt:
        return _PixelArtPainter(seed);
      case AvatarStyle.emoji:
        return _EmojiPainter(seed);
    }
  }
}

Color _hex(int value) => Color(value);

final _skinTones = [
  _hex(0xFFF5D0B5), _hex(0xFFE8B88A), _hex(0xFFD4A574),
  _hex(0xFFC68A5C), _hex(0xFF8D5524), _hex(0xFF6B3A2A),
];

final _hairColors = [
  _hex(0xFF1A1A1A), _hex(0xFF3D2B1F), _hex(0xFF6B4423),
  _hex(0xFFA0522D), _hex(0xFFD4A017), _hex(0xFFC0C0C0),
];

final _eyeColors = [
  _hex(0xFF3B2E2A), _hex(0xFF4A7023), _hex(0xFF2E5A88),
  _hex(0xFF6B4226), _hex(0xFF5D4037), _hex(0xFF1A5276),
];

final _bgPalettes = [
  [_hex(0xFF4A90E2), _hex(0xFF357ABD)],
  [_hex(0xFF6366F1), _hex(0xFF4F46E5)],
  [_hex(0xFF9B59B6), _hex(0xFF8E44AD)],
  [_hex(0xFFF39C12), _hex(0xFFE67E22)],
  [_hex(0xFFE74C3C), _hex(0xFFC0392B)],
  [_hex(0xFF0891B2), _hex(0xFF0E7490)],
];

class _PersonasPainter extends CustomPainter {
  final String seed;
  _PersonasPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final bgIdx = param(seed, 'bg', _bgPalettes.length);
    final skin = paramColor(seed, 'skin', _skinTones);
    final hairColor = paramColor(seed, 'hair', _hairColors);
    final eyeColor = paramColor(seed, 'eye', _eyeColors);
    final hairStyle = param(seed, 'hairStyle', 4);
    final mouthStyle = param(seed, 'mouth', 3);
    final hasGlasses = param(seed, 'glasses', 3) == 0;

    canvas.drawCircle(center, r, Paint()..shader = _bgGradient(bgIdx, size).createShader(Rect.fromCircle(center: center, radius: r)));

    final faceR = r * 0.55;
    final faceOffset = Offset(center.dx, center.dy + r * 0.02);

    canvas.drawCircle(faceOffset, faceR, Paint()..color = skin);

    if (hairStyle == 0 || hairStyle == 1) {
      final path = Path()
        ..moveTo(faceOffset.dx - faceR, faceOffset.dy - faceR * 0.2)
        ..quadraticBezierTo(faceOffset.dx - faceR * 0.5, faceOffset.dy - faceR * 1.2, faceOffset.dx, faceOffset.dy - faceR * 1.3)
        ..quadraticBezierTo(faceOffset.dx + faceR * 0.5, faceOffset.dy - faceR * 1.2, faceOffset.dx + faceR, faceOffset.dy - faceR * 0.2)
        ..quadraticBezierTo(faceOffset.dx + faceR * 1.1, faceOffset.dy + faceR * 0.3, faceOffset.dx + faceR * 0.6, faceOffset.dy + faceR * 0.1)
        ..quadraticBezierTo(faceOffset.dx + faceR * 0.3, faceOffset.dy + faceR * 0.05, faceOffset.dx, faceOffset.dy)
        ..quadraticBezierTo(faceOffset.dx - faceR * 0.3, faceOffset.dy + faceR * 0.05, faceOffset.dx - faceR * 0.6, faceOffset.dy + faceR * 0.1)
        ..quadraticBezierTo(faceOffset.dx - faceR * 1.1, faceOffset.dy + faceR * 0.3, faceOffset.dx - faceR, faceOffset.dy - faceR * 0.2)
        ..close();
      canvas.drawPath(path, Paint()..color = hairColor);
    }
    if (hairStyle == 2 || hairStyle == 5) {
      canvas.drawOval(Rect.fromCenter(center: Offset(faceOffset.dx, faceOffset.dy - faceR * 0.6), width: faceR * 2.2, height: faceR * 1.1), Paint()..color = hairColor);
    }
    if (hairStyle == 3) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(faceOffset.dx, faceOffset.dy - faceR * 0.2), width: faceR * 2.2, height: faceR * 0.9), Radius.circular(faceR * 0.15)), Paint()..color = hairColor);
      canvas.drawLine(Offset(faceOffset.dx, faceOffset.dy - faceR * 1.0), Offset(faceOffset.dx, faceOffset.dy - faceR * 0.4), Paint()..color = _hex(0xFFD4A574)..strokeWidth = faceR * 0.08);
    }
    if (hairStyle == 4) {
      for (var i = 0; i < 12; i++) {
        final angle = i * (pi / 6) - pi / 2;
        final dx = faceOffset.dx + cos(angle) * faceR * 0.7;
        final dy = faceOffset.dy + sin(angle) * faceR * 0.7;
        canvas.drawCircle(Offset(dx, dy), faceR * 0.18, Paint()..color = hairColor);
      }
    }

    final eyeY = faceOffset.dy - faceR * 0.1;
    final eyeX = faceR * 0.35;
    final eyeR = faceR * 0.12;

    canvas.drawCircle(Offset(faceOffset.dx - eyeX, eyeY), eyeR, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(faceOffset.dx + eyeX, eyeY), eyeR, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(faceOffset.dx - eyeX, eyeY), eyeR * 0.6, Paint()..color = eyeColor);
    canvas.drawCircle(Offset(faceOffset.dx + eyeX, eyeY), eyeR * 0.6, Paint()..color = eyeColor);

    final shineR = eyeR * 0.25;
    canvas.drawCircle(Offset(faceOffset.dx - eyeX - eyeR * 0.25, eyeY - eyeR * 0.25), shineR, Paint()..color = Colors.white70);
    canvas.drawCircle(Offset(faceOffset.dx + eyeX - eyeR * 0.25, eyeY - eyeR * 0.25), shineR, Paint()..color = Colors.white70);

    final browY = eyeY - eyeR * 0.9;
    for (final sign in [-1, 1]) {
      canvas.drawLine(
        Offset(faceOffset.dx + sign * (eyeX - eyeR * 0.5), browY),
        Offset(faceOffset.dx + sign * (eyeX + eyeR * 0.5), browY - faceR * 0.03),
        Paint()..color = hairColor..strokeWidth = faceR * 0.06..strokeCap = StrokeCap.round,
      );
    }

    if (hasGlasses) {
      for (final sign in [-1, 1]) {
        canvas.drawOval(Rect.fromCenter(center: Offset(faceOffset.dx + sign * eyeX, eyeY), width: eyeR * 2.8, height: eyeR * 2.4), Paint()..color = _hex(0xFF555555)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      }
      canvas.drawLine(Offset(faceOffset.dx - eyeX + eyeR * 1.4, eyeY), Offset(faceOffset.dx + eyeX - eyeR * 1.4, eyeY), Paint()..color = _hex(0xFF555555)..strokeWidth = 1.5);
    }

    final mouthY = faceOffset.dy + faceR * 0.35;
    if (mouthStyle == 0) {
      canvas.drawArc(Rect.fromCenter(center: Offset(faceOffset.dx, mouthY), width: faceR * 0.5, height: faceR * 0.3), 0, pi, false, Paint()..color = _hex(0xFFCC5555)..style = PaintingStyle.stroke..strokeWidth = faceR * 0.06);
    } else if (mouthStyle == 1) {
      canvas.drawLine(Offset(faceOffset.dx - faceR * 0.2, mouthY), Offset(faceOffset.dx + faceR * 0.2, mouthY), Paint()..color = _hex(0xFFCC5555)..strokeWidth = faceR * 0.05);
    } else {
      canvas.drawOval(Rect.fromCenter(center: Offset(faceOffset.dx, mouthY), width: faceR * 0.3, height: faceR * 0.2), Paint()..color = _hex(0xFFCC5555));
    }

    final noseY = faceOffset.dy + faceR * 0.12;
    canvas.drawCircle(Offset(faceOffset.dx, noseY), faceR * 0.04, Paint()..color = _hex(0xFFD4A574));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _CartoonPainter extends CustomPainter {
  final String seed;
  _CartoonPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final bgIdx = param(seed, 'bg', _bgPalettes.length);
    final skin = paramColor(seed, 'skin', _skinTones);
    final hairColor = paramColor(seed, 'hair', _hairColors);

    canvas.drawCircle(center, r, Paint()..shader = _bgGradient(bgIdx, size).createShader(Rect.fromCircle(center: center, radius: r)));

    final faceR = r * 0.6;
    final faceCenter = Offset(center.dx, center.dy + r * 0.02);
    canvas.drawCircle(faceCenter, faceR, Paint()..color = skin);

    canvas.drawOval(Rect.fromCenter(center: Offset(faceCenter.dx, faceCenter.dy - faceR * 0.7), width: faceR * 2.2, height: faceR * 0.7), Paint()..color = hairColor);

    final eyeR = faceR * 0.2;
    final eyeX = faceR * 0.3;
    final eyeY = faceCenter.dy - faceR * 0.05;

    for (final sign in [-1, 1]) {
      canvas.drawCircle(Offset(faceCenter.dx + sign * eyeX, eyeY), eyeR, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(faceCenter.dx + sign * eyeX, eyeY), eyeR * 0.65, Paint()..color = _eyeColors[param(seed, 'eyeColor', _eyeColors.length)]);
      canvas.drawCircle(Offset(faceCenter.dx + sign * eyeX - eyeR * 0.15, eyeY - eyeR * 0.15), eyeR * 0.22, Paint()..color = Colors.white70);
    }

    canvas.drawArc(Rect.fromCenter(center: Offset(faceCenter.dx, faceCenter.dy + faceR * 0.38), width: faceR * 0.45, height: faceR * 0.25), 0.1, pi - 0.2, false, Paint()..color = _hex(0xFFCC5555)..style = PaintingStyle.stroke..strokeWidth = faceR * 0.06);

    canvas.drawCircle(Offset(faceCenter.dx - faceR * 0.45, faceCenter.dy + faceR * 0.1), faceR * 0.12, Paint()..color = _hex(0xFFFFB6C1).withValues(alpha: 0.5));
    canvas.drawCircle(Offset(faceCenter.dx + faceR * 0.45, faceCenter.dy + faceR * 0.1), faceR * 0.12, Paint()..color = _hex(0xFFFFB6C1).withValues(alpha: 0.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RobotsPainter extends CustomPainter {
  final String seed;
  _RobotsPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final bgIdx = param(seed, 'bg', _bgPalettes.length);
    final accent = _bgPalettes[bgIdx].first;
    final bodyColor = _hex(0xFFE0E0E0);

    canvas.drawCircle(center, r, Paint()..shader = _bgGradient(bgIdx, size).createShader(Rect.fromCircle(center: center, radius: r)));

    final headRect = Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.02), width: r * 1.1, height: r * 1.0);
    canvas.drawRRect(RRect.fromRectAndRadius(headRect, Radius.circular(r * 0.15)), Paint()..color = bodyColor);

    final antennaBase = Offset(center.dx, center.dy - r * 0.48);
    canvas.drawLine(antennaBase, Offset(center.dx, center.dy - r * 0.9), Paint()..color = _hex(0xFF999999)..strokeWidth = 2);
    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.9), r * 0.08, Paint()..color = accent);

    final eyeY = center.dy - r * 0.08;
    for (final sign in [-1, 1]) {
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(center.dx + sign * r * 0.28, eyeY), width: r * 0.2, height: r * 0.25), Radius.circular(r * 0.03)), Paint()..color = _hex(0xFF222222));
      canvas.drawRect(Rect.fromCenter(center: Offset(center.dx + sign * r * 0.28, eyeY), width: r * 0.1, height: r * 0.12), Paint()..color = accent);
    }

    final mouthRect = Rect.fromCenter(center: Offset(center.dx, center.dy + r * 0.28), width: r * 0.5, height: r * 0.12);
    canvas.drawRRect(RRect.fromRectAndRadius(mouthRect, Radius.circular(r * 0.02)), Paint()..color = _hex(0xFF333333));
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(mouthRect.left + mouthRect.width * (i + 1) / 5, mouthRect.top),
        Offset(mouthRect.left + mouthRect.width * (i + 1) / 5, mouthRect.bottom),
        Paint()..color = bodyColor..strokeWidth = 1.5,
      );
    }

    for (final sign in [-1, 1]) {
      canvas.drawCircle(Offset(center.dx + sign * (r * 0.5), center.dy), r * 0.06, Paint()..color = _hex(0xFFCCCCCC));
      canvas.drawCircle(Offset(center.dx + sign * (r * 0.5), center.dy), r * 0.03, Paint()..color = accent);
    }

    canvas.drawLine(Offset(headRect.left + 2, headRect.top + headRect.height * 0.35), Offset(headRect.right - 2, headRect.top + headRect.height * 0.35), Paint()..color = _hex(0xFFCCCCCC)..strokeWidth = 0.5);
    canvas.drawLine(Offset(center.dx, headRect.top + r * 0.1), Offset(center.dx, headRect.bottom), Paint()..color = _hex(0xFFCCCCCC)..strokeWidth = 0.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _PixelArtPainter extends CustomPainter {
  final String seed;
  _PixelArtPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final bgIdx = param(seed, 'bg', _bgPalettes.length);

    canvas.drawCircle(center, r, Paint()..shader = _bgGradient(bgIdx, size).createShader(Rect.fromCircle(center: center, radius: r)));

    const gridSize = 8;
    final cellSize = size.width / gridSize;
    final offsetX = (size.width - gridSize * cellSize) / 2;
    final offsetY = (size.height - gridSize * cellSize) / 2;

    final palette = [
      paramColor(seed, 'c0', _skinTones),
      paramColor(seed, 'c1', _hairColors),
      paramColor(seed, 'c2', _eyeColors),
      Colors.white,
      _hex(0xFFCC5555),
      _hex(0xFF555555),
    ];

    final patternIdx = param(seed, 'pattern', 4);

    final patterns = [
      [
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 1, 1, 3, 3, 1, 1, 1],
        [1, 1, 1, 2, 2, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 4, 4, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
      ],
      [
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 5, 1, 1, 1, 1, 5, 1],
        [1, 1, 5, 5, 5, 5, 1, 1],
        [1, 1, 5, 3, 3, 5, 1, 1],
        [1, 1, 1, 5, 5, 1, 1, 1],
        [0, 1, 1, 4, 4, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
      ],
      [
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 1, 1, 3, 3, 1, 1, 1],
        [1, 1, 1, 3, 3, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 4, 4, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
      ],
      [
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [1, 5, 1, 1, 1, 1, 5, 1],
        [1, 1, 3, 5, 5, 3, 1, 1],
        [1, 1, 1, 5, 5, 1, 1, 1],
        [1, 1, 4, 1, 1, 4, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
      ],
    ];

    final grid = patterns[patternIdx];

    for (var y = 0; y < gridSize; y++) {
      for (var x = 0; x < gridSize; x++) {
        final idx = grid[y][x];
        if (idx == 0) continue;
        canvas.drawRect(
          Rect.fromLTWH(
            offsetX + x * cellSize,
            offsetY + y * cellSize,
            cellSize - 0.5,
            cellSize - 0.5,
          ),
          Paint()..color = palette[idx % palette.length],
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _EmojiPainter extends CustomPainter {
  final String seed;
  _EmojiPainter(this.seed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final bgIdx = param(seed, 'bg', _bgPalettes.length);
    final mouthStyle = param(seed, 'mouth', 5);
    final wink = param(seed, 'wink', 3) == 0;
    final hasSunglasses = param(seed, 'sunglasses', 4) == 0;

    canvas.drawCircle(center, r, Paint()..shader = _bgGradient(bgIdx, size).createShader(Rect.fromCircle(center: center, radius: r)));

    final faceR = r * 0.65;
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.03), faceR, Paint()..color = _hex(0xFFFFDE21));

    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.03), faceR, Paint()..color = _hex(0xFFE5C912)..style = PaintingStyle.stroke..strokeWidth = 2);

    final eyeR = faceR * 0.12;
    final eyeX = faceR * 0.3;
    final eyeY = center.dy + r * 0.03 - faceR * 0.08;

    if (hasSunglasses) {
      final glassesRect = Rect.fromCenter(center: Offset(center.dx, eyeY), width: faceR * 1.0, height: faceR * 0.45);
      canvas.drawRRect(RRect.fromRectAndRadius(glassesRect, Radius.circular(faceR * 0.15)), Paint()..color = _hex(0xFF333333)..style = PaintingStyle.fill);
      canvas.drawLine(Offset(center.dx - faceR * 0.15, eyeY), Offset(center.dx + faceR * 0.15, eyeY), Paint()..color = _hex(0xFF333333)..strokeWidth = 2);
    } else if (wink) {
      canvas.drawCircle(Offset(center.dx - eyeX, eyeY), eyeR, Paint()..color = _hex(0xFF5D4037));
      canvas.drawLine(Offset(center.dx + eyeX - eyeR * 0.7, eyeY), Offset(center.dx + eyeX + eyeR * 0.7, eyeY), Paint()..color = _hex(0xFF5D4037)..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    } else {
      canvas.drawCircle(Offset(center.dx - eyeX, eyeY), eyeR, Paint()..color = _hex(0xFF5D4037));
      canvas.drawCircle(Offset(center.dx + eyeX, eyeY), eyeR, Paint()..color = _hex(0xFF5D4037));
      canvas.drawCircle(Offset(center.dx - eyeX - eyeR * 0.3, eyeY - eyeR * 0.3), eyeR * 0.3, Paint()..color = Colors.white70);
      canvas.drawCircle(Offset(center.dx + eyeX - eyeR * 0.3, eyeY - eyeR * 0.3), eyeR * 0.3, Paint()..color = Colors.white70);
    }

    final mouthY = center.dy + r * 0.03 + faceR * 0.35;
    if (mouthStyle == 0) {
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, mouthY), width: faceR * 0.45, height: faceR * 0.25), 0, pi, false, Paint()..color = _hex(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = faceR * 0.06);
    } else if (mouthStyle == 1) {
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, mouthY), width: faceR * 0.45, height: faceR * 0.25), pi, pi, false, Paint()..color = _hex(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = faceR * 0.06);
    } else if (mouthStyle == 2) {
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY - faceR * 0.1), width: faceR * 0.3, height: faceR * 0.25), Paint()..color = _hex(0xFF5D4037));
    } else if (mouthStyle == 3) {
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY), width: faceR * 0.35, height: faceR * 0.3), Paint()..color = _hex(0xFF5D4037));
      canvas.drawOval(Rect.fromCenter(center: Offset(center.dx, mouthY + faceR * 0.2), width: faceR * 0.2, height: faceR * 0.15), Paint()..color = _hex(0xFFFF8A80));
    } else {
      canvas.drawArc(Rect.fromCenter(center: Offset(center.dx, mouthY), width: faceR * 0.45, height: faceR * 0.25), 0.15, pi - 0.3, false, Paint()..color = _hex(0xFF5D4037)..style = PaintingStyle.stroke..strokeWidth = faceR * 0.06);
    }

    if (!hasSunglasses) {
      canvas.drawCircle(Offset(center.dx - faceR * 0.4, center.dy + r * 0.03 + faceR * 0.12), faceR * 0.1, Paint()..color = _hex(0xFFFF8A80).withValues(alpha: 0.4));
      canvas.drawCircle(Offset(center.dx + faceR * 0.4, center.dy + r * 0.03 + faceR * 0.12), faceR * 0.1, Paint()..color = _hex(0xFFFF8A80).withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

Gradient _bgGradient(int idx, Size size) {
  final palette = _bgPalettes[idx % _bgPalettes.length];
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: palette,
  );
}

void showAvatarPreview(BuildContext context, {required AvatarConfig config, required VoidCallback onChangeTap}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (ctx) => Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: 'avatar_hero',
              child: VitalAvatar(style: config.style, seed: config.seed, size: 160),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  onChangeTap();
                },
                icon: const Icon(LucideIcons.edit, size: 18),
                label: const Text('Cambiar avatar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            ),
          ],
        ),
      ),
    ),
  );
}
