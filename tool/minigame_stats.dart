// Diğer mini oyunların dengesi: `dart run tool/minigame_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/match/minigames/dribble.dart';
import 'package:son_dusuk/domain/match/minigames/free_kick.dart';
import 'package:son_dusuk/domain/match/minigames/header.dart';
import 'package:son_dusuk/domain/match/minigames/pass.dart';
import 'package:son_dusuk/domain/match/minigames/penalty.dart';
import 'package:son_dusuk/domain/match/minigames/tackle.dart';
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

const n = 30000;
String pct(double v) => '${(100 * v).toStringAsFixed(1)}%';

void main() {
  for (final level in [30.0, 50.0, 80.0]) {
    final p = playerAt(level);
    final l = level / 99;
    print('--- nitelik ${level.round()} ---');

    // Penaltı
    double penalty(
      int Function(GameRandom) zone,
      double power, {
      List<int>? history,
    }) {
      final r = GameRandom(1);
      var goals = 0;
      for (var i = 0; i < n; i++) {
        final res = PenaltyResolver.resolve(
          zone: zone(r),
          power: power,
          composure: l,
          shooting: l,
          keeperSkill: 0.55,
          history: history ?? List.filled(6, 0),
          random: r,
        );
        if (res.isGoal) goals++;
      }
      return goals / n;
    }

    print(
      'Penaltı: köşe iyi güç ${pct(penalty((r) => r.pick([3, 5]), 0.8))}, '
      'rastgele bölge ${pct(penalty((r) => r.nextInt(6), 0.8))}, '
      'orta düşük ${pct(penalty((r) => 1, 0.8))}, '
      'hep aynı köşe (okunmuş) ${pct(penalty((r) => 5, 0.8, history: [0, 0, 0, 0, 0, 10]))}, '
      'aşırı güç ${pct(penalty((r) => r.pick([3, 5]), 1))}',
    );

    // Serbest vuruş
    double freeKick(ShotInput Function(GameRandom, WallSpec) bot) {
      final r = GameRandom(2);
      final profile = ShotProfile.freeKick(p, Difficulty.normal);
      var goals = 0;
      for (var i = 0; i < n; i++) {
        final wall = WallSpec.random(r);
        final res = FreeKickResolver.resolve(
          input: bot(r, wall),
          profile: profile,
          wall: wall,
          keeperSkill: 0.55,
          random: r,
        );
        if (res.isGoal) goals++;
      }
      return goals / n;
    }

    print(
      'Serbest vuruş: duvar üstü köşe ${pct(freeKick((r, w) => ShotInput(aimX: w.centerX > 0 ? -0.7 : 0.7, aimY: 0.9, power: 0.7, curve: 0, timing: 0.9)))}, '
      'duvara düz ${pct(freeKick((r, w) => ShotInput(aimX: w.centerX, aimY: 0.2, power: 0.7, curve: 0, timing: 0.9)))}, '
      'özensiz ${pct(freeKick((r, w) => ShotInput(aimX: (r.nextDouble() * 2 - 1) * 0.9, aimY: 0.05 + r.nextDouble() * 0.9, power: 0.4 + r.nextDouble() * 0.5, curve: (r.nextDouble() * 2 - 1) * 0.5, timing: r.nextDouble())))}',
    );

    // Kafa
    double header(double timing, double pressure) {
      final r = GameRandom(3);
      final profile = ShotProfile.header(p, Difficulty.normal);
      var goals = 0;
      for (var i = 0; i < n; i++) {
        final res = HeaderResolver.resolve(
          input: ShotInput(
            aimX: (r.nextDouble() * 2 - 1) * 0.8,
            aimY: 0.3,
            power: 0.7,
            curve: 0,
            timing: timing == -1 ? r.nextDouble() : timing,
          ),
          profile: profile,
          strength: l,
          pressure: pressure,
          keeperSkill: 0.55,
          random: r,
        );
        if (res.isGoal) goals++;
      }
      return goals / n;
    }

    print(
      'Kafa: mükemmel zamanlama ${pct(header(1, 0.4))}, '
      'rastgele zamanlama ${pct(header(-1, 0.4))}',
    );

    // Bire bir
    double oneOnOne(ShotInput Function(GameRandom) bot) {
      final r = GameRandom(4);
      final profile = ShotProfile.oneOnOne(p, Difficulty.normal);
      var goals = 0;
      for (var i = 0; i < n; i++) {
        final res = ShotResolver.resolve(
          input: bot(r),
          profile: profile,
          context: const ShotContext(
            keeperSkill: 0.67,
            pressure: 0,
            defenderAimX: 99,
          ),
          random: r,
        );
        if (res.isGoal) goals++;
      }
      return goals / n;
    }

    print(
      'Bire bir: özensiz ${pct(oneOnOne((r) => ShotInput(aimX: (r.nextDouble() * 2 - 1) * 0.9, aimY: 0.05 + r.nextDouble() * 0.85, power: 0.4 + r.nextDouble() * 0.5, curve: 0, timing: r.nextDouble())))}, '
      'düzgün ${pct(oneOnOne((r) => ShotInput(aimX: r.chance(0.5) ? -0.7 : 0.7, aimY: 0.2, power: 0.7, curve: 0, timing: 0.85)))}',
    );

    // Pas
    ({double assist, double complete}) pass(
      PassOption Function(List<PassOption>, GameRandom) pick,
      double Function(PassOption, GameRandom) power,
    ) {
      final r = GameRandom(5);
      var assists = 0;
      var done = 0;
      for (var i = 0; i < n; i++) {
        final options = PassResolver.generateOptions(level, r);
        final o = pick(options, r);
        final res = PassResolver.resolve(
          option: o,
          power: power(o, r),
          passing: l,
          vision: l,
          random: r,
        );
        if (res.assist) assists++;
        if (res.completed) done++;
      }
      return (assist: assists / n, complete: done / n);
    }

    final sloppy = pass((o, r) => r.pick(o), (o, r) => r.nextDouble());
    final goodPick = pass(
      (o, r) => o.reduce(
        (a, b) => (1 - a.risk) * a.reward > (1 - b.risk) * b.reward ? a : b,
      ),
      (o, r) => o.idealPower + (r.nextDouble() - 0.5) * 0.2,
    );
    print(
      'Pas: özensiz asist ${pct(sloppy.assist)} (tamam. ${pct(sloppy.complete)}), '
      'akıllı seçim asist ${pct(goodPick.assist)} (tamam. ${pct(goodPick.complete)})',
    );

    // Dribling: beceri oyuncuda; bot geçide ne kadar iyi girdiğini model eder.
    // [error] oyuncunun geçit merkezinden en fazla sapması (ekran genişliği oranı).
    double dribble(double error, {double scale = 1}) {
      final r = GameRandom(6);
      var ok = 0;
      for (var i = 0; i < n; i++) {
        final waves = DribbleResolver.generateWaves(r);
        final gap = DribbleResolver.gapHalf(skill: l, windowScale: scale);
        final amp = DribbleResolver.swayAmplitude(0.5);
        var hits = 0;
        for (final w in waves) {
          final c = DribbleResolver.gapCenterAt(w, w.arrival, amp);
          final x = c + (r.nextDouble() * 2 - 1) * error;
          if (DribbleResolver.isHit(
            playerX: x,
            wave: w,
            amplitude: amp,
            gapHalf: gap,
          )) {
            hits++;
          }
        }
        if (DribbleResolver.resolve(hits: hits, random: r).beaten) ok++;
      }
      return ok / n;
    }

    print(
      'Dribling (4 dalga): sapma 0.10 ${pct(dribble(0.10))}, '
      '0.15 ${pct(dribble(0.15))}, 0.22 ${pct(dribble(0.22))} | '
      'sapma 0.15: kolay ${pct(dribble(0.15, scale: 1.3))}, zor ${pct(dribble(0.15, scale: 0.8))}',
    );

    // Müdahale
    double tackle(double timing, double alignment) {
      final r = GameRandom(7);
      var won = 0;
      for (var i = 0; i < n; i++) {
        final res = TackleResolver.resolve(
          timing: timing == -1 ? r.nextDouble() : timing,
          alignment: alignment,
          defending: l,
          strength: l,
          attackerSkill: 0.5,
          random: r,
        );
        if (res.kind == TackleKind.won) won++;
      }
      return won / n;
    }

    print(
      'Müdahale: mükemmel ${pct(tackle(1, 1))}, rastgele zamanlama+iyi hizalama '
      '${pct(tackle(-1, 0.8))}, hizasız ${pct(tackle(1, 0.2))}',
    );
  }
}
