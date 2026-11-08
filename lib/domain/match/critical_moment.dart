import '../../core/game_random.dart';
import '../player/position.dart';
import 'match_balance.dart';

/// Oyuncuyu ilgilendiren kritik an türleri (her biri bir mini oyuna karşılık gelir).
enum MomentType {
  shot,
  oneOnOne,
  header,
  freeKick,
  penalty,
  keyPass,
  dribble,
  tackle,
}

class CriticalMoment {
  const CriticalMoment({required this.minute, required this.type});

  final int minute;
  final MomentType type;
}

/// Bir maç için oyuncunun kritik anlarını üretir.
/// Sayı ve tür dağılımı mevkiye göre değişir (bkz. [MatchBalance]).
abstract final class CriticalMomentGenerator {
  static List<CriticalMoment> generate(
    PlayerPosition position,
    GameRandom random,
  ) {
    final count = random.range(
      MatchBalance.momentCountMin,
      MatchBalance.momentCountMax,
    );

    // Benzersiz dakikalar.
    final minutes = <int>{};
    while (minutes.length < count) {
      minutes.add(random.range(2, 89));
    }

    final weights = MatchBalance.momentWeights[position]!;
    final total = weights.values.fold<double>(0, (a, b) => a + b);

    MomentType pickType() {
      var roll = random.nextDouble() * total;
      for (final entry in weights.entries) {
        roll -= entry.value;
        if (roll <= 0) return entry.key;
      }
      return weights.keys.last;
    }

    return [
      for (final minute in (minutes.toList()..sort()))
        CriticalMoment(minute: minute, type: pickType()),
    ];
  }
}
