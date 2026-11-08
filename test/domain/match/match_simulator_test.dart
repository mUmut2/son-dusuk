import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';

({double goals, double homeWin, double awayWin, double draw, double strongWin})
run(double home, double away, {int n = 4000, int seed = 1}) {
  final random = GameRandom(seed);
  var goals = 0;
  var hw = 0;
  var aw = 0;
  var d = 0;
  for (var i = 0; i < n; i++) {
    final r = MatchSimulator.simulate(
      homeStrength: home,
      awayStrength: away,
      random: random,
    );
    goals += r.totalGoals;
    if (r.homeGoals > r.awayGoals) {
      hw++;
    } else if (r.homeGoals < r.awayGoals) {
      aw++;
    } else {
      d++;
    }
  }
  return (
    goals: goals / n,
    homeWin: hw / n,
    awayWin: aw / n,
    draw: d / n,
    strongWin: (home >= away ? hw : aw) / n,
  );
}

void main() {
  group('MatchSimulator', () {
    test('eşit takımlar: maç başı ~2.5-3 gol', () {
      final s = run(60, 60);
      expect(s.goals, inInclusiveRange(2.5, 3.0));
    });

    test('ev sahibi avantajı var', () {
      final s = run(60, 60);
      expect(s.homeWin, greaterThan(s.awayWin + 0.05));
      // Gerçekçi dağılım: ~%40-48 ev, ~%22-30 beraberlik.
      expect(s.homeWin, inInclusiveRange(0.38, 0.5));
      expect(s.draw, inInclusiveRange(0.2, 0.32));
    });

    test('güçlü takım daha sık kazanır', () {
      final even = run(60, 60);
      final mild = run(70, 60);
      final big = run(85, 50);
      expect(mild.homeWin, greaterThan(even.homeWin + 0.05));
      expect(big.homeWin, greaterThan(0.8));
      // Güçlü deplasman takımı yine de favori.
      expect(run(50, 70).awayWin, greaterThan(0.5));
    });

    test('çok güçlü fark bile gol sayısını uçurmaz', () {
      expect(run(90, 40).goals, lessThan(4.5));
    });

    test('aynı seed aynı maçı üretir', () {
      MatchSimulator.simulate(
        homeStrength: 60,
        awayStrength: 55,
        random: GameRandom(3),
      );
      String score(int seed) {
        final r = MatchSimulator.simulate(
          homeStrength: 60,
          awayStrength: 55,
          random: GameRandom(seed),
        );
        return '${r.homeGoals}-${r.awayGoals}:'
            '${r.goals.map((g) => g.minute).join(",")}';
      }

      expect(score(7), score(7));
    });

    test('gol dakikaları 1-90 arasında', () {
      final r = MatchSimulator.simulate(
        homeStrength: 80,
        awayStrength: 40,
        random: GameRandom(5),
      );
      expect(r.goals.every((g) => g.minute >= 1 && g.minute <= 90), isTrue);
    });
  });
}
