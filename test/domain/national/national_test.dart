import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/career/week_report.dart';
import 'package:son_dusuk/domain/national/nation.dart';
import 'package:son_dusuk/domain/national/national_balance.dart';
import 'package:son_dusuk/domain/national/national_career.dart';
import 'package:son_dusuk/domain/national/national_engine.dart';
import 'package:son_dusuk/domain/national/tournament.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

CareerState career({int overall = 80, int age = 26}) {
  final base = CareerFactory.create(
    PlayerFactory.create(
      name: 'Deniz',
      birthplace: 'Bursa',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: GameRandom(1),
    ),
    GameRandom(1),
  );
  final strong = base.player.copyWith(
    age: age,
    attributes: base.player.attributes.copyWith({
      for (final a in Attribute.values) a: overall.toDouble(),
    }),
  );
  return base.copyWith(player: strong);
}

TournamentRun run({
  int season = 4,
  bool called = true,
  NationalRole role = NationalRole.starter,
  List<NationalMatchRecord> results = const [],
}) => TournamentRun(
  season: season,
  kind: NationalEngine.kindOf(season),
  called: called,
  role: role,
  results: results,
);

NationalMatchRecord win(int round, {bool played = true, int goals = 1}) =>
    NationalMatchRecord(
      round: round,
      opponentId: 'x',
      scoreFor: 2,
      scoreAgainst: 0,
      played: played,
      playerGoals: goals,
    );

