// Denge ayarı için maç istatistiği yazdırır: `dart run tool/match_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/league/league_factory.dart';
import 'package:son_dusuk/domain/league/season_simulator.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';

void main() {
  const n = 20000;
  for (final (home, away) in [(60.0, 60.0), (70.0, 60.0), (85.0, 50.0)]) {
    final random = GameRandom(1);
    var goals = 0;
    var hw = 0;
    var aw = 0;
    var draws = 0;
    var zeroZero = 0;
    for (var i = 0; i < n; i++) {
      final r = MatchSimulator.simulate(
        homeStrength: home,
        awayStrength: away,
        random: random,
      );
      goals += r.totalGoals;
      if (r.homeGoals > r.awayGoals) hw++;
      if (r.homeGoals < r.awayGoals) aw++;
      if (r.homeGoals == r.awayGoals) draws++;
      if (r.totalGoals == 0) zeroZero++;
    }
    String pct(int x) => '${(100 * x / n).toStringAsFixed(1)}%';
    print(
      '$home vs $away: ${(goals / n).toStringAsFixed(2)} gol/maç, '
      'ev ${pct(hw)}, ber ${pct(draws)}, dep ${pct(aw)}, 0-0 ${pct(zeroZero)}',
    );
  }

  final league = LeagueFactory.createPyramid(GameRandom(1)).first;
  final s = SeasonSimulator.simulate(league, GameRandom(2));
  print(
    'Sezon (${s.matchCount} maç): ${s.goalsPerMatch.toStringAsFixed(2)} gol/maç, '
    'lider ${s.standings.sorted.first.points} puan',
  );
}
