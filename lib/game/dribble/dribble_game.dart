import 'dart:math' as math;

import 'package:flutter/animation.dart';
import 'package:flutter/painting.dart';

import '../../core/game_random.dart';
import '../../domain/match/minigames/dribble.dart';
import '../../domain/match/minigames/mini_balance.dart';
import '../mini_game_base.dart';
import '../mini_game_types.dart';

enum _Phase { running, resolving, done }

/// Dribling: parmağını sağa sola sürükleyerek oyuncunu yönlendir; aşağı inen
/// savunmacı dalgalarının arasındaki yeşil geçitten geç. Hiçbirine çarpmadan
/// son dalgayı geçersen çalım tutar.
class DribbleGame extends MiniGameBase {
  DribbleGame({
    required super.hint,
    required super.onFinished,
    required this.labels,
    required double dribbling,
    required double agility,
    required double ballControl,
    required this.defenderSkill,
    required this.random,
    double performance = 1,
    this.windowScale = 1,
    this.tempo = 1,
    super.onImpact,
  }) : _waves = DribbleResolver.generateWaves(random, tempo: tempo),
       _gapHalf = DribbleResolver.gapHalf(
         skill: (dribbling + agility + ballControl) / 3,
         windowScale: windowScale,
         performance: performance,
       ),
       _sway = DribbleResolver.swayAmplitude(defenderSkill);

  final MiniGameLabels labels;
  final double defenderSkill;
  final GameRandom random;

  /// Zorluk: >1 geçit geniş (kolay), <1 dar (zor).
  final double windowScale;

  /// Zorluk: >1 dalgalar daha hızlı gelir.
  final double tempo;

  final List<DribbleWave> _waves;
  final double _gapHalf;
  final double _sway;

  _Phase _phase = _Phase.running;
  double _clock = 0;
  bool _initialized = false;
  double _playerX = 0;
  double _targetX = 0;
  int _next = 0; // sıradaki kontrol edilecek dalga
  int _hits = 0;
  int _hitWave = -1;
  double _hitSide = 0; // çarpılan savunmacı: -1 sol, +1 sağ
  double _animT = 0;
  DribbleResult? _result;

  double get _travel => MiniBalance.dribbleTravelSeconds / tempo;
  double get _lastArrival => _waves.last.arrival;

  double get _playerY => layout.height * 0.78;
  double get _topY => -layout.ballRadius * 5;

  /// Dalganın ekrandaki y'si: [arrival] anında oyuncunun hizasında olur.
  double _waveY(DribbleWave w) =>
      _playerY - (w.arrival - _clock) / _travel * (_playerY - _topY);

  void _init() {
    if (_initialized) return;
    _initialized = true;
    _playerX = layout.width / 2;
    _targetX = layout.width / 2;
  }

  @override
  void pointerDown(double x, double y) => _targetX = x;

  @override
  void dragStart(double x, double y) => _targetX = x;

  @override
  void dragUpdate(double x, double y) => _targetX = x;

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
      case _Phase.running:
        _clock += dt;
        final target = _targetX.clamp(l.width * 0.1, l.width * 0.9);
        final maxStep = MiniBalance.dribblePlayerSpeed * l.width * dt;
        final step = ((target - _playerX) * math.min(1, dt * 14)).clamp(
          -maxStep,
          maxStep,
        );
        _playerX += step;

        // Dalga oyuncunun hizasına geldiği an çarpışma kontrolü.
        while (_next < _waves.length && _clock >= _waves[_next].arrival) {
          final w = _waves[_next];
          if (DribbleResolver.isHit(
            playerX: _playerX / l.width,
            wave: w,
            amplitude: _sway,
            gapHalf: _gapHalf,
          )) {
            _hits++;
            _hitWave = _next;
            final center = DribbleResolver.gapCenterAt(w, w.arrival, _sway);
            _hitSide = _playerX / l.width < center ? -1 : 1;
            _startResolve(DribbleResolver.resolve(hits: _hits, random: random));
            return;
          }
          _next++;
        }
        if (_clock >= _lastArrival + 0.5) {
          _startResolve(DribbleResolver.resolve(hits: _hits, random: random));
        }
      case _Phase.resolving:
        // Dalgalar donar (saat ilerlemez); yalnızca sonuç animasyonu oynar.
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

    final offset = DribbleResolver.defenderOffset(_gapHalf);

    // Dalgalar: yeşil geçit ve iki yanında savunmacılar.
    for (var i = 0; i < _waves.length; i++) {
      final w = _waves[i];
      final y = _waveY(w);
      if (y < _topY - l.ballRadius * 3 || y > l.height + l.ballRadius * 4) {
        continue;
      }
      final center = DribbleResolver.gapCenterAt(w, _clock, _sway);
      final gx = center * l.width;
      final half = _gapHalf * l.width;
      final passed = y > _playerY + l.ballRadius;
      if (!passed) {
        final strip = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            gx - half,
            y - l.ballRadius * 2,
            gx + half,
            y + 2.6 * l.ballRadius,
          ),
          Radius.circular(l.ballRadius),
        );
        canvas
          ..drawRRect(strip, Paint()..color = const Color(0x3376FF03))
          ..drawRRect(
            strip,
            Paint()
              ..color = const Color(0x8876FF03)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2,
          );
      }
      for (final side in const [-1.0, 1.0]) {
        var dx = gx + side * offset * l.width;
        var tilt = 0.0;
        if (i == _hitWave && side == _hitSide) {
          // Çarpılan savunmacı topu almaya gelir.
          final t = Curves.easeOut.transform(_animT);
          dx += (_playerX - dx) * t * 0.6;
          tilt = side * 0.5 * t;
        }
        if (dx < l.width * 0.02 || dx > l.width * 0.98) continue;
        drawPerson(canvas, dx, y, const Color(0xFFC62828), tilt: tilt);
      }
    }

    var py = _playerY;
    if (_phase != _Phase.running && _result!.beaten) {
      // Hat geçildi: oyuncu ileri koşar.
      py -= l.height * 0.3 * Curves.easeOut.transform(_animT);
    }
    drawPerson(canvas, _playerX, py, const Color(0xFF1565C0), scale: 1.15);
    drawBall(canvas, _playerX + l.ballRadius * 2.2, py + l.ballRadius * 2.6);

    if (_phase == _Phase.running) _paintGuideArrow(canvas);
  }

  /// Sıradaki geçit oyuncudan uzaktaysa, gideceği yönü sarı okla gösterir.
  void _paintGuideArrow(Canvas canvas) {
    if (_next >= _waves.length) return;
    final l = layout;
    final gx =
        DribbleResolver.gapCenterAt(_waves[_next], _clock, _sway) * l.width;
    if ((gx - _playerX).abs() <= _gapHalf * l.width * 0.8) return;
    final dir = gx > _playerX ? 1.0 : -1.0;
    final s = l.ballRadius * 0.9;
    final x = _playerX + dir * l.ballRadius * 4;
    final y = _playerY - l.ballRadius * 8;
    canvas.drawPath(
      Path()
        ..moveTo(x + dir * s, y)
        ..lineTo(x - dir * s * 0.6, y - s)
        ..lineTo(x - dir * s * 0.6, y + s)
        ..close(),
      Paint()..color = const Color(0xFFFFEB3B),
    );
  }
}
