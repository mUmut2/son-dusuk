import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../../domain/match/minigames/pass.dart';
import '../../domain/match/moment_resolver.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';

enum _Phase { selecting, meter, flying }

/// Pas: bir takım arkadaşı seç, sonra güç ibresini yeşil bölgede durdur.
/// Vizyon yükseldikçe daha çok ve daha iyi seçenek görünür.
class PassGame extends MiniGameBase {
  PassGame({
    required super.hint,
    required super.onFinished,
    required this.labels,
    required this.options,
    required this.passing,
    required this.vision,
    required this.random,
    this.performance = 1,
    this.meterSpeed = 1,
    super.onImpact,
  });

  final MiniGameLabels labels;
  final List<PassOption> options;
  final double passing;
  final double vision;
  final GameRandom random;
  final double performance;
  final double meterSpeed;

  _Phase _phase = _Phase.selecting;
  PassOption? _selected;
  double _clock = 0;
  double _meterValue = 0;
  double _elapsed = 0;
  PassResult? _result;
  double _flightT = 0;

  ({double x, double y}) _mate(PassOption o) => (
    x: layout.goalCenterX + o.x * layout.width * 0.38,
    y: layout.ballY - o.depth * (layout.ballY - layout.height * 0.18),
  );

  /// Her seçeneğin yanına riskle orantılı bir rakip yerleştirilir.
  ({double x, double y}) _opponent(PassOption o) {
    final m = _mate(o);
    final dx = (o.x >= 0 ? -1 : 1) * layout.width * 0.07;
    return (x: (layout.ballX + m.x) / 2 + dx, y: (layout.ballY + m.y) / 2);
  }

  @override
  void pointerDown(double x, double y) {
    if (isFinished || _phase == _Phase.flying) return;
    if (_phase == _Phase.meter && y > layout.height * 0.84) {
      _pass();
      return;
    }
    PassOption? best;
    var bestDist = layout.ballRadius * 4.5;
    for (final o in options) {
      final m = _mate(o);
      final d = math.sqrt(math.pow(m.x - x, 2) + math.pow(m.y - y, 2));
      if (d < bestDist) {
        best = o;
        bestDist = d;
      }
    }
    if (best != null) {
      _selected = best;
      if (_phase == _Phase.selecting) {
        _phase = _Phase.meter;
        _clock = 0;
      }
    }
  }

  void _pass() {
    final o = _selected!;
    _result = PassResolver.resolve(
      option: o,
      power: _meterValue,
      passing: passing,
      vision: vision,
      random: random,
      performance: performance,
    );
    _phase = _Phase.flying;
    _flightT = 0;
  }

  @override
  void tick(double dt, double scaled) {
    _elapsed += dt;
    switch (_phase) {
      case _Phase.selecting:
        if (_elapsed > MiniBalance.passMaxSeconds) {
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
          MiniBalance.passMeterPeriod,
        );
        if (_elapsed > MiniBalance.passMaxSeconds + 4) _pass();
      case _Phase.flying:
        _flightT += scaled / 0.7;
        if (_flightT >= 1) {
          _flightT = 1;
          final r = _result!;
          finishGame(
            MiniGameFinish(
              r.assist ? MomentOutcome.assist : MomentOutcome.none,
            ),
            r.assist
                ? labels.passAssist
                : r.completed
                ? labels.passComplete
                : labels.passIntercepted,
            good: r.completed,
            shake: r.assist ? 0.3 : 0,
            slowMo: r.assist ? 0.5 : 1,
          );
        }
    }
  }

  @override
  void paintScene(Canvas canvas) {
    final l = layout;
    drawPitchStripes(canvas);
    final line = Paint()
      ..color = const Color(0x55FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, l.height * 0.12),
      Offset(l.width, l.height * 0.12),
      line,
    );

    // Pas çizgileri, rakipler ve takım arkadaşları
    for (var i = 0; i < options.length; i++) {
      final o = options[i];
      final m = _mate(o);
      final sel = identical(o, _selected);
      canvas.drawLine(
        Offset(l.ballX, l.ballY),
        Offset(m.x, m.y),
        Paint()
          ..color = sel ? const Color(0xFFFFEB3B) : const Color(0x44FFFFFF)
          ..strokeWidth = sel ? 4 : 2,
      );
      final opp = _opponent(o);
      // Rakip büyüklüğü = kesilme riski.
      drawPerson(
        canvas,
        opp.x,
        opp.y,
        const Color(0xFFC62828),
        scale: 0.6 + o.risk * 1.2,
      );
      drawPerson(
        canvas,
        m.x,
        m.y,
        sel ? const Color(0xFFFFD600) : const Color(0xFF1565C0),
        scale: 1.1,
        label: '${i + 1}',
      );
    }

    // Top ve uçuş
    var bx = l.ballX;
    var by = l.ballY;
    final r = _result;
    if (_phase == _Phase.flying && r != null) {
      final target = r.completed ? _mate(r.option) : _opponent(r.option);
      final t = Curves.easeOut.transform(_flightT);
      bx = l.ballX + (target.x - l.ballX) * t;
      by = l.ballY + (target.y - l.ballY) * t;
    }
    drawPerson(
      canvas,
      l.ballX - l.ballRadius * 3,
      l.ballY + l.ballRadius,
      const Color(0xFF1565C0),
    );
    drawBall(canvas, bx, by);

    if (_phase == _Phase.meter && _selected != null) {
      final half = MiniBalance.passPowerTolerance * (0.6 + 0.8 * passing) * 0.5;
      drawMeter(
        canvas,
        _meterValue,
        zoneCenter: _selected!.idealPower,
        zoneHalf: half,
        label: labels.shootButton,
      );
    }
  }
}
