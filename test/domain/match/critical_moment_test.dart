import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/match/critical_moment.dart';
import 'package:son_dusuk/domain/match/match_balance.dart';
import 'package:son_dusuk/domain/match/match_session.dart';
import 'package:son_dusuk/domain/match/match_simulator.dart';
import 'package:son_dusuk/domain/match/moment_resolver.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/attributes.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

Player playerWith(PlayerPosition position, double level) {
  final base = PlayerFactory.create(
    name: 'T',
    birthplace: 'Ankara',
    position: position,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: GameRandom(1),
  );
  return base.copyWith(
    attributes: Attributes({for (final a in Attribute.values) a: level}),
  );
}

void main() {
  group('CriticalMomentGenerator', () {
    test('maç başı ortalama 5-8 an, sıralı ve benzersiz dakika', () {
      final random = GameRandom(1);
      var total = 0;
      const n = 2000;
      for (var i = 0; i < n; i++) {
        final moments = CriticalMomentGenerator.generate(
          PlayerPosition.forward,
          random,
        );
        total += moments.length;
        expect(moments.length, inInclusiveRange(5, 8));
        final minutes = moments.map((m) => m.minute).toList();
        expect(minutes.toSet(), hasLength(minutes.length));
        expect([...minutes]..sort(), minutes);
        expect(minutes.every((m) => m >= 2 && m <= 89), isTrue);
      }
      expect(total / n, inInclusiveRange(5.5, 7.5));
    });

    test('mevki an türünü belirler', () {
      Map<MomentType, int> count(PlayerPosition p) {
        final random = GameRandom(2);
        final c = <MomentType, int>{};
        for (var i = 0; i < 3000; i++) {
          for (final m in CriticalMomentGenerator.generate(p, random)) {
            c[m.type] = (c[m.type] ?? 0) + 1;
          }
        }
        return c;
      }

      final fw = count(PlayerPosition.forward);
      final cm = count(PlayerPosition.centralMid);
      final df = count(PlayerPosition.defender);

      expect(fw[MomentType.shot]!, greaterThan(cm[MomentType.shot]! * 2));
      expect(cm[MomentType.keyPass]!, greaterThan(fw[MomentType.keyPass]!));
      expect(df[MomentType.tackle]!, greaterThan(fw[MomentType.tackle]! * 4));
    });

    test('tüm mevkilerin ağırlık tablosu tam', () {
      for (final p in PlayerPosition.values) {
        final w = MatchBalance.momentWeights[p]!;
        expect(w.keys.toSet(), MomentType.values.toSet());
        expect(w.values.fold<double>(0, (a, b) => a + b), closeTo(1, 0.011));
      }
    });
  });

  group('MomentResolver', () {
    test('yüksek nitelik gol olasılığını artırır', () {
      final weak = playerWith(PlayerPosition.forward, 30);
      final strong = playerWith(PlayerPosition.forward, 90);
      for (final t in [MomentType.shot, MomentType.oneOnOne]) {
        expect(
          MomentResolver.goalProbability(strong, t),
          greaterThan(MomentResolver.goalProbability(weak, t)),
        );
      }
      expect(
        MomentResolver.tackleSuccess(playerWith(PlayerPosition.defender, 90)),
        greaterThan(
          MomentResolver.tackleSuccess(playerWith(PlayerPosition.defender, 30)),
        ),
      );
    });

    test('nitelik 50 referans olasılığı verir', () {
      final p = playerWith(PlayerPosition.forward, 50);
      expect(
        MomentResolver.goalProbability(p, MomentType.penalty),
        closeTo(MatchBalance.goalChance[MomentType.penalty]!, 1e-9),
      );
    });
  });

  group('MatchSession (kritik anlar maç sonucuna geri beslenir)', () {
    ({double total, double playerGoals, double teamFor}) average(
      Player player, {
      int n = 3000,
    }) {
      final random = GameRandom(11);
      var total = 0;
      var pg = 0;
      var tf = 0;
      for (var i = 0; i < n; i++) {
        final s = MatchSession.start(
          homeStrength: 60,
          awayStrength: 60,
          playerSide: Side.home,
          player: player,
          random: random,
        )..autoPlay(player, random);
        final r = s.result;
        expect(s.isFinished, isTrue);
        total += r.totalGoals;
        tf += r.homeGoals;
        pg += r.goals.where((g) => g.byPlayer).length;
      }
      return (total: total / n, playerGoals: pg / n, teamFor: tf / n);
    }

    test('ortalama (50) oyuncu toplam gol ortalamasını bozmaz', () {
      final a = average(playerWith(PlayerPosition.forward, 50));
      expect(a.total, inInclusiveRange(2.5, 3.0));
      expect(a.playerGoals, inInclusiveRange(0.15, 0.7));
    });

    test('iyi oyuncu takımına gerçekten daha çok gol getirir', () {
      final weak = average(playerWith(PlayerPosition.forward, 30));
      final strong = average(playerWith(PlayerPosition.forward, 90));
      expect(strong.playerGoals, greaterThan(weak.playerGoals * 1.5));
      expect(strong.teamFor, greaterThan(weak.teamFor));
    });

    test('mini oyun sonucu skora yansır', () {
      final player = playerWith(PlayerPosition.forward, 50);
      final random = GameRandom(4);
      final s = MatchSession.start(
        homeStrength: 60,
        awayStrength: 60,
        playerSide: Side.away,
        player: player,
        random: random,
      );
      final before = s.result.awayGoals;
      s.resolve(s.moments.first, MomentOutcome.goal);
      expect(s.result.awayGoals, before + 1);
      expect(s.result.goals.where((g) => g.byPlayer), hasLength(1));

      final homeBefore = s.result.homeGoals;
      s.resolve(s.moments[1], MomentOutcome.conceded);
      expect(s.result.homeGoals, homeBefore + 1);
    });
  });
}
