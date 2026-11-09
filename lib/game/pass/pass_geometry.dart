import 'dart:math' as math;
import 'dart:ui';

import '../../domain/match/minigames/pass.dart';
import '../person_painter.dart';
import '../shot/shot_geometry.dart';

/// Bir pas seçeneğinin ekrandaki yeri: takım arkadaşı ve hemen altındaki rakip.
class PassSlot {
  const PassSlot({
    required this.mateX,
    required this.mateY,
    required this.defenderX,
    required this.defenderY,
    required this.defenderScale,
  });

  final double mateX;
  final double mateY;
  final double defenderX;
  final double defenderY;
  final double defenderScale;
}

/// Pas sahnesi yerleşimi (Flame'den bağımsız). Her seçenek kendi sütununu alır;
/// takım arkadaşı ile rakibi aynı sütunda alt alta durur, bu yüzden hiçbir
/// oyuncu bir başkasının üstüne binemez (bkz. pass_geometry_test).
abstract final class PassGeometry {
  static const double mateScale = 0.9;
  static const double passerScale = 1.0;

  /// Rakip büyüklüğü riskle artar ama bu sınırlar içinde kalır.
  static const double defenderMinScale = 0.65;
  static const double defenderMaxScale = 1.0;

  /// Sütunlar ekran genişliğinin bu bölümüne eşit aralıkla dizilir.
  static const double marginFraction = 0.06;

  /// Rakip, takım arkadaşının bu kadar (top yarıçapı birimi) altındadır.
  static const double defenderGap = 6.2;

  /// En alttaki takım arkadaşı, pasör ile arasında bu kadar boşluk bırakır.
  static const double passerClearance = 15;

  /// Pasörün gövde merkezi topun bu kadar üstündedir.
  static const double passerRise = 2.2;

  static double defenderScaleFor(PassOption o) =>
      (0.65 + o.risk * 1.0).clamp(defenderMinScale, defenderMaxScale);

  /// Pasörün gövde merkezi; top ayağının yanındadır.
  static ({double x, double y}) passer(ShotLayout l) =>
      (x: l.ballX, y: l.ballY - l.ballRadius * passerRise);

  static List<PassSlot> place(ShotLayout l, List<PassOption> options) {
    final n = options.length;
    final u = l.ballRadius;
    final left = l.width * marginFraction;
    final span = l.width * (1 - 2 * marginFraction);

    // Soldan sağa sıra: seçeneğin yanal konumuna göre.
    final order = [for (var i = 0; i < n; i++) i]
      ..sort((a, b) => options[a].x.compareTo(options[b].x));

    final yMin = l.height * 0.2;
    final yMax = math.max(yMin, l.ballY - u * passerClearance);

    final slots = List<PassSlot?>.filled(n, null);
    for (var rank = 0; rank < n; rank++) {
      final o = options[order[rank]];
      final x = left + span * (rank + 0.5) / n;
      // depth 0.2 (yakın) .. 0.85 (uzak)
      final t = ((o.depth - 0.2) / 0.65).clamp(0.0, 1.0);
      final y = yMax - t * (yMax - yMin);
      slots[order[rank]] = PassSlot(
        mateX: x,
        mateY: y,
        defenderX: x,
        defenderY: y + u * defenderGap,
        defenderScale: defenderScaleFor(o),
      );
    }
    return slots.cast<PassSlot>();
  }

  /// Sahnedeki tüm figürlerin kapladığı alanlar (pasör dahil).
  static List<Rect> allBounds(ShotLayout l, List<PassSlot> slots) {
    final u = l.ballRadius;
    final p = passer(l);
    return [
      personBounds(p.x, p.y, u, scale: passerScale),
      for (final s in slots) ...[
        personBounds(s.mateX, s.mateY, u, scale: mateScale),
        personBounds(s.defenderX, s.defenderY, u, scale: s.defenderScale),
      ],
    ];
  }
}
