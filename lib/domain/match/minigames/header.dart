import '../../../core/game_random.dart';
import '../shot/shot_models.dart';
import '../shot/shot_resolver.dart';
import 'mini_balance.dart';

/// Kafa vuruşu: zamanlamalı sıçrayış + yön. Önce havada mücadele, sonra kaleci.
abstract final class HeaderResolver {
  /// [strength] 0-1 (Güç). [pressure] 0-1 (rakip savunmacı baskısı).
  static ShotResult resolve({
    required ShotInput input,
    required ShotProfile profile,
    required double strength,
    required double pressure,
    required double keeperSkill,
    required GameRandom random,
  }) {
    // Havadaki mücadele: kötü zamanlama + baskı = top rakipte kalır.
    final lost =
        pressure *
        (1 - input.timing) *
        (1 - strength * MiniBalance.headerStrengthEdge);
    if (random.chance(lost)) {
      return ShotResult(
        outcome: ShotOutcome.blocked,
        finalX: input.aimX,
        finalY: MiniBalance.headerAimY,
        keeperX: 0,
        timing: input.timing,
      );
    }

    // Kafa vuruşları yerden ve orta güçtedir; kalecinin mesafesi kısadır.
    final header = ShotInput(
      aimX: input.aimX,
      aimY: MiniBalance.headerAimY,
      power: 0.5 + 0.4 * strength,
      curve: 0,
      timing: input.timing,
    );
    return ShotResolver.resolve(
      input: header,
      profile: profile,
      context: ShotContext(
        keeperSkill: (keeperSkill + MiniBalance.headerKeeperBonus).clamp(
          0.0,
          0.95,
        ),
        pressure: 0,
        defenderAimX: 99,
      ),
      random: random,
    );
  }
}
