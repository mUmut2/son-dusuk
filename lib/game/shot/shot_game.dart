import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/shot/shot_balance.dart';
import '../../domain/match/shot/shot_models.dart';
import '../../domain/match/shot/shot_resolver.dart';
import 'shot_geometry.dart';

/// Oyun içinde gösterilen yerelleştirilmiş metinler (Flutter tarafından verilir).
class ShotGameLabels {
  const ShotGameLabels({
    required this.hint,
    required this.invalidSwipe,
    required this.goal,
    required this.saved,
    required this.blocked,
    required this.offTarget,
    required this.woodwork,
    required this.timeout,
    required this.perfect,
  });

  final String hint;
  final String invalidSwipe;
  final String goal;
  final String saved;
  final String blocked;
  final String offTarget;
  final String woodwork;
  final String timeout;
  final String perfect;

  String forOutcome(ShotOutcome o) => switch (o) {
    ShotOutcome.goal => goal,
    ShotOutcome.saved => saved,
    ShotOutcome.blocked => blocked,
    ShotOutcome.offTarget => offTarget,
    ShotOutcome.woodwork => woodwork,
    ShotOutcome.timeout => timeout,
  };
}

enum _Phase { aiming, flying, showing, done }

/// Şut mini oyunu: zamanlama halkası + swipe (yön, güç, falso).
/// Fizik/sonuç `ShotResolver`'dadır; burası yalnızca girdiyi toplar ve canlandırır.
class ShotGame extends FlameGame {
  ShotGame({
    required this.profile,
    required this.shotContext,
    required this.random,
    required this.labels,
    required this.onFinished,
    this.onImpact,
  });

  final ShotProfile profile;
  final ShotContext shotContext;
  final GameRandom random;
  final ShotGameLabels labels;
  final void Function(ShotResult result) onFinished;

  /// Gol/kurtarış anında titreşim vb. için.
  final void Function(ShotOutcome outcome)? onImpact;

  ShotLayout _layout = ShotLayout(1, 1);
  _Phase _phase = _Phase.aiming;

  // Halka
  static const double _ringOverrun = 1.25; // geç kalma bölgesi
  static const double _ringPause = 0.3;
  double _ringClock = 0;
  int _cycles = 0;

  // Swipe
  final List<({double x, double y})> _path = [];
  bool _dragging = false;
  double _gripTiming = 0;
  String? _toast;
  double _toastTime = 0;

  // Uçuş / sonuç
  ShotResult? _result;
  late ({double x, double y}) _flightStart;
  late ({double x, double y}) _flightEnd;
  double _flightControlOffset = 0;
  double _flightT = 0;
  double _showT = 0;
  double _shake = 0;
  double _timeScale = 1;
  bool _impactFired = false;

  double get _ringProgress {
    final cycleLength = profile.ringSeconds * _ringOverrun + _ringPause;
    final t = _ringClock % cycleLength;
    return t / profile.ringSeconds;
  }

  bool get _ringActive => _ringProgress <= _ringOverrun;

  @override
  Color backgroundColor() => const Color(0xFF2E7D32);

  @override
  Future<void> onLoad() async {
    add(_TouchLayer(this));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout = ShotLayout(size.x, size.y);
  }

  // --- Girdi (TouchLayer çağırır) ---

  void _dragStart(double x, double y) {
    if (_phase != _Phase.aiming || !_ringActive) return;
    if (!ShotGeometry.nearBall(_layout, x, y)) return;
    _dragging = true;
    _gripTiming = profile.timingQuality(_ringProgress);
    _path
      ..clear()
      ..add((x: x, y: y));
  }

  void _dragUpdate(double x, double y) {
    if (_dragging) _path.add((x: x, y: y));
  }

