import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/match/match_session.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';
import 'package:son_dusuk/domain/match/moment_resolver.dart';
import 'package:son_dusuk/domain/match/player_rating.dart';
import 'package:son_dusuk/domain/match/shot/shot_models.dart';
import 'package:son_dusuk/domain/match/shot/shot_resolver.dart';
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

double goalRate(
  ShotInput Function(GameRandom r, ShotContext c) bot, {
  double level = 50,
  Difficulty difficulty = Difficulty.normal,
  int n = 8000,
}) {
  final random = GameRandom(1);
  final profile = ShotProfile.fromPlayer(playerAt(level), difficulty);
  var goals = 0;
  for (var i = 0; i < n; i++) {
    final ctx = ShotContext.random(random, difficulty, profile: profile);
    final r = ShotResolver.resolve(
      input: bot(random, ctx),
      profile: profile,
      context: ctx,
      random: random,
    );
    if (r.isGoal) goals++;
  }
  return goals / n;
}

ShotInput sloppy(GameRandom r, ShotContext c) => ShotInput(
  aimX: (r.nextDouble() * 2 - 1) * 0.9,
  aimY: 0.05 + r.nextDouble() * 0.85,
  power: 0.4 + r.nextDouble() * 0.5,
  curve: (r.nextDouble() * 2 - 1) * 0.3,
  timing: r.nextDouble(),
);

ShotInput decent(GameRandom r, ShotContext c) => ShotInput(
  aimX: c.defenderAimX > 0 ? -0.7 : 0.7,
  aimY: r.chance(0.5) ? 0.2 : 0.65,
  power: 0.65 + r.nextDouble() * 0.2,
  curve: 0,
  timing: 0.7 + r.nextDouble() * 0.3,
);

