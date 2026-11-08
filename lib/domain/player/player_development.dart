import 'dart:math' as math;

import '../../core/game_random.dart';
import 'age_curve.dart';
import 'player.dart';
import 'position.dart';

/// Yıllık yaşlanma ve nitelik gelişimi.
///
/// Pozitif değişimler: yaş eğrisi x profesyonellik x potansiyel çarpanı,
/// tavana yaklaştıkça yavaşlar. Negatif değişimler (yaşlılık) tavandan
/// bağımsızdır. Antrenman, maç ve mentor etkileri sonraki fazlarda eklenir.
abstract final class PlayerDevelopment {
  static Player advanceYear(Player player, GameRandom random) {
    final growthFactor = 0.8 + 0.7 * (player.potential - 55) / 42;
    final professionalFactor = 0.6 + 0.8 * player.professionalism;

    final next = player.attributes.map((attribute, value) {
      final base = AgeCurve.annualDelta(player.age, attribute.kind);
      if (base > 0) {
        final ceiling = PositionProfile.ceiling(
          player.position,
          attribute,
          player.potential,
        );
        final headroom = ((ceiling - value) / 10).clamp(0.0, 1.0);
        final gain =
            (base * growthFactor * professionalFactor +
                random.gaussian(stdDev: 0.6)) *
            headroom;
        return math.min(value + gain, math.max(ceiling, value));
      }
      return value + base + random.gaussian(stdDev: 0.3);
    });

    return player.copyWith(age: player.age + 1, attributes: next);
  }
}
