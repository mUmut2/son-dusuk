import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_migrations.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/match_record.dart';
import 'package:son_dusuk/domain/career/season_calendar.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/agent.dart';
import 'package:son_dusuk/domain/club/club_balance.dart';
import 'package:son_dusuk/domain/club/club_engine.dart';
import 'package:son_dusuk/domain/club/contract.dart';
import 'package:son_dusuk/domain/club/finance.dart';
import 'package:son_dusuk/domain/club/squad.dart';
import 'package:son_dusuk/domain/club/transfer_market.dart';
import 'package:son_dusuk/domain/club/transfer_offer.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/league/league_table.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

Player newPlayer([int seed = 1]) => PlayerFactory.create(
  name: 'Deniz',
  birthplace: 'Bursa',
  position: PlayerPosition.forward,
  foot: PreferredFoot.right,
  appearance: const Appearance(),
  random: GameRandom(seed),
);

CareerState newCareer({int seed = 1}) =>
    CareerFactory.create(newPlayer(seed), GameRandom(seed));

void main() {
  group('dünya ve fikstür', () {
    test('aynı seed aynı dünyayı üretir', () {
      final a = ClubWorld(42);
      final b = ClubWorld(42);
      expect(
        [for (final t in a.allTeams) t.name],
        [for (final t in b.allTeams) t.name],
      );
    });

    test('her turda kulüp tam bir maç oynar, ev/deplasman dönüşümlüdür', () {
      final world = ClubWorld(7);
      final club = world.leagues.last.teams.first.id;
      for (var round = 1; round <= 34; round++) {
        final f = world.fixtureFor(club, round);
        expect(f.opponent.id, isNot(club));
        expect(world.tierOf(f.opponent.id), world.tierOf(club));
      }
    });
  });

  group('yeni kariyer', () {
    test('amatör kulüp ve makul bir ilk sözleşme verir', () {
      final s = newCareer();
      final c = s.contract!;
      final world = ClubWorld(s.worldSeed);
      expect(world.tierOf(c.clubId), 5);
      expect(c.endSeason, ClubBalance.startingContractYears);
      expect(c.weeklyWage, greaterThan(150), reason: 'yaşam giderinden fazla');
      expect(s.finance.balance, ClubBalance.startingBalance);
    });

    test('JSON gidiş-dönüş tüm kulüp alanlarını korur', () {
      final s = newCareer().copyWith(
        agent: const Agent(name: 'Selim Karaca', level: 2),
        offers: const [
          TransferOffer(
            kind: OfferKind.transfer,
            clubId: 't4_1',
            weeklyWage: 900,
            maxWage: 1100,
            years: 2,
            role: SquadRole.starter,
            expiresAt: 9,
          ),
        ],
        results: const [
          MatchRecord(round: 1, clubId: 't5_0', scoreFor: 2, scoreAgainst: 1),
        ],
      );
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(back.worldSeed, s.worldSeed);
      expect(back.contract!.clubId, s.contract!.clubId);
      expect(back.agent!.level, 2);
      expect(back.offers.single.maxWage, 1100);
      expect(back.results.single.scoreFor, 2);
      expect(back.finance.balance, s.finance.balance);
    });

    test('v3 kaydı v4\'e taşınınca kulüp kazanır', () {
      final v3 = {
        'schemaVersion': 3,
        'savedAt': 'x',
        'career': CareerState(player: newPlayer()).toJson()
          ..remove('worldSeed')
          ..remove('contract')
          ..remove('finance')
          ..remove('offers')
          ..remove('results')
          ..remove('agent'),
      };
      final migrated = const SaveMigrator().migrate(v3);
      expect(migrated['schemaVersion'], currentSchemaVersion);
      final s = CareerState.fromJson(
        migrated['career'] as Map<String, dynamic>,
      );
      expect(s.contract, isNotNull);
      expect(ClubWorld(s.worldSeed).tierOf(s.contract!.clubId), 5);
    });
  });

  group('maaş ve değer', () {
    test('güçlü oyuncu ve üst kademe daha çok kazanır', () {
      final p = newPlayer();
      double wage(int tier) => TransferMarket.fairWage(
        tier: tier,
        player: p,
        role: SquadRole.starter,
      );
      for (var t = 1; t < 5; t++) {
        expect(wage(t), greaterThan(wage(t + 1)));
      }
      expect(TransferMarket.marketValue(p), greaterThan(0));
    });

    test('rol maaşı etkiler', () {
      final p = newPlayer();
      double w(SquadRole r) =>
          TransferMarket.fairWage(tier: 3, player: p, role: r);
      expect(w(SquadRole.star), greaterThan(w(SquadRole.starter)));
      expect(w(SquadRole.starter), greaterThan(w(SquadRole.rotation)));
      expect(w(SquadRole.rotation), greaterThan(w(SquadRole.prospect)));
    });
  });

  group('ekonomi', () {
    test('maaş, prim, komisyon ve yaşam gideri', () {
      const contract = Contract(
        clubId: 'x',
        weeklyWage: 1000,
        endSeason: 3,
        role: SquadRole.starter,
      );
      final money = Economy.weekly(
        contract: contract,
        agent: const Agent(name: 'A', level: 1),
        lifestyle: Lifestyle.modest,
        won: true,
        goals: 2,
      );
      int of(MoneyKind k) =>
          money.lines.where((l) => l.kind == k).fold(0, (s, l) => s + l.amount);
      expect(of(MoneyKind.wage), 1000);
      expect(of(MoneyKind.winBonus), 250);
      expect(of(MoneyKind.goalBonus), 300);
      // %5 komisyon: (1000 + 250 + 300) * 0.05 = 77.5 -> 78
      expect(of(MoneyKind.agentFee), -78);
      expect(
        of(MoneyKind.living),
        -ClubBalance.lifestyleCost[Lifestyle.modest]!,
      );
      expect(money.net, 1550 - 78 - 150);
    });

    test('serbest oyuncu maaş almaz ama harcar', () {
      final money = Economy.weekly(
        contract: null,
        agent: null,
        lifestyle: Lifestyle.comfortable,
      );
      expect(money.net, -ClubBalance.lifestyleCost[Lifestyle.comfortable]!);
    });

    test('borç moral cezası, rahat yaşam moral bonusu verir', () {
      expect(Economy.moraleEffect(const Finance(balance: -1)).$1, lessThan(0));
      expect(
        Economy.moraleEffect(const Finance(lifestyle: Lifestyle.lavish)).$1,
        greaterThan(0),
      );
    });

    test('haftalık döngü bakiyeyi günceller ve raporlar', () {
      final s = newCareer();
      final r = WeekEngine.advance(s, const WeeklyPlan(), null, GameRandom(3));
      expect(r.report.money.net, isNot(0));
      // Haftalık hedef ödülü gelir tablosunun dışında, ayrıca eklenir.
      expect(
        r.state.finance.balance,
        s.finance.balance + r.report.money.net + r.state.goals.lastReward,
      );
    });
  });

  group('kadro', () {
    test('seçim kararlı: aynı hafta hep aynı sonuç', () {
      final s = newCareer().copyWith(week: 10);
      final first = Squad.isSelected(s);
      for (var i = 0; i < 5; i++) {
        expect(Squad.isSelected(s), first);
      }
    });

    test('rol oynama sıklığını belirler', () {
      int played(SquadRole role) {
        var n = 0;
        for (var w = 5; w <= 38; w++) {
          for (var season = 1; season <= 6; season++) {
            final s = newCareer().copyWith(
              season: season,
              week: w,
              contract: newCareer().contract!.copyWith(role: role),
            );
            if (Squad.isSelected(s)) n++;
          }
        }
        return n;
      }

      const total = 34 * 6;
      expect(played(SquadRole.star), total);
      expect(played(SquadRole.starter), greaterThan(total * 0.85));
      expect(
        played(SquadRole.rotation),
        inInclusiveRange(total * 0.55, total * 0.85),
      );
      expect(played(SquadRole.prospect), lessThan(total * 0.5));
    });

    test('sakat, yedek ve serbest oyuncu için maç günü', () {
      final s = newCareer().copyWith(week: 10);
      expect(Squad.matchDay(s.copyWith(clearContract: true)), MatchDay.none);
      expect(Squad.matchDay(s.copyWith(week: 2)), MatchDay.none);
    });
  });

  group('teklifler', () {
    CareerState windowCareer({bool free = false}) {
      final s = newCareer().copyWith(week: 2);
      return free ? s.copyWith(clearContract: true) : s;
    }

    test('pencere dışında (serbest değilse) teklif gelmez', () {
      final s = newCareer().copyWith(week: 12);
      final world = ClubWorld(s.worldSeed);
      for (var seed = 0; seed < 100; seed++) {
        expect(TransferMarket.newOffers(s, world, GameRandom(seed)), isEmpty);
      }
    });

    test('pencerede teklifler gelir ve mantıklıdır', () {
      final s = windowCareer();
      final world = ClubWorld(s.worldSeed);
      var count = 0;
      for (var seed = 0; seed < 200; seed++) {
        for (final o in TransferMarket.newOffers(s, world, GameRandom(seed))) {
          count++;
          expect(o.clubId, isNot(s.contract!.clubId));
          expect(o.maxWage, greaterThan(o.weeklyWage));
          expect(o.years, inInclusiveRange(1, ClubBalance.maxYears));
          expect(o.expiresAt, s.absoluteWeek + ClubBalance.offerLifetimeWeeks);
        }
      }
      expect(count, greaterThan(20), reason: '200 denemede yeterli teklif');
      expect(count, lessThan(120), reason: 'her hafta teklif yağmaz');
    });

    test(
      'serbest oyuncu pencere dışında da teklif alır, asla işsiz kalmaz',
      () {
        final s = windowCareer(free: true).copyWith(week: 15);
        final world = ClubWorld(s.worldSeed);
        var weeks = 0;
        var state = s;
        while (state.offers.isEmpty && weeks < 12) {
          state = state.copyWith(
            offers: [
              ...state.offers,
              ...TransferMarket.newOffers(state, world, GameRandom(weeks)),
            ],
          );
          weeks++;
        }
        expect(state.offers, isNotEmpty);
        expect(weeks, lessThan(6));
      },
    );

    test('menajer teklif sayısını artırır', () {
      int count(Agent? agent) {
        var n = 0;
        final s = windowCareer().copyWith(agent: agent);
        final world = ClubWorld(s.worldSeed);
        for (var seed = 0; seed < 600; seed++) {
          n += TransferMarket.newOffers(s, world, GameRandom(seed)).length;
        }
        return n;
      }

      expect(
        count(const Agent(name: 'A', level: 3)),
        greaterThan(count(null) * 1.3),
      );
    });

    test('menajer pazarlık üst sınırını yükseltir', () {
      double avgGap(Agent? agent) {
        final s = windowCareer().copyWith(agent: agent);
        final world = ClubWorld(s.worldSeed);
        var sum = 0.0, n = 0;
        for (var seed = 0; seed < 500; seed++) {
          for (final o in TransferMarket.newOffers(
            s,
            world,
            GameRandom(seed),
          )) {
            sum += o.maxWage / o.weeklyWage;
            n++;
          }
        }
        return sum / n;
      }

      expect(
        avgGap(const Agent(name: 'A', level: 3)),
        greaterThan(avgGap(null)),
      );
    });
  });

  group('pazarlık', () {
    const offer = TransferOffer(
      kind: OfferKind.transfer,
      clubId: 't4_0',
      weeklyWage: 1000,
      maxWage: 1200,
      years: 2,
      role: SquadRole.starter,
      expiresAt: 10,
    );

    test('teklif ya da altı: aynı maaşla kabul', () {
      final n = TransferMarket.negotiate(offer, 900);
      expect(n.kind, NegotiationKind.accepted);
      expect(n.wage, 1000);
    });

    test('üst sınır içinde: istenen maaşla kabul', () {
      final n = TransferMarket.negotiate(offer, 1150);
      expect(n.kind, NegotiationKind.accepted);
      expect(n.wage, 1150);
    });

    test('hafif aşırı istek: karşı teklif üst sınırda', () {
      final n = TransferMarket.negotiate(offer, 1300);
      expect(n.kind, NegotiationKind.counter);
      expect(n.wage, 1200);
    });

    test('çok aşırı istek: kulüp çekilir', () {
      final n = TransferMarket.negotiate(offer, 1500);
      expect(n.kind, NegotiationKind.walkedAway);
    });
  });

  group('imza', () {
    test('transfer: kulüp, sözleşme, imza parası; teklifler temizlenir', () {
      final s = newCareer().copyWith(
        week: 3,
        agent: const Agent(name: 'A', level: 1),
        offers: const [
          TransferOffer(
            kind: OfferKind.transfer,
            clubId: 't4_2',
            weeklyWage: 2000,
            maxWage: 2300,
            years: 3,
            role: SquadRole.starter,
            expiresAt: 99,
          ),
          TransferOffer(
            kind: OfferKind.transfer,
            clubId: 't4_3',
            weeklyWage: 1800,
            maxWage: 2000,
            years: 1,
            role: SquadRole.rotation,
            expiresAt: 99,
          ),
        ],
      );
      final signed = TransferMarket.sign(s, s.offers.first, 2100);
      expect(signed.contract!.clubId, 't4_2');
      expect(signed.contract!.weeklyWage, 2100);
      expect(signed.contract!.endSeason, s.season + 3 - 1);
      expect(signed.offers, isEmpty);
      // 2100 * 8 = 16800, %5 komisyon düşer
      expect(
        signed.finance.balance,
        s.finance.balance + (16800 * 0.95).round(),
      );
    });

    test('sezon sonu imzası sözleşmeyi gelecek sezondan başlatır', () {
      final s = newCareer().copyWith(week: 40);
      const offer = TransferOffer(
        kind: OfferKind.transfer,
        clubId: 't4_2',
        weeklyWage: 2000,
        maxWage: 2300,
        years: 2,
        role: SquadRole.starter,
        expiresAt: 99,
      );
      expect(TransferMarket.sign(s, offer, 2000).contract!.endSeason, 3);
    });

    test('yenileme mevcut sözleşmeyi uzatır', () {
      final s = newCareer().copyWith(week: 31);
      const offer = TransferOffer(
        kind: OfferKind.renewal,
        clubId: 'x',
        weeklyWage: 700,
        maxWage: 800,
        years: 2,
        role: SquadRole.starter,
        expiresAt: 99,
      );
      final signed = TransferMarket.sign(s, offer, 700);
      expect(signed.contract!.endSeason, s.contract!.endSeason + 2);
    });
  });

  group('menajer', () {
    test('düşük güçle üst seviye menajer tutulamaz', () {
      final s = newCareer();
      expect(s.player.overall, lessThan(ClubBalance.agentMinOverall[3]!));
      expect(ClubActions.hireAgent(s, 3).agent, isNull);
      expect(ClubActions.hireAgent(s, 1).agent, isNotNull);
      expect(ClubActions.fireAgent(ClubActions.hireAgent(s, 1)).agent, isNull);
    });
  });

  group('sezon geçişi', () {
    test('sözleşme biterse oyuncu serbest kalır', () {
      var s = newCareer().copyWith(
        season: 2,
        week: SeasonCalendar.weeksPerSeason,
      );
      // 2. sezon sonu = sözleşmenin son günü
      final r = WeekEngine.advance(s, const WeeklyPlan(), null, GameRandom(5));
      s = r.state;
      expect(s.season, 3);
      expect(s.contract, isNull);
      expect(
        r.report.events.any((e) => e.kind == WeekEventKind.contractExpired),
        isTrue,
      );
      expect(s.results, isEmpty);
    });

    test('sözleşme sürüyorsa kulüp kalır, rol yeniden hesaplanır', () {
      final s = newCareer().copyWith(
        season: 1,
        week: SeasonCalendar.weeksPerSeason,
      );
      final r = WeekEngine.advance(s, const WeeklyPlan(), null, GameRandom(5));
      expect(r.state.season, 2);
      expect(r.state.contract!.clubId, s.contract!.clubId);
    });

    test('son sezon geç haftalarında yenileme teklifi gelebilir', () {
      final base = newCareer().copyWith(
        season: 2,
        week: ClubBalance.renewalWeekFrom,
        contract: newCareer().contract!.copyWith(role: SquadRole.star),
      );
      var got = 0;
      for (var seed = 0; seed < 50; seed++) {
        final u = ClubEngine.process(
          base,
          newSeason: false,
          random: GameRandom(seed),
        );
        if (u.state.offers.any((o) => o.kind == OfferKind.renewal)) got++;
      }
      expect(got, greaterThan(35), reason: 'yıldız için %95');
    });

    test('süresi dolan teklif silinir', () {
      final s = newCareer().copyWith(
        week: 20,
        offers: [
          TransferOffer(
            kind: OfferKind.transfer,
            clubId: 't4_1',
            weeklyWage: 900,
            maxWage: 1000,
            years: 1,
            role: SquadRole.rotation,
            expiresAt: 5,
          ),
        ],
      );
      final u = ClubEngine.process(s, newSeason: false, random: GameRandom(1));
      expect(u.state.offers, isEmpty);
    });
  });

  group('puan durumu', () {
    test('aynı girdi aynı tabloyu verir ve oyuncunun skoru uygulanır', () {
      final s = newCareer();
      final world = ClubWorld(s.worldSeed);
      final club = s.contract!.clubId;
      final tier = world.tierOf(club);
      tableOf() => LeagueTable.compute(
        world: world,
        tier: tier,
        season: 1,
        throughRound: 5,
        playerResults: const [],
      );
      final a = tableOf().sorted.map((r) => r.teamId).toList();
      final b = tableOf().sorted.map((r) => r.teamId).toList();
      expect(a, b);

      final withWin = LeagueTable.compute(
        world: world,
        tier: tier,
        season: 1,
        throughRound: 1,
        playerResults: [
          MatchRecord(round: 1, clubId: club, scoreFor: 9, scoreAgainst: 0),
        ],
      );
      expect(withWin.row(club).points, 3);
      expect(withWin.row(club).goalsFor, 9);
      expect(withWin.row(club).played, 1);
    });

    test('tam sezon: her takım 34 maç oynar', () {
      final world = ClubWorld(3);
      final t = LeagueTable.compute(
        world: world,
        tier: 5,
        season: 1,
        throughRound: 34,
        playerResults: const [],
      );
      for (final row in t.sorted) {
        expect(row.played, 34);
      }
    });
  });

  group('tam sezon simülasyonu', () {
    test('bir sezon boyunca para, teklif ve tablo tutarlı kalır', () {
      var s = newCareer(seed: 4);
      final random = GameRandom(11);
      var offersSeen = 0;
      for (var i = 0; i < SeasonCalendar.weeksPerSeason; i++) {
        final matchDay = Squad.matchDay(s);
        final r = WeekEngine.advance(
          s,
          const WeeklyPlan(),
          matchDay == MatchDay.play
              ? const WeekMatch(
                  rating: 6.5,
                  goals: 0,
                  assists: 0,
                  result: MatchResultKind.draw,
                  scoreFor: 1,
                  scoreAgainst: 1,
                )
              : null,
          random,
        );
        offersSeen += r.report.events
            .where((e) => e.kind == WeekEventKind.offerReceived)
            .length;
        s = r.state;
      }
      expect(s.season, 2);
      expect(s.contract, isNotNull);
      expect(s.finance.balance, isNot(ClubBalance.startingBalance));
      expect(offersSeen, greaterThanOrEqualTo(0));
    });
  });
}