void main() {
  group('ShotProfile', () {
    test('zamanlama kalitesi: tepe ±pencere, sonra doğrusal düşüş', () {
      final p = ShotProfile.fromPlayer(playerAt(50), Difficulty.normal);
      expect(p.timingQuality(1), 1);
      expect(p.timingQuality(1.05), 1);
      expect(p.timingQuality(0.95), 1);
      expect(p.timingQuality(0), 0);
      expect(p.timingQuality(1.6), 0);
      expect(p.timingQuality(0.8), inExclusiveRange(0, 1));
      expect(p.timingQuality(0.8), closeTo(p.timingQuality(1.2), 1e-9));
    });

    test('nitelik ve zorluk parametreleri yönlendirir', () {
      final weak = ShotProfile.fromPlayer(playerAt(30), Difficulty.normal);
      final strong = ShotProfile.fromPlayer(playerAt(90), Difficulty.normal);
      expect(strong.sigma, lessThan(weak.sigma));
      expect(strong.ringSeconds, greaterThan(weak.ringSeconds));
      expect(strong.curveGain, greaterThan(weak.curveGain));

      final easy = ShotProfile.fromPlayer(playerAt(50), Difficulty.easy);
      final hard = ShotProfile.fromPlayer(playerAt(50), Difficulty.hard);
      expect(easy.ringSeconds, greaterThan(hard.ringSeconds));
      expect(easy.goodHalfWindow, greaterThan(hard.goodHalfWindow));
    });
  });

  group('ShotResolver', () {
    test('aynı seed aynı sonucu verir', () {
      String run() {
        final random = GameRandom(5);
        final profile = ShotProfile.fromPlayer(playerAt(60), Difficulty.normal);
        final ctx = ShotContext.random(random, Difficulty.normal);
        final r = ShotResolver.resolve(
          input: const ShotInput(
            aimX: 0.5,
            aimY: 0.4,
            power: 0.7,
            curve: 0.2,
            timing: 0.9,
          ),
          profile: profile,
          context: ctx,
          random: random,
        );
        return '${r.outcome}:${r.finalX}:${r.finalY}:${r.keeperX}';
      }

      expect(run(), run());
    });

    test('çok kötü hedef isabetsiz olur', () {
      final random = GameRandom(1);
      final profile = ShotProfile.fromPlayer(playerAt(50), Difficulty.normal);
      const ctx = ShotContext(keeperSkill: 0.5, pressure: 0, defenderAimX: 5);
      for (var i = 0; i < 50; i++) {
        final r = ShotResolver.resolve(
          input: const ShotInput(
            aimX: 2.5,
            aimY: 0.5,
            power: 0.7,
            curve: 0,
            timing: 1,
          ),
          profile: profile,
          context: ctx,
          random: random,
        );
        expect(r.outcome, ShotOutcome.offTarget);
      }
    });

    test('savunmacının tam önüne yerden vuruş çoğunlukla engellenir', () {
      final random = GameRandom(2);
      final profile = ShotProfile.fromPlayer(playerAt(50), Difficulty.normal);
      const ctx = ShotContext(keeperSkill: 0.5, pressure: 1, defenderAimX: 0);
      var blocked = 0;
      for (var i = 0; i < 400; i++) {
        final r = ShotResolver.resolve(
          input: const ShotInput(
            aimX: 0,
            aimY: 0.05,
            power: 0.7,
            curve: 0,
            timing: 1,
          ),
          profile: profile,
          context: ctx,
          random: random,
        );
        if (r.outcome == ShotOutcome.blocked) blocked++;
      }
      expect(blocked / 400, greaterThan(0.7));
    });

    test('zamanlama: mükemmel zamanlama özensize göre daha çok gol', () {
      double rate(double timing) => goalRate(
        (r, c) => ShotInput(
          aimX: c.defenderAimX > 0 ? -0.7 : 0.7,
          aimY: 0.2,
          power: 0.7,
          curve: 0,
          timing: timing,
        ),
      );
      expect(rate(1), greaterThan(rate(0.1) + 0.1));
    });

    test('düzgün oynayan özensiz oynayandan belirgin iyi', () {
      expect(goalRate(decent), greaterThan(goalRate(sloppy) * 1.15));
    });

    test('yüksek nitelik gol oranını artırır', () {
      expect(
        goalRate(sloppy, level: 85),
        greaterThan(goalRate(sloppy, level: 30)),
      );
    });

    test('zorluk: kolay > normal > zor', () {
      final easy = goalRate(decent, difficulty: Difficulty.easy);
      final normal = goalRate(decent);
      final hard = goalRate(decent, difficulty: Difficulty.hard);
      expect(easy, greaterThan(normal));
      expect(normal, greaterThan(hard));
    });

    test(
      'gol oranları sağlıklı bantta (kaleci her şeyi kurtarmaz/hep gol olmaz)',
      () {
        final s = goalRate(sloppy);
        final d = goalRate(decent);
        expect(s, inInclusiveRange(0.2, 0.45));
        expect(d, inInclusiveRange(0.3, 0.6));
      },
    );
  });

  group('PlayerRating', () {
    MatchSession session(Side side) => MatchSession.start(
      homeStrength: 60,
      awayStrength: 60,
      playerSide: side,
      player: playerAt(50),
      random: GameRandom(3),
    );

    test('gol ve asist reytingi yükseltir, yenen gol düşürür', () {
      final good = session(Side.home);
      good
        ..resolve(good.moments[0], MomentOutcome.goal)
        ..resolve(good.moments[1], MomentOutcome.assist);
      final bad = session(Side.home);
      bad.resolve(bad.moments[0], MomentOutcome.conceded);
      expect(
        PlayerRating.compute(good),
        greaterThan(PlayerRating.compute(bad)),
      );
      expect(PlayerRating.compute(good), lessThanOrEqualTo(10));
      expect(PlayerRating.compute(bad), greaterThanOrEqualTo(1));
    });

    test('nextMoment sırayla ilerler', () {
      final s = session(Side.away);
      final first = s.nextMoment!;
      expect(first, s.moments.first);
      s.resolve(first, MomentOutcome.none);
      expect(s.nextMoment, s.moments[1]);
      s.autoPlay(playerAt(50), GameRandom(1));
      expect(s.nextMoment, isNull);
      expect(s.isFinished, isTrue);
    });
  });
}
