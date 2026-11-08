import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/app/router.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/achievements/achievements.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/season_record.dart';
import 'package:son_dusuk/domain/national/national_career.dart';
import 'package:son_dusuk/domain/national/national_engine.dart';
import 'package:son_dusuk/domain/player/attribute.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/providers.dart';

CareerState baseCareer({int age = 26, int overall = 90}) {
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
  return base.copyWith(
    player: base.player.copyWith(
      age: age,
      attributes: base.player.attributes.copyWith({
        for (final a in Attribute.values) a: overall.toDouble(),
      }),
    ),
  );
}

Future<ProviderContainer> pumpAt(
  WidgetTester tester,
  CareerState career,
  String route, {
  Size size = const Size(800, 3000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  await container.read(activeCareerProvider.notifier).start(0, career);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  container.read(routerProvider).go(route);
  await tester.pumpAndSettle();
  return container;
}

TournamentRun calledRun(int season, {List<NationalMatchRecord>? results}) =>
    TournamentRun(
      season: season,
      kind: NationalEngine.kindOf(season),
      called: true,
      role: NationalRole.starter,
      results: results ?? const [],
    );

void main() {
  testWidgets('milli takım ekranı: boş durum sıradaki turnuvayı söyler', (
    tester,
  ) async {
    await pumpAt(tester, baseCareer(), '/game/national');
    expect(find.text('Milli Takım'), findsOneWidget);
    expect(find.text('Anatolya'), findsOneWidget);
    expect(find.textContaining('Sıradaki turnuva: Kıtalar Kupası'), findsOne);
    expect(find.textContaining('Henüz milli takım geçmişin yok'), findsOne);
  });

  testWidgets('milli takım ekranı: eşleşme tablosu ve geçmiş turnuvalar', (
    tester,
  ) async {
    final career = baseCareer().copyWith(
      season: 6,
      week: 40,
      national: NationalCareer(
        caps: 1,
        goals: 1,
        current: calledRun(
          6,
          results: const [
            NationalMatchRecord(
              round: 0,
              opponentId: 'n_0',
              scoreFor: 2,
              scoreAgainst: 0,
              played: true,
              playerGoals: 1,
            ),
          ],
        ),
        past: const [
          TournamentRecord(
            season: 4,
            kind: TournamentKind.world,
            called: true,
            stage: TournamentStage.champion,
            appearances: 3,
            goals: 2,
          ),
        ],
      ),
    );
    await pumpAt(tester, career, '/game/national');

    expect(find.text('Eşleşmeler'), findsOneWidget);
    expect(find.textContaining('Kadrodasın'), findsOneWidget);
    expect(find.text('Son 16 · Hafta 39'), findsOneWidget);
    expect(find.text('Final · Hafta 42'), findsOneWidget);
    expect(find.text('Oynadın'), findsOneWidget);
    expect(find.text('Geçmiş Turnuvalar'), findsOneWidget);
    expect(find.textContaining('Dünya Kupası · Sezon 4'), findsOneWidget);
    expect(find.textContaining('Şampiyon oldu'), findsOneWidget);
  });

  testWidgets('başarımlar ekranı: sayaç ve açılan başarım', (tester) async {
    final career = baseCareer().copyWith(achievements: {'firstGoal': 3});
    await pumpAt(tester, career, '/game/achievements');
    expect(find.text('Başarımlar'), findsOneWidget);
    expect(find.text('1 / ${Achievement.values.length}'), findsOneWidget);
    expect(find.text('Ağlar Sallandı'), findsOneWidget);
    expect(find.text('Kilitli'), findsNothing); // simge olarak gösterilir
  });

  testWidgets('profil: genç oyuncu emekli olamaz', (tester) async {
    await pumpAt(tester, baseCareer(age: 24), '/game/profile');
    expect(
      find.text('Emekli olmak için en az 30 yaşında olmalısın.'),
      findsOneWidget,
    );
    // OutlinedButton.icon özel bir alt sınıf üretir; türe göre aranır.
    final button = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Futbolu Bırak'),
        matching: find.byWidgetPredicate((w) => w is OutlinedButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('profil: emekli ol -> onay -> kariyer özeti', (tester) async {
    final career = baseCareer(age: 33).copyWith(
      history: const [
        SeasonRecord(
          season: 1,
          age: 32,
          overall: 88,
          clubId: 't5_0',
          tier: 5,
          position: 1,
          matches: 30,
          goals: 12,
          assists: 5,
          averageRating: 6.9,
        ),
      ],
    );
    final container = await pumpAt(tester, career, '/game/profile');

    await tester.ensureVisible(find.text('Futbolu Bırak'));
    await tester.tap(find.text('Futbolu Bırak'));
    await tester.pumpAndSettle();
    expect(find.text('Futbolu bırakıyor musun?'), findsOneWidget);

    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(container.read(activeCareerProvider)!.state.retired, isFalse);

    await tester.ensureVisible(find.text('Futbolu Bırak'));
    await tester.tap(find.text('Futbolu Bırak'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Evet, bırak'));
    await tester.pumpAndSettle();

    expect(container.read(activeCareerProvider)!.state.retired, isTrue);
    expect(
      container.read(saveRepositoryProvider).load(0)!.retired,
      isTrue,
      reason: 'kalıcı kayıt',
    );
    expect(find.text('Kariyer Özeti'), findsOneWidget);
    expect(find.text('33 yaşında futbolu bıraktı'), findsOneWidget);
    expect(find.text('Miras'), findsOneWidget);
    expect(find.text('Sezon Sezon'), findsOneWidget);
    expect(find.text('Sezon 1 · 32 yaş'), findsOneWidget);

    await tester.ensureVisible(find.text('Ana Menüye Dön'));
    await tester.tap(find.text('Ana Menüye Dön'));
    await tester.pumpAndSettle();
    expect(find.text('Emekli · 33 yaş · Zirve 90'), findsOneWidget);
  });

  testWidgets('emekli kariyerde oyun rotaları kariyer özetine yönlenir', (
    tester,
  ) async {
    final career = baseCareer(age: 35).copyWith(retired: true);
    await pumpAt(tester, career, '/game/training');
    expect(find.text('Kariyer Özeti'), findsOneWidget);
    expect(find.text('Haftayı Planla'), findsNothing);
  });

  testWidgets('milli maç: kadrodaysan maç ekranı turnuva maçını oynatır', (
    tester,
  ) async {
    // Bu sezon ilk 11'de olduğun bir turnuva haftası bul.
    CareerState? career;
    for (final season in [4, 6, 8, 10, 12, 14]) {
      final c = baseCareer().copyWith(
        season: season,
        week: 39,
        national: NationalCareer(current: calledRun(season)),
      );
      if (NationalEngine.dayOf(c) == NationalDay.play) {
        career = c;
        break;
      }
    }
    expect(career, isNotNull, reason: 'oynanan bir hafta bulunamadı');

    final container = await pumpAt(tester, career!, '/game/training');
    expect(find.text('Milli Maçı Oyna'), findsOneWidget);
    expect(find.textContaining('Bu hafta milli maç var'), findsOneWidget);

    await tester.tap(find.text('Milli Maçı Oyna'));
    await tester.pumpAndSettle();
    expect(find.text('Milli Maç · Son 16'), findsOneWidget);
    expect(
      find.text('Eleme maçı: beraberlikte penaltılara gidilir.'),
      findsOne,
    );

    await tester.tap(find.text('Hızlı Simüle Et'));
    await tester.pumpAndSettle();
    expect(find.text('Maç Sonu'), findsOneWidget);
    // Berabere biten maçın bir kazananı olmalı (penaltılar).
    expect(
      find.textContaining('Penaltılarda').evaluate().isNotEmpty ||
          find.text('Galibiyet').evaluate().isNotEmpty ||
          find.text('Mağlubiyet').evaluate().isNotEmpty,
      isTrue,
    );

    await tester.tap(find.text('Haftayı Bitir'));
    await tester.pumpAndSettle();

    final after = container.read(activeCareerProvider)!.state;
    expect(after.national.caps, 1);
    expect(after.national.current!.results.single.played, isTrue);
    expect(after.week, 40);
    expect(find.textContaining('Son 16: Anatolya'), findsOneWidget);
  });

  testWidgets('dar telefon ekranında yeni ekranlar taşmaz', (tester) async {
    final career = baseCareer(age: 34).copyWith(
      season: 6,
      week: 41,
      retired: true,
      achievements: {'firstGoal': 3, 'worldChampion': 9},
      history: [
        for (var i = 1; i <= 3; i++)
          SeasonRecord(
            season: i,
            age: 30 + i,
            overall: 80,
            clubId: 't1_0',
            tier: 1,
            position: i,
            matches: 30,
            goals: 12,
            assists: 5,
            averageRating: 7.1,
          ),
      ],
      national: NationalCareer(
        caps: 12,
        goals: 5,
        current: calledRun(
          6,
          results: const [
            NationalMatchRecord(
              round: 0,
              opponentId: 'n_0',
              scoreFor: 1,
              scoreAgainst: 1,
              pensFor: 4,
              pensAgainst: 3,
              played: true,
            ),
          ],
        ),
        past: const [
          TournamentRecord(
            season: 4,
            kind: TournamentKind.world,
            called: false,
            stage: TournamentStage.roundOf16,
          ),
        ],
      ),
    );
    final container = await pumpAt(
      tester,
      career,
      '/game/summary',
      size: const Size(360, 740),
    );
    expect(tester.takeException(), isNull);
    final router = container.read(routerProvider);
    for (final route in ['/game/national', '/game/achievements']) {
      router.go(route);
      await tester.pumpAndSettle();
      // Emekli kayıt yalnızca özet/başarım/hafta rotalarını açar; milli takım
      // ekranı özete yönlenir, bu yüzden yalnızca istisnasızlığı denetliyoruz.
      expect(tester.takeException(), isNull, reason: route);
    }
  });

  testWidgets('dar ekranda milli takım, başarım ve özet ekranları taşmaz', (
    tester,
  ) async {
    final career = baseCareer(age: 34).copyWith(
      season: 6,
      week: 41,
      achievements: {'firstGoal': 3, 'worldChampion': 9},
      national: NationalCareer(
        caps: 12,
        goals: 5,
        current: calledRun(
          6,
          results: const [
            NationalMatchRecord(
              round: 0,
              opponentId: 'n_0',
              scoreFor: 1,
              scoreAgainst: 1,
              pensFor: 4,
              pensAgainst: 3,
              played: true,
            ),
          ],
        ),
        past: const [
          TournamentRecord(
            season: 4,
            kind: TournamentKind.world,
            called: false,
            stage: TournamentStage.roundOf16,
          ),
        ],
      ),
    );
    final container = await pumpAt(
      tester,
      career,
      '/game/national',
      size: const Size(360, 740),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Eşleşmeler'), findsOneWidget);
    final router = container.read(routerProvider);
    for (final route in ['/game/achievements', '/game/summary']) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
  });
}
