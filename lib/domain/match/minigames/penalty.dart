import 'dart:math' as math;

import '../../../core/game_random.dart';
import '../shot/shot_models.dart';
import 'mini_balance.dart';

class PenaltyResult {
  const PenaltyResult({
    required this.outcome,
    required this.zone,
    required this.keeperZone,
    required this.finalX,
    required this.finalY,
  });

  final ShotOutcome outcome;

  /// Seçilen ve kalecinin daldığı bölge (0-5).
  final int zone;
  final int keeperZone;
  final double finalX;
  final double finalY;

  bool get isGoal => outcome == ShotOutcome.goal;
}

/// Penaltı: bölge seçimi + güç ibresi + kalecinin okuma (psikoloji) öğesi.
abstract final class PenaltyResolver {
  static const int zoneCount = 6;

  static double zoneX(int zone) => MiniBalance.penaltyZoneX[zone % 3];
  static double zoneY(int zone) => MiniBalance.penaltyZoneY[zone ~/ 3];

  /// Kalecinin bölge olasılıkları: eşit taban + oyuncunun geçmiş tercihleri.
  /// Hep aynı köşeye vuran oyuncu okunur.
  static List<double> keeperWeights(List<int> history) {
    assert(history.length == zoneCount);
    final total = history.fold<int>(0, (a, b) => a + b);
    final weights = [
      for (var i = 0; i < zoneCount; i++)
        (1 - MiniBalance.keeperHistoryWeight) / zoneCount +
            (total == 0
                ? MiniBalance.keeperHistoryWeight / zoneCount
                : MiniBalance.keeperHistoryWeight * history[i] / total),
    ];
    return weights;
  }

  static int _pickKeeperZone(List<double> weights, GameRandom random) {
    var roll = random.nextDouble() * weights.fold(0.0, (a, b) => a + b);
    for (var i = 0; i < weights.length; i++) {
      roll -= weights[i];
      if (roll <= 0) return i;
    }
    return weights.length - 1;
  }

  /// [power] 0-1 (ibre). [composure]/[shooting] 0-1 nitelikler.
  /// [performance]: form/kondisyon/moral çarpanı (düşükse titreme artar).
  static PenaltyResult resolve({
    required int zone,
    required double power,
    required double composure,
    required double shooting,
    required double keeperSkill,
    required List<int> history,
    required GameRandom random,
    double performance = 1,
  }) {
    var sigma =
        MiniBalance.penaltySigmaBase *
        (1 - MiniBalance.penaltyComposureCut * composure) *
        (1 + MiniBalance.penaltyPressure * 0.5 * (1 - composure)) *
        (1 - 0.2 * shooting) /
        performance.clamp(0.6, 1.2);
    if (power > MiniBalance.penaltyRushedPower) {
      sigma *= MiniBalance.penaltyRushedSigma;
    }

    final finalX = zoneX(zone) + random.gaussian(stdDev: sigma);
    final finalY = zoneY(zone) + random.gaussian(stdDev: sigma * 0.7);
    final keeperZone = _pickKeeperZone(keeperWeights(history), random);

    PenaltyResult result(ShotOutcome o) => PenaltyResult(
      outcome: o,
      zone: zone,
      keeperZone: keeperZone,
      finalX: finalX,
      finalY: finalY,
    );

    const m = 0.06;
    if (finalX.abs() > 1 + m || finalY > 1 + m || finalY < -m) {
      return result(ShotOutcome.offTarget);
    }
    if (finalX.abs() > 1 || finalY > 1) return result(ShotOutcome.woodwork);

    final dx = finalX - zoneX(keeperZone);
    final dy = (finalY - zoneY(keeperZone)) * 0.6;
    final distance = math.sqrt(dx * dx + dy * dy);
    final skill = 0.7 + 0.3 * keeperSkill;
    var save = 0.0;
    if (distance < MiniBalance.keeperNearRadius) {
      save = MiniBalance.keeperSaveNear * skill;
    } else if (distance < MiniBalance.keeperAdjacentRadius) {
      save = MiniBalance.keeperSaveAdjacent * skill;
    }
    if (power < MiniBalance.penaltyWeakPower) {
      save = math.min(0.97, save + MiniBalance.weakPowerSaveBonus);
    }
    return random.chance(save)
        ? result(ShotOutcome.saved)
        : result(ShotOutcome.goal);
  }
}