  void _dragEnd(double speed) {
    if (!_dragging) return;
    _dragging = false;
    final reading = ShotGeometry.read(_layout, _path, speed);
    _path.clear();
    if (reading == null) {
      _toast = labels.invalidSwipe;
      _toastTime = 1.2;
      return;
    }
    final input = ShotInput(
      aimX: reading.aimX,
      aimY: reading.aimY,
      power: reading.power,
      curve: reading.curve,
      timing: _gripTiming,
    );
    _launch(
      ShotResolver.resolve(
        input: input,
        profile: profile,
        context: shotContext,
        random: random,
      ),
      reading.curve,
    );
  }

  void _launch(ShotResult result, double curve) {
    _result = result;
    _phase = _Phase.flying;
    _flightT = 0;
    _flightStart = (x: _layout.ballX, y: _layout.ballY);
    if (result.outcome == ShotOutcome.blocked) {
      _flightEnd = _layout.defenderPosition(shotContext.defenderAimX);
      _flightControlOffset = 0;
    } else {
      _flightEnd = _layout.toScreen(result.finalX, result.finalY);
      _flightControlOffset = curve * _layout.width * 0.18;
    }
  }

  void _timeout() {
    _result = const ShotResult.timeout();
    _phase = _Phase.showing;
    _showT = 0;
    _fireImpact();
  }

  void _fireImpact() {
    if (_impactFired) return;
    _impactFired = true;
    final r = _result!;
    if (r.outcome == ShotOutcome.goal) {
      _shake = 0.35;
      _timeScale = 0.4;
    } else if (r.outcome == ShotOutcome.woodwork ||
        r.outcome == ShotOutcome.saved) {
      _shake = 0.15;
    }
    onImpact?.call(r.outcome);
  }

  // --- Güncelleme ---

  @override
  void update(double dt) {
    super.update(dt);
    final scaled = dt * _timeScale;

    if (_toastTime > 0) _toastTime -= dt;
    if (_shake > 0) _shake -= dt;

    switch (_phase) {
      case _Phase.aiming:
        final before = _ringClock;
        _ringClock += dt;
        final cycleLength = profile.ringSeconds * _ringOverrun + _ringPause;
        if ((_ringClock ~/ cycleLength) > (before ~/ cycleLength) &&
            !_dragging) {
          _cycles++;
          if (_cycles >= ShotBalance.ringMaxCycles) _timeout();
        }
      case _Phase.flying:
        _flightT += scaled / ShotBalance.ballFlightSeconds;
        if (_flightT >= 1) {
          _flightT = 1;
          _phase = _Phase.showing;
          _showT = 0;
          _fireImpact();
        }
      case _Phase.showing:
        _showT += scaled;
        if (_showT > 1.4 / 1) {
          _phase = _Phase.done;
          onFinished(_result!);
        }
      case _Phase.done:
        break;
    }
  }

  // --- Çizim ---

