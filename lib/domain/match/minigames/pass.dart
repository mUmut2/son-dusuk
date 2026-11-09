import '../../../core/game_random.dart';
import '../match_balance.dart';
import 'mini_balance.dart';

enum PassType { safe, forward, through, switchPlay }

/// Pas seçeneği: hedef oyuncu (ekran konumu için x/derinlik), risk ve ödül.
class PassOption {
  const PassOption({
    required this.type,
    required this.x,
    required this.depth,
    required this.risk,
    required this.reward,
    required this.idealPower,
  });

  final PassType type;

  /// Yanal konum (-1 sol .. +1 sağ) ve ileri derinlik (0 yakın .. 1 uzak).
  final double x;
  final double depth;

  /// Kesilme olasılığı tabanı (0-1) ve tamamlanırsa asist olasılığı.
  final double risk;
  final double reward;

  /// Bu pas için doğru güç ibresi değeri (0-1).
  final double idealPower;
}

class PassResult {
  const PassResult({
    required this.option,
    required this.completed,
    required this.assist,
    required this.accuracy,
  });

  final PassOption option;
  final bool completed;
  final bool assist;

  /// İbre isabeti (0-1).
  final double accuracy;
}

abstract final class PassResolver {
  /// Vizyon yükseldikçe daha çok ve daha iyi (düşük riskli, yüksek ödüllü)
  /// seçenek görünür. En az 2 seçenek.
  static List<PassOption> generateOptions(double vision, GameRandom random) {
    final count = vision < MiniBalance.visionTwo
        ? 2
        : vision < MiniBalance.visionThree
        ? 3
        : 4;
    final v = (vision / 99).clamp(0.0, 1.0);

    // Her seçeneğe ayrı bir şerit: oyuncular birbirinin üstüne binmesin.
    final lanes = [-0.75, -0.25, 0.25, 0.75];
    for (var i = lanes.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = lanes[i];
      lanes[i] = lanes[j];
      lanes[j] = t;
    }
    var laneIndex = 0;

    PassOption make(
      PassType type,
      double risk,
      double reward,
      double power,
      double depth,
    ) {
      return PassOption(
        type: type,
        x:
            lanes[laneIndex++ % lanes.length] +
            (random.nextDouble() - 0.5) * 0.1,
        depth: depth,
        risk: (risk * (1 - MiniBalance.visionRiskCut * v)).clamp(0.0, 0.95),
        reward: reward * (1 + MiniBalance.visionRewardGain * v),
        idealPower: power,
      );
    }

    final all = [
      make(
        PassType.safe,
        MiniBalance.safeRisk,
        MiniBalance.safeReward,
        MiniBalance.safePower,
        0.25,
      ),
      make(
        PassType.forward,
        MiniBalance.forwardRisk,
        MiniBalance.forwardReward,
        MiniBalance.forwardPower,
        0.5,
      ),
      make(
        PassType.through,
        MiniBalance.throughRisk,
        MiniBalance.throughReward,
        MiniBalance.throughPower,
        0.8,
      ),
      make(
        PassType.switchPlay,
        MiniBalance.switchRisk,
        MiniBalance.switchReward,
        MiniBalance.switchPower,
        0.6,
      ),
    ];
    return all.take(count).toList();
  }

  /// İbre isabeti: ideal güce yakınlık (0-1).
  static double accuracy(PassOption option, double power, double passing) {
    final tolerance =
        MiniBalance.passPowerTolerance * (0.6 + 0.8 * passing.clamp(0.0, 1.0));
    return (1 - (power - option.idealPower).abs() / tolerance).clamp(0.0, 1.0);
  }

  static PassResult resolve({
    required PassOption option,
    required double power,
    required double passing,
    required double vision,
    required GameRandom random,
    double performance = 1,
  }) {
    final acc = accuracy(option, power, passing);
    final complete =
        ((1 - option.risk * (1 - 0.5 * passing)) *
                (0.35 + 0.65 * acc) *
                performance)
            .clamp(0.02, 0.97);
    final completed = random.chance(complete);
    final assistChance =
        option.reward *
        MatchBalance.attributeFactor(vision * 99) *
        (0.5 + 0.5 * acc);
    final assist = completed && random.chance(assistChance.clamp(0.0, 0.9));
    return PassResult(
      option: option,
      completed: completed,
      assist: assist,
      accuracy: acc,
    );
  }
}
