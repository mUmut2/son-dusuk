import 'package:flutter/material.dart';

import '../../app/l10n/app_localizations.dart';
import '../../domain/social/event_models.dart';
import '../../game/person_painter.dart';
import '../l10n_labels.dart';

/// Mikrofon uzatan muhabir (oyundaki karakter çizimiyle aynı stil).
class ReporterAvatar extends StatelessWidget {
  const ReporterAvatar({this.size = 88, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.95),
      painter: const _ScenePainter(
        shirt: Color(0xFF455A64),
        variant: 6,
        microphone: true,
      ),
    );
  }
}

/// Gazete fotoğrafındaki oyuncu ve muhabir.
class _PhotoPainter extends CustomPainter {
  const _PhotoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF81C784),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.38),
      Paint()..color = const Color(0xFF66BB6A),
    );
    final u = size.width / 8.5;
    paintPerson(
      canvas,
      size.width * 0.38,
      size.height * 0.52,
      u,
      const Color(0xFF1565C0),
    );
    paintPerson(
      canvas,
      size.width * 0.8,
      size.height * 0.52,
      u * 0.75,
      const Color(0xFF455A64),
      variant: 6,
    );
    _paintMicrophone(canvas, size.width * 0.62, size.height * 0.5, u);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter({
    required this.shirt,
    required this.variant,
    required this.microphone,
  });

  final Color shirt;
  final int variant;
  final bool microphone;

  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 8.6;
    final cx = size.width * 0.42;
    final cy = u * 3.7;
    paintPerson(canvas, cx, cy, u, shirt, variant: variant);
    if (microphone) _paintMicrophone(canvas, cx + u * 1.22, cy + u * 0.36, u);
  }

  @override
  bool shouldRepaint(_) => false;
}

/// (x, y) elin konumu; mikrofon elden yukarı doğru uzanır.
void _paintMicrophone(Canvas canvas, double x, double y, double u) {
  final tip = Offset(x + u * 0.9, y - u * 1.5);
  canvas
    ..drawLine(
      Offset(x, y),
      tip,
      Paint()
        ..color = const Color(0xFF424242)
        ..strokeWidth = u * 0.28
        ..strokeCap = StrokeCap.round,
    )
    ..drawCircle(tip, u * 0.6, Paint()..color = const Color(0xFF212121))
    ..drawCircle(
      tip.translate(-u * 0.18, -u * 0.18),
      u * 0.17,
      Paint()..color = const Color(0x88FFFFFF),
    );
}

/// Muhabirin sorusunun konuşma balonu (kuyruğu soldaki muhabire bakar).
class SpeechBubble extends StatelessWidget {
  const SpeechBubble({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: child,
        ),
        Positioned(
          left: -6,
          top: 26,
          child: Transform.rotate(
            angle: 0.785398,
            child: Container(
              width: 14,
              height: 14,
              color: scheme.primaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

Color toneColor(EventTone t) => switch (t) {
  EventTone.humble => const Color(0xFF43A047),
  EventTone.funny => const Color(0xFFF57C00),
  EventTone.cool => const Color(0xFF1E88E5),
  EventTone.harsh => const Color(0xFFE53935),
  EventTone.honest => const Color(0xFF8E24AA),
  EventTone.silent => const Color(0xFF757575),
};

IconData toneIcon(EventTone t) => switch (t) {
  EventTone.humble => Icons.sentiment_satisfied_alt,
  EventTone.funny => Icons.emoji_emotions,
  EventTone.cool => Icons.star,
  EventTone.harsh => Icons.local_fire_department,
  EventTone.honest => Icons.favorite,
  EventTone.silent => Icons.volume_off,
};

/// Cevabın tavrı: renkli ikonlu küçük rozet.
class ToneChip extends StatelessWidget {
  const ToneChip({required this.tone, super.key});

  final EventTone tone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = toneColor(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(toneIcon(tone), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            l10n.toneName(tone),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cevabın ertesi günkü gazete manşeti.
class NewspaperCard extends StatelessWidget {
  const NewspaperCard({
    required this.headline,
    required this.story,
    this.backfired = false,
    super.key,
  });

  final String headline;
  final String story;
  final bool backfired;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const ink = Color(0xFF212121);
    const paper = Color(0xFFFFF8E1);
    final accent = backfired ? const Color(0xFFC62828) : ink;

    return Container(
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBCAAA4), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.interviewNewspaper,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              fontSize: 13,
              color: ink,
            ),
          ),
          const Divider(color: ink, thickness: 2, height: 12),
          Text(
            backfired ? l10n.interviewBackfireHeadline : headline,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w900,
              fontSize: 26,
              height: 1.1,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const CustomPaint(
                  size: Size(92, 92),
                  painter: _PhotoPainter(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  story,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 15,
                    height: 1.4,
                    color: ink,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
