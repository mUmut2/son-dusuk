import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_development.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

/// 16 -> 38 yaş kariyerini simüle eder; her yaştaki oyuncuyu döndürür.
List<Player> simulateCareer(int seed, PlayerPosition position) {
  final random = GameRandom(seed);
  var player = PlayerFactory.create(
    name: 'Sim',
    birthplace: 'Ankara',
    position: position,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: random,
  );
  final history = [player];
  while (player.age < 38) {
    player = PlayerDevelopment.advanceYear(player, random);
    history.add(player);
  }
  return history;
}

void main() {
  const careers = 300; // x 22 sezon = 6600 sezon

  test('gelişim makul aralıkta kalır (aşırı güçlü / hiç gelişmeyen yok)', () {
    final peaks = <int>[];
    final gains = <int>[];
    for (var seed = 0; seed < careers; seed++) {
      final position = PlayerPosition.values[seed % 5];
      final history = simulateCareer(seed, position);
      final peak = history
          .map((p) => p.overall)
          .reduce((a, b) => a > b ? a : b);
      peaks.add(peak);
      gains.add(peak - history.first.overall);
      for (final p in history) {
        for (final a in Attribute.values) {
          expect(p.attributes[a], inInclusiveRange(1, 99));
        }
      }
    }
    final meanPeak = peaks.reduce((a, b) => a + b) / careers;
    // Not: bilgi amaçlı, ayarlama için bkz. docs/GDD.md denge tabloları.
    // ignore: avoid_print
    print(
      'ortalama zirve: ${meanPeak.toStringAsFixed(1)}, '
      'min: ${peaks.reduce((a, b) => a < b ? a : b)}, '
      'max: ${peaks.reduce((a, b) => a > b ? a : b)}',
    );

    expect(meanPeak, inInclusiveRange(58, 80));
    expect(peaks.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(95));
    expect(peaks.reduce((a, b) => a < b ? a : b), greaterThan(45));
    expect(gains.every((g) => g >= 5), isTrue, reason: 'herkes gelişmeli');
  });

  test('yüksek potansiyel daha yüksek zirve getirir', () {
    double meanPeak(bool high) {
      final peaks = <int>[];
      for (var seed = 0; seed < 2000 && peaks.length < 60; seed++) {
        final h = simulateCareer(seed, PlayerPosition.forward);
        if ((h.first.potential >= 82) == high &&
            (high || h.first.potential <= 62)) {
          peaks.add(h.map((p) => p.overall).reduce((a, b) => a > b ? a : b));
        }
      }
      return peaks.reduce((a, b) => a + b) / peaks.length;
    }

    expect(meanPeak(true), greaterThan(meanPeak(false) + 8));
  });

  test('30 yaş sonrası fiziksel nitelikler düşer, zihinsel korunur', () {
    var physicalDrop = 0.0;
    var mentalChange = 0.0;
    for (var seed = 0; seed < careers; seed++) {
      final h = simulateCareer(seed, PlayerPosition.centralMid);
      final at28 = h.firstWhere((p) => p.age == 28).attributes;
      final at36 = h.firstWhere((p) => p.age == 36).attributes;
      physicalDrop += at28.raw(Attribute.pace) - at36.raw(Attribute.pace);
      mentalChange += at36.raw(Attribute.vision) - at28.raw(Attribute.vision);
    }
    expect(physicalDrop / careers, greaterThan(10));
    expect(mentalChange / careers, greaterThanOrEqualTo(-1));
  });
}
