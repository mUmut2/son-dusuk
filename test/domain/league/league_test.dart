import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/league/fixture_generator.dart';
import 'package:son_dusuk/domain/league/league_factory.dart';
import 'package:son_dusuk/domain/league/season_simulator.dart';
import 'package:son_dusuk/domain/league/standings.dart';

void main() {
  group('FixtureGenerator', () {
    for (final n in [4, 10, 18, 20]) {
      test('$n takım: herkes herkesle iki kez, haftada bir maç', () {
        final ids = [for (var i = 0; i < n; i++) 't$i'];
        final rounds = FixtureGenerator.doubleRoundRobin(ids);

        expect(rounds, hasLength(2 * (n - 1)));

        // Hiçbir takım aynı hafta iki maç yapmaz; herkes her hafta oynar.
        for (final round in rounds) {
          final seen = <String>[];
          for (final f in round) {
            seen
              ..add(f.homeId)
              ..add(f.awayId);
          }
          expect(seen.toSet(), hasLength(n));
          expect(seen, hasLength(n));
        }

        // Her sıralı çift (ev, deplasman) tam bir kez oynanır.
        final pairs = [
          for (final round in rounds)
            for (final f in round) '${f.homeId}-${f.awayId}',
        ];
        expect(pairs.toSet(), hasLength(n * (n - 1)));
        expect(pairs, hasLength(n * (n - 1)));

        // Herkes n-1 ev, n-1 deplasman maçı yapar.
        for (final id in ids) {
          expect(pairs.where((p) => p.startsWith('$id-')), hasLength(n - 1));
          expect(pairs.where((p) => p.endsWith('-$id')), hasLength(n - 1));
        }
      });
    }

    test('ev/deplasman dengesi: art arda 3 aynı saha yok', () {
      final ids = [for (var i = 0; i < 18; i++) 't$i'];
      final rounds = FixtureGenerator.doubleRoundRobin(ids);
      for (final id in ids) {
        var streak = 0;
        var lastHome = false;
        var worst = 0;
        for (final round in rounds) {
          final f = round.firstWhere((f) => f.homeId == id || f.awayId == id);
          final home = f.homeId == id;
          streak = (streak > 0 && home == lastHome) ? streak + 1 : 1;
          lastHome = home;
          if (streak > worst) worst = streak;
        }
        expect(worst, lessThanOrEqualTo(3), reason: '$id: $worst');
      }
    });

    test('tek sayıda takım hata verir', () {
      expect(
        () => FixtureGenerator.doubleRoundRobin(['a', 'b', 'c']),
        throwsArgumentError,
      );
    });
  });

  group('Standings', () {
    test('puan, averaj ve sıralama doğru', () {
      final s = Standings(['a', 'b', 'c'])
        ..record('a', 'b', 2, 0)
        ..record('b', 'c', 1, 1)
        ..record('c', 'a', 0, 3);

      final rows = s.sorted;
      expect(rows.map((r) => r.teamId), ['a', 'b', 'c']);
      expect(s.row('a').points, 6);
      expect(s.row('a').goalDifference, 5);
      expect(s.row('b').points, 1);
      expect(s.row('b').drawn, 1);
      expect(s.row('c').lost, 1);
    });

    test('puan eşitse averaj, sonra atılan gol belirler', () {
      final s = Standings(['a', 'b', 'c', 'd'])
        ..record('a', 'c', 1, 0) // a 3p, +1
        ..record('b', 'd', 3, 1); // b 3p, +2
      expect(s.sorted.first.teamId, 'b');
    });
  });

  group('LeagueFactory', () {
    test('5 lig, 18 takım, takım adları piramitte tek', () {
      final pyramid = LeagueFactory.createPyramid(GameRandom(1));
      expect(pyramid, hasLength(5));
      final names = <String>[];
      final ids = <String>[];
      for (final league in pyramid) {
        expect(league.teams, hasLength(18));
        for (final t in league.teams) {
          names.add(t.name);
          ids.add(t.id);
        }
      }
      expect(names.toSet(), hasLength(90));
      expect(ids.toSet(), hasLength(90));
    });

    test('üst ligler ortalama olarak daha güçlü', () {
      final pyramid = LeagueFactory.createPyramid(GameRandom(2));
      double mean(int i) =>
          pyramid[i].teams.map((t) => t.strength).reduce((a, b) => a + b) / 18;
      for (var i = 0; i < 4; i++) {
        expect(mean(i), greaterThan(mean(i + 1)));
      }
    });
  });

  group('SeasonSimulator', () {
    test('tam sezon: 306 maç, tutarlı puan durumu', () {
      final league = LeagueFactory.createPyramid(GameRandom(3)).first;
      final r = SeasonSimulator.simulate(league, GameRandom(4));
      final rows = r.standings.sorted;

      expect(r.matchCount, 306);
      expect(rows.every((row) => row.played == 34), isTrue);
      expect(
        rows.fold<int>(0, (a, row) => a + row.goalsFor),
        rows.fold<int>(0, (a, row) => a + row.goalsAgainst),
      );
      expect(rows.fold<int>(0, (a, row) => a + row.goalsFor), r.totalGoals);
      expect(
        rows.fold<int>(0, (a, row) => a + row.won),
        rows.fold<int>(0, (a, row) => a + row.lost),
      );
    });

    test('aynı seed aynı sezonu üretir', () {
      final league = LeagueFactory.createPyramid(GameRandom(3)).first;
      String table(int seed) => SeasonSimulator.simulate(
        league,
        GameRandom(seed),
      ).standings.sorted.map((r) => '${r.teamId}:${r.points}').join(',');
      expect(table(9), table(9));
    });

    test('güçlü takımlar genelde üst sıralarda biter', () {
      var strongestInTop3 = 0;
      const seasons = 40;
      for (var s = 0; s < seasons; s++) {
        final league = LeagueFactory.createPyramid(GameRandom(s)).first;
        final strongest = ([
          ...league.teams,
        ]..sort((a, b) => b.strength.compareTo(a.strength))).first;
        final r = SeasonSimulator.simulate(league, GameRandom(1000 + s));
        final top3 = r.standings.sorted.take(3).map((e) => e.teamId);
        if (top3.contains(strongest.id)) strongestInTop3++;
      }
      expect(strongestInTop3 / seasons, greaterThan(0.6));
    });
  });
}
