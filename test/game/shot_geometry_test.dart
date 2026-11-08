import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/game/shot/shot_geometry.dart';

void main() {
  final layout = ShotLayout(400, 800);
  ({double x, double y}) p(double x, double y) => (x: x, y: y);

  test('düz yukarı swipe ortaya gider, falso yok', () {
    final path = [
      p(layout.ballX, layout.ballY),
      p(layout.ballX, layout.ballY - 300),
      p(layout.ballX, layout.ballY - 600),
    ];
    final r = ShotGeometry.read(layout, path, 2000)!;
    expect(r.aimX, closeTo(0, 1e-9));
    expect(r.curve, closeTo(0, 1e-9));
    expect(r.power, inInclusiveRange(0.1, 1));
  });

  test('sağa açılı swipe pozitif aimX, sola negatif', () {
    final right = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX + 100, layout.ballY - 400),
    ], 1500)!;
    final left = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX - 100, layout.ballY - 400),
    ], 1500)!;
    expect(right.aimX, greaterThan(0));
    expect(left.aimX, lessThan(0));
    expect(right.aimX, closeTo(-left.aimX, 1e-9));
  });

  test('yol sağa kavisliyse falso pozitif, sola kavisliyse negatif', () {
    final bulgeRight = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX + 60, layout.ballY - 200),
      p(layout.ballX, layout.ballY - 400),
    ], 1500)!;
    final bulgeLeft = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX - 60, layout.ballY - 200),
      p(layout.ballX, layout.ballY - 400),
    ], 1500)!;
    expect(bulgeRight.curve, greaterThan(0));
    expect(bulgeLeft.curve, lessThan(0));
  });

  test('swipe uzunluğu yüksekliği belirler', () {
    final d = layout.ballY - layout.goalBottom;
    final low = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX, layout.ballY - d * 0.8),
    ], 1500)!;
    final high = ShotGeometry.read(layout, [
      p(layout.ballX, layout.ballY),
      p(layout.ballX, layout.ballY - d - layout.goalHeight * 0.8),
    ], 1500)!;
    expect(low.aimY, lessThan(0.1));
    expect(high.aimY, closeTo(0.8, 1e-9));
  });

  test('güç hızla artar ve sınırlıdır', () {
    final path = [
      p(layout.ballX, layout.ballY),
      p(layout.ballX, layout.ballY - 300),
    ];
    final slow = ShotGeometry.read(layout, path, 400)!;
    final fast = ShotGeometry.read(layout, path, 9999)!;
    expect(fast.power, 1);
    expect(slow.power, lessThan(0.2));
  });

  test('aşağı veya çok kısa swipe geçersiz', () {
    expect(
      ShotGeometry.read(layout, [
        p(layout.ballX, layout.ballY),
        p(layout.ballX, layout.ballY + 200),
      ], 1500),
      isNull,
    );
    expect(
      ShotGeometry.read(layout, [
        p(layout.ballX, layout.ballY),
        p(layout.ballX, layout.ballY - 10),
      ], 1500),
      isNull,
    );
  });

  test('topa yakın başlangıç kabul edilir', () {
    expect(ShotGeometry.nearBall(layout, layout.ballX, layout.ballY), isTrue);
    expect(ShotGeometry.nearBall(layout, layout.ballX, 100), isFalse);
  });
}
