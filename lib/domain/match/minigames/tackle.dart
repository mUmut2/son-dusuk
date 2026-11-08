import '../../../core/game_random.dart';
import '../moment_resolver.dart';
import 'mini_balance.dart';

enum TackleKind { won, foul, beaten }

class TackleResult {
  const TackleResult({required this.kind, required this.outcome});

  final TackleKind kind;
  final MomentOutcome outcome;
}

/// Savunma müdahalesi: rakibin önünde pozisyon al ve topu açtığı anda müdahale et.
abstract final class TackleResolver {
  /// [timing] 0-1 (top ayaktan en uzakken 1), [alignment] 0-1 (oyuncu rakibin
  /// hizasında mı). Nitelikler 0-1.
  static TackleResult resolve({
    required double timing,
    required double alignment,
    required double defending,
    required double strength,
    required double attackerSkill,
    required GameRandom random,
    double performance = 1,
  }) {
    final beaten = TackleResult(
      kind: TackleKind.beaten,
      outcome: random.chance(MiniBalance.beatenConcedeChance)
          ? MomentOutcome.conceded
          : MomentOutcome.none,
    );

    // Hizada değilse müdahale edecek yer yoktur: rakip geçer.
    if (alignment < MiniBalance.tackleMinAlignment) return beaten;

    final skill =
        1 -
        MiniBalance.tackleSkillSpread / 2 +
        MiniBalance.tackleSkillSpread * ((defending + strength) / 2);
    final p =
        ((MiniBalance.tackleBase + MiniBalance.tackleSpan * timing) *
                skill *
                (1 - MiniBalance.tackleAttackerEdge * attackerSkill) *
                (0.5 + 0.5 * alignment) *
                performance)
            .clamp(0.02, 0.95);
    if (random.chance(p)) {
      return const TackleResult(
        kind: TackleKind.won,
        outcome: MomentOutcome.none,
      );
    }

    final foul = (1 - timing) * MiniBalance.foulChance * (1 - 0.4 * defending);
    if (random.chance(foul)) {
      return TackleResult(
        kind: TackleKind.foul,
        outcome: random.chance(MiniBalance.foulConcedeChance)
            ? MomentOutcome.conceded
            : MomentOutcome.none,
      );
    }
    return beaten;
  }
}
