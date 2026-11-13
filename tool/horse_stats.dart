// At yarışı dengesi: `dart run tool/horse_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/spending/horse_racing.dart';

void main() {
  const worlds = 12;
  var races = 0;
  var favoriteWins = 0;
  var longshotWins = 0;
  var oddsSum = 0.0;
  var minOdds = 1000.0;
  var maxOdds = 0.0;
  final stake = <String, double>{};
  final paid = <String, double>{};
  void bet(String name, bool hit, double odds) {
    stake[name] = (stake[name] ?? 0) + 1;
    if (hit) paid[name] = (paid[name] ?? 0) + odds;
  }

  final random = GameRandom(5);
  for (var w = 0; w < worlds; w++) {
    final base = CareerFactory.create(
      PlayerFactory.create(
        name: 'T',
        birthplace: 'Ankara',
        position: PlayerPosition.forward,
        foot: PreferredFoot.right,
        appearance: const Appearance(),
        random: GameRandom(40 + w),
      ),
      GameRandom(40 + w),
    );
    for (var week = 1; week <= SeasonCalendar.weeksPerSeason; week++) {
      final s = base.copyWith(week: week);
      final card = HorseRacing.card(s);
      final result = HorseRacing.run(s);
      races++;
      final fav = List<int>.generate(card.horses.length, (i) => i)
        ..sort((a, b) => card.winOdds[a].compareTo(card.winOdds[b]));
      final long = fav.last;
      if (result.winner == fav.first) favoriteWins++;
      if (result.winner == long) longshotWins++;
      for (final o in card.winOdds) {
        oddsSum += o;
        if (o < minOdds) minOdds = o;
        if (o > maxOdds) maxOdds = o;
      }
      final pick = random.nextInt(card.horses.length);
      bet(
        'Favori kazanır',
        result.winner == fav.first,
        card.winOdds[fav.first],
      );
      bet('Rastgele kazanır', result.winner == pick, card.winOdds[pick]);
      bet('Dışlanan kazanır', result.winner == long, card.winOdds[long]);
      bet('Favori ilk 3', result.placed(fav.first), card.placeOdds[fav.first]);
      bet('Rastgele ilk 3', result.placed(pick), card.placeOdds[pick]);
    }
  }
  print('Yarış sayısı: $races');
  print(
    'Favori kazanma: ${(favoriteWins / races * 100).toStringAsFixed(0)}%, '
    'en dışlanan: ${(longshotWins / races * 100).toStringAsFixed(0)}%',
  );
  print(
    'Oran: ort ${(oddsSum / (races * 6)).toStringAsFixed(1)}, '
    'en düşük $minOdds, en yüksek $maxOdds',
  );
  for (final k in stake.keys) {
    print(
      '  $k: geri ödeme ${((paid[k] ?? 0) / stake[k]! * 100).toStringAsFixed(0)}%',
    );
  }
}
