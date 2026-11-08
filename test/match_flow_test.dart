import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/l10n/app_localizations.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/match/match_screen.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<void> pumpMatch(WidgetTester tester, int seed) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  container
      .read(activeCareerProvider.notifier)
      .open(
        0,
        CareerState(
          player: PlayerFactory.create(
            name: 'Test',
            birthplace: 'Ankara',
            position: PlayerPosition.forward,
            foot: PreferredFoot.right,
            appearance: const Appearance(),
            random: GameRandom(1),
          ),
        ),
      );

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('tr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MatchScreen(key: ValueKey(seed), seed: seed),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('hızlı simülasyon doğrudan maç özetine götürür', (tester) async {
    await pumpMatch(tester, 1);
    expect(find.text('Hazırlık Maçı'), findsOneWidget);

    await tester.tap(find.text('Hızlı Simüle Et'));
    await tester.pumpAndSettle();

    expect(find.text('Maç Sonu'), findsOneWidget);
    expect(find.text('Oyuncu Reytingi'), findsOneWidget);
    expect(find.text('Ana Sayfaya Dön'), findsOneWidget);
  });

  testWidgets('an adım adım ilerler ve özete ulaşır', (tester) async {
    await pumpMatch(tester, 2);
    await tester.tap(find.text('Maça Başla'));
    await tester.pumpAndSettle();

    var guard = 0;
    while (find.text('Maç Sonu').evaluate().isEmpty && guard++ < 20) {
      expect(find.textContaining('. dakika'), findsOneWidget);
      if (find.text('Otomatik Çöz').evaluate().isNotEmpty) {
        await tester.tap(find.text('Otomatik Çöz'));
      } else {
        // Şut anı: mini oyunu oynamadan kalanı hızlı simüle et.
        await tester.tap(find.text('Kalanı Hızlı Simüle Et'));
      }
      await tester.pumpAndSettle();
      if (find.text('Devam').evaluate().isNotEmpty) {
        await tester.tap(find.text('Devam'));
        await tester.pumpAndSettle();
      }
    }
    expect(find.text('Maç Sonu'), findsOneWidget);
  });

  testWidgets('şut anında "Oyna" Flame oyununu açar', (tester) async {
    // İlk anı şut olan bir seed bul.
    var found = false;
    for (var seed = 0; seed < 80 && !found; seed++) {
      await pumpMatch(tester, seed);
      await tester.tap(find.text('Maça Başla'));
      await tester.pumpAndSettle();
      found = find.text('Oyna').evaluate().isNotEmpty;
    }
    expect(found, isTrue, reason: 'şut anı olan bir seed bulunamadı');

    await tester.tap(find.text('Oyna'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byWidgetPredicate((w) => w is GameWidget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
