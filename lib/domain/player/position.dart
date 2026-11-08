import 'attribute.dart';

/// Oynanabilir mevkiler (kaleci yok).
enum PlayerPosition { forward, winger, attackingMid, centralMid, defender }

enum PreferredFoot { left, right, both }

/// Mevkinin hangi niteliklere ne kadar önem verdiğini tanımlar.
/// Hem "genel güç" hesabında hem de nitelik tavanlarında kullanılır.
abstract final class PositionProfile {
  static const double key = 1;
  static const double mid = 0.6;
  static const double low = 0.3;

  static const Map<PlayerPosition, ({Set<Attribute> key, Set<Attribute> mid})>
  _profiles = {
    PlayerPosition.forward: (
      key: {
        Attribute.shooting,
        Attribute.finesse,
        Attribute.heading,
        Attribute.composure,
      },
      mid: {
        Attribute.dribbling,
        Attribute.pace,
        Attribute.strength,
        Attribute.ballControl,
        Attribute.agility,
      },
    ),
    PlayerPosition.winger: (
      key: {
        Attribute.pace,
        Attribute.dribbling,
        Attribute.agility,
        Attribute.passing,
      },
      mid: {
        Attribute.shooting,
        Attribute.finesse,
        Attribute.ballControl,
        Attribute.stamina,
        Attribute.vision,
      },
    ),
    PlayerPosition.attackingMid: (
      key: {
        Attribute.passing,
        Attribute.vision,
        Attribute.dribbling,
        Attribute.ballControl,
      },
      mid: {
        Attribute.shooting,
        Attribute.finesse,
        Attribute.agility,
        Attribute.composure,
        Attribute.setPieces,
      },
    ),
    PlayerPosition.centralMid: (
      key: {
        Attribute.passing,
        Attribute.vision,
        Attribute.stamina,
        Attribute.ballControl,
      },
      mid: {
        Attribute.defending,
        Attribute.strength,
        Attribute.composure,
        Attribute.dribbling,
        Attribute.setPieces,
      },
    ),
    PlayerPosition.defender: (
      key: {
        Attribute.defending,
        Attribute.strength,
        Attribute.heading,
        Attribute.stamina,
      },
      mid: {
        Attribute.pace,
        Attribute.passing,
        Attribute.composure,
        Attribute.ballControl,
        Attribute.agility,
      },
    ),
  };

  /// [position] için [attribute] önem ağırlığı (0.3 / 0.6 / 1.0).
  static double weight(PlayerPosition position, Attribute attribute) {
    final profile = _profiles[position]!;
    if (profile.key.contains(attribute)) return key;
    if (profile.mid.contains(attribute)) return mid;
    return low;
  }

  /// Bir niteliğin ulaşabileceği tavan. Potansiyel, mevkinin ana nitelikleri
  /// için tavandır; ikincil nitelikler daha düşük bir tavana sahiptir.
  static double ceiling(
    PlayerPosition position,
    Attribute attribute,
    double potential,
  ) {
    return potential - (1 - weight(position, attribute)) * 18;
  }
}
