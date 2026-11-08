import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_migrations.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

CareerState newCareer({
  int seed = 1,
  int week = 1,
  PlayerStatus status = const PlayerStatus(),
  double injuryProneness = 0.5,
}) {
  final p = PlayerFactory.create(
    name: 'T',
    birthplace: 'Ankara',
    position: PlayerPosition.forward,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: GameRandom(seed),
  );
  return CareerState(
    player: Player(
      name: p.name,
      birthplace: p.birthplace,
      position: p.position,
      foot: p.foot,
      appearance: p.appearance,
      age: p.age,
      attributes: p.attributes,
      potential: 85,
      injuryProneness: injuryProneness,
      professionalism: 0.5,
    ),
    week: week,
    status: status,
  );
}

const injury = Injury(type: InjuryType.muscle, weeksLeft: 3, totalWeeks: 3);

WeekMatch match(double rating, MatchResultKind r, {int goals = 0}) =>
    WeekMatch(rating: rating, goals: goals, assists: 0, result: r);

void main() {
  group('antrenman', () {
    test('odaktaki nitelikler artar, diğerleri aynı kalır', () {
      final s = newCareer();
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(focus: TrainingFocus.shooting),
        null,
        GameRandom(1),
      );
      final a0 = s.player.attributes;
      final a1 = r.state.player.attributes;
      for (final a in [Attribute.shooting, Attribute.finesse]) {
        expect(a1.raw(a), greaterThan(a0.raw(a)));
      }
      expect(a1.raw(Attribute.pace), a0.raw(Attribute.pace));
      expect(r.report.attributeGains, isNotEmpty);
    });

    test('yoğunluk kazancı artırır, dinlenme hiç kazandırmaz', () {
      double gain(TrainingIntensity i) {
        final r = WeekEngine.advance(
          newCareer(),
          WeeklyPlan(focus: TrainingFocus.technical, intensity: i),
          null,
          GameRandom(1),
        );
        return r.report.attributeGains.fold(0.0, (s, g) => s + g.delta);
      }

      expect(
        gain(TrainingIntensity.hard),
        greaterThan(gain(TrainingIntensity.normal)),
      );
      expect(
        gain(TrainingIntensity.normal),
        greaterThan(gain(TrainingIntensity.light)),
      );

      final rest = WeekEngine.advance(
        newCareer(),
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(1),
      );
      expect(rest.report.attributeGains, isEmpty);
    });

    test('yaş büyüdükçe antrenman verimi düşer', () {
      double gainAt(int age) {
        final base = newCareer();
        final s = base.copyWith(player: base.player.copyWith(age: age));
        return WeekEngine.advance(
          s,
          const WeeklyPlan(),
          null,
          GameRandom(1),
        ).report.attributeGains.fold(0.0, (a, g) => a + g.delta);
      }

      expect(gainAt(17), greaterThan(gainAt(24)));
      expect(gainAt(24), greaterThan(gainAt(33)));
    });
  });

  group('kondisyon', () {
    test('dinlenme odağı kondisyonu yeniler, sert antrenman yorar', () {
      const tired = PlayerStatus(condition: 40);
      final rest = WeekEngine.advance(
        newCareer(status: tired),
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(2),
      );
      final hard = WeekEngine.advance(
        newCareer(status: tired),
        const WeeklyPlan(intensity: TrainingIntensity.hard),
        match(6, MatchResultKind.draw),
        GameRandom(2),
      );
      expect(rest.state.status.condition, greaterThan(tired.condition + 30));
      expect(hard.state.status.condition, lessThan(tired.condition + 5));
    });

    test('0-100 aralığında kalır', () {
      final r = WeekEngine.advance(
        newCareer(),
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(1),
      );
      expect(r.state.status.condition, 100);
    });
  });

  group('sakatlık', () {
    test('sakat oyuncu antrenman yapmaz, maç oynamaz, süre azalır', () {
      final s = newCareer(status: const PlayerStatus(injury: injury));
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(focus: TrainingFocus.shooting),
        match(8, MatchResultKind.win),
        GameRandom(3),
      );
      expect(r.report.attributeGains, isEmpty);
      expect(r.report.playedMatch, isFalse);
      expect(r.state.stats.matches, 0);
      expect(
        r.report.events.map((e) => e.kind),
        contains(WeekEventKind.trainingBlocked),
      );
      expect(r.state.status.injury!.weeksLeft, lessThan(3));
    });

    test('iyileşince sakatlık biter ve olay üretir', () {
      var s = newCareer(
        status: const PlayerStatus(
          injury: Injury(type: InjuryType.muscle, weeksLeft: 1, totalWeeks: 1),
        ),
      );
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(3),
      );
      s = r.state;
      expect(s.status.isInjured, isFalse);
      expect(
        r.report.events.map((e) => e.kind),
        contains(WeekEventKind.healed),
      );
    });

    test('düşük kondisyon sakatlık oranını belirgin artırır', () {
      int injuries(double condition) {
        var count = 0;
        final random = GameRandom(7);
        for (var i = 0; i < 4000; i++) {
          final r = WeekEngine.advance(
            newCareer(status: PlayerStatus(condition: condition)),
            const WeeklyPlan(
              focus: TrainingFocus.rest,
              intensity: TrainingIntensity.light,
            ),
            null,
            random,
          );
          if (r.state.status.isInjured) count++;
        }
        return count;
      }

      // Dinlenme kondisyonu +45 yenilediği için çok düşükten başlatıyoruz.
      expect(injuries(0), greaterThan(injuries(100)));
    });

    test('yüksek sakatlanma eğilimi daha çok sakatlık getirir', () {
      int injuries(double prone) {
        var count = 0;
        final random = GameRandom(8);
        for (var i = 0; i < 6000; i++) {
          final r = WeekEngine.advance(
            newCareer(injuryProneness: prone),
            const WeeklyPlan(),
            match(6, MatchResultKind.draw),
            random,
          );
          if (r.state.status.isInjured) count++;
        }
        return count;
      }

      expect(injuries(1), greaterThan(injuries(0)));
    });

    test(
      'riskli erken dönüş: sakatlık biter, tekrar sakatlanma riski yüksek',
      () {
        final s = newCareer(status: const PlayerStatus(injury: injury));
        final back = WeekEngine.returnEarly(s);
        expect(back.status.isInjured, isFalse);
        expect(back.status.relapseRisk, greaterThan(0.3));
        expect(back.status.condition, lessThan(100));

        int injuries(CareerState c) {
          var count = 0;
          final random = GameRandom(9);
          for (var i = 0; i < 3000; i++) {
            if (WeekEngine.advance(
              c,
              const WeeklyPlan(),
              null,
              random,
            ).state.status.isInjured) {
              count++;
            }
          }
          return count;
        }

        final healthy = newCareer();
        expect(injuries(back), greaterThan(injuries(healthy) * 5));
      },
    );

    test('tekrar sakatlanma daha uzun sürer ve işaretlenir', () {
      final c = newCareer(status: const PlayerStatus(relapseRisk: 1));
      final r = WeekEngine.advance(c, const WeeklyPlan(), null, GameRandom(1));
      expect(r.state.status.isInjured, isTrue);
      expect(r.state.status.injury!.isRelapse, isTrue);
      expect(
        r.report.events.map((e) => e.kind),
        contains(WeekEventKind.relapse),
      );
    });

    test('erken dönüş sakat değilse etkisiz', () {
      final s = newCareer();
      expect(WeekEngine.returnEarly(s).status.relapseRisk, 0);
    });
  });

  group('form (son 5 maçın ortalaması, 0-10)', () {
    test('başlangıç formu 6.0 (maç yok)', () {
      expect(const PlayerStatus().form, 6.0);
      final r = WeekEngine.advance(
        newCareer(),
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(1),
      );
      expect(r.state.status.form, 6.0);
    });

    test('form tam olarak son maçların reyting ortalamasıdır', () {
      var s = newCareer();
      final random = GameRandom(1);
      for (final rating in [8.0, 7.0, 6.0]) {
        s = WeekEngine.advance(
          s,
          const WeeklyPlan(focus: TrainingFocus.rest),
          match(rating, MatchResultKind.draw),
          random,
        ).state;
      }
      expect(s.status.form, closeTo(7.0, 1e-9));
    });

    test('iyi maçlar formu 10a, kötü maçlar 0a yaklaştırır', () {
      var good = newCareer();
      var bad = newCareer();
      final random = GameRandom(1);
      for (var i = 0; i < 4; i++) {
        good = WeekEngine.advance(
          good,
          const WeeklyPlan(focus: TrainingFocus.rest),
          match(9, MatchResultKind.win),
          random,
        ).state;
        bad = WeekEngine.advance(
          bad,
          const WeeklyPlan(focus: TrainingFocus.rest),
          match(3, MatchResultKind.loss),
          random,
        ).state;
      }
      expect(good.status.form, 9);
      expect(bad.status.form, 3);
      expect(good.status.form, lessThanOrEqualTo(10));
      expect(bad.status.form, greaterThanOrEqualTo(0));
    });

    test('pencere son 5 maçı tutar (eski maçlar düşer)', () {
      var s = newCareer();
      final random = GameRandom(1);
      for (final rating in [2.0, 8.0, 8.0, 8.0, 8.0, 8.0]) {
        s = WeekEngine.advance(
          s,
          const WeeklyPlan(focus: TrainingFocus.rest),
          match(rating, MatchResultKind.draw),
          random,
        ).state;
      }
      expect(s.status.recentRatings, hasLength(5));
      expect(s.status.form, closeTo(8.0, 1e-9));
    });

    test('maç oynanmayan haftada form değişmez', () {
      var s = newCareer(status: const PlayerStatus(form: 8));
      final random = GameRandom(1);
      for (var i = 0; i < 5; i++) {
        s = WeekEngine.advance(
          s,
          const WeeklyPlan(focus: TrainingFocus.rest),
          null,
          random,
        ).state;
      }
      expect(s.status.form, 8);
    });
  });

  group('moral', () {
    test('galibiyet ve iyi reyting moral artırır; mağlubiyet düşürür', () {
      const base = PlayerStatus(morale: 60);
      final win = WeekEngine.advance(
        newCareer(status: base),
        const WeeklyPlan(focus: TrainingFocus.rest),
        match(8, MatchResultKind.win),
        GameRandom(1),
      );
      final loss = WeekEngine.advance(
        newCareer(status: base),
        const WeeklyPlan(focus: TrainingFocus.rest),
        match(4.5, MatchResultKind.loss),
        GameRandom(1),
      );
      expect(win.state.status.morale, greaterThan(60));
      expect(loss.state.status.morale, lessThan(60));
    });

    test('sosyal aktivite moral kazandırır; arkadaşlar kondisyondan yer', () {
      final none = WeekEngine.advance(
        newCareer(),
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(1),
      );
      final friends = WeekEngine.advance(
        newCareer(),
        const WeeklyPlan(
          focus: TrainingFocus.rest,
          social: SocialActivity.friends,
        ),
        null,
        GameRandom(1),
      );
      expect(
        friends.state.status.morale,
        greaterThan(none.state.status.morale),
      );
      expect(
        friends.report.totalDelta(StatKind.condition),
        lessThan(none.report.totalDelta(StatKind.condition)),
      );
    });

    test('moral zamanla başlangıç seviyesine yaklaşır', () {
      var s = newCareer(status: const PlayerStatus(morale: 10));
      final random = GameRandom(1);
      for (var i = 0; i < 30; i++) {
        s = WeekEngine.advance(
          s,
          const WeeklyPlan(focus: TrainingFocus.rest),
          null,
          random,
        ).state;
      }
      expect(s.status.morale, inInclusiveRange(40, 70));
    });

    test('zincir: sakatlık moral düşürür', () {
      // Sakatlanma anı moral cezası verir (rapor nedeni injuryOnset).
      final c = newCareer(status: const PlayerStatus(relapseRisk: 1));
      final r = WeekEngine.advance(c, const WeeklyPlan(), null, GameRandom(1));
      expect(
        r.report.statChanges.map((x) => x.reason),
        contains(WeekReason.injuryOnset),
      );
      expect(r.state.status.morale, lessThan(c.status.morale));
    });
  });

  group('performans çarpanı', () {
    test('form artırır, düşük kondisyon ve moral azaltır', () {
      const neutral = PlayerStatus();
      expect(neutral.performanceMultiplier, 1);
      expect(
        const PlayerStatus(form: 10).performanceMultiplier,
        greaterThan(1),
      );
      expect(
        const PlayerStatus(condition: 10).performanceMultiplier,
        lessThan(0.85),
      );
      expect(
        const PlayerStatus(morale: 5).performanceMultiplier,
        lessThan(0.95),
      );
      expect(
        const PlayerStatus(
          condition: 0,
          morale: 0,
          form: -10,
        ).performanceMultiplier,
        greaterThanOrEqualTo(0.6),
      );
    });
  });

  group('takvim', () {
    test('hafta ilerler; sezon sonunda yaş ve sezon artar', () {
      var s = newCareer(week: SeasonCalendar.weeksPerSeason);
      expect(s.player.age, 16);
      final r = WeekEngine.advance(
        s,
        const WeeklyPlan(focus: TrainingFocus.rest),
        null,
        GameRandom(1),
      );
      s = r.state;
      expect(s.season, 2);
      expect(s.week, 1);
      expect(s.player.age, 17);
      expect(
        r.report.events.map((e) => e.kind),
        contains(WeekEventKind.newSeason),
      );
      expect(r.report.week, SeasonCalendar.weeksPerSeason);

      final mid = WeekEngine.advance(
        newCareer(week: 10),
        const WeeklyPlan(),
        null,
        GameRandom(1),
      );
      expect(mid.state.week, 11);
      expect(mid.state.season, 1);
    });

    test('lig maçı yalnızca lig haftalarında var', () {
      expect(WeekEngine.hasMatch(2), isFalse);
      expect(WeekEngine.hasMatch(5), isTrue);
      expect(WeekEngine.hasMatch(38), isTrue);
      expect(WeekEngine.hasMatch(40), isFalse);
    });
  });

  group('kayıt', () {
    test('durum JSON gidiş-dönüş kayıpsız', () {
      final s = newCareer(
        status: const PlayerStatus(
          condition: 55.5,
          form: 7.4,
          morale: 70,
          injury: injury,
          relapseRisk: 0.2,
          recentRatings: [6.5, 7.2],
        ),
      ).copyWith(stats: const CareerStats(matches: 3, goals: 2, ratingSum: 20));
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(jsonEncode(back.toJson()), jsonEncode(s.toJson()));
      expect(back.status.injury!.type, InjuryType.muscle);
      expect(back.stats.averageRating, closeTo(20 / 3, 1e-9));
    });

    test('v1 kaydı v2\'ye göç eder (varsayılan durum eklenir)', () {
      final v1 = {
        'schemaVersion': 1,
        'career': {
          'player': newCareer().player.toJson(),
          'season': 2,
          'week': 7,
        },
      };
      final migrated = const SaveMigrator().migrate(v1);
      expect(migrated['schemaVersion'], 3);
      final career = CareerState.fromJson(
        migrated['career'] as Map<String, dynamic>,
      );
      expect(career.week, 7);
      expect(career.status.condition, 100);
      expect(career.stats.matches, 0);
    });
  });

  group('kayıt: form göçü', () {
    test('v2 kaydı v3e göç eder: form reyting ortalamasına dönüşür', () {
      final v2 = {
        'schemaVersion': 2,
        'career': {
          'player': newCareer().player.toJson(),
          'status': {
            'condition': 80,
            'form': -4, // eski -10..+10 ölçeği
            'morale': 55,
            'recentRatings': [5.0, 7.0],
          },
        },
      };
      final migrated = const SaveMigrator().migrate(v2);
      expect(migrated['schemaVersion'], 3);
      final career = CareerState.fromJson(
        migrated['career'] as Map<String, dynamic>,
      );
      expect(career.status.form, closeTo(6.0, 1e-9));
      expect(career.status.condition, 80);
    });

    test('maçı olmayan v2 kaydında form 6.0 olur', () {
      final v2 = {
        'schemaVersion': 2,
        'career': {
          'player': newCareer().player.toJson(),
          'status': {'condition': 90, 'form': 2.5, 'morale': 60},
        },
      };
      final career = CareerState.fromJson(
        const SaveMigrator().migrate(v2)['career'] as Map<String, dynamic>,
      );
      expect(career.status.form, 6.0);
    });
  });

  group('denge: uzun vadeli simülasyon', () {
    ({double injuriesPerSeason, double avgCondition, int gain}) run(
      WeeklyPlan plan, {
      int seasons = 3,
      int careers = 60,
    }) {
      var injuries = 0;
      var weeks = 0;
      var conditionSum = 0.0;
      var totalGain = 0.0;
      for (var c = 0; c < careers; c++) {
        final random = GameRandom(100 + c);
        var s = newCareer(seed: c);
        final start = s.player.attributes;
        var wasInjured = false;
        for (var w = 0; w < SeasonCalendar.weeksPerSeason * seasons; w++) {
          final hasMatch = WeekEngine.hasMatch(s.week) && !s.status.isInjured;
          final result = WeekEngine.advance(
            s,
            plan,
            hasMatch ? match(6.2, MatchResultKind.draw) : null,
            random,
          );
          s = result.state;
          if (s.status.isInjured && !wasInjured) injuries++;
          wasInjured = s.status.isInjured;
          conditionSum += s.status.condition;
          weeks++;
          expect(s.status.condition, inInclusiveRange(0, 100));
          expect(s.status.morale, inInclusiveRange(0, 100));
          expect(s.status.form, inInclusiveRange(0, 10));
        }
        for (final a in Attribute.values) {
          totalGain += s.player.attributes.raw(a) - start.raw(a);
        }
      }
      return (
        injuriesPerSeason: injuries / (careers * seasons),
        avgCondition: conditionSum / weeks,
        gain: (totalGain / careers).round(),
      );
    }

    test('makul sakatlık sıklığı ve kondisyon (normal plan)', () {
      final r = run(const WeeklyPlan());
      // ignore: avoid_print
      print(
        'normal: sakatlık/sezon ${r.injuriesPerSeason.toStringAsFixed(2)}, '
        'ort. kondisyon ${r.avgCondition.toStringAsFixed(0)}',
      );
      expect(r.injuriesPerSeason, inInclusiveRange(0.3, 2.0));
      expect(r.avgCondition, inInclusiveRange(55, 100));
    });

    test('sürekli sert antrenman yorar ve daha çok sakatlık getirir', () {
      final normal = run(const WeeklyPlan());
      final hard = run(const WeeklyPlan(intensity: TrainingIntensity.hard));
      // ignore: avoid_print
      print(
        'sert: sakatlık/sezon ${hard.injuriesPerSeason.toStringAsFixed(2)}, '
        'ort. kondisyon ${hard.avgCondition.toStringAsFixed(0)}',
      );
      expect(hard.avgCondition, lessThan(normal.avgCondition));
      expect(hard.injuriesPerSeason, greaterThan(normal.injuriesPerSeason));
    });

    test('antrenman, antrenmansızdan daha çok gelişim sağlar', () {
      final trained = run(const WeeklyPlan());
      final idle = run(const WeeklyPlan(focus: TrainingFocus.rest));
      expect(trained.gain, greaterThan(idle.gain));
    });
  });
}
