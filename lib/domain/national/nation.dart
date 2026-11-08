import '../../core/game_random.dart';
import '../../core/seed_mix.dart';
import 'national_balance.dart';

/// Kurgusal bir ülke (gerçek ülke adı kullanılmaz).
class Nation {
  const Nation({required this.id, required this.name, required this.strength});

  final String id;
  final String name;

  /// Takım gücü; kulüp takımlarıyla aynı ölçekte (maç simülasyonuna girer).
  final double strength;
}

/// Turnuvalara katılan 16 kurgusal ülke. Aynı [worldSeed] her zaman aynı
/// ülkeleri verir; güçler her turnuvada ([nations] `season`) biraz oynar.
class NationalWorld {
  NationalWorld(this.worldSeed);

  static const String homeId = 'n_home';
  static const String homeName = 'Anatolya';

  static const List<String> _names = [
    'Valdora',
    'Estrelya',
    'Kaldonia',
    'Mirovia',
    'Tarsana',
    'Belmora',
    'Norvenya',
    'Zefiria',
    'Orlanda',
    'Havrenya',
    'Selvora',
    'Pelagya',
    'Ruvenya',
    'Sundara',
    'Talvera',
  ];

  final int worldSeed;

  /// [season] turnuvasının 16 ülkesi (ilki oyuncunun ülkesi).
  List<Nation> nations(int season) {
    assert(_names.length + 1 == NationalBalance.nationCount);
    final base = GameRandom(mixSeed([worldSeed, 1717]));
    final jitter = GameRandom(mixSeed([worldSeed, season, 1718]));
    double wobble() => jitter.gaussian(stdDev: NationalBalance.yearlyJitter);
    return [
      Nation(
        id: homeId,
        name: homeName,
        strength: NationalBalance.homeStrength + wobble(),
      ),
      for (var i = 0; i < _names.length; i++)
        Nation(
          id: 'n_$i',
          name: _names[i],
          strength:
              (base.gaussian(
                        mean: NationalBalance.otherMean,
                        stdDev: NationalBalance.otherStdDev,
                      ) +
                      wobble())
                  .clamp(45.0, 88.0)
                  .toDouble(),
        ),
    ];
  }
}
