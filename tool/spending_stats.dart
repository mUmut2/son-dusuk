// Bahis ve ceza dengesi: `dart run tool/spending_stats.dart`
// ignore_for_file: avoid_print
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/spending/betting.dart';
import 'package:son_dusuk/domain/spending/spending_engine.dart';
import 'package:son_dusuk/domain/spending/spending_models.dart';

CareerState fresh(int seed) {
  final random = GameRandom(seed);
  final player = PlayerFactory.create(
    name: 'T',
    birthplace: 'Ankara',
    position: PlayerPosition.forward,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: random,
  );
  final s = CareerFactory.create(player, random).copyWith(week: 5);
  return s.copyWith(finance: s.finance.copyWith(balance: 20000));
}

/// [perWeek] bahis, [stakeIndex]. tutar seçeneğiyle [weeks] hafta oynar.
void profile(String name, int perWeek, int stakeIndex, {int every = 1}) {
  const careers = 60;
  const weeks = 34;
  var firstWarn = 0;
  var firstFine = 0;
  var firstBan = 0;
  var warned = 0;
  var fined = 0;
  var banned = 0;
  var balance = 0.0;
  var suspendedWeeks = 0;
  var staked = 0;
  var paid = 0;

  for (var c = 0; c < careers; c++) {
    final random = GameRandom(300 + c);
    var s = fresh(300 + c);
    final world = ClubWorld(s.worldSeed);
    var seenStage = 0;
    for (var w = 0; w < weeks; w++) {
      for (var k = 0; k < (w % every == 0 ? perWeek : 0); k++) {
        final stakes = Betting.stakeOptions(s.finance.balance);
        s =
            SpendingEngine.placeBet(
              s,
              world,
              k,
              BetPick.values[random.nextInt(3)],
              stakes[stakeIndex.clamp(0, stakes.length - 1)],
            ) ??
            s;
      }
      final next = s.copyWith(week: s.week + 1);
      final before = s.spending.totalWon;
      final u = SpendingEngine.afterWeek(s, next, random);
      paid += u.state.spending.totalWon - before;
      s = u.state;
      if (s.spending.suspended) suspendedWeeks++;
      final fine = s.spending.totalFines;
      if (fine > 0 && firstFine == 0) firstFine = w + 1;
      if (s.spending.penaltyStage > seenStage) {
        seenStage = s.spending.penaltyStage;
        if (seenStage == 1 && firstWarn == 0) firstWarn = w + 1;
      }
      if (s.spending.suspendedWeeks == 3 && firstBan == 0) firstBan = w + 1;
    }
    staked += s.spending.totalStaked;
    if (firstWarn > 0) warned++;
    if (firstFine > 0) fined++;
    if (firstBan > 0) banned++;
    balance += s.finance.balance;
    firstWarn = firstFine = firstBan = 0;
  }
  print('$name:');
  print(
    '  ceza alan: uyarı $warned/$careers, para cezası $fined/$careers, '
    'kadro dışı $banned/$careers',
  );
  print(
    '  kadro dışı hafta/kariyer: ${(suspendedWeeks / careers).toStringAsFixed(1)}',
  );
  print(
    '  bitiş bakiyesi ortalaması (başlangıç 20000): ${(balance / careers).round()}',
  );
  if (staked > 0) {
    print('  geri ödeme oranı: ${(paid / staked * 100).toStringAsFixed(0)}%');
  }
}

void main() {
  profile('Ara sıra (4 haftada bir, 1 bahis, orta tutar)', 1, 1, every: 4);
  profile('Düzenli (haftada 1, küçük tutar)', 1, 0);
  profile('Düzenli (haftada 1, büyük tutar)', 1, 2);
  profile('Sık (haftada 2, orta tutar)', 2, 1);
  profile('Aşırı (haftada 3, büyük tutar)', 3, 2);
}