  ({double x, double y}) get _ballPosition {
    if (_phase == _Phase.aiming) return (x: _layout.ballX, y: _layout.ballY);
    final t = Curves.easeOut.transform(_flightT);
    final cx = (_flightStart.x + _flightEnd.x) / 2 + _flightControlOffset;
    final cy = (_flightStart.y + _flightEnd.y) / 2;
    final u = 1 - t;
    return (
      x: u * u * _flightStart.x + 2 * u * t * cx + t * t * _flightEnd.x,
      y: u * u * _flightStart.y + 2 * u * t * cy + t * t * _flightEnd.y,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (_shake > 0) {
      canvas.translate(
        (math.Random().nextDouble() - 0.5) * 10,
        (math.Random().nextDouble() - 0.5) * 10,
      );
    }
    _drawPitch(canvas);
    _drawGoal(canvas);
    _drawKeeper(canvas);
    _drawDefender(canvas);
    if (_phase == _Phase.aiming) {
      _drawRing(canvas);
      _drawAimPreview(canvas);
    }
    _drawBall(canvas);
    canvas.restore();
    _drawTexts(canvas);
    super.render(canvas);
  }

  void _drawPitch(Canvas canvas) {
    final l = _layout;
    final stripe = Paint()..color = const Color(0xFF348A39);
    const stripes = 8;
    for (var i = 0; i < stripes; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, l.height / stripes * i, l.width, l.height / stripes),
        stripe,
      );
    }
    final line = Paint()
      ..color = const Color(0x88FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(0, l.goalBottom),
      Offset(l.width, l.goalBottom),
      line,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        l.goalCenterX - l.goalHalfWidth * 1.5,
        l.goalBottom,
        l.goalCenterX + l.goalHalfWidth * 1.5,
        l.goalBottom + l.height * 0.2,
      ),
      line,
    );
  }

  void _drawGoal(Canvas canvas) {
    final l = _layout;
    final left = l.goalCenterX - l.goalHalfWidth;
    final right = l.goalCenterX + l.goalHalfWidth;
    final top = l.goalBottom - l.goalHeight;

    final net = Paint()
      ..color = const Color(0x55FFFFFF)
      ..strokeWidth = 1;
    for (var i = 1; i < 12; i++) {
      final x = left + (right - left) * i / 12;
      canvas.drawLine(Offset(x, top), Offset(x, l.goalBottom), net);
    }
    for (var i = 1; i < 5; i++) {
      final y = top + l.goalHeight * i / 5;
      canvas.drawLine(Offset(left, y), Offset(right, y), net);
    }
    final post = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(left, l.goalBottom)
        ..lineTo(left, top)
        ..lineTo(right, top)
        ..lineTo(right, l.goalBottom),
      post,
    );
  }

  void _drawKeeper(Canvas canvas) {
    final l = _layout;
    var kx = l.goalCenterX;
    var ky = l.goalBottom - l.goalHeight * 0.35;
    var tilt = 0.0;
    final r = _result;
    if (r != null && r.outcome != ShotOutcome.timeout) {
      final dive = Curves.easeOut.transform((_flightT * 1.6).clamp(0.0, 1.0));
      final target = l.toScreen(r.keeperX, 0.3);
      kx = l.goalCenterX + (target.x - l.goalCenterX) * dive;
      ky = ky + (target.y - ky) * dive * 0.6;
      tilt = (r.keeperX) * 0.9 * dive;
    }
    canvas
      ..save()
      ..translate(kx, ky)
      ..rotate(tilt);
    final body = Paint()..color = const Color(0xFFFFB300);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: l.ballRadius * 2.4,
            height: l.ballRadius * 3.6,
          ),
          Radius.circular(l.ballRadius),
        ),
        body,
      )
      ..drawCircle(
        Offset(0, -l.ballRadius * 2.2),
        l.ballRadius * 0.9,
        Paint()..color = const Color(0xFFD9A47A),
      )
      ..restore();
  }

  void _drawDefender(Canvas canvas) {
    final l = _layout;
    var pos = l.defenderPosition(shotContext.defenderAimX);
    if (_result?.outcome == ShotOutcome.timeout) {
      final t = Curves.easeIn.transform((_showT * 2).clamp(0.0, 1.0));
      pos = (
        x: pos.x + (l.ballX - pos.x) * t,
        y: pos.y + (l.ballY - pos.y) * t,
      );
    }
    // Baskı arttıkça savunmacı daha belirgin/iri çizilir.
    final scale = 0.8 + 0.5 * shotContext.pressure;
    canvas
      ..save()
      ..translate(pos.x, pos.y);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: l.ballRadius * 2.4 * scale,
            height: l.ballRadius * 3.6 * scale,
          ),
          Radius.circular(l.ballRadius),
        ),
        Paint()..color = const Color(0xFF1565C0),
      )
      ..drawCircle(
        Offset(0, -l.ballRadius * 2.2 * scale),
        l.ballRadius * 0.9 * scale,
        Paint()..color = const Color(0xFFD9A47A),
      )
      ..restore();
  }

  void _drawRing(Canvas canvas) {
    if (!_ringActive) return;
    final l = _layout;
    final progress = _ringProgress.clamp(0.0, _ringOverrun);
    final maxR = l.ballRadius * 7;
    final radius = maxR - (maxR - l.ballRadius) * progress.clamp(0.0, 1.0);
    final quality = profile.timingQuality(_ringProgress);
    final color = Color.lerp(
      const Color(0xFFFFFFFF),
      quality >= 0.99 ? const Color(0xFFFFD600) : const Color(0xFF76FF03),
      quality,
    )!;
    canvas
      ..drawCircle(
        Offset(l.ballX, l.ballY),
        radius,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      )
      ..drawCircle(
        Offset(l.ballX, l.ballY),
        l.ballRadius * 1.5,
        Paint()
          ..color = const Color(0x66FFFFFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  void _drawAimPreview(Canvas canvas) {
    if (!_dragging || _path.length < 2) return;
    final trail = Paint()
      ..color = const Color(0xCCFFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(_path.first.x, _path.first.y);
    for (final p in _path.skip(1)) {
      path.lineTo(p.x, p.y);
    }
    canvas.drawPath(path, trail);

    // Tahmini varış noktası (sapma ve zamanlama hariç, adil ipucu).
    final reading = ShotGeometry.read(_layout, _path, 1500);
    if (reading != null) {
      final x = reading.aimX + reading.curve * profile.curveGain;
      final target = _layout.toScreen(x, reading.aimY);
      canvas.drawCircle(
        Offset(target.x, target.y),
        _layout.ballRadius * 0.8,
        Paint()
          ..color = const Color(0xFFFFEB3B)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }
  }

  void _drawBall(Canvas canvas) {
    final p = _ballPosition;
    final shrink = _phase == _Phase.aiming ? 1.0 : (1 - 0.35 * _flightT);
    final r = _layout.ballRadius * shrink;
    canvas
      ..drawCircle(
        Offset(p.x + 3, p.y + 4),
        r,
        Paint()..color = const Color(0x44000000),
      )
      ..drawCircle(
        Offset(p.x, p.y),
        r,
        Paint()..color = const Color(0xFFFFFFFF),
      )
      ..drawCircle(
        Offset(p.x, p.y),
        r * 0.4,
        Paint()..color = const Color(0xFF263238),
      );
  }

  void _drawTexts(Canvas canvas) {
    final l = _layout;
    if (_phase == _Phase.aiming) {
      _text(canvas, labels.hint, l.width / 2, l.height * 0.93, size: 16);
    }
    if (_toastTime > 0 && _toast != null) {
      _text(canvas, _toast!, l.width / 2, l.height * 0.55, size: 20);
    }
    if (_phase == _Phase.showing || _phase == _Phase.done) {
      final r = _result!;
      final color = r.isGoal
          ? const Color(0xFFFFEB3B)
          : const Color(0xFFFFFFFF);
      _text(
        canvas,
        labels.forOutcome(r.outcome),
        l.width / 2,
        l.height * 0.5,
        size: 44,
        color: color,
        bold: true,
      );
      if (r.perfectTiming && r.outcome != ShotOutcome.timeout) {
        _text(canvas, labels.perfect, l.width / 2, l.height * 0.58, size: 20);
      }
    }
  }

  void _text(
    Canvas canvas,
    String text,
    double cx,
    double cy, {
    double size = 18,
    Color color = const Color(0xFFFFFFFF),
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
          shadows: const [Shadow(blurRadius: 6, color: Color(0xFF000000))],
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: _layout.width - 32);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }
}

/// Tüm ekranı kaplayan, sürükleme olaylarını oyuna ileten katman.
class _TouchLayer extends PositionComponent with DragCallbacks {
  _TouchLayer(this.game);

  final ShotGame game;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final p = event.canvasPosition;
    game._dragStart(p.x, p.y);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final p = event.canvasEndPosition;
    game._dragUpdate(p.x, p.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    game._dragEnd(event.velocity.length);
  }
}
