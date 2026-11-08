import '../../core/game_random.dart';
import 'team.dart';

/// Kurgusal lig piramidi üretir. Takım adları tamamen uydurmadır
/// (gerçek kulüp adı kullanılmaz); lig adları arayüzde ARB'den gelir.
abstract final class LeagueFactory {
  static const int tierCount = 5;
  static const int teamsPerLeague = 18;

  /// Kademe başına ortalama takım gücü (1 = en üst).
  static const List<double> tierStrength = [76, 66, 56, 46, 36];

  static const List<String> _stems = [
    'Akova',
    'Çınaralan',
    'Güzelhisar',
    'Yelkenli',
    'Demirtepe',
    'Sarıkaya',
    'Mavikent',
    'Kayalıdere',
    'Otlukbeli',
    'Aydınlar',
    'Tuzlaova',
    'Börtlüce',
    'Gümüşköy',
    'Kızılören',
    'Dağkent',
    'Serinova',
    'Çakmaklı',
    'Ormanlık',
    'Taşpınar',
    'Beyazdere',
    'Yıldırımlı',
    'Karlıova',
    'Ilgazlı',
    'Mercanlı',
    'Şahinbeli',
    'Bozkurtlu',
    'Yeniçay',
    'Sulakent',
    'Esenova',
    'Gökbayır',
  ];
  static const List<String> _suffixes = ['Spor', 'Gücü', 'Atletik'];

  /// 5 ligin tamamını üretir; her takım adı piramitte tektir.
  static List<League> createPyramid(GameRandom random) {
    final names = <String>[
      for (final stem in _stems)
        for (final suffix in _suffixes) '$stem $suffix',
    ];
    assert(names.length >= tierCount * teamsPerLeague);
    _shuffle(names, random);

    return [
      for (var tier = 1; tier <= tierCount; tier++)
        League(
          tier: tier,
          teams: [
            for (var i = 0; i < teamsPerLeague; i++)
              Team(
                id: 't${tier}_$i',
                name: names[(tier - 1) * teamsPerLeague + i],
                strength: random
                    .gaussian(mean: tierStrength[tier - 1], stdDev: 6)
                    .clamp(5.0, 99.0)
                    .toDouble(),
              ),
          ],
        ),
    ];
  }

  static void _shuffle<T>(List<T> list, GameRandom random) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}
