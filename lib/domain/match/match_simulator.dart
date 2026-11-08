import 'dart:math' as math;

import '../../core/game_random.dart';
import 'match_balance.dart';

enum Side { home, away }

class MatchGoal {
  const MatchGoal({
    required this.minute,
    required this.side,
    this.byPlayer = false,
    this.assistedByPlayer = false,
  });

  final int minute;
  final Side side;

  /// Goli kullanıcının oyuncusu attı.
  final bool byPlayer;

  /// Golün asistini kullanıcının oyuncusu yaptı.
  final bool assistedByPlayer;
}

class MatchResult {
  const MatchResult({required this.goals});

  final List<MatchGoal> goals;

  int get homeGoals => goals.where((g) => g.side == Side.home).length;
  int get awayGoals => goals.where((g) => g.side == Side.away).length;
  int get totalGoals => goals.length;
}

/// Takım gücüne dayalı, seed'e bağlı 90 dakikalık maç simülasyonu.
///
/// Her dakika, takımın gol beklentisine göre bağımsız bir "gol var mı?"
/// denemesi yapılır (yaklaşık Poisson). Beklenti: temel gol x ev sahibi
/// çarpanı x exp(eğim x güç farkı).
abstract final class MatchSimulator {
  /// Takımların maç başı gol beklentileri (home, away).
  ///
  /// [neutral]: tarafsız saha (turnuva); ev sahibi avantajı uygulanmaz.
  static ({double home, double away}) expectedGoals({
    required double homeStrength,
    required double awayStrength,
    bool neutral = false,
  }) {
    final diff = homeStrength - awayStrength;
    final advantage = neutral ? 1.0 : MatchBalance.homeAdvantage;
    return (
      home:
          MatchBalance.baseGoals *
          advantage *
          math.exp(MatchBalance.strengthSlope * diff),
      away:
          MatchBalance.baseGoals /
          advantage *
          math.exp(-MatchBalance.strengthSlope * diff),
    );
  }

  /// [homeReduction] / [awayReduction]: kritik anlarda ayrıca hesaplanan
  /// beklenen golün takım beklentisinden düşülmesi (çifte sayımı önler).
  static List<MatchGoal> simulateGoals({
    required double homeStrength,
    required double awayStrength,
    required GameRandom random,
    double homeReduction = 0,
    double awayReduction = 0,
    bool neutral = false,
  }) {
    final expected = expectedGoals(
      homeStrength: homeStrength,
      awayStrength: awayStrength,
      neutral: neutral,
    );
    final homeLambda = math.max(
      MatchBalance.minGoalExpectation,
      expected.home - homeReduction,
    );
    final awayLambda = math.max(
      MatchBalance.minGoalExpectation,
      expected.away - awayReduction,
    );

    final goals = <MatchGoal>[];
    for (var minute = 1; minute <= MatchBalance.matchMinutes; minute++) {
      if (random.chance(homeLambda / MatchBalance.matchMinutes)) {
        goals.add(MatchGoal(minute: minute, side: Side.home));
      }
      if (random.chance(awayLambda / MatchBalance.matchMinutes)) {
        goals.add(MatchGoal(minute: minute, side: Side.away));
      }
    }
    return goals;
  }

  /// Oyuncusuz (arka plan) maç.
  static MatchResult simulate({
    required double homeStrength,
    required double awayStrength,
    required GameRandom random,
  }) {
    return MatchResult(
      goals: simulateGoals(
        homeStrength: homeStrength,
        awayStrength: awayStrength,
        random: random,
      ),
    );
  }
}
