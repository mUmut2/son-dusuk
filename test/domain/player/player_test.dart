import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/player/age_curve.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/attributes.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

Player newPlayer(int seed, {PlayerPosition position = PlayerPosition.forward}) {
  return PlayerFactory.create(
    name: 'Test Oyuncu',
    birthplace: 'Ankara',
    position: position,
    foot: PreferredFoot.right,
    appearance: const Appearance(),
    random: GameRandom(seed),
  );
}

void main() {
  group('Attributes', () {
    test('değerler 1-99 aralığına sıkıştırılır', () {
      final a = Attributes({Attribute.shooting: 500, Attribute.pace: -20});
      expect(a[Attribute.shooting], 99);
      expect(a[Attribute.pace], 1);
      expect(a[Attribute.vision], 1, reason: 'eksik nitelik minimuma düşer');
    });

    test('genel güç mevkiye göre değişir', () {
      final a = Attributes({
        for (final x in Attribute.values) x: 30,
        Attribute.shooting: 90,
        Attribute.finesse: 90,
        Attribute.heading: 90,
        Attribute.composure: 90,
      });
      expect(
        a.overall(PlayerPosition.forward),
        greaterThan(a.overall(PlayerPosition.defender)),
      );
    });
  });

  group('AgeCurve', () {
    test('gençken hızlı gelişim, 29+ fiziksel düşüş', () {
      expect(AgeCurve.annualDelta(17, AttributeKind.physical), greaterThan(3));
      expect(
        AgeCurve.annualDelta(25, AttributeKind.physical).abs(),
        lessThan(1),
      );
      for (var age = 29; age <= 40; age++) {
        expect(AgeCurve.annualDelta(age, AttributeKind.physical), lessThan(0));
      }
    });

    test('zihinsel nitelikler yaşlılıkta düşmez', () {
      for (var age = 16; age <= 40; age++) {
        expect(
          AgeCurve.annualDelta(age, AttributeKind.mental),
          greaterThanOrEqualTo(0),
        );
      }
    });

    test('fiziksel düşüş zihinsel ve teknikten daha sert', () {
      expect(
        AgeCurve.annualDelta(33, AttributeKind.physical),
        lessThan(AgeCurve.annualDelta(33, AttributeKind.technical)),
      );
    });
  });

  group('PlayerFactory', () {
    test('16 yaşında, geçerli aralıklarda oyuncu üretir', () {
      for (var seed = 0; seed < 200; seed++) {
        final p = newPlayer(seed);
        expect(p.age, 16);
        expect(p.potential, inInclusiveRange(55, 97));
        expect(p.injuryProneness, inInclusiveRange(0, 1));
        expect(p.professionalism, inInclusiveRange(0, 1));
        expect(p.overall, inInclusiveRange(30, 60));
      }
    });

    test('aynı seed aynı oyuncuyu üretir', () {
      expect(
        jsonEncode(newPlayer(5).toJson()),
        jsonEncode(newPlayer(5).toJson()),
      );
    });

    test('ana nitelikler ikincillerden yüksek başlar', () {
      var keyHigher = 0;
      for (var seed = 0; seed < 100; seed++) {
        final p = newPlayer(seed);
        if (p.attributes[Attribute.shooting] >
            p.attributes[Attribute.defending]) {
          keyHigher++;
        }
      }
      expect(keyHigher, greaterThan(90));
    });
  });

  test('CareerState JSON gidiş-dönüş kayıpsız', () {
    final state = CareerState(player: newPlayer(3), season: 4, week: 12);
    final restored = CareerState.fromJson(
      jsonDecode(jsonEncode(state.toJson())) as Map<String, dynamic>,
    );
    expect(jsonEncode(restored.toJson()), jsonEncode(state.toJson()));
    expect(restored.season, 4);
    expect(restored.player.position, PlayerPosition.forward);
  });
}
