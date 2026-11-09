import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/minigames/dribble.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../../domain/match/moment_resolver.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';

enum _Phase { approach, telegraph, resolving, done }

/// Dribling: parmağını sürükleyerek oyuncunu yönlendir (yön tuşu yok).
/// Savunmacı atılmadan hemen önce, atıldığı yanın TERSİNE hızlı bir çalım
/// (swipe) yap.
class DribbleGame extends MiniGameBase {
  DribbleGame({
    required super.hint,
    required super.onFinished,
    required this.labels,
    required this.dribbling,
    required this.agility,
    required this.ballControl,
    required this.defenderSkill,
    required this.random,
    this.performance = 1,
    this.telegraphScale = 1,
    super.onImpact,
  });

  final MiniGameLabels labels;
  final double dribbling;
  final double agility;
  final double ballControl;
  final double defenderSkill;
  final GameRandom random;
  final double performance;

  /// Zorluk: <1 savunmacının hamlesi daha az belli olur.
  final double telegraphScale;

  static const double _minSwipeSpeed = 300;

  _Phase _phase = _Phase.approach;
  double _clock = 0;
  late final double _lungeDelay =
      MiniBalance.lungeDelayMin +
      random.nextDouble() *
          (MiniBalance.lungeDelayMax - MiniBalance.lungeDelayMin);
  late final int _lungeDir = random.chance(0.5)
      ? -1
      : 1; // savunmacı hangi yana atılır
  late final double _telegraph = MiniBalance.lungeTelegraph * telegraphScale;

  double _playerX = 0;
  double _targetX = 0;
  double _defenderX = 0;
  double _defenderY = 0;
  bool _initialized = false;

  // Sonuç animasyonu
  DribbleResult? _result;
  double _animT = 0;
  int _swipeDir = 0;

  double get _lungeTime => _lungeDelay + _telegraph;

  void _init() {
    if (_initialized) return;
    _initialized = true;
    _playerX = layout.ballX;
    _targetX = layout.ballX;
    _defenderX = layout.ballX;
    _defenderY = layout.height * 0.2;
  }

  @override
  void dragStart(double x, double y) => _targetX = x;

  @override
  void dragUpdate(double x, double y) => _targetX = x;

  @override
  void dragEnd(double vx, double vy) {
    if (_phase != _Phase.approach && _phase != _Phase.telegraph) return;
    if (vx.abs() < _minSwipeSpeed || vx.abs() < vy.abs() * 0.5) return;
    // Hamle başlamadan çok önce yapılan çalım zamanlama olarak sayılmaz.
    final delta = _clock - _lungeTime;
    final dir = vx > 0 ? 1 : -1;
    _swipeDir = dir;
    final res = DribbleResolver.resolve(
      timing: DribbleResolver.timingQuality(delta),
      correctDirection: dir == -_lungeDir,
      dribbling: dribbling,
      agility: agility,
      ballControl: ballControl,
      defenderSkill: defenderSkill,
      random: random,
      performance: performance,
    );
    _startResolve(res);
  }

  void _startResolve(DribbleResult res) {
    _result = res;
    _phase = _Phase.resolving;
    _animT = 0;
  }

  @override
  void tick(double dt, double scaled) {
    _init();
    final l = layout;
    switch (_phase) {
      case _Phase.approach:
      case _Phase.telegraph:
        _clock += dt;
        _playerX += (_targetX - _playerX) * math.min(1, dt * 8);
        _playerX = _playerX.clamp(l.width * 0.1, l.width * 0.9);
        // Savunmacı oyuncunun yanına doğru kayar ve yaklaşır.
        _defenderX += (_playerX - _defenderX) * math.min(1, dt * 2.2);
        final targetY = l.ballY - l.height * 0.2;
        _defenderY += (targetY - _defenderY) * math.min(1, dt * 0.9);
        if (_phase == _Phase.approach && _clock >= _lungeDelay) {
          _phase = _Phase.telegraph;
        }
        if (_clock > _lungeTime + MiniBalance.dribbleGoodWindow) {
          // Çalım atılmadı: savunmacı topu alır.
          _startResolve(
            const DribbleResult(beaten: false, outcome: MomentOutcome.none),
          );
        }
      case _Phase.resolving:
        _animT += scaled / 0.7;
        if (_animT >= 1) {
          _animT = 1;
          final r = _result!;
          _phase = _Phase.done;
          finishGame(
            MiniGameFinish(r.outcome),
            r.beaten ? labels.dribbleBeaten : labels.dribbleFail,
            good: r.beaten,
            shake: r.beaten ? 0.25 : 0.1,
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

    var px = _playerX;
    var py = l.ballY;
    var dx = _defenderX;
    var dy = _defenderY;
    var lean = 0.0;

    if (_phase == _Phase.telegraph) {
      // Savunmacı atılacağı yana eğilir.
      lean =
          _lungeDir *
          0.35 *
          ((_clock - _lungeDelay) / _telegraph).clamp(0.0, 1.0);
    }
    if (_phase == _Phase.resolving || _phase == _Phase.done) {
      final t = Curves.easeOut.transform(_animT);
      final r = _result!;
      if (r.beaten) {
        px += _swipeDir * l.width * 0.22 * t;
        py -= l.height * 0.2 * t;
        dx += _lungeDir * l.width * 0.15 * t;
        lean = _lungeDir * 0.6;
      } else {
        // Savunmacı topu alır.
        dx += (px - dx) * t;
        dy += (py - dy) * t;
        lean = 0;
      }
    }

    // Savunmacının hamle işareti
    if (_phase == _Phase.telegraph) {
      final p = ((_clock - _lungeDelay) / _telegraph).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(dx, dy),
        l.ballRadius * (2 + 3 * (1 - p)),
        Paint()
          ..color = Color.lerp(
            const Color(0x88FFEB3B),
            const Color(0xCCFF1744),
            p,
          )!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      );
    }

    drawPerson(canvas, dx, dy, const Color(0xFFC62828), scale: 1.3, tilt: lean);
    drawPerson(canvas, px, py, const Color(0xFF1565C0), scale: 1.2);
    // Top oyuncunun ayağının yanında (kafayla üst üste binmez).
    drawBall(canvas, px + l.ballRadius * 2.2, py + l.ballRadius * 2.6);

    // Savunmacının atılacağı yönü gösteren ok.
    if (_phase == _Phase.telegraph) {
      final ax = dx + _lungeDir * l.ballRadius * 4.5;
      final ay = dy - l.ballRadius * 1.5;
      final s = l.ballRadius * 1.1;
      canvas.drawPath(
        Path()
          ..moveTo(ax + _lungeDir * s, ay)
          ..lineTo(ax - _lungeDir * s * 0.6, ay - s)
          ..lineTo(ax - _lungeDir * s * 0.6, ay + s)
          ..close(),
        Paint()..color = const Color(0xFFFFEB3B),
      );
    }
  }
}
