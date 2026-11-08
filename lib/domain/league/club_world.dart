import '../../core/game_random.dart';
import 'fixture_generator.dart';
import 'league_factory.dart';
import 'team.dart';

/// Bir turdaki oyuncu kulübünün maçı.
class ClubFixture {
  const ClubFixture({required this.opponent, required this.home});

  final Team opponent;
  final bool home;
}

/// Kariyerin dünyası: 5 kademeli lig piramidi. Aynı [seed] her zaman aynı
/// dünyayı üretir; kayıtta yalnızca seed saklanır.
class ClubWorld {
  ClubWorld(this.seed) : leagues = LeagueFactory.createPyramid(GameRandom(seed)) {
    for (final league in leagues) {
      for (final team in league.teams) {
        _teams[team.id] = team;
        _tiers[team.id] = league.tier;
      }
    }
  }

  final int seed;
  final List<League> leagues;
  final Map<String, Team> _teams = {};
  final Map<String, int> _tiers = {};
  final Map<int, List<List<Fixture>>> _fixtures = {};

  Iterable<Team> get allTeams => _teams.values;

  Team team(String id) => _teams[id]!;

  /// 1 = en üst lig, 5 = amatör lig.
  int tierOf(String id) => _tiers[id]!;

  League leagueOf(String clubId) => leagues[tierOf(clubId) - 1];

  /// Kademenin 34 turluk fikstürü.
  List<List<Fixture>> fixtures(int tier) => _fixtures.putIfAbsent(
    tier,
    () => FixtureGenerator.doubleRoundRobin([
      for (final t in leagues[tier - 1].teams) t.id,
    ]),
  );

  /// [clubId] kulübünün [round]. tur (1-34) maçı.
  ClubFixture fixtureFor(String clubId, int round) {
    final tier = tierOf(clubId);
    for (final f in fixtures(tier)[round - 1]) {
      if (f.homeId == clubId) {
        return ClubFixture(opponent: team(f.awayId), home: true);
      }
      if (f.awayId == clubId) {
        return ClubFixture(opponent: team(f.homeId), home: false);
      }
    }
    throw StateError('$clubId $round. turda maç oynamıyor');
  }

  /// Yeni kariyerin başlangıç kulübü: amatör ligden, seed'e bağlı bir takım.
  Team startingClub(GameRandom random) =>
      random.pick(leagues.last.teams);
}
