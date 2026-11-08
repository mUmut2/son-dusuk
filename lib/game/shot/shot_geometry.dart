import 'dart:math' as math;

import '../../domain/match/shot/shot_balance.dart';

/// Ekran koordinatlarında sahne yerleşimi ve kale düzlemi dönüşümleri.
/// Flame'den bağımsız saf Dart; swipe okuma mantığı testle doğrulanır.
class ShotLayout {
  ShotLayout(this.width, this.height);

  final double width;
  final double height;

  double get ballX => width / 2;
  double get ballY => height * 0.82;
  double get ballRadius => math.min(width, height) * 0.035;

  double get goalCenterX => width / 2;
  double get goalHalfWidth => width * 0.38;
  double get goalBottom => height * 0.27; // kale çizgisi (zemin)
  double get goalHeight => height * 0.15;

  /// Kale düzlemi (x: -1..1, y: 0..1) -> ekran.
  ({double x, double y}) toScreen(double x, double y) =>
      (x: goalCenterX + x * goalHalfWidth, y: goalBottom - y * goalHeight);

  /// Savunmacının ekrandaki yeri: top ile şut çizgisi arasının ortası.
  ({double x, double y}) defenderPosition(double defenderAimX) {
    final target = toScreen(defenderAimX, 0);
    return (x: (ballX + target.x) / 2, y: (ballY + goalBottom) / 2);
  }
}

class SwipeReading {
  const SwipeReading({
    required this.aimX,
    required this.aimY,
    required this.curve,
    required this.power,
  });

  final double aimX;
  final double aimY;
  final double curve;
  final double power;
}

abstract final class ShotGeometry {
  /// Topa yakın başlangıç sayılır (ekran birimi: top yarıçapı çarpanı).
  static const double grabRadiusFactor = 3.0;
  static const double minSwipeLength = 40;

  static bool nearBall(ShotLayout layout, double x, double y) {
    final dx = x - layout.ballX;
    final dy = y - layout.ballY;
    return math.sqrt(dx * dx + dy * dy) <= layout.ballRadius * grabRadiusFactor;
  }

  /// [path]: parmağın (x, y) noktaları; [speed]: bırakma hızı (px/sn).
  /// Geçersiz swipe (aşağı/çok kısa) için null döner.
  static SwipeReading? read(
    ShotLayout layout,
    List<({double x, double y})> path,
    double speed,
  ) {
    if (path.length < 2) return null;
    final start = path.first;
    final end = path.last;
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final dyUp = -dy;
    final chord = math.sqrt(dx * dx + dy * dy);
    if (dyUp <= 0 || chord < minSwipeLength) return null;

    // Çizgiyi kale çizgisine uzat: yatay hedef.
    final distanceToGoal = layout.ballY - layout.goalBottom;
    final t = distanceToGoal / dyUp;
    final aimScreenX = start.x + dx * t;
    final aimX = (aimScreenX - layout.goalCenterX) / layout.goalHalfWidth;

    // Yükseklik: swipe kale çizgisini geçtiyse geçtiği kadar yukarı.
    final aimY = dyUp >= distanceToGoal
        ? ((dyUp - distanceToGoal) / layout.goalHeight).clamp(0.05, 1.3)
        : 0.05;

    // Falso: yolun akordan en büyük işaretli sapması (sağ = +).
    var maxDeviation = 0.0;
    for (final p in path) {
      final cross = dx * (p.y - start.y) - dy * (p.x - start.x);
      final signed = cross / chord;
      if (signed.abs() > maxDeviation.abs()) maxDeviation = signed;
    }
    final curve = (maxDeviation / chord / ShotBalance.fullCurveRatio).clamp(
      -1.0,
      1.0,
    );

    final power =
        ((speed - ShotBalance.minSwipeSpeed) /
                (ShotBalance.maxSwipeSpeed - ShotBalance.minSwipeSpeed))
            .clamp(0.1, 1.0);

    return SwipeReading(aimX: aimX, aimY: aimY, curve: curve, power: power);
  }
}
