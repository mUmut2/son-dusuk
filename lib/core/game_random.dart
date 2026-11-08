import 'dart:math';

/// Oyundaki TEK rastgelelik kaynağı. Seed verilirse sonuçlar tekrarlanabilir
/// (test edilebilirlik ve "günlük zorluk" için). Domain kodu `dart:math`
/// Random'ı doğrudan kullanmaz, her zaman bunu alır.
class GameRandom {
  GameRandom([int? seed]) : _random = Random(seed);

  final Random _random;

  /// [0, 1) aralığında ondalık sayı.
  double nextDouble() => _random.nextDouble();

  /// [0, max) aralığında tam sayı.
  int nextInt(int max) => _random.nextInt(max);

  /// [min, max] aralığında (uçlar dahil) tam sayı.
  int range(int min, int max) {
    assert(min <= max, 'min, max değerinden büyük olamaz');
    return min + _random.nextInt(max - min + 1);
  }

  /// [chance] olasılığıyla (0..1) true döner.
  bool chance(double chance) => _random.nextDouble() < chance;

  /// Ortalaması [mean], standart sapması [stdDev] olan normal dağılımlı sayı.
  double gaussian({double mean = 0, double stdDev = 1}) {
    // Box-Muller dönüşümü; log(0)'dan kaçınmak için 1 - u kullanılır.
    final u1 = 1 - _random.nextDouble();
    final u2 = _random.nextDouble();
    final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    return mean + z * stdDev;
  }

  /// Listeden eşit olasılıkla bir eleman seçer.
  T pick<T>(List<T> items) {
    assert(items.isNotEmpty, 'Boş listeden seçim yapılamaz');
    return items[_random.nextInt(items.length)];
  }
}
