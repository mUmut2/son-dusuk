import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';

void main() {
  group('GameRandom', () {
    test('aynı seed aynı diziyi üretir', () {
      final a = GameRandom(42);
      final b = GameRandom(42);
      expect(
        List.generate(20, (_) => a.nextDouble()),
        List.generate(20, (_) => b.nextDouble()),
      );
    });

    test('range uçlar dahil sınırlar içinde kalır', () {
      final r = GameRandom(1);
      final values = List.generate(1000, (_) => r.range(3, 5));
      expect(values.every((v) => v >= 3 && v <= 5), isTrue);
      expect(values.toSet(), {3, 4, 5});
    });

    test('gaussian ortalama ve sapmaya yakın çıkar', () {
      final r = GameRandom(7);
      final samples =
          List.generate(20000, (_) => r.gaussian(mean: 10, stdDev: 2));
      final mean = samples.reduce((a, b) => a + b) / samples.length;
      expect(mean, closeTo(10, 0.1));
    });
  });
}
