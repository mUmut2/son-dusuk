import '../../core/game_random.dart';
import 'age_curve.dart';
import 'attribute.dart';
import 'attributes.dart';
import 'player.dart';
import 'position.dart';

/// Yeni (16 yaşında) oyuncu üretir. Gizli nitelikler rastgele gelir.
abstract final class PlayerFactory {
  static Player create({
    required String name,
    required String birthplace,
    required PlayerPosition position,
    required PreferredFoot foot,
    required Appearance appearance,
    required GameRandom random,
  }) {
    final potential = random
        .gaussian(mean: 76, stdDev: 9)
        .clamp(55.0, 97.0)
        .toDouble();

    final attributes = Attributes({
      for (final a in Attribute.values)
        a:
            28 +
            PositionProfile.weight(position, a) * 20 +
            random.gaussian(stdDev: 3),
    });

    return Player(
      name: name,
      birthplace: birthplace,
      position: position,
      foot: foot,
      appearance: appearance,
      age: AgeCurve.startAge,
      attributes: attributes,
      potential: potential,
      injuryProneness: random.gaussian(mean: 0.5, stdDev: 0.2).clamp(0.0, 1.0),
      professionalism: random.gaussian(mean: 0.5, stdDev: 0.2).clamp(0.0, 1.0),
    );
  }
}
