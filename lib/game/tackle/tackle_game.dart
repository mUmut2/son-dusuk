import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../../domain/match/minigames/tackle.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';

enum _Phase { approach, resolving, done }

/// Savunma müdahalesi: parmağını kaydırarak rakibin önünde pozisyon al,
/// topu ayağından en çok açtığı anda parmağını BIRAK (ya da dokun) ve müdahale et.
/// Çok erken ya da yanlış hizada müdahale faul riski taşır.
class TackleGame extends MiniGameBase {
  TackleGame({
    required super.hint,
    required super.onFinished,
    required this.labels,
    required this.defending,
    required this.strength,
    required this.attackerSkill,
    required this.random,
    this.performance = 1,
    this.approachScale = 1,
    super.onImpact,
  });

  final MiniGameLabels labels;
  final double defending;
  final double strength;
  final double attackerSkill;
  final GameRandom random;
  final double performance;

  /// Zorluk: <1 rakip daha çabuk gelir.
  final double approachScale;

  _Phase _phase = _Phase.approach;
  double _clock = 0;
  bool _initialized = false;
  double _playerX = 0;
  double _targetX = 0;
  late final double _weavePhase = random.nextDouble() * math.pi * 2;
  late final double _weaveSpeed = 1.6 + random.nextDouble() * 0.8;

  TackleResult? _result;
  double _animT = 0;

  double get _duration => MiniBalance.tackleApproachSeconds * approachScale;

  double get _progress => (_clock / _duration).clamp(0.0, 1.0);

  double get _playerY => layout.height * 0.78;

  double get _attackerX =>
      layout.ballX +
      math.sin(_clock * _weaveSpeed + _weavePhase) * layout.width * 0.26;

  /// Rakip en fazla bu kadar (top yarıçapı) kadar yaklaşır: oyuncuyla arasında
  /// top için yer kalır ve iki figür üst üste binmez.
  static const double _closestDistance = 12;

  double get _attackerY =>
      layout.height * 0.16 +
      (_playerY - layout.height * 0.16 - layout.ballRadius * _closestDistance) *
          _progress;

  /// Top ayaktan uzaklığı (0 yakın .. 1 en uzak).
  double get _ballOpen =>
      MiniGameBase.pingPong(_clock, MiniBalance.tacklePeriod);

  void _init() {
    if (_initialized) return;
    _initialized = true;
    _playerX = layout.ballX;
    _targetX = layout.ballX;
  }

  @override
  void dragStart(double x, double y) => _targetX = x;

  @override
  void dragUpdate(double x, double y) => _targetX = x;

  @override
  void dragEnd(double vx, double vy) => _tackle();

  @override
  void tapUp(double x, double y) => _tackle();

  void _tackle() {
    if (_phase != _Phase.approach) return;
    // Rakip henüz menzile girmediyse müdahale boşa gider (faul riski).
    final inRange = _progress >= 0.75;
    if (!inRange) showToast(labels.tooEarly);

    final maxDist = layout.width * 0.22;
    final alignment = (1 - (_playerX - _attackerX).abs() / maxDist).clamp(
      0.0,
      1.0,
    );
    final timing = inRange ? ((_ballOpen - 0.5) / 0.45).clamp(0.0, 1.0) : 0.0;
    _result = TackleResolver.resolve(
      timing: timing,
      alignment: alignment,
      defending: defending,
      strength: strength,
      attackerSkill: attackerSkill,
      random: random,
      performance: performance,
    );
    _phase = _Phase.resolving;
    _animT = 0;
  }

  @override
  void tick(double dt, double scaled) {
    _init();
    switch (_phase) {
      case _Phase.approach:
        _clock += dt;
        _playerX += (_targetX - _playerX) * math.min(1, dt * 9);
        _playerX = _playerX.clamp(layout.width * 0.1, layout.width * 0.9);
        if (_clock >= _duration) {
          // Müdahale edilmedi: rakip geçer.
          _result = TackleResolver.resolve(
            timing: 0,
            alignment: 0,
            defending: defending,
            strength: strength,
            attackerSkill: attackerSkill,
            random: random,
            performance: performance,
          );
          _phase = _Phase.resolving;
          _animT = 0;
        }
      case _Phase.resolving:
        _animT += scaled / 0.6;
        if (_animT >= 1) {
          _animT = 1;
          final r = _result!;
          _phase = _Phase.done;
          finishGame(
            MiniGameFinish(r.outcome),
            switch (r.kind) {
              TackleKind.won => labels.tackleWon,
              TackleKind.foul => labels.tackleFoul,
              TackleKind.beaten => labels.tackleBeaten,
            },
            good: r.kind == TackleKind.won,
            shake: r.kind == TackleKind.won ? 0.25 : 0.1,
          );
        }
      case _Phase.done:
        break;
    }
  }

  @override
  void paintScene(Canvas canvas) {
    _init();
    final l = layout;
    drawPitchStripes(canvas);

    var ax = _attackerX;
    var ay = _attackerY;
    final open = _ballOpen;
    var ballX = ax;
    var ballY = ay + l.ballRadius * 2 + open * l.ballRadius * 4;
    var tilt = 0.0;

    if (_phase != _Phase.approach) {
      final t = Curves.easeOut.transform(_animT);
      switch (_result!.kind) {
        case TackleKind.won:
          // Top kazanılır: oyuncuya doğru gelir, rakip sendeler.
          ballX = ballX + (_playerX - ballX) * t;
          ballY = ballY + (_playerY - ballY) * t;
          tilt = 0.6 * t;
        case TackleKind.foul:
          tilt = -0.9 * t;
        case TackleKind.beaten:
          ax += (ax >= l.ballX ? 1 : -1) * l.width * 0.16 * t;
          ay += l.height * 0.05 * t;
          ballX = ax;
          ballY = ay + l.ballRadius * 2;
      }
    }

    // Müdahale penceresi göstergesi (top en uzakken parlar).
    if (_phase == _Phase.approach && open > 0.8) {
      canvas.drawCircle(
        Offset(ballX, ballY),
        l.ballRadius * 2.4,
        Paint()
          ..color = const Color(0xCCFFEB3B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    drawPerson(canvas, ax, ay, const Color(0xFFC62828), scale: 1.2, tilt: tilt);
    drawBall(canvas, ballX, ballY);
    drawPerson(canvas, _playerX, _playerY, const Color(0xFF1565C0), scale: 1.2);
  }
}
