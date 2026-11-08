import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart';

import 'mini_game_types.dart';
import 'shot/shot_geometry.dart';

/// Şut dışındaki mini oyunların ortak tabanı: yerleşim, dokunma, sonuç
/// gösterimi, sarsıntı/yavaş çekim ve çizim yardımcıları.
abstract class MiniGameBase extends FlameGame {
  MiniGameBase({required this.hint, required this.onFinished, this.onImpact});

  final String hint;
  final void Function(MiniGameFinish finish) onFinished;

  /// Sonuç anında titreşim için (true = olumlu sonuç).
  final void Function(bool good)? onImpact;

  ShotLayout layout = ShotLayout(1, 1);
  double timeScale = 1;
  double shakeTime = 0;

  String? _toast;
  double _toastTime = 0;

  String? _resultText;
  bool _resultGood = false;
  MiniGameFinish? _pending;
  double _endTimer = 0;
  bool _done = false;

  bool get isFinished => _pending != null || _done;

  @override
  Color backgroundColor() => const Color(0xFF2E7D32);

  @override
  Future<void> onLoad() async {
    add(_TouchLayer(this));
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    layout = ShotLayout(size.x, size.y);
  }

  // --- Alt sınıfların kullandığı kancalar ---
  void pointerDown(double x, double y) {}
  void tapUp(double x, double y) {}
  void dragStart(double x, double y) {}
  void dragUpdate(double x, double y) {}
  void dragEnd(double vx, double vy) {}
  void tick(double dt, double scaledDt);
  void paintScene(Canvas canvas);

  void showToast(String text, [double seconds = 1.2]) {
    _toast = text;
    _toastTime = seconds;
  }

  /// Mini oyunu bitirir; sonuç metni gösterildikten sonra [onFinished] çağrılır.
  void finishGame(
    MiniGameFinish finish,
    String text, {
    required bool good,
    double shake = 0,
    double slowMo = 1,
  }) {
    if (isFinished) return;
    _pending = finish;
    _resultText = text;
    _resultGood = good;
    shakeTime = shake;
    timeScale = slowMo;
    onImpact?.call(good);
  }

  @override
  void update(double dt) {
    super.update(dt);
    final scaled = dt * timeScale;
    if (_toastTime > 0) _toastTime -= dt;
    if (shakeTime > 0) shakeTime -= dt;
    if (!isFinished) tick(dt, scaled);
    if (_pending != null) {
      _endTimer += dt; // yavaş çekim sonuç süresini uzatmaz
      if (_endTimer > 1.5) {
        final f = _pending!;
        _pending = null;
        _done = true;
        onFinished(f);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    if (shakeTime > 0) {
      final r = math.Random();
      canvas.translate(
        (r.nextDouble() - 0.5) * 10,
        (r.nextDouble() - 0.5) * 10,
      );
    }
    paintScene(canvas);
    canvas.restore();

    final l = layout;
    if (!isFinished) {
      drawText(canvas, hint, l.width / 2, l.height * 0.045, size: 15);
    }
    if (_toastTime > 0 && _toast != null) {
      drawText(canvas, _toast!, l.width / 2, l.height * 0.5, size: 22);
    }
    if (isFinished || _done) {
      drawText(
        canvas,
        _resultText ?? '',
        l.width / 2,
        l.height * 0.5,
        size: 40,
        bold: true,
        color: _resultGood ? const Color(0xFFFFEB3B) : const Color(0xFFFFFFFF),
      );
    }
    super.render(canvas);
  }

  // --- Çizim yardımcıları ---

  void drawPitchStripes(Canvas canvas) {
    final l = layout;
    final stripe = Paint()..color = const Color(0xFF348A39);
    for (var i = 0; i < 8; i += 2) {
      canvas.drawRect(
        Rect.fromLTWH(0, l.height / 8 * i, l.width, l.height / 8),
        stripe,
      );
    }
  }

  void drawGoalFrame(Canvas canvas) {
    final l = layout;
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
    canvas.drawPath(
      Path()
        ..moveTo(left, l.goalBottom)
        ..lineTo(left, top)
        ..lineTo(right, top)
        ..lineTo(right, l.goalBottom),
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  void drawPerson(
    Canvas canvas,
    double x,
    double y,
    Color shirt, {
    double scale = 1,
    double tilt = 0,
    String? label,
  }) {
    final r = layout.ballRadius * scale;
    canvas
      ..save()
      ..translate(x, y)
      ..rotate(tilt)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: r * 2.4, height: r * 3.6),
          Radius.circular(r),
        ),
        Paint()..color = shirt,
      )
      ..drawCircle(
        Offset(0, -r * 2.2),
        r * 0.9,
        Paint()..color = const Color(0xFFD9A47A),
      )
      ..restore();
    if (label != null) {
      drawText(canvas, label, x, y, size: r * 1.3, bold: true);
    }
  }

  void drawBall(Canvas canvas, double x, double y, {double scale = 1}) {
    final r = layout.ballRadius * scale;
    canvas
      ..drawCircle(
        Offset(x + 3, y + 4),
        r,
        Paint()..color = const Color(0x44000000),
      )
      ..drawCircle(Offset(x, y), r, Paint()..color = const Color(0xFFFFFFFF))
      ..drawCircle(
        Offset(x, y),
        r * 0.4,
        Paint()..color = const Color(0xFF263238),
      );
  }

  /// Yatay güç ibresi. [value] 0-1; [zoneCenter]/[zoneHalf] doğru bölge.
  void drawMeter(
    Canvas canvas,
    double value, {
    double? zoneCenter,
    double zoneHalf = 0,
    String? label,
  }) {
    final l = layout;
    final rect = Rect.fromLTWH(
      l.width * 0.12,
      l.height * 0.9,
      l.width * 0.76,
      22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(11)),
      Paint()..color = const Color(0x99000000),
    );
    if (zoneCenter != null) {
      final zl = (zoneCenter - zoneHalf).clamp(0.0, 1.0);
      final zr = (zoneCenter + zoneHalf).clamp(0.0, 1.0);
      canvas.drawRect(
        Rect.fromLTRB(
          rect.left + rect.width * zl,
          rect.top,
          rect.left + rect.width * zr,
          rect.bottom,
        ),
        Paint()..color = const Color(0xAA76FF03),
      );
    }
    final x = rect.left + rect.width * value.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x, rect.center.dy),
          width: 8,
          height: 34,
        ),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    if (label != null) {
      drawText(canvas, label, l.width / 2, rect.top - 18, size: 16, bold: true);
    }
  }

  void drawText(
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
    )..layout(maxWidth: layout.width - 32);
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  /// Üçgen dalga (0-1-0) — salınan ibreler için.
  static double pingPong(double t, double period) =>
      (1 - math.cos(2 * math.pi * t / period)) / 2;
}

class _TouchLayer extends PositionComponent with DragCallbacks, TapCallbacks {
  _TouchLayer(this.game);

  final MiniGameBase game;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  /// Katman tüm ekranı kaplar; boyutu henüz atanmamış olsa bile dokunuşları yakalar.
  @override
  bool containsLocalPoint(Vector2 point) => true;

  @override
  void onTapDown(TapDownEvent event) {
    final p = event.canvasPosition;
    game.pointerDown(p.x, p.y);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final p = event.canvasPosition;
    game.tapUp(p.x, p.y);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final p = event.canvasPosition;
    game.dragStart(p.x, p.y);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final p = event.canvasEndPosition;
    game.dragUpdate(p.x, p.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    game.dragEnd(event.velocity.x, event.velocity.y);
  }
}
