import '../../../core/game_random.dart';
import '../shot/shot_models.dart';
import '../shot/shot_resolver.dart';
import 'mini_balance.dart';

/// Duvar: şut çizgisini kesen savunma barikatı (kale düzlemi birimi).
class WallSpec {
  const WallSpec({
    required this.centerX,
    required this.halfWidth,
    required this.jumps,
  });

  factory WallSpec.random(GameRandom random) => WallSpec(
    centerX: (random.nextDouble() * 2 - 1) * 0.35,
    halfWidth:
        MiniBalance.wallHalfWidthMin +
        random.nextDouble() *
            (MiniBalance.wallHalfWidthMax - MiniBalance.wallHalfWidthMin),
    jumps: random.chance(MiniBalance.wallJumpChance),
  );

  final double centerX;
  final double halfWidth;

  /// Duvar zıplıyor mu (yüksekliği artırır).
  final bool jumps;

  double get height =>
      MiniBalance.wallHeight + (jumps ? MiniBalance.wallJumpBonus : 0);
}

/// Serbest vuruş: duvarı aş ya da kavisle dolan, sonra kaleciye karşı çöz.
abstract final class FreeKickResolver {
  static ShotResult resolve({
    required ShotInput input,
    required ShotProfile profile,
    required WallSpec wall,
    required double keeperSkill,
    required GameRandom random,
  }) {
    final power = (input.power * profile.powerEfficiency).clamp(0.1, 1.0);
    final clearance =
        input.aimY * (MiniBalance.clearanceA + MiniBalance.clearanceB * power);
    final overWall = clearance >= wall.height;
    final lineHitsWall = (input.aimX - wall.centerX).abs() < wall.halfWidth;

    if (lineHitsWall && !overWall) {
      return ShotResult(
        outcome: ShotOutcome.blocked,
        finalX: input.aimX,
        finalY: input.aimY,
        keeperX: 0,
        timing: input.timing,
      );
    }

    return ShotResolver.resolve(
      input: input,
      profile: profile,
      // Savunmacı yok (duvar zaten çözüldü): baskı 0, çizgi uzakta.
      context: ShotContext(
        keeperSkill: keeperSkill,
        pressure: 0,
        defenderAimX: 99,
      ),
      random: random,
    );
  }
}
