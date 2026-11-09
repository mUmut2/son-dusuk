import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/game_random.dart';
import '../domain/career/difficulty.dart';
import '../domain/career/player_status.dart';
import '../domain/match/critical_moment.dart';
import '../domain/match/minigames/free_kick.dart';
import '../domain/match/minigames/header.dart';
import '../domain/match/minigames/mini_balance.dart';
import '../domain/match/minigames/pass.dart';
import '../domain/match/moment_resolver.dart';
import '../domain/match/shot/shot_balance.dart';
import '../domain/match/shot/shot_models.dart';
import '../domain/player/attribute.dart';
import '../domain/player/player.dart';
import 'dribble/dribble_game.dart';
import 'mini_game_types.dart';
import 'pass/pass_game.dart';
import 'penalty/penalty_game.dart';
import 'shot/shot_game.dart';
import 'tackle/tackle_game.dart';

/// Kritik an türüne uygun mini oyunu kurar ve Flutter ağacına gömer.
/// Oyun örneği bir kez oluşturulur; nitelikler, form/kondisyon/moral ve zorluk
/// parametreleri buradan oyunlara dağıtılır.
class MiniGameView extends StatefulWidget {
  const MiniGameView({
    required this.type,
    required this.player,
    required this.status,
    required this.difficulty,
    required this.labels,
    required this.penaltyHistory,
    required this.onFinished,
    this.vibration = true,
    this.random,
    super.key,
  });

  final MomentType type;
  final Player player;
  final PlayerStatus status;
  final Difficulty difficulty;
  final MiniGameLabels labels;

  /// Penaltı bölgelerinin geçmiş sayıları (6 eleman).
  final List<int> penaltyHistory;
  final void Function(MiniGameFinish finish) onFinished;
  final bool vibration;

  /// Testler/günlük zorluk için seed'li rastgelelik.
  final GameRandom? random;

  @override
  State<MiniGameView> createState() => _MiniGameViewState();
}

class _MiniGameViewState extends State<MiniGameView> {
  late final FlameGame _game;

  void _vibrate(bool good) {
    if (!widget.vibration) return;
    if (good) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void initState() {
    super.initState();
    _game = _build();
  }

  FlameGame _build() {
    final random = widget.random ?? GameRandom();
    final player = widget.player;
    final status = widget.status;
    final d = widget.difficulty;
    final labels = widget.labels;
    final perf = status.performanceMultiplier;
    double n(Attribute a) => player.attributes.raw(a) / 99;

    // Zorluk: yalnızca tolerans ve rakip gücünü etkiler.
    final meterSpeed = switch (d) {
      Difficulty.easy => 0.8,
      Difficulty.normal => 1.0,
      Difficulty.hard => 1.25,
    };
    final opponentSkill = switch (d) {
      Difficulty.easy => 0.35,
      Difficulty.normal => 0.5,
      Difficulty.hard => 0.65,
    };
    final windowScale = switch (d) {
      Difficulty.easy => 1.3,
      Difficulty.normal => 1.0,
      Difficulty.hard => 0.8,
    };

    final baseProfile = ShotProfile.fromPlayer(player, d, status: status);
    final keeperSkill = ShotContext.random(
      random,
      d,
      profile: baseProfile,
    ).keeperSkill;

    void shotFinish(ShotResult r) => widget.onFinished(
      MiniGameFinish(r.isGoal ? MomentOutcome.goal : MomentOutcome.none),
    );

    switch (widget.type) {
      case MomentType.shot:
        return ShotGame(
          profile: baseProfile,
          shotContext: ShotContext.random(random, d, profile: baseProfile),
          random: random,
          labels: labels,
          onFinished: shotFinish,
          onImpact: (o) => _vibrate(o == ShotOutcome.goal),
        );
      case MomentType.oneOnOne:
        return ShotGame(
          profile: ShotProfile.oneOnOne(player, d, status: status),
          shotContext: ShotContext(
            keeperSkill: (keeperSkill + ShotBalance.oneOnOneKeeperBonus).clamp(
              0.2,
              0.95,
            ),
            pressure: 0,
            defenderAimX: 99,
          ),
          random: random,
          labels: labels,
          variant: ShotVariant.oneOnOne,
          onFinished: shotFinish,
          onImpact: (o) => _vibrate(o == ShotOutcome.goal),
        );
      case MomentType.freeKick:
        final profile = ShotProfile.freeKick(player, d, status: status);
        final wall = WallSpec.random(random);
        return ShotGame(
          profile: profile,
          shotContext: ShotContext(
            keeperSkill: keeperSkill,
            pressure: 0,
            defenderAimX: 99,
          ),
          random: random,
          labels: labels,
          variant: ShotVariant.freeKick,
          wall: wall,
          customResolver: (input) => FreeKickResolver.resolve(
            input: input,
            profile: profile,
            wall: wall,
            keeperSkill: keeperSkill,
            random: random,
          ),
          onFinished: shotFinish,
          onImpact: (o) => _vibrate(o == ShotOutcome.goal),
        );
      case MomentType.header:
        final profile = ShotProfile.header(player, d, status: status);
        final pressure =
            random.nextDouble() * MiniBalance.headerDuelPressureMax;
        return ShotGame(
          profile: profile,
          shotContext: ShotContext(
            keeperSkill: keeperSkill,
            pressure: pressure,
            defenderAimX: 99,
          ),
          random: random,
          labels: labels,
          variant: ShotVariant.header,
          customResolver: (input) => HeaderResolver.resolve(
            input: input,
            profile: profile,
            strength: n(Attribute.strength),
            pressure: pressure,
            keeperSkill: keeperSkill,
            random: random,
          ),
          onFinished: shotFinish,
          onImpact: (o) => _vibrate(o == ShotOutcome.goal),
        );
      case MomentType.penalty:
        return PenaltyGame(
          hint: labels.hints[MomentType.penalty]!,
          labels: labels,
          composure: n(Attribute.composure),
          shooting: n(Attribute.shooting),
          keeperSkill: keeperSkill,
          history: widget.penaltyHistory,
          random: random,
          performance: perf,
          meterSpeed: meterSpeed,
          onFinished: widget.onFinished,
          onImpact: _vibrate,
        );
      case MomentType.keyPass:
        return PassGame(
          hint: labels.hints[MomentType.keyPass]!,
          labels: labels,
          options: PassResolver.generateOptions(
            player.attributes.raw(Attribute.vision),
            random,
          ),
          passing: n(Attribute.passing),
          vision: n(Attribute.vision),
          random: random,
          performance: perf,
          meterSpeed: meterSpeed,
          onFinished: widget.onFinished,
          onImpact: _vibrate,
        );
      case MomentType.dribble:
        return DribbleGame(
          hint: labels.hints[MomentType.dribble]!,
          labels: labels,
          dribbling: n(Attribute.dribbling),
          agility: n(Attribute.agility),
          ballControl: n(Attribute.ballControl),
          defenderSkill: opponentSkill,
          random: random,
          performance: perf,
          windowScale: windowScale,
          tempo: meterSpeed,
          onFinished: widget.onFinished,
          onImpact: _vibrate,
        );
      case MomentType.tackle:
        return TackleGame(
          hint: labels.hints[MomentType.tackle]!,
          labels: labels,
          defending: n(Attribute.defending),
          strength: n(Attribute.strength),
          attackerSkill: opponentSkill,
          random: random,
          performance: perf,
          approachScale: 1 / windowScale,
          onFinished: widget.onFinished,
          onImpact: _vibrate,
        );
    }
  }

  @override
  Widget build(BuildContext context) => GameWidget(game: _game);
}
