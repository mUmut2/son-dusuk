import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/match/minigames/dribble.dart';
import 'package:son_dusuk/domain/match/minigames/free_kick.dart';
import 'package:son_dusuk/domain/match/minigames/header.dart';
import 'package:son_dusuk/domain/match/minigames/mini_balance.dart';
import 'package:son_dusuk/domain/match/minigames/pass.dart';
import 'package:son_dusuk/domain/match/minigames/penalty.dart';
import 'package:son_dusuk/domain/match/minigames/tackle.dart';
import 'package:son_dusuk/domain/match/shot/shot_models.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/attributes.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/position.dart';

Player playerAt(double level) => Player(
  name: 'x',
  birthplace: 'x',
  position: PlayerPosition.forward,
  foot: PreferredFoot.right,
  appearance: const Appearance(),
  age: 25,
  attributes: Attributes({for (final a in Attribute.values) a: level}),
  potential: 80,
  injuryProneness: 0.5,
  professionalism: 0.5,
);

const trials = 6000;

void main() {
  group('Penaltı', () {
    double rate(
      int Function(GameRandom) zone, {
      double power = 0.8,
      double composure = 0.5,
      List<int>? history,
      double performance = 1,
    }) {
      final r = GameRandom(1);
      var goals = 0;
      for (var i = 0; i < trials; i++) {
        if (PenaltyResolver.resolve(
          zone: zone(r),
          power: power,
          composure: composure,
          shooting: 0.5,
          keeperSkill: 0.55,
          history: history ?? List.filled(6, 0),
          random: r,
          performance: performance,
        ).isGoal) {
          goals++;
        }
      }
      return goals / trials;
    }

    test('kaleci olasılıkları toplamı 1; geçmiş eğilimi kaydırır', () {
      final even = PenaltyResolver.keeperWeights(List.filled(6, 0));
      expect(even.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
      expect(even.every((w) => (w - 1 / 6).abs() < 1e-9), isTrue);

      final biased = PenaltyResolver.keeperWeights([0, 0, 0, 0, 0, 12]);
      expect(biased.fold<double>(0, (a, b) => a + b), closeTo(1, 1e-9));
      expect(biased[5], greaterThan(biased[0] * 3));
    });

    test('gerçekçi gol oranı (~%70-80)', () {
      expect(rate((r) => r.nextInt(6)), inInclusiveRange(0.62, 0.85));
    });

    test('hep aynı köşeye vurmak okunur ve cezalandırılır', () {
      final predictable = rate((r) => 5, history: [0, 0, 0, 0, 0, 12]);
      final varied = rate((r) => r.nextInt(6), history: [0, 0, 0, 0, 0, 12]);
      expect(varied, greaterThan(predictable + 0.1));
    });

    test('zayıf vuruş daha çok kurtarılır, aşırı güç sapmayı artırır', () {
      expect(
        rate((r) => 4, power: 0.8),
        greaterThan(rate((r) => 4, power: 0.2)),
      );
      expect(
        rate((r) => r.pick([3, 5]), power: 0.8, composure: 0.1),
        greaterThan(rate((r) => r.pick([3, 5]), power: 1, composure: 0.1)),
      );
    });

    test('Sakinlik titremeyi azaltır (köşelerde daha az auta)', () {
      expect(
        rate((r) => r.pick([3, 5]), composure: 0.95),
        greaterThan(rate((r) => r.pick([3, 5]), composure: 0.05)),
      );
    });

    test('düşük performans (yorgunluk) gol oranını düşürür', () {
      expect(
        rate((r) => r.pick([3, 5]), performance: 1),
        greaterThan(rate((r) => r.pick([3, 5]), performance: 0.6)),
      );
    });

    test('bölge koordinatları 6 bölgeyi kapsar', () {
      final points = {
        for (var z = 0; z < 6; z++)
          (PenaltyResolver.zoneX(z), PenaltyResolver.zoneY(z)),
      };
      expect(points, hasLength(6));
    });
  });

  group('Serbest vuruş', () {
    final profile = ShotProfile.freeKick(playerAt(60), Difficulty.normal);
    const wall = WallSpec(centerX: 0, halfWidth: 0.25, jumps: false);

    ShotResult kick(ShotInput input, {WallSpec w = wall, int seed = 1}) =>
        FreeKickResolver.resolve(
          input: input,
          profile: profile,
          wall: w,
          keeperSkill: 0.5,
          random: GameRandom(seed),
        );

    test('düz ve alçak vuruş duvara takılır', () {
      final r = kick(
        const ShotInput(aimX: 0, aimY: 0.2, power: 0.7, curve: 0, timing: 1),
      );
      expect(r.outcome, ShotOutcome.blocked);
    });

    test('duvarın yanından hedef alınırsa engellenmez', () {
      for (var seed = 0; seed < 30; seed++) {
        final r = kick(
          const ShotInput(
            aimX: 0.8,
            aimY: 0.2,
            power: 0.7,
            curve: 0,
            timing: 1,
          ),
          seed: seed,
        );
        expect(r.outcome, isNot(ShotOutcome.blocked));
      }
    });

    test('duvarı aşan yüksek vuruş engellenmez; zıplayan duvar daha zor', () {
      const high = ShotInput(
        aimX: 0,
        aimY: 0.62,
        power: 0.7,
        curve: 0,
        timing: 1,
      );
      expect(kick(high).outcome, isNot(ShotOutcome.blocked));
      const jumping = WallSpec(centerX: 0, halfWidth: 0.25, jumps: true);
      expect(kick(high, w: jumping).outcome, ShotOutcome.blocked);
      expect(jumping.height, greaterThan(wall.height));
    });

    test('Duran Top yüksek oyuncunun falsosu daha etkili', () {
      final weak = ShotProfile.freeKick(playerAt(20), Difficulty.normal);
      final strong = ShotProfile.freeKick(playerAt(95), Difficulty.normal);
      expect(strong.curveGain, greaterThan(weak.curveGain * 1.3));
      expect(strong.sigma, lessThan(weak.sigma));
    });

    test('rastgele duvar geçerli aralıklarda', () {
      final r = GameRandom(1);
      for (var i = 0; i < 200; i++) {
        final w = WallSpec.random(r);
        expect(w.halfWidth, inInclusiveRange(0.14, 0.30));
        expect(w.centerX.abs(), lessThanOrEqualTo(0.35));
      }
    });
  });

  group('Kafa vuruşu', () {
    double rate(double timing, double pressure, {double strength = 0.5}) {
      final r = GameRandom(3);
      final profile = ShotProfile.header(playerAt(50), Difficulty.normal);
      var goals = 0;
      for (var i = 0; i < trials; i++) {
        if (HeaderResolver.resolve(
          input: ShotInput(
            aimX: (r.nextDouble() * 2 - 1) * 0.8,
            aimY: 0.3,
            power: 0.7,
            curve: 0,
            timing: timing,
          ),
          profile: profile,
          strength: strength,
          pressure: pressure,
          keeperSkill: 0.55,
          random: r,
        ).isGoal) {
          goals++;
        }
      }
      return goals / trials;
    }

    test('mükemmel zamanlama kötüden belirgin iyi', () {
      expect(rate(1, 0.5), greaterThan(rate(0.1, 0.5) + 0.1));
    });

    test('rakip baskısı gol oranını düşürür, Güç dengeler', () {
      expect(rate(0.4, 0), greaterThan(rate(0.4, 0.7)));
      expect(
        rate(0.4, 0.7, strength: 1),
        greaterThan(rate(0.4, 0.7, strength: 0)),
      );
    });

    test('kafa profili falso içermez', () {
      expect(ShotProfile.header(playerAt(90), Difficulty.normal).curveGain, 0);
    });
  });

  group('Bire bir', () {
    test('profil halkası şuttan daha hızlı', () {
      final shot = ShotProfile.fromPlayer(playerAt(50), Difficulty.normal);
      final oneOnOne = ShotProfile.oneOnOne(playerAt(50), Difficulty.normal);
      expect(oneOnOne.ringSeconds, lessThan(shot.ringSeconds));
    });
  });

  group('Pas', () {
    test('seçenek sayısı vizyona göre: en az 2, en çok 4', () {
      final r = GameRandom(1);
      expect(PassResolver.generateOptions(10, r), hasLength(2));
      expect(PassResolver.generateOptions(55, r), hasLength(3));
      expect(PassResolver.generateOptions(90, r), hasLength(4));
    });

    test(
      'yüksek vizyon aynı pasta daha düşük risk, daha yüksek ödül verir',
      () {
        final low = PassResolver.generateOptions(10, GameRandom(2));
        final high = PassResolver.generateOptions(95, GameRandom(2));
        for (var i = 0; i < 2; i++) {
          expect(high[i].type, low[i].type);
          expect(high[i].risk, lessThan(low[i].risk));
          expect(high[i].reward, greaterThan(low[i].reward));
        }
      },
    );

    test('yüksek vizyonda ara pas (riskli, ödüllü) görünür', () {
      expect(
        PassResolver.generateOptions(95, GameRandom(1)).map((o) => o.type),
        containsAll([PassType.through, PassType.switchPlay]),
      );
      expect(
        PassResolver.generateOptions(10, GameRandom(1)).map((o) => o.type),
        isNot(contains(PassType.through)),
      );
    });

    test('ibre ideal güçte tepe yapar', () {
      final o = PassResolver.generateOptions(50, GameRandom(1))[1];
      expect(PassResolver.accuracy(o, o.idealPower, 0.5), 1);
      expect(PassResolver.accuracy(o, o.idealPower + 0.5, 0.5), 0);
      expect(
        PassResolver.accuracy(o, o.idealPower + 0.1, 0.9),
        greaterThan(PassResolver.accuracy(o, o.idealPower + 0.1, 0.1)),
      );
    });

    ({double assist, double complete}) run(
      PassOption Function(List<PassOption>, GameRandom) pick,
      double Function(PassOption, GameRandom) power,
    ) {
      final r = GameRandom(5);
      var a = 0;
      var c = 0;
      for (var i = 0; i < trials; i++) {
        final o = pick(PassResolver.generateOptions(60, r), r);
        final res = PassResolver.resolve(
          option: o,
          power: power(o, r),
          passing: 0.6,
          vision: 0.6,
          random: r,
        );
        if (res.assist) a++;
        if (res.completed) c++;
      }
      return (assist: a / trials, complete: c / trials);
    }

    test('doğru güç tamamlanma oranını artırır; riskli pas risk taşır', () {
      final exact = run((o, r) => o[1], (o, r) => o.idealPower);
      final off = run((o, r) => o[1], (o, r) => 0.05);
      expect(exact.complete, greaterThan(off.complete + 0.2));

      final safe = run((o, r) => o[0], (o, r) => o.idealPower);
      final through = run((o, r) => o[2], (o, r) => o.idealPower);
      expect(safe.complete, greaterThan(through.complete));
    });

    test('akıllı seçim özensizden fazla asist üretir ama baskın değil', () {
      final sloppy = run((o, r) => r.pick(o), (o, r) => r.nextDouble());
      final smart = run(
        (o, r) => o.reduce(
          (a, b) => (1 - a.risk) * a.reward > (1 - b.risk) * b.reward ? a : b,
        ),
        (o, r) => o.idealPower,
      );
      expect(smart.assist, greaterThan(sloppy.assist));
      expect(smart.assist, lessThan(0.2));
    });
  });

  group('Dribling', () {
    double beatenRate(
      double timing,
      bool dir, {
      double skill = 0.5,
      double defender = 0.5,
    }) {
      final r = GameRandom(6);
      var ok = 0;
      for (var i = 0; i < trials; i++) {
        if (DribbleResolver.resolve(
          timing: timing,
          correctDirection: dir,
          dribbling: skill,
          agility: skill,
          ballControl: skill,
          defenderSkill: defender,
          random: r,
        ).beaten) {
          ok++;
        }
      }
      return ok / trials;
    }

    test('zamanlama kalitesi: tepe ±pencere, sonra düşer', () {
      expect(DribbleResolver.timingQuality(0), 1);
      expect(DribbleResolver.timingQuality(0.05), 1);
      expect(DribbleResolver.timingQuality(-0.05), 1);
      expect(DribbleResolver.timingQuality(0.5), 0);
      expect(DribbleResolver.timingQuality(0.15), inExclusiveRange(0, 1));
    });

    test('yanlış yön neredeyse hiç başarılı değil', () {
      expect(beatenRate(1, false), lessThan(0.08));
      expect(beatenRate(1, true), greaterThan(0.6));
    });

    test('iyi zamanlama, yetenek ve zayıf savunmacı başarıyı artırır', () {
      expect(beatenRate(1, true), greaterThan(beatenRate(0.2, true) + 0.2));
      expect(
        beatenRate(0.6, true, skill: 0.9),
        greaterThan(beatenRate(0.6, true, skill: 0.1)),
      );
      expect(
        beatenRate(0.6, true, defender: 0.1),
        greaterThan(beatenRate(0.6, true, defender: 0.9)),
      );
    });
  });

  group('Müdahale', () {
    TackleKind kind(
      double timing,
      double alignment,
      GameRandom r, {
      double defending = 0.5,
    }) => TackleResolver.resolve(
      timing: timing,
      alignment: alignment,
      defending: defending,
      strength: 0.5,
      attackerSkill: 0.5,
      random: r,
    ).kind;

    test('hizasız oyuncuyu rakip geçer', () {
      final r = GameRandom(1);
      for (var i = 0; i < 200; i++) {
        expect(kind(1, 0.1, r), TackleKind.beaten);
      }
    });

    test(
      'mükemmel zamanlama çoğunlukla kazanır, kötü zamanlama faul/geçilme',
      () {
        final r = GameRandom(2);
        var good = 0;
        var badWon = 0;
        var fouls = 0;
        for (var i = 0; i < trials; i++) {
          if (kind(1, 1, r) == TackleKind.won) good++;
          final k = kind(0.05, 1, r);
          if (k == TackleKind.won) badWon++;
          if (k == TackleKind.foul) fouls++;
        }
        expect(good / trials, greaterThan(0.8));
        expect(good, greaterThan(badWon * 1.5));
        expect(fouls, greaterThan(0));
      },
    );

    test('Defans yüksek oyuncu daha az faul yapar', () {
      int fouls(double defending) {
        final r = GameRandom(3);
        var f = 0;
        for (var i = 0; i < trials; i++) {
          if (kind(0.05, 1, r, defending: defending) == TackleKind.foul) f++;
        }
        return f;
      }

      expect(fouls(0.1), greaterThan(fouls(0.95)));
    });

    test('yenilen gol yalnızca geçilme/faul sonrası olabilir', () {
      final r = GameRandom(4);
      for (var i = 0; i < 2000; i++) {
        final res = TackleResolver.resolve(
          timing: 0.9,
          alignment: 1,
          defending: 0.9,
          strength: 0.9,
          attackerSkill: 0.1,
          random: r,
        );
        if (res.kind == TackleKind.won) {
          expect(res.outcome.concededGoal, isFalse);
        }
      }
      expect(MiniBalance.beatenConcedeChance, greaterThan(0));
    });
  });
}
