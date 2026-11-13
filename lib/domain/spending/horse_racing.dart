import 'dart:math' as math;

import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import '../career/career_state.dart';
import 'spending_balance.dart';

/// Yarışa giren bir at (kurgusal). İsim ARB listesinden [nameIndex] ile seçilir.
class Horse {
  const Horse({
    required this.nameIndex,
    required this.rating,
    required this.stamina,
  });

  final int nameIndex;

  /// Güç: [SpendingBalance.horseRatingMin]..[SpendingBalance.horseRatingMax].
  final double rating;

  /// Yarışın son bölümünde yavaşlamaya direnç, 0..1.
  final double stamina;
}

/// Bahis türü: birinci olur / ilk üçe girer.
enum RaceBet { win, place }

/// Haftanın yarışı: atlar ve bahis oranları.
class RaceCard {
  const RaceCard({
    required this.horses,
    required this.winOdds,
    required this.placeOdds,
  });

  final List<Horse> horses;
  final List<double> winOdds;
  final List<double> placeOdds;

  double odds(int horse, RaceBet kind) =>
      kind == RaceBet.win ? winOdds[horse] : placeOdds[horse];
}

/// Yarışın sonucu: varış sırası ve animasyon için her adımdaki konumlar.
class RaceResult {
  const RaceResult({required this.order, required this.positions});

  /// Varış sırası: [order].first kazanan atın indeksi.
  final List<int> order;

  /// [adım][at] konumu, 0..1 (bitiş çizgisi 1). Son adımda hepsi 1'dir.
  final List<List<double>> positions;

  int get winner => order.first;

  bool placed(int horse) => order.indexOf(horse) < 3;
}

/// Kurgusal at yarışı: haftalık seed'li kart, oranlar ve simülasyon (saf Dart).
abstract final class HorseRacing {
  /// Bu haftanın atları. Aynı sezon/hafta hep aynı kart.
  static List<Horse> horses(CareerState s) {
    final random = GameRandom(mixSeed([s.worldSeed, s.season, s.week, 70]));
    final names = List<int>.generate(SpendingBalance.horseNamePool, (i) => i);
    for (var i = names.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final t = names[i];
      names[i] = names[j];
      names[j] = t;
    }
    final span =
        SpendingBalance.horseRatingMax - SpendingBalance.horseRatingMin;
    return [
      for (var i = 0; i < SpendingBalance.horseCount; i++)
        Horse(
          nameIndex: names[i],
          rating:
              SpendingBalance.horseRatingMin +
              span * (0.1 + 0.8 * random.nextDouble()),
          stamina: random.nextDouble(),
        ),
    ];
  }

  /// Haftanın kartı: atlar + Monte Carlo ile hesaplanan oranlar.
  static RaceCard card(CareerState s) {
    final hs = horses(s);
    final random = GameRandom(mixSeed([s.worldSeed, s.season, s.week, 71]));
    final wins = List.filled(hs.length, 0);
    final places = List.filled(hs.length, 0);
    for (var i = 0; i < SpendingBalance.oddsSimulations; i++) {
      final r = simulate(hs, random, record: false);
      wins[r.order[0]]++;
      for (var k = 0; k < 3; k++) {
        places[r.order[k]]++;
      }
    }
    double odds(int count, double margin, double lo, double hi) {
      final p = (count + 1) / (SpendingBalance.oddsSimulations + 2);
      final raw = (1 / p) * (1 - margin);
      return (raw.clamp(lo, hi) * 10).round() / 10;
    }

    return RaceCard(
      horses: hs,
      winOdds: [
        for (final w in wins)
          odds(
            w,
            SpendingBalance.horseWinMargin,
            SpendingBalance.horseWinOddsMin,
            SpendingBalance.horseWinOddsMax,
          ),
      ],
      placeOdds: [
        for (final p in places)
          odds(
            p,
            SpendingBalance.horsePlaceMargin,
            SpendingBalance.horsePlaceOddsMin,
            SpendingBalance.horsePlaceOddsMax,
          ),
      ],
    );
  }

  /// Bu haftanın gerçek yarışı (seed'li: aynı hafta hep aynı sonuç).
  static RaceResult run(CareerState s) => simulate(
    horses(s),
    GameRandom(mixSeed([s.worldSeed, s.season, s.week, 72])),
  );

  /// Yarışı adım adım oynatır. [record] false ise konumlar saklanmaz (hızlı).
  static RaceResult simulate(
    List<Horse> horses,
    GameRandom random, {
    bool record = true,
  }) {
    final n = horses.length;
    final span =
        SpendingBalance.horseRatingMax - SpendingBalance.horseRatingMin;
    final dayForm = [
      for (var i = 0; i < n; i++)
        1 + random.gaussian(stdDev: SpendingBalance.raceDayFormSpread),
    ];
    final pos = List.filled(n, 0.0);
    final finish = List.filled(n, double.infinity);
    final frames = <List<double>>[];

    for (var t = 1; t <= SpendingBalance.raceMaxTicks; t++) {
      for (var i = 0; i < n; i++) {
        if (finish[i] != double.infinity) continue;
        final h = horses[i];
        final strength = (h.rating - SpendingBalance.horseRatingMin) / span;
        var step =
            SpendingBalance.raceBaseStep *
            (1 -
                SpendingBalance.raceRatingSpread / 2 +
                SpendingBalance.raceRatingSpread * strength) *
            dayForm[i] *
            math.max(
              0.2,
              1 + random.gaussian(stdDev: SpendingBalance.raceNoise),
            );
        if (pos[i] > SpendingBalance.raceFadeStart) {
          step *= 1 - SpendingBalance.raceFadeAmount * (1 - h.stamina);
        }
        final before = pos[i];
        pos[i] += step;
        if (pos[i] >= 1) {
          finish[i] = t - 1 + (1 - before) / step;
        }
      }
      if (record) {
        frames.add([for (final p in pos) p.clamp(0.0, 1.0)]);
      }
      if (finish.every((f) => f != double.infinity)) break;
    }
    // Süre dolduysa kalanlar konuma göre sıralanır.
    for (var i = 0; i < n; i++) {
      if (finish[i] == double.infinity) {
        finish[i] = SpendingBalance.raceMaxTicks + (1 - pos[i]) * 100;
      }
    }
    final order = List<int>.generate(n, (i) => i)
      ..sort((a, b) => finish[a].compareTo(finish[b]));
    return RaceResult(order: order, positions: frames);
  }
}
