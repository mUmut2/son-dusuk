// Şut mini oyunu dengesi: `dart run tool/shot_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
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

/// Sabit "oyuncu davranışı"; sonuç dağılımını döndürür.
Map<ShotOutcome, double> run(
  String label,
  ShotInput Function(GameRandom r, ShotContext c) bot, {
  double level = 50,
  Difficulty difficulty = Difficulty.normal,
  int n = 40000,
}) {
  final random = GameRandom(1);
  final profile = ShotProfile.fromPlayer(playerAt(level), difficulty);
  final counts = <ShotOutcome, int>{};
  for (var i = 0; i < n; i++) {
    final ctx = ShotContext.random(random, difficulty, profile: profile);
    final res = ShotResolver.resolve(
      input: bot(random, ctx),
      profile: profile,
      context: ctx,
      random: random,
    );
    counts[res.outcome] = (counts[res.outcome] ?? 0) + 1;
  }
  final out = {for (final e in counts.entries) e.key: e.value / n};
  print(
    '$label (nitelik ${level.round()}): '
    '${ShotOutcome.values.map((o) => '${o.name} ${(100 * (out[o] ?? 0)).toStringAsFixed(1)}%').join(', ')}',
  );
  return out;
}

ShotInput sloppy(GameRandom r, ShotContext c) => ShotInput(
  aimX: (r.nextDouble() * 2 - 1) * 0.9,
  aimY: 0.05 + r.nextDouble() * 0.85,
  power: 0.4 + r.nextDouble() * 0.5,
  curve: (r.nextDouble() * 2 - 1) * 0.3,
  timing: r.nextDouble(),
);

ShotInput decent(GameRandom r, ShotContext c) => ShotInput(
  aimX: (c.defenderAimX > 0 ? -0.7 : 0.7),
  aimY: r.chance(0.5) ? 0.2 : 0.65,
  power: 0.65 + r.nextDouble() * 0.2,
  curve: 0,
  timing: 0.7 + r.nextDouble() * 0.3,
);

ShotInput expert(GameRandom r, ShotContext c) => ShotInput(
  aimX: (c.defenderAimX > 0 ? -0.8 : 0.8),
  aimY: r.chance(0.5) ? 0.15 : 0.72,
  power: 0.7,
  curve: 0,
  timing: 1,
);

ShotInput center(GameRandom r, ShotContext c) =>
    const ShotInput(aimX: 0, aimY: 0.4, power: 0.7, curve: 0, timing: 1);

void main() {
  run('Özensiz', sloppy);
  run('Düzgün', decent);
  run('Uzman', expert);
  run('Ortaya', center);
  run('Özensiz', sloppy, level: 80);
  run('Düzgün', decent, level: 80);
  run('Uzman', expert, level: 80);
  run('Özensiz', sloppy, level: 30);
  run('Uzman', expert, level: 30);
  run('Düzgün zor', decent, difficulty: Difficulty.hard);
  run('Düzgün kolay', decent, difficulty: Difficulty.easy);
}
