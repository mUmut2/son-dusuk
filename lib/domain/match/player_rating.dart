import 'match_session.dart';
import 'match_simulator.dart';

/// Maç sonu oyuncu reytingi (1-10). Basit ve açıklanabilir:
/// 6.0 + 1.3/gol + 0.8/asist - 0.6/kritik andan yenen gol ± 0.3 (galibiyet/mağlubiyet).
abstract final class PlayerRating {
  static double compute(MatchSession session) {
    final result = session.result;
    final goals = result.goals.where((g) => g.byPlayer).length;
    final assists = result.goals.where((g) => g.assistedByPlayer).length;
    final conceded = session.concededFromMoments;

    final own = session.playerSide == Side.home
        ? result.homeGoals
        : result.awayGoals;
    final other = result.totalGoals - own;
    final resultBonus = own > other ? 0.3 : (own < other ? -0.3 : 0.0);

    final rating =
        6.0 + 1.3 * goals + 0.8 * assists - 0.6 * conceded + resultBonus;
    return rating.clamp(1.0, 10.0);
  }
}
