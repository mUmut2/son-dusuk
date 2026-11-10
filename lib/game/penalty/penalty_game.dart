import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/moment_resolver.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../../domain/match/minigames/penalty.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';

enum _Phase { pickZone, meter, flying }

/// Penaltı: kale bölgesine dokunarak köşe seç, alttaki ibreyi doğru anda
/// durdur (dokun). Kaleci geçmiş penaltılarını okur: hep aynı yere vurma!
class PenaltyGame extends MiniGameBase {
  PenaltyGame({
    required super.hint,
    required super.onFinished,
    required this.labels,
    required this.composure,
    required this.shooting,
    required this.keeperSkill,
    required this.history,
    required this.random,
    this.performance = 1,
    this.meterSpeed = 1,
    super.onImpact,
  });

  final MiniGameLabels labels;
  final double composure;
  final double shooting;
  final double keeperSkill;
  final List<int> history;
  final GameRandom random;
  final double performance;

  /// Zorluk: >1 ibre daha hızlı.
  final double meterSpeed;

  _Phase _phase = _Phase.pickZone;
  int? _zone;
  double _clock = 0;
  double _meterValue = 0;
  PenaltyResult? _result;
  double _flightT = 0;
  late ({double x, double y}) _target;

  ({double left, double right, double top, double bottom}) get _goalRect => (
    left: layout.goalCenterX - layout.goalHalfWidth,
    right: layout.goalCenterX + layout.goalHalfWidth,
    top: layout.goalBottom - layout.goalHeight,
    bottom: layout.goalBottom,
  );

  int? _zoneAt(double x, double y) {
    final g = _goalRect;
    const pad = 16.0;
    if (x < g.left - pad || x > g.right + pad) return null;
    if (y < g.top - pad || y > g.bottom + pad) return null;
    final col = (((x - g.left) / (g.right - g.left)) * 3).floor().clamp(0, 2);
    final topHalf = y < (g.top + g.bottom) / 2;
    return (topHalf ? 3 : 0) + col;
  }

  @override
  void pointerDown(double x, double y) {
    if (isFinished || _phase == _Phase.flying) return;
    final z = _zoneAt(x, y);
    if (z != null) {
      _zone = z;
      if (_phase == _Phase.pickZone) {
        _phase = _Phase.meter;
        _clock = 0;
      }
      return;
    }
    if (_phase == _Phase.meter && y > layout.height * 0.5) _shoot();
  }

  void _shoot() {
    final zone = _zone!;
    final res = PenaltyResolver.resolve(
      zone: zone,
      power: _meterValue,
      composure: composure,
      shooting: shooting,
      keeperSkill: keeperSkill,
      history: history,
      random: random,
      performance: performance,
    );
    _result = res;
    _phase = _Phase.flying;
    _flightT = 0;
    _target = layout.toScreen(res.finalX, res.finalY);
  }

  @override
  void tick(double dt, double scaled) {
    switch (_phase) {
      case _Phase.pickZone:
        // Bölge seçilmezse süre dolar ve fırsat kaçar.
        _clock += dt;
        if (_clock > MiniBalance.penaltyMaxSeconds) {
          finishGame(
            const MiniGameFinish(MomentOutcome.none),
            labels.timeout,
            good: false,
          );
        }
      case _Phase.meter:
        _clock += dt * meterSpeed;
        _meterValue = MiniGameBase.pingPong(
          _clock,
          MiniBalance.penaltyMeterPeriod,
        );
        if (_clock > MiniBalance.penaltyMaxSeconds) _shoot();
      case _Phase.flying:
        _flightT += scaled / 0.6;
        if (_flightT >= 1) {
          _flightT = 1;
          final r = _result!;
          finishGame(
            MiniGameFinish(
              r.isGoal ? MomentOutcome.goal : MomentOutcome.none,
              penaltyZone: r.zone,
            ),
            labels.forShotOutcome(r.outcome),
            good: r.isGoal,
            shake: r.isGoal ? 0.35 : 0.15,
            slowMo: r.isGoal ? 0.4 : 1,
          );
        }
    }
  }

  @override
  void paintScene(Canvas canvas) {
    final l = layout;
    drawPitchStripes(canvas);
    // Penaltı noktası ve alanı
    final line = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(0, l.goalBottom),
      Offset(l.width, l.goalBottom),
      line,
    );
    drawGoalFrame(canvas);

    final g = _goalRect;
    // Bölge ızgarası
    final grid = Paint()
      ..color = const Color(0x44FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    for (var i = 1; i < 3; i++) {
      final x = g.left + (g.right - g.left) * i / 3;
      canvas.drawLine(Offset(x, g.top), Offset(x, g.bottom), grid);
    }
    canvas.drawLine(
      Offset(g.left, (g.top + g.bottom) / 2),
      Offset(g.right, (g.top + g.bottom) / 2),
      grid,
    );
    if (_zone != null) {
      final col = _zone! % 3;
      final top = _zone! >= 3;
      final w = (g.right - g.left) / 3;
      final h = (g.bottom - g.top) / 2;
      canvas.drawRect(
        Rect.fromLTWH(g.left + col * w, top ? g.top : g.top + h, w, h),
        Paint()..color = const Color(0x66FFEB3B),
      );
    }

    _drawKeeper(canvas);

    final ballStart = (x: l.ballX, y: l.ballY);
    var bx = ballStart.x;
    var by = ballStart.y;
    var scale = 1.0;
    if (_phase == _Phase.flying) {
      final t = Curves.easeOut.transform(_flightT);
      bx = ballStart.x + (_target.x - ballStart.x) * t;
      by = ballStart.y + (_target.y - ballStart.y) * t;
      scale = 1 - 0.4 * t;
    }
    drawBall(canvas, bx, by, scale: scale);
    drawPerson(
      canvas,
      l.ballX + l.ballRadius * 4,
      l.ballY + l.ballRadius * 2,
      const Color(0xFF1565C0),
    );

    if (_phase == _Phase.meter) {
      drawMeter(
        canvas,
        _meterValue,
        zoneCenter:
            (MiniBalance.penaltyWeakPower + MiniBalance.penaltyRushedPower) / 2,
        zoneHalf:
            (MiniBalance.penaltyRushedPower - MiniBalance.penaltyWeakPower) / 2,
        label: labels.shootButton,
      );
    }
  }

  void _drawKeeper(Canvas canvas) {
    final l = layout;
    var kx = l.goalCenterX;
    var ky = l.goalBottom - l.goalHeight * 0.35;
    var tilt = 0.0;
    final r = _result;
    if (r != null) {
      final dive = Curves.easeOut.transform((_flightT * 1.4).clamp(0.0, 1.0));
      final t = l.toScreen(
        PenaltyResolver.zoneX(r.keeperZone),
        PenaltyResolver.zoneY(r.keeperZone),
      );
      kx += (t.x - kx) * dive;
      ky += (t.y - ky) * dive * 0.7;
      tilt = PenaltyResolver.zoneX(r.keeperZone) * 0.9 * dive;
    }
    drawPerson(
      canvas,
      kx,
      ky,
      const Color(0xFFFFB300),
      tilt: tilt,
      keeper: true,
      variant: 3,
    );
  }
}
