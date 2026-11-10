import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/game/sound_service.dart';
import 'package:son_dusuk/presentation/providers.dart';

class _FakeSound extends SoundService {
  final played = <Sfx>[];

  @override
  Future<void> play(Sfx sfx) async => played.add(sfx);
}

void main() {
  test('her ses efektinin geçerli bir WAV dosyası var', () {
    for (final sfx in Sfx.values) {
      final file = File('assets/sounds/${sfx.name}.wav');
      expect(file.existsSync(), isTrue, reason: '${sfx.name}.wav yok');
      final bytes = file.readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
      expect(bytes.length, greaterThan(2000));
      expect(bytes.length, lessThan(100000), reason: 'ses dosyası şişmiş');
    }
  });

  test('pubspec ses klasörünü asset olarak tanımlar', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/sounds/'));
  });

  Future<List<Sfx>> run(WidgetTester tester, {required bool soundOn}) async {
    SharedPreferences.setMockInitialValues({'settings_sound': soundOn});
    final prefs = await SharedPreferences.getInstance();
    final fake = _FakeSound();
    late WidgetRef captured;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          soundServiceProvider.overrideWithValue(fake),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) {
              captured = ref;
              return const SizedBox();
            },
          ),
        ),
      ),
    );
    captured.playSfx(Sfx.goal);
    captured.playSfx(Sfx.buy);
    return fake.played;
  }

  testWidgets('ses açıkken efekt çalar', (tester) async {
    expect(await run(tester, soundOn: true), [Sfx.goal, Sfx.buy]);
  });

  testWidgets('ses kapalıyken hiçbir şey çalmaz', (tester) async {
    expect(await run(tester, soundOn: false), isEmpty);
  });
}
