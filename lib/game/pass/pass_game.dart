import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../../domain/match/minigames/pass.dart';
import '../../domain/match/moment_resolver.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';
import 'pass_geometry.dart';

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

  /// Yerleşim ekran boyutuna bağlıdır; boyut değişince yeniden hesaplanır.
  List<PassSlot> _slots = const [];
  ({double w, double h}) _slotsFor = (w: 0, h: 0);

  List<PassSlot> get _layoutSlots {
    if (_slotsFor.w != layout.width || _slotsFor.h != layout.height) {
      _slots = PassGeometry.place(layout, options);
      _slotsFor = (w: layout.width, h: layout.height);
    }
    return _slots;
  }

  ({double x, double y}) _mate(PassOption o) {
    final s = _layoutSlots[options.indexOf(o)];
    return (x: s.mateX, y: s.mateY);
  }

  ({double x, double y}) _opponent(PassOption o) {
    final s = _layoutSlots[options.indexOf(o)];
    return (x: s.defenderX, y: s.defenderY);
  }

  /// Top pasörün ayağının yanında durur; pas çizgileri buradan çıkar.
  ({double x, double y}) get _ballStart => (
    x: layout.ballX + layout.ballRadius * 1.8,
    y: layout.ballY + layout.ballRadius * 0.3,
  );

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

    // Pas çizgileri (figürlerin altında kalır)
    final start = _ballStart;
    for (final o in options) {
      final m = _mate(o);
      final sel = identical(o, _selected);
      canvas.drawLine(
        Offset(start.x, start.y),
        Offset(m.x, m.y),
        Paint()
          ..color = sel ? const Color(0xFFFFEB3B) : const Color(0x44FFFFFF)
          ..strokeWidth = sel ? 4 : 2,
      );
    }

    // Rakipler (büyüklük = kesilme riski) ve takım arkadaşları
    for (var i = 0; i < options.length; i++) {
      final o = options[i];
      final s = _layoutSlots[i];
      drawPerson(
        canvas,
        s.defenderX,
        s.defenderY,
        const Color(0xFFC62828),
        scale: s.defenderScale,
        variant: i + 1,
      );
      drawPerson(
        canvas,
        s.mateX,
        s.mateY,
        identical(o, _selected)
            ? const Color(0xFFFFD600)
            : const Color(0xFF1565C0),
        scale: PassGeometry.mateScale,
        label: '${i + 1}',
        variant: i + 4,
      );
    }

    // Pasör, top ve uçuş
    final passer = PassGeometry.passer(l);
    drawPerson(
      canvas,
      passer.x,
      passer.y,
      const Color(0xFF1565C0),
      scale: PassGeometry.passerScale,
    );
    var bx = start.x;
    var by = start.y;
    final r = _result;
    if (_phase == _Phase.flying && r != null) {
      final target = r.completed ? _mate(r.option) : _opponent(r.option);
      final t = Curves.easeOut.transform(_flightT);
      bx = start.x + (target.x - start.x) * t;
      by = start.y + (target.y - start.y) * t;
    }
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
