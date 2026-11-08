import '../../../core/game_random.dart';
import '../moment_resolver.dart';
import 'mini_balance.dart';

class DribbleResult {
  const DribbleResult({required this.beaten, required this.outcome});

  /// Savunmacı geçildi mi.
  final bool beaten;
  final MomentOutcome outcome;
}

/// Dribling: savunmacı atılmadan hemen önce doğru yöne çalım atmak.
abstract final class DribbleResolver {
  /// [timing] 0-1 (atılma anına yakınlık), [correctDirection]: savunmacının
  /// atıldığı yanın tersine çalım atıldı mı. Nitelikler 0-1.
  static DribbleResult resolve({
    required double timing,
    required bool correctDirection,
    required double dribbling,
    required double agility,
    required double ballControl,
    required double defenderSkill,
    required GameRandom random,
    double performance = 1,
  }) {
    final raw = correctDirection
        ? MiniBalance.dribbleBase + MiniBalance.dribbleSpan * timing
        : MiniBalance.dribbleWrongDirection;
    final skill =
        1 -
        MiniBalance.dribbleSkillSpread / 2 +
        MiniBalance.dribbleSkillSpread *
            ((dribbling + agility + ballControl) / 3);
    final p =
        (raw *
                skill *
                (1 - MiniBalance.dribbleDefenderEdge * defenderSkill) *
                performance)
            .clamp(0.02, 0.95);
    final beaten = random.chance(p);
    final assist =
        beaten && random.chance(MiniBalance.dribbleAssistGivenSuccess);
    return DribbleResult(
      beaten: beaten,
      outcome: assist ? MomentOutcome.assist : MomentOutcome.none,
    );
  }

  /// Çalım atılan an ile savunmacının atılma anı arasındaki farktan (sn)
  /// zamanlama kalitesi (0-1).
  static double timingQuality(double deltaSeconds) {
    final d = deltaSeconds.abs();
    if (d <= MiniBalance.dribblePerfectWindow) return 1;
    return (1 -
            (d - MiniBalance.dribblePerfectWindow) /
                (MiniBalance.dribbleGoodWindow -
                    MiniBalance.dribblePerfectWindow))
        .clamp(0.0, 1.0);
  }
}
