import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/game_random.dart';
import '../../domain/career/difficulty.dart';
import '../../domain/career/player_status.dart';
import '../../domain/match/shot/shot_models.dart';
import '../../domain/player/player.dart';
import 'shot_game.dart';

/// Şut mini oyununu Flutter ağacına gömer. Oyun örneği bir kez oluşturulur.
class ShotGameView extends StatefulWidget {
  const ShotGameView({
    required this.player,
    required this.difficulty,
    this.status,
    required this.labels,
    required this.onFinished,
    this.vibration = true,
    this.random,
    super.key,
  });

  final Player player;
  final Difficulty difficulty;
  final PlayerStatus? status;
  final ShotGameLabels labels;
  final void Function(ShotResult result) onFinished;
  final bool vibration;

  /// Testler/günlük zorluk için seed'li rastgelelik.
  final GameRandom? random;

  @override
  State<ShotGameView> createState() => _ShotGameViewState();
}

class _ShotGameViewState extends State<ShotGameView> {
  late final ShotGame _game;

  @override
  void initState() {
    super.initState();
    final random = widget.random ?? GameRandom();
    final profile = ShotProfile.fromPlayer(
      widget.player,
      widget.difficulty,
      status: widget.status,
    );
    _game = ShotGame(
      profile: profile,
      shotContext: ShotContext.random(
        random,
        widget.difficulty,
        profile: profile,
      ),
      random: random,
      labels: widget.labels,
      onFinished: widget.onFinished,
      onImpact: (outcome) {
        if (!widget.vibration) return;
        if (outcome == ShotOutcome.goal) {
          HapticFeedback.heavyImpact();
        } else {
          HapticFeedback.lightImpact();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: _game);
  }
}
