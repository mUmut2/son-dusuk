class Fixture {
  const Fixture({required this.homeId, required this.awayId});

  final String homeId;
  final String awayId;
}

/// Çift devreli lig fikstürü (daire yöntemi).
///
/// n takım için 2*(n-1) hafta üretir. Her hafta her takım tam bir maç
/// oynar; ikinci devre ilk devrenin ev/deplasman olarak tersidir.
abstract final class FixtureGenerator {
  static List<List<Fixture>> doubleRoundRobin(List<String> teamIds) {
    final n = teamIds.length;
    if (n < 2 || n.isOdd) {
      throw ArgumentError('Takım sayısı çift ve en az 2 olmalı: $n');
    }

    final rotation = [...teamIds];
    final firstHalf = <List<Fixture>>[];

    for (var round = 0; round < n - 1; round++) {
      final fixtures = <Fixture>[];
      for (var i = 0; i < n ~/ 2; i++) {
        final a = rotation[i];
        final b = rotation[n - 1 - i];
        // Bir takım her turda bir sıra kayar; sıra numarasının paritesi
        // ev/deplasmanı dönüşümlü yapar (sabit takım tur paritesini kullanır).
        final swap = (i == 0 ? round : i).isOdd;
        fixtures.add(
          swap ? Fixture(homeId: b, awayId: a) : Fixture(homeId: a, awayId: b),
        );
      }
      firstHalf.add(fixtures);
      // İlk eleman sabit, geri kalanlar bir adım döner.
      rotation.insert(1, rotation.removeLast());
    }

    final secondHalf = [
      for (final round in firstHalf)
        [for (final f in round) Fixture(homeId: f.awayId, awayId: f.homeId)],
    ];
    return [...firstHalf, ...secondHalf];
  }
}
