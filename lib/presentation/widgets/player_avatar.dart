import 'package:flutter/material.dart';

import '../../domain/player/player.dart';

/// Avatar paletleri (indeksler `Appearance` içinde saklanır).
const List<Color> skinTones = [
  Color(0xFFF1C9A5),
  Color(0xFFD9A47A),
  Color(0xFFB87B53),
  Color(0xFF8A5A3B),
  Color(0xFF5E3B26),
];
const List<Color> hairColors = [
  Color(0xFF1C1410),
  Color(0xFF4A3020),
  Color(0xFF8A5A2B),
  Color(0xFFD8B25A),
  Color(0xFFB0B0B0),
];
const List<Color> kitColors = [
  Color(0xFFD62828),
  Color(0xFF1D4ED8),
  Color(0xFFF2C94C),
  Color(0xFF16A34A),
  Color(0xFF7C3AED),
  Color(0xFFF8FAFC),
];

Color _pick(List<Color> palette, int i) =>
    palette[i.clamp(0, palette.length - 1)];

/// Basit vektör avatar (CustomPainter). Gerçek asset ile değiştirilebilir.
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({required this.appearance, this.size = 72, super.key});

  final Appearance appearance;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _AvatarPainter(
          skin: _pick(skinTones, appearance.skinTone),
          hair: _pick(hairColors, appearance.hairColor),
          kit: _pick(kitColors, appearance.kitColor),
        ),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({required this.skin, required this.hair, required this.kit});

  final Color skin;
  final Color hair;
  final Color kit;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(s / 2),
    );
    canvas
      ..save()
      ..clipRRect(clip)
      ..drawRect(Offset.zero & size, Paint()..color = const Color(0xFF2E7D32));

    // Forma (gövde)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.15, s * 0.62, s * 0.7, s * 0.6),
        Radius.circular(s * 0.2),
      ),
      Paint()..color = kit,
    );
    // Boyun + kafa
    canvas
      ..drawRect(
        Rect.fromLTWH(s * 0.43, s * 0.5, s * 0.14, s * 0.16),
        Paint()..color = skin,
      )
      ..drawCircle(Offset(s / 2, s * 0.4), s * 0.2, Paint()..color = skin);
    // Saç
    canvas
      ..drawArc(
        Rect.fromCircle(center: Offset(s / 2, s * 0.4), radius: s * 0.21),
        3.14,
        3.14,
        true,
        Paint()..color = hair,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_AvatarPainter old) =>
      old.skin != skin || old.hair != hair || old.kit != kit;
}
