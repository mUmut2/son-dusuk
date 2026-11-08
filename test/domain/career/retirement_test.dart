import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_migrations.dart';
import 'package:son_dusuk/domain/achievements/achievements.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/legacy_balance.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/career/retirement.dart';
import 'package:son_dusuk/domain/career/season_record.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/national/national_career.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

CareerState career({int age = 31}) {
  final base = CareerFactory.create(
    PlayerFactory.create(
      name: 'Deniz',
      birthplace: 'Bursa',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: GameRandom(1),
    ),
    GameRandom(1),
  );
  return base.copyWith(player: base.player.copyWith(age: age));
}

SeasonRecord record(int season, {String? club = 't5_0', int position = 3}) =>
    SeasonRecord(
      season: season,
      age: 16 + season,
      overall: 60,
      clubId: club,
      tier: 5,
      position: position,
      matches: 30,
      goals: 10,
      assists: 4,
      averageRating: 6.5,
    );

void main() {
  group('başarımlar', () {
    test('koşul sağlanınca açılır, tekrar açılmaz', () {
      final s = career().copyWith(
        stats: const CareerStats(matches: 1, goals: 1),
      );
      final first = AchievementEngine.sync(s);
      expect(
        first.unlocked,
        containsAll([Achievement.firstMatch, Achievement.firstGoal]),
      );
      expect(first.events.first.kind, WeekEventKind.achievement);
      expect(first.state.achievements.keys, contains('firstMatch'));
      expect(first.state.news, isNotEmpty);

      final second = AchievementEngine.sync(first.state);
      expect(second.unlocked, isEmpty);
    });

    test('hat-trick ve yüksek reyting yalnızca o maçta açılır', () {
      final s = career();
      expect(
        AchievementEngine.sync(s, matchGoals: 3).unlocked,
        contains(Achievement.hatTrick),
      );
      expect(
        AchievementEngine.sync(s, matchGoals: 2).unlocked,
        isNot(contains(Achievement.hatTrick)),
      );
      expect(
        AchievementEngine.sync(s, matchRating: 9.9).unlocked,
        contains(Achievement.starPerformance),
      );
    });

    test('milli takım ve lig başarımları geçmişten gelir', () {
      final s = career().copyWith(
        history: [record(1, position: 1)],
        national: const NationalCareer(
          caps: 2,
          goals: 1,
          past: [
            TournamentRecord(
              season: 4,
              kind: TournamentKind.world,
              called: true,
              stage: TournamentStage.champion,
            ),
          ],
        ),
      );
      final got = AchievementEngine.sync(s, tier: 1).unlocked;
      expect(
        got,
        containsAll([
          Achievement.leagueChampion,
          Achievement.topLeague,
          Achievement.nationalDebut,
          Achievement.nationalGoal,
          Achievement.nationalFinal,
          Achievement.worldChampion,
        ]),
      );
      expect(got, isNot(contains(Achievement.continentalChampion)));
    });

    test('sadakat: 10 sezon arka arkaya aynı kulüp', () {
      bool loyal(int n) => AchievementEngine.isMet(
        Achievement.loyal,
        career().copyWith(history: [for (var i = 1; i <= n; i++) record(i)]),
      );
      expect(loyal(9), isFalse);
      expect(loyal(10), isTrue);
    });
  });

  group('emeklilik', () {
    test('gönüllü emeklilik yaşı ve zorunlu yaş', () {
      expect(Retirement.canRetire(career(age: 29)), isFalse);
      expect(
        Retirement.canRetire(career(age: LegacyBalance.voluntaryAge)),
        isTrue,
      );
      expect(Retirement.mustRetire(career(age: 39)), isFalse);
      expect(Retirement.mustRetire(career(age: 40)), isTrue);
    });

    test(
      'emekli olunca yarım sezon geçmişe yazılır, bekleyenler temizlenir',
      () {
        final s = career().copyWith(
          seasonStats: const CareerStats(matches: 5, goals: 2, assists: 1),
          stats: const CareerStats(matches: 5, goals: 2, assists: 1),
        );
        final r = Retirement.retire(s);
        expect(r.retired, isTrue);
        expect(r.history.single.matches, 5);
        expect(r.offers, isEmpty);
        expect(r.pendingEvents, isEmpty);
        expect(r.news.first.kind.name, 'achievement');
        // İkinci çağrı bir şeyi değiştirmez.
        expect(Retirement.retire(r).history, hasLength(1));
        expect(Retirement.canRetire(r), isFalse);
      },
    );

    test('kariyer özeti: toplamlar ve miras sıralaması', () {
      final empty = CareerSummary.of(career());
      expect(empty.rank, LegacyRank.amateur);

      final big = career().copyWith(
        stats: const CareerStats(matches: 600, goals: 400, assists: 150),
        history: [for (var i = 1; i <= 20; i++) record(i, position: 1)],
        national: const NationalCareer(caps: 50, goals: 20),
        achievements: {for (final a in Achievement.values) a.name: 1},
      );
      final summary = CareerSummary.of(big, tier: 1);
      expect(summary.seasons, 20);
      expect(summary.leagueTitles, 20);
      expect(summary.bestTier, 1);
      expect(summary.rank, LegacyRank.legend);
      expect(summary.score, greaterThan(empty.score));
    });

    test('sıralama eşikleri artan sırada', () {
      final t = LegacyBalance.rankThresholds;
      for (var i = 1; i < t.length; i++) {
        expect(t[i], greaterThan(t[i - 1]));
      }
      expect(t, hasLength(LegacyRank.values.length));
    });
  });

  group('sezon geçmişi ve zorunlu emeklilik (hafta motoru)', () {
    test(
      'sezon bitince geçmişe kayıt yazılır, sezon istatistiği sıfırlanır',
      () {
        final s = career(age: 22).copyWith(
          week: 42,
          seasonStats: const CareerStats(matches: 20, goals: 7, assists: 3),
        );
        final r = WeekEngine.advance(
          s,
          const WeeklyPlan(),
          null,
          GameRandom(2),
        );
        expect(r.state.season, 2);
        expect(r.state.history, hasLength(1));
        expect(r.state.history.single.season, 1);
        expect(r.state.history.single.goals, 7);
        expect(r.state.history.single.position, inInclusiveRange(1, 18));
        expect(r.state.seasonStats.matches, 0);
      },
    );

    test('40 yaşa gelen oyuncu sezon sonunda emekli olur', () {
      final s = career(age: 39).copyWith(week: 42);
      final r = WeekEngine.advance(s, const WeeklyPlan(), null, GameRandom(2));
      expect(r.state.player.age, 40);
      expect(r.state.retired, isTrue);
      expect(
        r.report.events.map((e) => e.kind),
        contains(WeekEventKind.retired),
      );
    });

    test('maç oynanınca sezon istatistiği de artar', () {
      final s = career(age: 22).copyWith(week: 10);
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(),
        const WeekMatch(
          rating: 7,
          goals: 3,
          assists: 0,
          result: MatchResultKind.win,
          scoreFor: 3,
          scoreAgainst: 0,
        ),
        GameRandom(3),
      );
      expect(r.state.seasonStats.goals, 3);
      expect(r.state.stats.goals, 3);
      // Hat-trick başarımı aynı haftanın raporunda görünür.
      expect(
        r.report.events
            .where((e) => e.kind == WeekEventKind.achievement)
            .map((e) => e.detail),
        contains('hatTrick'),
      );
    });
  });

  group('kayıt', () {
    test('Faz 8 alanları JSON gidiş-dönüşte korunur', () {
      final s = career().copyWith(
        seasonStats: const CareerStats(matches: 3),
        history: [record(1)],
        achievements: {'firstMatch': 5},
        retired: true,
        national: const NationalCareer(caps: 4),
      );
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(back.retired, isTrue);
      expect(back.history.single.clubId, 't5_0');
      expect(back.achievements['firstMatch'], 5);
      expect(back.national.caps, 4);
      expect(back.seasonStats.matches, 3);
    });

    test('v5 kaydı yeni alanlar olmadan yüklenir (varsayılanlar)', () {
      final json = career().toJson()
        ..remove('seasonStats')
        ..remove('history')
        ..remove('national')
        ..remove('achievements')
        ..remove('retired');
      final envelope = {
        'schemaVersion': 5,
        'savedAt': '2026-01-01T00:00:00.000',
        'career': json,
      };
      final migrated = const SaveMigrator().migrate(envelope);
      expect(migrated['schemaVersion'], currentSchemaVersion);
      final back = CareerState.fromJson(
        migrated['career'] as Map<String, dynamic>,
      );
      expect(back.retired, isFalse);
      expect(back.history, isEmpty);
      expect(back.national.caps, 0);
      expect(back.achievements, isEmpty);
    });

    test('transfer sayacı yalnızca kulüp değişiminde artar', () {
      const stats = CareerStats();
      expect(stats.addTransfer().transfers, 1);
      expect(stats.addMatch(goals: 0, assists: 0, rating: 6).transfers, 0);
      expect(stats.addTransfer().addPenalty(2).transfers, 1);
    });
  });
}
