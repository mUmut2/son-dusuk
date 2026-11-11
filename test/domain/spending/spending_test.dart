import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/event_models.dart';
import 'package:son_dusuk/domain/social/feed_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/domain/spending/betting.dart';
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

ClubWorld worldOf(CareerState s) => ClubWorld(s.worldSeed);

void main() {
  group('model', () {
    test('JSON gidiş-dönüş ve eski kayıt varsayılanı', () {
      final s = newCareer();
      final w = worldOf(s);
      final bet = SpendingEngine.placeBet(
        s,
        w,
        0,
        BetPick.home,
        Betting.stakeOptions(s.finance.balance).first,
      )!;
      final bought = SpendingEngine.buyProperty(
        bet,
        Property.watch,
        GameRandom(1),
      )!;
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(bought.toJson())) as Map<String, dynamic>,
      );
      expect(back.spending.properties, [Property.watch]);
      expect(back.spending.bets.length, 1);
      expect(back.spending.habit, bought.spending.habit);

      final old = newCareer().toJson()..remove('spending');
      expect(CareerState.fromJson(old).spending.properties, isEmpty);
    });

    test('mülklerin moral katkısı üst sınırlı', () {
      final all = const Spending().copyWith(properties: Property.values);
      expect(all.moraleBonus, SpendingBalance.propertyMoraleCap);
      expect(const Spending().moraleBonus, 0);
    });
  });

  group('mülk ve bağış', () {
    test('satın alma parayı düşer, etkiyi uygular, akışa yansır', () {
      final s = newCareer();
      final before = s.relations[Relation.media];
      final next = SpendingEngine.buyProperty(s, Property.car, GameRandom(1))!;
      expect(
        next.finance.balance,
        s.finance.balance - SpendingBalance.propertyPrice[Property.car]!,
      );
      expect(next.spending.owns(Property.car), isTrue);
      expect(next.relations[Relation.media], greaterThan(before));
      expect(next.feed.posts.first.kind, FeedKind.shopping);
      expect(next.feed.posts.first.params['item'], 'car');
    });

    test('aynı mülk ikinci kez ya da parasız alınamaz', () {
      final s = newCareer();
      final once = SpendingEngine.buyProperty(
        s,
        Property.watch,
        GameRandom(1),
      )!;
      expect(
        SpendingEngine.buyProperty(once, Property.watch, GameRandom(1)),
        isNull,
      );
      final poor = newCareer(balance: 100);
      expect(
        SpendingEngine.buyProperty(poor, Property.yacht, GameRandom(1)),
        isNull,
      );
    });

    test('bağış: etki, bekleme süresi ve para kontrolü', () {
      final s = newCareer(week: 10);
      final fans = s.relations[Relation.fans];
      final next = SpendingEngine.donate(s, Donation.charity, GameRandom(1))!;
      expect(next.finance.balance, lessThan(s.finance.balance));
      expect(next.relations[Relation.fans], greaterThan(fans));
      expect(
        SpendingEngine.donate(next, Donation.familyGift, GameRandom(1)),
        isNull,
      );
      final later = next.copyWith(week: next.week + 3);
      expect(
        SpendingEngine.donate(later, Donation.familyGift, GameRandom(1)),
        isNotNull,
      );
      expect(
        SpendingEngine.donate(
          newCareer(balance: 10),
          Donation.charity,
          GameRandom(1),
        ),
        isNull,
      );
    });

    test('mülk moral tabanını yükseltir', () {
      final s = newCareer();
      final rich = s.copyWith(
        spending: s.spending.copyWith(properties: [Property.villa]),
      );
      expect(rich.spending.moraleBonus, greaterThan(0));
    });
  });

  group('kupon ve oranlar', () {
    test('lig haftasında 3 maç, kendi takımı hariç, aynı hafta aynı kupon', () {
      final s = newCareer(week: 10);
      final w = worldOf(s);
      final c = Betting.coupon(s, w);
      expect(c.length, SpendingBalance.couponSize);
      final own = s.contract!.clubId;
      for (final m in c) {
        expect(m.homeId, isNot(own));
        expect(m.awayId, isNot(own));
      }
      final again = Betting.coupon(s, w);
      expect([for (final m in c) m.homeId], [for (final m in again) m.homeId]);
    });

    test('hazırlık haftasında ve kulüpsüzken kupon yok', () {
      final s = newCareer(week: 2);
      expect(Betting.coupon(s, worldOf(s)), isEmpty);
      final free = newCareer(week: 10).copyWith(clearContract: true);
      expect(Betting.coupon(free, worldOf(free)), isEmpty);
    });

    test('oranlar sınırlar içinde ve büro payı var (toplam olasılık > 1)', () {
      for (var week = 5; week < 30; week++) {
        final s = newCareer(week: week);
        for (final m in Betting.coupon(s, worldOf(s))) {
          var over = 0.0;
          for (final p in BetPick.values) {
            final o = m.odds(p);
            expect(o, greaterThanOrEqualTo(SpendingBalance.minOdds));
            expect(o, lessThanOrEqualTo(SpendingBalance.maxOdds));
            over += 1 / o;
          }
          expect(over, greaterThan(1));
        }
      }
    });

    test('bahis tutarı seçenekleri artan ve en az taban', () {
      for (final b in [50, 1500, 20000, 5000000]) {
        final o = Betting.stakeOptions(b);
        expect(o.first, greaterThanOrEqualTo(SpendingBalance.minStake));
        expect([...o]..sort(), o);
        expect(o.toSet().length, o.length);
      }
    });

    test('uzun vadede bahis kaybettirir (beklenen değer negatif)', () {
      var staked = 0;
      var paid = 0;
      for (var seed = 1; seed <= 6; seed++) {
        final base = newCareer(week: 5).copyWith(worldSeed: seed);
        final w = worldOf(base);
        for (var week = 5; week <= 38; week++) {
          final s = base.copyWith(week: week);
          final c = Betting.coupon(s, w);
          for (var i = 0; i < c.length; i++) {
            for (final pick in BetPick.values) {
              final bet = PlacedBet(
                homeId: c[i].homeId,
                awayId: c[i].awayId,
                pick: pick,
                stake: 100,
                odds: c[i].odds(pick),
                season: s.season,
                week: s.week,
              );
              final r = Betting.settle(bet, s.worldSeed, w);
              staked += r.stake;
              paid += r.payout;
            }
          }
        }
      }
      final rtp = paid / staked;
      expect(rtp, lessThan(1.0));
      expect(rtp, greaterThan(0.6));
    });

    test('aynı bahis hep aynı sonucu verir', () {
      final s = newCareer(week: 10);
      final w = worldOf(s);
      final m = Betting.coupon(s, w).first;
      final bet = PlacedBet(
        homeId: m.homeId,
        awayId: m.awayId,
        pick: BetPick.home,
        stake: 100,
        odds: m.oddsHome,
        season: s.season,
        week: s.week,
      );
      final a = Betting.settle(bet, s.worldSeed, w);
      final b = Betting.settle(bet, s.worldSeed, w);
      expect(a.homeGoals, b.homeGoals);
      expect(a.awayGoals, b.awayGoals);
      expect(a.payout, b.payout);
    });
  });

  group('bahis yapma', () {
    test('tutarı düşer, alışkanlığı artırır; aynı maça ikinci bahis yok', () {
      final s = newCareer(week: 10);
      final w = worldOf(s);
      final next = SpendingEngine.placeBet(s, w, 0, BetPick.draw, 100)!;
      expect(next.finance.balance, s.finance.balance - 100);
      expect(next.spending.habit, greaterThan(0));
      expect(next.spending.bets.single.pick, BetPick.draw);
      expect(next.spending.totalStaked, 100);
      expect(SpendingEngine.placeBet(next, w, 0, BetPick.home, 100), isNull);
      expect(SpendingEngine.placeBet(next, w, 1, BetPick.home, 100), isNotNull);
    });

    test('geçersiz bahisler reddedilir', () {
      final s = newCareer(week: 10, balance: 500);
      final w = worldOf(s);
      expect(SpendingEngine.placeBet(s, w, 9, BetPick.home, 100), isNull);
      expect(SpendingEngine.placeBet(s, w, 0, BetPick.home, 5), isNull);
      expect(SpendingEngine.placeBet(s, w, 0, BetPick.home, 9999), isNull);
      final pre = newCareer(week: 2);
      expect(
        SpendingEngine.placeBet(pre, worldOf(pre), 0, BetPick.home, 100),
        isNull,
      );
    });

    test('büyük tutar daha çok alışkanlık yaratır', () {
      final s = newCareer(week: 10, balance: 10000);
      final w = worldOf(s);
      final small = SpendingEngine.placeBet(s, w, 0, BetPick.home, 200)!;
      final big = SpendingEngine.placeBet(s, w, 0, BetPick.home, 5000)!;
      expect(big.spending.habit, greaterThan(small.spending.habit));
    });
  });

  group('haftalık işlem', () {
    test('bahisler sonuçlanır, bakiye ve geçmiş güncellenir', () {
      final s = newCareer(week: 10);
      final w = worldOf(s);
      var placed = SpendingEngine.placeBet(s, w, 0, BetPick.home, 100)!;
      placed = SpendingEngine.placeBet(placed, w, 1, BetPick.away, 100)!;
      final next = placed.copyWith(week: 11);
      final u = SpendingEngine.afterWeek(placed, next, GameRandom(1));
      expect(u.state.spending.bets, isEmpty);
      expect(u.state.spending.settled.length, 2);
      final payout = u.state.spending.settled.fold(0, (a, b) => a + b.payout);
      expect(u.state.finance.balance, next.finance.balance + payout);
      expect(u.state.spending.totalWon, payout);
      expect(u.events.any((e) => e.kind == WeekEventKind.betSettled), isTrue);
    });

    test('bahis oynanmayan hafta alışkanlığı azaltır', () {
      final s = newCareer().copyWith(spending: const Spending(habit: 30));
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      expect(u.state.spending.habit, 30 - SpendingBalance.habitDecay);
    });

    test('uyarı basamağı: ilişki düşer, bir kez uyarır', () {
      final s = newCareer().copyWith(spending: const Spending(habit: 50));
      final coach = s.relations[Relation.coach];
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      expect(u.state.spending.penaltyStage, 1);
      expect(u.state.relations[Relation.coach], lessThan(coach));
      expect(u.events.map((e) => e.kind), contains(WeekEventKind.betWarning));
      final again = SpendingEngine.afterWeek(u.state, u.state, GameRandom(1));
      expect(
        again.events.map((e) => e.kind),
        isNot(contains(WeekEventKind.betWarning)),
      );
    });

    test('para cezası basamağı: bakiye düşer, haber ve akış gelir', () {
      final s = newCareer().copyWith(spending: const Spending(habit: 70));
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      expect(u.state.spending.penaltyStage, 2);
      expect(u.state.finance.balance, lessThan(s.finance.balance));
      expect(
        s.finance.balance - u.state.finance.balance,
        greaterThanOrEqualTo(SpendingBalance.minFine),
      );
      expect(u.state.spending.totalFines, greaterThan(0));
      expect(u.events.map((e) => e.kind), contains(WeekEventKind.betFined));
      expect(u.state.news.first.kind, NewsKind.betting);
      expect(u.state.feed.posts.first.kind, FeedKind.betFined);
    });

    test('kadro dışı basamağı: süre, yardım programı ve maça çıkamama', () {
      final s = newCareer(
        week: 12,
      ).copyWith(spending: const Spending(habit: 90));
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      final sp = u.state.spending;
      expect(sp.suspendedWeeks, SpendingBalance.banWeeks);
      expect(sp.habit, SpendingBalance.habitAfterHelp);
      expect(sp.penaltyStage, 1);
      expect(u.events.map((e) => e.kind), contains(WeekEventKind.betSuspended));
      expect(Squad.matchDay(u.state), MatchDay.suspended);

      // Süre her hafta azalır; ceza tekrar tetiklenmez.
      var cur = u.state;
      for (var i = 0; i < SpendingBalance.banWeeks; i++) {
        cur = SpendingEngine.afterWeek(cur, cur, GameRandom(i)).state;
      }
      expect(cur.spending.suspended, isFalse);
      expect(cur.spending.totalFines, sp.totalFines);
    });

    test('alışkanlık düşünce basamak sıfırlanır', () {
      final s = newCareer().copyWith(
        spending: const Spending(habit: 20, penaltyStage: 2),
      );
      final u = SpendingEngine.afterWeek(s, s, GameRandom(1));
      expect(u.state.spending.penaltyStage, 0);
    });

    test('hafta motoru: kadro dışı oyuncu için "kadro dışı" olayı çıkar', () {
      final s = newCareer(
        week: 12,
      ).copyWith(spending: const Spending(suspendedWeeks: 2));
      final r = WeekEngine.advance(s, const WeeklyPlan(), null, GameRandom(1));
      final kinds = r.report.events.map((e) => e.kind);
      expect(kinds, contains(WeekEventKind.suspended));
      expect(kinds, isNot(contains(WeekEventKind.benched)));
      expect(r.state.spending.suspendedWeeks, 1);
    });

    test('çok bahis oynayan oyuncu sonunda cezalanır (simülasyon)', () {
      var s = newCareer(week: 5, balance: 200000);
      final w = worldOf(s);
      final random = GameRandom(3);
      var fined = false;
      for (var i = 0; i < 12 && !fined; i++) {
        for (var k = 0; k < 3; k++) {
          s =
              SpendingEngine.placeBet(
                s,
                w,
                k,
                BetPick.home,
                Betting.stakeOptions(s.finance.balance).last,
              ) ??
              s;
        }
        final next = s.copyWith(week: s.week + 1);
        final u = SpendingEngine.afterWeek(s, next, random);
        s = u.state;
        fined = u.events.any(
          (e) =>
              e.kind == WeekEventKind.betFined ||
              e.kind == WeekEventKind.betSuspended,
        );
      }
      expect(fined, isTrue);
    });
  });

  group('metinler', () {
    test('mülk, bağış, bahis ve olay metinleri tam', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      for (final p in Property.values) {
        expect(l10n.propertyName(p), isNotEmpty);
        expect(l10n.propertyDesc(p), isNotEmpty);
      }
      for (final d in Donation.values) {
        expect(l10n.donationName(d), isNotEmpty);
        expect(l10n.donationDesc(d), isNotEmpty);
      }
      for (final p in BetPick.values) {
        expect(l10n.betPickName(p), isNotEmpty);
      }
      for (final h in [0.0, 45.0, 70.0, 90.0]) {
        expect(l10n.habitLevelName(h), isNotEmpty);
        expect(l10n.habitHint(h), isNotEmpty);
      }
      for (final kind in [
        WeekEventKind.betSettled,
        WeekEventKind.betWarning,
        WeekEventKind.betFined,
        WeekEventKind.betSuspended,
        WeekEventKind.suspended,
      ]) {
        final t = l10n.eventText(
          WeekEvent(kind, detail: '-500', weeks: 3),
          clubName: '',
          eventTitle: '',
        );
        expect(t, isNotEmpty, reason: kind.name);
        expect(t.contains('{'), isFalse);
      }
      for (final stage in ['warned', 'fined', 'suspended']) {
        final t = l10n.newsText(
          NewsItem(
            kind: NewsKind.betting,
            season: 1,
            week: 1,
            params: {'stage': stage},
          ),
          (id) => id,
        );
        expect(t, isNotEmpty);
      }
    });
  });
}
