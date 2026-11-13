import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/feed_models.dart';
import 'package:son_dusuk/domain/spending/horse_racing.dart';
import 'package:son_dusuk/domain/spending/spending_balance.dart';
import 'package:son_dusuk/domain/spending/spending_engine.dart';
import 'package:son_dusuk/domain/spending/spending_models.dart';
import 'package:son_dusuk/presentation/l10n_labels.dart';

CareerState newCareer({int week = 10, int balance = 100000}) {
  final s = CareerFactory.create(
    PlayerFactory.create(
      name: 'Deniz',
      birthplace: 'Bursa',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: GameRandom(1),
    ),
    GameRandom(1),
  ).copyWith(week: week);
  return s.copyWith(finance: s.finance.copyWith(balance: balance));
}

RaceOutcome? race(
  CareerState s,
  int horse, {
  RaceBet kind = RaceBet.win,
  int stake = 0,
  RaceCard? card,
}) => SpendingEngine.runRace(
  s,
  horse: horse,
  kind: kind,
  stake: stake,
  random: GameRandom(1),
  card: card,
);

void main() {
  group('atlar ve kart', () {
    test('altı farklı at, aralıklar içinde, aynı hafta aynı kart', () {
      final s = newCareer();
      final a = HorseRacing.horses(s);
      final b = HorseRacing.horses(s);
      expect(a.length, SpendingBalance.horseCount);
      expect({for (final h in a) h.nameIndex}.length, a.length);
      for (var i = 0; i < a.length; i++) {
        expect(a[i].nameIndex, b[i].nameIndex);
        expect(a[i].nameIndex, lessThan(SpendingBalance.horseNamePool));
        expect(a[i].rating, inInclusiveRange(40, 90));
        expect(a[i].stamina, inInclusiveRange(0, 1));
      }
      final other = HorseRacing.horses(s.copyWith(week: 11));
      expect([
        for (final h in other) h.nameIndex,
      ], isNot([for (final h in a) h.nameIndex]));
    });

    test('oranlar sınırlar içinde ve büro payı var', () {
      for (var week = 5; week < 15; week++) {
        final c = HorseRacing.card(newCareer(week: week));
        var over = 0.0;
        for (var i = 0; i < c.horses.length; i++) {
          expect(
            c.winOdds[i],
            inInclusiveRange(
              SpendingBalance.horseWinOddsMin,
              SpendingBalance.horseWinOddsMax,
            ),
          );
          expect(
            c.placeOdds[i],
            inInclusiveRange(
              SpendingBalance.horsePlaceOddsMin,
              SpendingBalance.horsePlaceOddsMax,
            ),
          );
          expect(c.placeOdds[i], lessThanOrEqualTo(c.winOdds[i]));
          over += 1 / c.winOdds[i];
        }
        expect(over, greaterThan(1));
      }
    });
  });

  group('yarış simülasyonu', () {
    test('aynı hafta aynı sonuç; sıralama geçerli; konumlar tutarlı', () {
      final s = newCareer();
      final a = HorseRacing.run(s);
      final b = HorseRacing.run(s);
      expect(a.order, b.order);
      expect([...a.order]..sort(), [0, 1, 2, 3, 4, 5]);
      expect(a.positions.length, greaterThan(10));
      for (final f in a.positions.last) {
        expect(f, 1.0);
      }
      for (var h = 0; h < 6; h++) {
        for (var t = 1; t < a.positions.length; t++) {
          expect(
            a.positions[t][h],
            greaterThanOrEqualTo(a.positions[t - 1][h]),
          );
        }
      }
    });

    test('güçlü at daha sık kazanır', () {
      var bestWins = 0;
      const n = 150;
      for (var w = 0; w < n; w++) {
        final s = newCareer(week: 5 + w % 30).copyWith(season: 1 + w ~/ 30);
        final hs = HorseRacing.horses(s);
        var best = 0;
        for (var i = 1; i < hs.length; i++) {
          if (hs[i].rating > hs[best].rating) best = i;
        }
        if (HorseRacing.run(s).winner == best) bestWins++;
      }
      expect(bestWins / n, greaterThan(0.3));
      expect(bestWins / n, lessThan(0.8));
    });
  });

  group('yarış bahsi', () {
    test('bahissiz izleme: para ve alışkanlık değişmez, hafta kilitlenir', () {
      final s = newCareer();
      final o = race(s, 2)!;
      expect(o.state.finance.balance, s.finance.balance);
      expect(o.state.spending.habit, s.spending.habit);
      expect(o.state.spending.raceWeek, s.absoluteWeek);
      expect(o.payout, 0);
      expect(SpendingEngine.raceReady(o.state), isFalse);
      expect(race(o.state, 2), isNull);
      final next = o.state.copyWith(week: o.state.week + 1);
      expect(SpendingEngine.raceReady(next), isTrue);
    });

    test('kazanan bahis tutar x oran öder; kaybeden tutarı kaybeder', () {
      final s = newCareer();
      final card = HorseRacing.card(s);
      var won = false;
      var lost = false;
      for (var h = 0; h < 6; h++) {
        final o = race(s, h, stake: 1000, card: card)!;
        expect(o.state.spending.totalStaked, 1000);
        expect(o.state.spending.habit, greaterThan(0));
        if (o.hit) {
          won = true;
          final pay = (1000 * card.winOdds[h]).round();
          expect(o.payout, pay);
          expect(o.state.finance.balance, s.finance.balance - 1000 + pay);
          expect(o.state.spending.totalWon, pay);
        } else {
          lost = true;
          expect(o.payout, 0);
          expect(o.state.finance.balance, s.finance.balance - 1000);
        }
      }
      expect(won, isTrue);
      expect(lost, isTrue);
    });

    test('ilk üç bahsi 3 ata, birincilik bahsi 1 ata tutar', () {
      final s = newCareer();
      var win = 0;
      var place = 0;
      for (var h = 0; h < 6; h++) {
        for (final kind in RaceBet.values) {
          if (race(s, h, kind: kind)!.hit) {
            kind == RaceBet.win ? win++ : place++;
          }
        }
      }
      expect(win, 1);
      expect(place, 3);
    });

    test('geçersiz bahisler reddedilir', () {
      final s = newCareer(balance: 500);
      expect(race(s, 0, stake: 5), isNull);
      expect(race(s, 0, stake: 9999), isNull);
      expect(race(s, 9), isNull);
    });

    test('büyük kazanç akışta paylaşım olur', () {
      var seen = false;
      for (var week = 5; week < 40 && !seen; week++) {
        final s = newCareer(week: week);
        final card = HorseRacing.card(s);
        for (var h = 0; h < 6 && !seen; h++) {
          final o = race(s, h, stake: 100, card: card)!;
          if (o.payout >= 100 * SpendingBalance.horseBigWinMultiple) {
            seen = true;
            expect(o.state.feed.posts.first.kind, FeedKind.horseWin);
            expect(
              o.state.feed.posts.first.params['horse'],
              '${card.horses[h].nameIndex}',
            );
          }
        }
      }
      expect(seen, isTrue);
    });

    test('yarış haftası kayda yazılıp okunur', () {
      final o = race(newCareer(), 0)!;
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(o.state.toJson())) as Map<String, dynamic>,
      );
      expect(back.spending.raceWeek, o.state.spending.raceWeek);
    });

    test('yarış bahsi de şans alışkanlığı ve cezaya sayılır', () {
      var s = newCareer(
        balance: 200000,
      ).copyWith(spending: const Spending(habit: 66));
      s = race(s, 0, stake: 20000)!.state;
      expect(s.spending.habit, greaterThan(70));
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      expect(u.state.spending.totalFines, greaterThan(0));
      expect(u.events.map((e) => e.kind), contains(WeekEventKind.betFined));
    });
  });

  group('metinler', () {
    test('40 farklı kurgusal at ismi var, hepsi çözülür', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      final names = l10n.horse_names.split('|');
      expect(names.length, SpendingBalance.horseNamePool);
      expect(names.toSet().length, names.length);
      for (var i = 0; i < names.length; i++) {
        expect(l10n.horseName(i), names[i]);
        expect(names[i].trim(), isNotEmpty);
      }
    });
  });
}
