import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/week_engine.dart';
import 'package:son_dusuk/domain/career/weekly_plan.dart';
import 'package:son_dusuk/domain/club/club_balance.dart';
import 'package:son_dusuk/domain/club/equipment.dart';
import 'package:son_dusuk/domain/club/finance.dart';
import 'package:son_dusuk/domain/club/transfer_market.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

CareerState career({int balance = 1000000}) {
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
  return base.copyWith(week: 10, finance: Finance(balance: balance));
}

void main() {
  group('satın alma', () {
    test('para düşer, seviye artar; son seviyeden sonra alınamaz', () {
      var s = career();
      for (var i = 0; i < ClubBalance.equipmentMaxLevel; i++) {
        s = ClubActions.buyEquipment(s, EquipmentSlot.boots);
      }
      expect(s.equipment.level(EquipmentSlot.boots), 3);
      final spent = ClubBalance.equipmentPrice[EquipmentSlot.boots]!.reduce(
        (a, b) => a + b,
      );
      expect(s.finance.balance, 1000000 - spent);
      expect(s.equipment.nextPrice(EquipmentSlot.boots), isNull);
      final again = ClubActions.buyEquipment(s, EquipmentSlot.boots);
      expect(again.finance.balance, s.finance.balance);
    });

    test('para yetmezse alınmaz', () {
      final s = career(balance: 100);
      final r = ClubActions.buyEquipment(s, EquipmentSlot.trainingKit);
      expect(r.equipment.level(EquipmentSlot.trainingKit), 0);
      expect(r.finance.balance, 100);
    });

    test('JSON gidiş-dönüşte korunur; eski kayıt boş ekipmanla yüklenir', () {
      final s = ClubActions.buyEquipment(career(), EquipmentSlot.shinGuards);
      final back = CareerState.fromJson(
        jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>,
      );
      expect(back.equipment.level(EquipmentSlot.shinGuards), 1);
      final old = s.toJson()..remove('equipment');
      expect(CareerState.fromJson(old).equipment.levels, isEmpty);
    });
  });

  group('etkiler', () {
    test('krampon maç niteliklerini artırır, diğerlerini değil', () {
      const eq = Equipment({'boots': 3});
      final p = career().player;
      final boosted = eq.applyToPlayer(p);
      expect(
        boosted.attributes.raw(Attribute.shooting),
        closeTo(p.attributes.raw(Attribute.shooting) + 6, 1e-9),
      );
      expect(
        boosted.attributes.raw(Attribute.defending),
        p.attributes.raw(Attribute.defending),
      );
      expect(const Equipment().applyToPlayer(p), same(p));
    });

    test('antrenman seti haftalık kazancı artırır', () {
      double gain(Equipment eq) {
        final s = career().copyWith(equipment: eq);
        final r = WeekEngine.advance(
          s,
          const WeeklyPlan(),
          null,
          GameRandom(5),
        );
        return r.report.attributeGains.fold(0.0, (a, g) => a + g.delta);
      }

      final plain = gain(const Equipment());
      final kit = gain(const Equipment({'trainingKit': 3}));
      expect(plain, greaterThan(0));
      expect(
        kit,
        closeTo(plain * (1 + 3 * ClubBalance.trainingKitPerLevel), 1e-6),
      );
    });

    test('çarpanlar ekipmansızken nötr', () {
      const e = Equipment();
      expect(e.trainingMultiplier, 1);
      expect(e.injuryMultiplier, 1);
      expect(e.recoveryBonus, 0);
      expect(e.bootsBonus, 0);
      const full = Equipment({'shinGuards': 3, 'recoveryKit': 3});
      expect(full.injuryMultiplier, lessThan(1));
      expect(full.recoveryBonus, greaterThan(0));
    });
  });
}
