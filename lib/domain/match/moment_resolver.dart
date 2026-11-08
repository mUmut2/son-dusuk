import '../../core/game_random.dart';
import '../player/player.dart';
import 'critical_moment.dart';
import 'match_balance.dart';

/// Bir kritik anın sonucu. Mini oyunlar da aynı nesneyi üretir
/// (örn. şut mini oyunu `MomentOutcome.goal()` döner).
class MomentOutcome {
  const MomentOutcome({
    this.playerGoal = false,
    this.playerAssist = false,
    this.concededGoal = false,
  });

  static const MomentOutcome none = MomentOutcome();
  static const MomentOutcome goal = MomentOutcome(playerGoal: true);
  static const MomentOutcome assist = MomentOutcome(playerAssist: true);
  static const MomentOutcome conceded = MomentOutcome(concededGoal: true);

  final bool playerGoal;
  final bool playerAssist;
  final bool concededGoal;
}

/// Kritik anları oyuncunun niteliklerine göre otomatik çözer
/// ("hızlı simülasyon"). Mini oyunlar bunun yerine kendi sonucunu üretir.
abstract final class MomentResolver {
  /// Oyuncunun bu an için belirleyici nitelik ortalaması (1-99).
  static double relevantAttribute(Player player, MomentType type) {
    final attrs = MatchBalance.momentAttributes[type]!;
    final sum = attrs.fold<double>(0, (s, a) => s + player.attributes.raw(a));
    return sum / attrs.length;
  }

  /// Anın gerçek gol/asist olasılığı (nitelikli).
  static double goalProbability(
    Player player,
    MomentType type, {
    double performance = 1,
  }) {
    final base = MatchBalance.goalChance[type]!;
    final factor = MatchBalance.attributeFactor(
      relevantAttribute(player, type),
    );
    return (base * factor * performance).clamp(0.0, 0.95);
  }

  /// Müdahale başarı olasılığı.
  static double tackleSuccess(Player player, {double performance = 1}) {
    final factor = MatchBalance.attributeFactor(
      relevantAttribute(player, MomentType.tackle),
    );
    return (MatchBalance.tackleSuccess * factor * performance).clamp(
      0.05,
      0.95,
    );
  }

  static MomentOutcome autoResolve(
    CriticalMoment moment,
    Player player,
    GameRandom random, {
    double performance = 1,
  }) {
    switch (moment.type) {
      case MomentType.keyPass:
      case MomentType.dribble:
        return random.chance(
              goalProbability(player, moment.type, performance: performance),
            )
            ? MomentOutcome.assist
            : MomentOutcome.none;
      case MomentType.tackle:
        if (random.chance(tackleSuccess(player, performance: performance))) {
          return MomentOutcome.none;
        }
        return random.chance(MatchBalance.concedeOnFailedTackle)
            ? MomentOutcome.conceded
            : MomentOutcome.none;
      case MomentType.shot:
      case MomentType.oneOnOne:
      case MomentType.header:
      case MomentType.freeKick:
      case MomentType.penalty:
        return random.chance(
              goalProbability(player, moment.type, performance: performance),
            )
            ? MomentOutcome.goal
            : MomentOutcome.none;
    }
  }
}