void main() {
  group('takvim', () {
    test('turnuva çift sezonlarda, dört yılda bir dünya kupası', () {
      expect(NationalEngine.isTournamentSeason(1), isFalse);
      expect(NationalEngine.isTournamentSeason(2), isTrue);
      expect(NationalEngine.kindOf(2), TournamentKind.continental);
      expect(NationalEngine.kindOf(4), TournamentKind.world);
      expect(NationalEngine.kindOf(6), TournamentKind.continental);
    });

    test('39-42. haftalar tur 0-3, diğerleri null', () {
      expect(NationalEngine.roundOfWeek(38), isNull);
      expect(NationalEngine.roundOfWeek(39), 0);
      expect(NationalEngine.roundOfWeek(42), 3);
    });
  });

  group('eşleşme tablosu', () {
    test('16 ülke, 8-4-2-1 maç; aynı seed aynı tablo', () {
      final a = Tournament(world: NationalWorld(7), season: 4);
      final b = Tournament(world: NationalWorld(7), season: 4);
      expect(a.nations, hasLength(16));
      expect([for (final r in a.rounds) r.length], [8, 4, 2, 1]);
      expect(
        [for (final m in a.rounds[0]) '${m.a!.id}-${m.b!.id}'],
        [for (final m in b.rounds[0]) '${m.a!.id}-${m.b!.id}'],
      );
      expect(a.rounds[0].any((m) => m.involves(NationalWorld.homeId)), isTrue);
    });

    test('oyuncunun ülkesi dışındaki maçlar oynanmış, kazanan ilerler', () {
      final t = Tournament(world: NationalWorld(3), season: 2);
      for (final m in t.rounds[0]) {
        if (m.involves(NationalWorld.homeId)) {
          expect(m.decided, isFalse, reason: 'sonuç verilmedi');
        } else {
          expect(m.decided, isTrue);
          expect(m.winner, isNotNull);
        }
      }
      // Rakip, çeyrek finaldeki diğer koldan gelir ve belli olmalı.
      expect(t.opponentOfHome(0), isNotNull);
    });

    test('ülkenin sonucu işlenir; kaybedince sonraki turlarda yer almaz', () {
      final loss = NationalMatchRecord(
        round: 0,
        opponentId: 'x',
        scoreFor: 0,
        scoreAgainst: 1,
      );
      final t = Tournament(
        world: NationalWorld(3),
        season: 2,
        homeResults: [loss],
      );
      expect(t.homeMatch(0)!.decided, isTrue);
      expect(t.homeMatch(0)!.winner!.id, isNot(NationalWorld.homeId));
      expect(t.homeMatch(1), isNull);
    });

    test('penaltı atışları: kazananın golü her zaman fazla', () {
      final random = GameRandom(5);
      for (var i = 0; i < 200; i++) {
        final (a, b) = Shootout.decide(70, 66, random);
        expect(a, isNot(b));
        expect(a > b ? a : b, inInclusiveRange(3, 5));
        expect(a < b ? a : b, greaterThanOrEqualTo(1));
      }
    });
  });

  group('çağrılma', () {
    test('güçlü oyuncu çağrılır, zayıf ve genç çağrılmaz', () {
      expect(NationalEngine.roleFor(career(overall: 90), 1), isNotNull);
      expect(
        NationalEngine.roleFor(career(overall: 90), 1),
        NationalRole.starter,
      );
      expect(NationalEngine.roleFor(career(overall: 55), 4), isNull);
      expect(NationalEngine.roleFor(career(overall: 95, age: 17), 1), isNull);
    });

    test('lig kademesi çağrılmayı etkiler', () {
      final s = career(overall: 72);
      expect(
        NationalEngine.callUpScore(s, 1),
        greaterThan(NationalEngine.callUpScore(s, 4)),
      );
    });
  });

  group('turnuva haftaları', () {
    test('38 -> 39: kadro açıklanır (çağrılma ya da dışarıda kalma)', () {
      final prev = career(overall: 90).copyWith(season: 4, week: 38);
      final next = prev.copyWith(week: 39);
      final u = NationalEngine.afterWeek(prev: prev, next: next);
      expect(u.state.national.current, isNotNull);
      expect(u.state.national.current!.called, isTrue);
      expect(u.events.first.kind, WeekEventKind.nationalCalled);

      final weak = career(overall: 50).copyWith(season: 4, week: 38);
      final w = NationalEngine.afterWeek(
        prev: weak,
        next: weak.copyWith(week: 39),
      );
      expect(w.state.national.current!.called, isFalse);
      expect(w.events.first.kind, WeekEventKind.nationalOmitted);
    });

    test('tek sayılı sezonda turnuva başlamaz', () {
      final prev = career(overall: 90).copyWith(season: 3, week: 38);
      final u = NationalEngine.afterWeek(
        prev: prev,
        next: prev.copyWith(week: 39),
      );
      expect(u.state.national.current, isNull);
      expect(u.events, isEmpty);
    });

    test('oynanan maç: milli maç sayısı, gol ve prim işlenir', () {
      final prev = career(
        overall: 90,
      ).copyWith(season: 4, week: 39, national: NationalCareer(current: run()));
      final next = prev.copyWith(week: 40);
      final u = NationalEngine.afterWeek(
        prev: prev,
        next: next,
        play: const NationalPlay(goals: 2, scoreFor: 3, scoreAgainst: 1),
      );
      final nat = u.state.national;
      expect(nat.caps, 1);
      expect(nat.goals, 2);
      expect(nat.current!.results.single.played, isTrue);
      expect(u.bonus, greaterThan(0));
      expect(u.state.finance.balance, prev.finance.balance + u.bonus);
      expect(u.opponent, isNotNull);
      expect(
        u.events.map((e) => e.kind),
        contains(WeekEventKind.nationalMatch),
      );
    });

    test('oynamadığın hafta ülkenin maçı seed ile simüle edilir', () {
      final prev = career(
        overall: 90,
      ).copyWith(season: 4, week: 39, national: NationalCareer(current: run()));
      final next = prev.copyWith(week: 40);
      final a = NationalEngine.afterWeek(prev: prev, next: next);
      final b = NationalEngine.afterWeek(prev: prev, next: next);
      final ra = a.state.national.current!.results.single;
      final rb = b.state.national.current!.results.single;
      expect(ra.played, isFalse);
      expect(a.state.national.caps, 0);
      expect(
        '${ra.scoreFor}-${ra.scoreAgainst}-${ra.pensFor}',
        '${rb.scoreFor}-${rb.scoreAgainst}-${rb.pensFor}',
      );
    });

    test('elenince turnuva kaydı yazılır, sonraki hafta maç yok', () {
      final prev = career(overall: 90).copyWith(
        season: 4,
        week: 40,
        national: NationalCareer(current: run(results: [win(0)])),
      );
      final u = NationalEngine.afterWeek(
        prev: prev,
        next: prev.copyWith(week: 41),
        play: const NationalPlay(goals: 0, scoreFor: 0, scoreAgainst: 2),
      );
      final nat = u.state.national;
      expect(nat.past.single.stage, TournamentStage.quarterFinal);
      expect(nat.past.single.called, isTrue);
      expect(u.events.map((e) => e.kind), contains(WeekEventKind.nationalOut));
      expect(NationalEngine.dayOf(u.state), NationalDay.eliminated);
    });

    test('finali kazanmak şampiyonluk, prim ve moral getirir', () {
      final prev = career(overall: 90).copyWith(
        season: 4,
        week: 42,
        national: NationalCareer(
          current: run(results: [win(0), win(1), win(2)]),
        ),
      );
      final next = prev.copyWith(season: 5, week: 1);
      final u = NationalEngine.afterWeek(
        prev: prev,
        next: next,
        play: const NationalPlay(goals: 1, scoreFor: 1, scoreAgainst: 0),
      );
      final nat = u.state.national;
      expect(nat.past.single.stage, TournamentStage.champion);
      expect(nat.titles, 1);
      expect(
        u.events.map((e) => e.kind),
        contains(WeekEventKind.nationalChampion),
      );
      expect(u.bonus, greaterThan(NationalBalance.wageFloor));
      expect(u.state.status.morale, greaterThan(next.status.morale));
      // Yeni sezon: biten turnuva kartı kalkar, özet kalır.
      expect(nat.current, isNull);
    });

    test('kadroda olmayan oyuncu maça çıkmaz ama ülke oynar', () {
      final prev = career(overall: 50).copyWith(
        season: 4,
        week: 39,
        national: NationalCareer(current: run(called: false)),
      );
      expect(NationalEngine.dayOf(prev), NationalDay.notCalled);
      final u = NationalEngine.afterWeek(
        prev: prev,
        next: prev.copyWith(week: 40),
      );
      expect(u.state.national.current!.results, hasLength(1));
      expect(u.state.national.caps, 0);
      expect(u.bonus, 0);
    });
  });

  group('günün durumu', () {
    test('turnuva yokken none; sakatken injured', () {
      expect(NationalEngine.dayOf(career()), NationalDay.none);
      final s = career(
        overall: 90,
      ).copyWith(season: 4, week: 39, national: NationalCareer(current: run()));
      final injured = s.copyWith(
        status: s.status.copyWith(
          injury: const Injury(
            type: InjuryType.muscle,
            weeksLeft: 3,
            totalWeeks: 3,
          ),
        ),
      );
      expect(NationalEngine.dayOf(injured), NationalDay.injured);
      expect({
        NationalDay.play,
        NationalDay.benched,
      }, contains(NationalEngine.dayOf(s)));
    });

    test('ana kadro rezervden sık oynar', () {
      int plays(NationalRole role) {
        var n = 0;
        for (var seed = 1; seed <= 200; seed++) {
          final s = career(overall: 90).copyWith(
            worldSeed: seed,
            season: 4,
            week: 39,
            national: NationalCareer(current: run(role: role)),
          );
          if (NationalEngine.dayOf(s) == NationalDay.play) n++;
        }
        return n;
      }

      expect(
        plays(NationalRole.starter),
        greaterThan(plays(NationalRole.reserve)),
      );
    });
  });

  test('milli takım kaydı JSON gidiş-dönüş', () {
    final nat = NationalCareer(
      caps: 7,
      goals: 3,
      current: run(results: [win(0)]),
      past: const [
        TournamentRecord(
          season: 2,
          kind: TournamentKind.continental,
          called: true,
          stage: TournamentStage.champion,
          appearances: 3,
          goals: 2,
        ),
      ],
    );
    final back = NationalCareer.fromJson(
      jsonDecode(jsonEncode(nat.toJson())) as Map<String, dynamic>,
    );
    expect(back.caps, 7);
    expect(back.current!.results.single.won, isTrue);
    expect(back.past.single.isTitle, isTrue);
    expect(back.titles, 1);
  });
}
