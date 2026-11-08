import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_migrations.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/event_catalog.dart';
import 'package:son_dusuk/domain/social/event_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/domain/social/social_balance.dart';
import 'package:son_dusuk/domain/social/social_engine.dart';
import 'package:son_dusuk/presentation/event_texts.dart';

CareerState newCareer({int week = 10}) => CareerFactory.create(
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

PendingEvent pending(String id, CareerState s, {int life = 5}) => PendingEvent(
  id: id,
  createdAt: s.absoluteWeek,
  expiresAt: s.absoluteWeek + life,
  params: const {'opponent': 'Rakip SK', 'score': '2-1'},
);

void main() {
  group('ilişkiler', () {
    test('varsayılanlar, kırpma, yönelme ve JSON', () {
      const r = Relationships();
      expect(r[Relation.family], 70);
      final up = r.add({Relation.fans: 100, Relation.coach: -100});
      expect(up[Relation.fans], 100);
      expect(up[Relation.coach], 0);

      final drifted = up.drift(0.5);
      expect(drifted[Relation.fans], lessThan(100));
      expect(drifted[Relation.coach], greaterThan(0));

      final back = Relationships.fromJson(
        jsonDecode(jsonEncode(up.toJson())) as Map<String, dynamic>,
      );
      expect(back[Relation.fans], 100);
    });

    test('seviyeler', () {
      expect(Relationships.levelOf(5), 0);
      expect(Relationships.levelOf(30), 1);
      expect(Relationships.levelOf(50), 2);
      expect(Relationships.levelOf(70), 3);
      expect(Relationships.levelOf(95), 4);
    });
  });

  group('katalog', () {
    test('kimlikler tektir; her şablonda en az 2 seçenek', () {
      final ids = EventCatalog.all.map((t) => t.id).toList();
      expect(ids.toSet().length, ids.length);
      for (final t in EventCatalog.all) {
        expect(t.choices.length, inInclusiveRange(2, 3), reason: t.id);
      }
    });

    test('her olayın Türkçe metni, seçenekleri ve sonuçları tam', () async {
      final l10n = await AppLocalizations.delegate.load(const Locale('tr'));
      for (final t in EventCatalog.all) {
        final x = l10n.eventTexts(t.id, const {
          'opponent': 'A',
          'score': '1-0',
        });
        expect(x.title, isNotEmpty, reason: t.id);
        expect(x.body, isNotEmpty, reason: t.id);
        expect(x.choices, hasLength(t.choices.length), reason: t.id);
        expect(x.results, hasLength(t.choices.length), reason: t.id);
        for (var i = 0; i < t.choices.length; i++) {
          expect(x.choices[i], isNotEmpty);
          expect(x.results[i], isNotEmpty);
          if (t.choices[i].risky) {
            expect(x.backfires[i], isNotNull, reason: '${t.id} c$i');
          }
        }
      }
    });

    test('basın olayları maç sonucuna göre uygun şablonu seçer', () {
      final s = newCareer();
      bool fits(String id, EventContext c) => EventCatalog.byId(id).when(c);
      expect(
        fits('pressWin', EventContext(state: s, rating: 7, won: true)),
        isTrue,
      );
      expect(
        fits('pressWin', EventContext(state: s, rating: 7, lost: true)),
        isFalse,
      );
      expect(
        fits('pressLoss', EventContext(state: s, rating: 5, lost: true)),
        isTrue,
      );
      expect(
        fits('pressStar', EventContext(state: s, rating: 8, goals: 2)),
        isTrue,
      );
      expect(
        fits('pressStar', EventContext(state: s, rating: 8, goals: 1)),
        isFalse,
      );
      expect(fits('pressPoor', EventContext(state: s, rating: 4.5)), isTrue);
      expect(fits('pressBench', EventContext(state: s, benched: true)), isTrue);
    });
  });

  group('çözüm', () {
    test('sonuç uygulanır, olay düşer, haber eklenir', () {
      final s = newCareer();
      final p = pending('fanMeet', s);
      final r = SocialEngine.resolve(
        s.copyWith(pendingEvents: [p]),
        p,
        0,
        GameRandom(1),
      );
      expect(r.backfired, isFalse);
      expect(r.state.pendingEvents, isEmpty);
      expect(r.state.relations[Relation.fans], s.relations[Relation.fans] + 6);
      expect(r.state.status.morale, s.status.morale + 3);
      expect(r.state.news.first.kind, NewsKind.event);
      expect(r.state.news.first.params['id'], 'fanMeet');
    });

    test('riskli seçenek yaklaşık altChance oranında ters tepmez', () {
      final s = newCareer();
      final p = pending('partyInvite', s);
      var back = 0;
      const n = 600;
      for (var seed = 0; seed < n; seed++) {
        final r = SocialEngine.resolve(
          s.copyWith(pendingEvents: [p]),
          p,
          0,
          GameRandom(seed),
        );
        if (r.backfired) back++;
      }
      expect(back / n, closeTo(0.3, 0.06));
    });

    test('risksiz seçenek asla ters tepmez', () {
      final s = newCareer();
      final p = pending('partyInvite', s);
      for (var seed = 0; seed < 50; seed++) {
        expect(
          SocialEngine.resolve(
            s.copyWith(pendingEvents: [p]),
            p,
            1,
            GameRandom(seed),
          ).backfired,
          isFalse,
        );
      }
    });

    test('para: maaş katı ve sabit tutar', () {
      final s = newCareer();
      final wage = s.contract!.weeklyWage;
      final spons = SocialEngine.applyEffect(
        s,
        const EventEffect(moneyWeeks: 6),
      );
      expect(
        spons.finance.balance,
        s.finance.balance +
            (6 * (wage < SocialBalance.minWageForMoney ? 500 : wage)).round(),
      );
      final help = SocialEngine.applyEffect(s, const EventEffect(money: 2500));
      expect(help.finance.balance, s.finance.balance + 2500);
    });

    test('rehab: sakatlık kısalır ama en az 1 hafta kalır', () {
      final s = newCareer().copyWith(
        status: const PlayerStatus(
          injury: Injury(type: InjuryType.muscle, weeksLeft: 3, totalWeeks: 3),
        ),
      );
      final once = SocialEngine.applyEffect(s, const EventEffect(healWeeks: 2));
      expect(once.status.injury!.weeksLeft, 1);
      final over = SocialEngine.applyEffect(s, const EventEffect(healWeeks: 9));
      expect(over.status.injury!.weeksLeft, 1);
    });
  });

  group('haftalık akış', () {
    WeekSocialInput win() => const WeekSocialInput(
      rating: 8,
      goals: 2,
      won: true,
      scoreFor: 3,
      scoreAgainst: 1,
      opponent: 'Rakip SK',
    );

    test('galibiyet ve goller taraftarı, iyi reyting hocayı yükseltir', () {
      final s = newCareer();
      final u = SocialEngine.afterWeek(s, s, win(), GameRandom(1));
      expect(
        u.state.relations[Relation.fans],
        greaterThan(s.relations[Relation.fans]),
      );
      expect(
        u.state.relations[Relation.coach],
        greaterThan(s.relations[Relation.coach]),
      );
      expect(u.state.news.first.kind, NewsKind.match);
      expect(u.state.news.first.params['score'], '3-1');
    });

    test('yenilgi ve kötü reyting düşürür', () {
      final s = newCareer();
      final u = SocialEngine.afterWeek(
        s,
        s,
        const WeekSocialInput(
          rating: 4.5,
          lost: true,
          scoreAgainst: 2,
          opponent: 'X',
        ),
        GameRandom(1),
      );
      expect(
        u.state.relations[Relation.fans],
        lessThan(s.relations[Relation.fans]),
      );
      expect(
        u.state.relations[Relation.coach],
        lessThan(s.relations[Relation.coach]),
      );
    });

    test('ilişkiler zamanla nötre yaklaşır', () {
      var s = newCareer().copyWith(
        relations: const Relationships().add({Relation.fans: 50}),
      );
      for (var i = 0; i < 40; i++) {
        s = SocialEngine.afterWeek(
          s,
          s,
          const WeekSocialInput(),
          GameRandom(i),
        ).state.copyWith(pendingEvents: []);
      }
      // 90'dan, haftada %3 yönelmeyle 40 haftada ≈55'e iner.
      expect(s.relations[Relation.fans], inInclusiveRange(45, 65));
    });

    test('dikkat çekici maçlarda basın sorusu sık gelir', () {
      final s = newCareer();
      var press = 0;
      for (var seed = 0; seed < 200; seed++) {
        final u = SocialEngine.afterWeek(s, s, win(), GameRandom(seed));
        if (u.state.pendingEvents.any(
          (p) => EventCatalog.byId(p.id).kind == EventKind.press,
        )) {
          press++;
        }
      }
      expect(press / 200, greaterThan(0.75));
    });

    test('maç yoksa basın olayı gelmez; rastgele olay seyrek gelir', () {
      final s = newCareer();
      var any = 0;
      for (var seed = 0; seed < 300; seed++) {
        final u = SocialEngine.afterWeek(
          s,
          s,
          const WeekSocialInput(),
          GameRandom(seed),
        );
        for (final p in u.state.pendingEvents) {
          expect(EventCatalog.byId(p.id).kind, isNot(EventKind.press));
        }
        if (u.state.pendingEvents.isNotEmpty) any++;
      }
      expect(any / 300, inInclusiveRange(0.1, 0.3));
    });

    test('bekleyen olay sınırı aşılmaz, aynı olay tekrar gelmez', () {
      var s = newCareer();
      for (var i = 0; i < 80; i++) {
        s = SocialEngine.afterWeek(
          s,
          s.copyWith(week: 10 + (i % 25)),
          win(),
          GameRandom(i),
        ).state;
        expect(
          s.pendingEvents.length,
          lessThanOrEqualTo(SocialBalance.pendingCap),
        );
        final ids = s.pendingEvents.map((p) => p.id).toList();
        expect(ids.toSet().length, ids.length);
      }
    });

    test('süresi dolan olay yok sayma sonucuyla kapanır', () {
      final s = newCareer();
      final expired = PendingEvent(
        id: 'pressWin',
        createdAt: s.absoluteWeek - 5,
        expiresAt: s.absoluteWeek - 1,
      );
      final u = SocialEngine.afterWeek(
        s.copyWith(pendingEvents: [expired]),
        s.copyWith(pendingEvents: [expired]),
        const WeekSocialInput(),
        GameRandom(3),
      );
      expect(u.state.pendingEvents.any((p) => p.id == 'pressWin'), isFalse);
      // yok say: medya -2 (yönelme ve diğer etkiler küçük)
      expect(
        u.state.relations[Relation.media],
        lessThan(s.relations[Relation.media]),
      );
    });

    test('koşul: rehab yalnız uzun sakatlıkta, borç yardımı yalnız borçta', () {
      final s = newCareer();
      expect(
        EventCatalog.byId('injuryRehab').when(EventContext(state: s)),
        isFalse,
      );
      expect(
        EventCatalog.byId('debtHelp').when(EventContext(state: s)),
        isFalse,
      );
      final debt = s.copyWith(finance: s.finance.copyWith(balance: -10));
      expect(
        EventCatalog.byId('debtHelp').when(EventContext(state: debt)),
        isTrue,
      );
    });
  });

  group('oyuna etkiler', () {
    test(
      'hoca ilişkisi maça çıkma, medya teklif sıklığı, aile moral tabanı',
      () {
        final s = newCareer();
        final good = s.copyWith(
          relations: s.relations.add({
            Relation.coach: 50,
            Relation.media: 60,
            Relation.family: 30,
          }),
        );
        final bad = s.copyWith(
          relations: s.relations.add({
            Relation.coach: -50,
            Relation.media: -40,
            Relation.family: -60,
          }),
        );
        expect(SocialEngine.coachSelectionBonus(good), greaterThan(0));
        expect(SocialEngine.coachSelectionBonus(bad), lessThan(0));
        expect(
          SocialEngine.offerFactor(good),
          greaterThan(SocialEngine.offerFactor(bad)),
        );
        expect(
          SocialEngine.moraleBaseline(good, 60),
          greaterThan(SocialEngine.moraleBaseline(bad, 60)),
        );
      },
    );
  });

  group('kayıt', () {
    test('v4 kaydı v5\'e taşınır, sosyal alanlar varsayılanla gelir', () {
      final v4 = {
        'schemaVersion': 4,
        'savedAt': 'x',
        'career': newCareer().toJson()
          ..remove('relations')
          ..remove('pendingEvents')
          ..remove('news')
          ..remove('eventSeen'),
      };
      final m = const SaveMigrator().migrate(v4);
      expect(m['schemaVersion'], currentSchemaVersion);
      final s = CareerState.fromJson(m['career'] as Map<String, dynamic>);
      expect(s.pendingEvents, isEmpty);
      expect(s.relations[Relation.coach], 50);
    });

    test('JSON gidiş-dönüş olay, haber ve ilişkileri korur', () {
      final s0 = newCareer();
      final s = s0.copyWith(
        pendingEvents: [pending('fanMeet', s0)],
        news: const [
          NewsItem(
            kind: NewsKind.match,
            season: 1,
            week: 6,
            params: {'score': '1-0'},
          ),
        ],
        eventSeen: const {'fanMeet': 3},
        relations: s0.relations.add({Relation.fans: 12}),
      );
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(back.pendingEvents.single.id, 'fanMeet');
      expect(back.pendingEvents.single.params['score'], '2-1');
      expect(back.news.single.params['score'], '1-0');
      expect(back.eventSeen['fanMeet'], 3);
      expect(back.relations[Relation.fans], s.relations[Relation.fans]);
    });
  });
}
