import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/providers.dart';

void main() {
  test(
    'CareerStats penaltı bölgeleri JSON gidiş-dönüş ve eski kayıt uyumu',
    () {
      final stats = const CareerStats()
          .addPenalty(2)
          .addPenalty(2)
          .addPenalty(5);
      expect(stats.penaltyZones, [0, 0, 2, 0, 0, 1]);

      final back = CareerStats.fromJson(
        jsonDecode(jsonEncode(stats.toJson())) as Map<String, dynamic>,
      );
      expect(back.penaltyZones, [0, 0, 2, 0, 0, 1]);

      // Anahtarı olmayan eski kayıt: sıfırlarla başlar.
      expect(CareerStats.fromJson({'matches': 3}).penaltyZones, hasLength(6));
      expect(
        CareerStats.fromJson({
          'penaltyZones': [1, 2],
        }).penaltyZones,
        [1, 2, 0, 0, 0, 0],
      );
    },
  );

  test('recordPenalty bölgeyi kalıcı kaydeder', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(activeCareerProvider.notifier);
    await notifier.start(
      0,
      CareerState(
        player: PlayerFactory.create(
          name: 'T',
          birthplace: 'Ankara',
          position: PlayerPosition.forward,
          foot: PreferredFoot.right,
          appearance: const Appearance(),
          random: GameRandom(1),
        ),
      ),
    );
    await notifier.recordPenalty(4);
    await notifier.recordPenalty(4);

    final saved = container.read(saveRepositoryProvider).load(0)!;
    expect(saved.stats.penaltyZones[4], 2);
    expect(
      container.read(activeCareerProvider)!.state.stats.penaltyZones[4],
      2,
    );
  });
}
