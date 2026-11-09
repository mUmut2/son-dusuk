import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_migrations.dart';
import 'package:son_dusuk/data/save_repository.dart';
import 'package:son_dusuk/data/settings_repository.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';

CareerState career(String name) => CareerState(
  player: PlayerFactory.create(
    name: name,
    birthplace: 'İzmir',
    position: PlayerPosition.winger,
    foot: PreferredFoot.left,
    appearance: const Appearance(skinTone: 2),
    random: GameRandom(1),
  ),
);

Future<SaveRepository> repo([SaveMigrator? migrator]) async {
  SharedPreferences.setMockInitialValues({});
  return SaveRepository(
    await SharedPreferences.getInstance(),
    migrator: migrator,
  );
}

void main() {
  test('3 slot başta boş', () async {
    final r = await repo();
    expect(r.slots().map((s) => s.status), everyElement(SlotStatus.empty));
    expect(r.slots(), hasLength(3));
  });

  test('kaydet / yükle / sil', () async {
    final r = await repo();
    await r.save(1, career('Ali'));
    expect(r.load(1)!.player.name, 'Ali');
    expect(r.load(0), isNull);
    expect(r.slots()[1].status, SlotStatus.ok);
    expect(r.slots()[1].savedAt, isNotNull);

    await r.delete(1);
    expect(r.load(1), isNull);
  });

  test('slotlar birbirinden bağımsız, deleteAll hepsini siler', () async {
    final r = await repo();
    await r.save(0, career('A'));
    await r.save(2, career('B'));
    expect(r.load(0)!.player.name, 'A');
    expect(r.load(2)!.player.name, 'B');
    await r.deleteAll();
    expect(r.slots().map((s) => s.status), everyElement(SlotStatus.empty));
  });

  test('geçersiz slot hata verir', () async {
    final r = await repo();
    expect(() => r.load(3), throwsRangeError);
  });

  test('bozuk kayıt corrupt olarak işaretlenir, uygulama çökmez', () async {
    SharedPreferences.setMockInitialValues({'save_slot_0': '{bozuk json'});
    final r = SaveRepository(await SharedPreferences.getInstance());
    expect(r.slots()[0].status, SlotStatus.corrupt);
    expect(() => r.load(0), throwsA(isA<SaveException>()));
  });

  test('daha yeni sürümden kayıt reddedilir', () async {
    SharedPreferences.setMockInitialValues({
      'save_slot_0': jsonEncode({
        'schemaVersion': 99,
        'career': career('X').toJson(),
      }),
    });
    final r = SaveRepository(await SharedPreferences.getInstance());
    expect(r.slots()[0].status, SlotStatus.corrupt);
  });

  test('eski sürüm kayıt göç adımıyla yükseltilir', () async {
    final v2 = SaveMigrator(
      currentVersion: 2,
      steps: {
        1: (e) => {
          ...e,
          'career': {...(e['career'] as Map<String, dynamic>), 'season': 7},
        },
      },
    );
    SharedPreferences.setMockInitialValues({
      'save_slot_0': jsonEncode({
        'schemaVersion': 1,
        'career': career('Eski').toJson(),
      }),
    });
    final r = SaveRepository(
      await SharedPreferences.getInstance(),
      migrator: v2,
    );
    expect(r.load(0)!.season, 7);
  });

  test('ayarlar varsayılanla başlar ve kalıcı olur', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final s = SettingsRepository(prefs);
    // Çocuk dostu: varsayılan zorluk kolay.
    expect(s.load().difficulty, Difficulty.easy);
    expect(s.load().soundOn, isTrue);

    await s.save(
      const GameSettings(soundOn: false, difficulty: Difficulty.hard),
    );
    final loaded = SettingsRepository(prefs).load();
    expect(loaded.soundOn, isFalse);
    expect(loaded.difficulty, Difficulty.hard);
  });
}
