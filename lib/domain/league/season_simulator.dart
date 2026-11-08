import '../../core/game_random.dart';
import '../match/match_simulator.dart';
import 'fixture_generator.dart';
import 'standings.dart';
import 'team.dart';

class SeasonResult {
  const SeasonResult({
    required this.standings,
    required this.matchCount,
    required this.totalGoals,
    required this.homeWins,
    required this.draws,
  });

  final Standings standings;
  final int matchCount;
  final int totalGoals;
  final int homeWins;
  final int draws;

  double get goalsPerMatch => totalGoals / matchCount;
  double get homeWinRate => homeWins / matchCount;
  double get drawRate => draws / matchCount;
}

/// Bir ligin tüm sezonunu (oyuncusuz) simüle eder.
abstract final class SeasonSimulator {
  static SeasonResult simulate(League league, GameRandom random) {
    final byId = {for (final t in league.teams) t.id: t};
    final rounds = FixtureGenerator.doubleRoundRobin([
      for (final t in league.teams) t.id,
    ]);
    final standings = Standings(byId.keys);

    var matches = 0;
    var goals = 0;
    var homeWins = 0;
    var draws = 0;

    for (final round in rounds) {
      for (final fixture in round) {
        final result = MatchSimulator.simulate(
          homeStrength: byId[fixture.homeId]!.strength,
          awayStrength: byId[fixture.awayId]!.strength,
          random: random,
        );
        standings.record(
          fixture.homeId,
          fixture.awayId,
          result.homeGoals,
          result.awayGoals,
        );
        matches++;
        goals += result.totalGoals;
        if (result.homeGoals > result.awayGoals) homeWins++;
        if (result.homeGoals == result.awayGoals) draws++;
      }
    }

    return SeasonResult(
      standings: standings,
      matchCount: matches,
      totalGoals: goals,
      homeWins: homeWins,
      draws: draws,
    );
  }
}
