import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/app/router.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/club/contract.dart';
import 'package:son_dusuk/domain/club/finance.dart';
import 'package:son_dusuk/domain/club/transfer_offer.dart';
import 'package:son_dusuk/domain/league/club_world.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<ProviderContainer> pumpClub(
  WidgetTester tester, {
  CareerState Function(CareerState base, ClubWorld world)? setup,
}) async {
  tester.view.physicalSize = const Size(800, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  var career = CareerFactory.create(
    PlayerFactory.create(
      name: 'Deniz',
      birthplace: 'Bursa',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: GameRandom(1),
    ),
    GameRandom(1),
  ).copyWith(week: 8);
  if (setup != null) career = setup(career, ClubWorld(career.worldSeed));
  await container.read(activeCareerProvider.notifier).start(0, career);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  container.read(routerProvider).go('/game/club');
  await tester.pumpAndSettle();
  return container;
}

TransferOffer offerFrom(
  ClubWorld world, {
  int wage = 2000,
  int maxWage = 2400,
  int tier = 4,
}) => TransferOffer(
  kind: OfferKind.transfer,
  clubId: world.leagues[tier - 1].teams.first.id,
  weeklyWage: wage,
  maxWage: maxWage,
  years: 3,
  role: SquadRole.starter,
  expiresAt: 200,
);

void main() {
  testWidgets('kulüp sekmesi: sözleşme, tablo, finans ve menajer görünür', (
    tester,
  ) async {
    await pumpClub(tester);
    expect(find.text('Sözleşme'), findsOneWidget);
    expect(find.text('Maaş'), findsOneWidget);
    expect(find.text('Teklifler'), findsOneWidget);
    expect(find.text('Şu an bekleyen teklif yok.'), findsOneWidget);
    expect(find.text('Menajer'), findsOneWidget);
    expect(find.text('Finans'), findsOneWidget);
    expect(find.text('Bakiye'), findsOneWidget);
    expect(find.text('Lig Tablosu'), findsOneWidget);
  });

  testWidgets('teklifi kabul etmek kulübü değiştirir ve imza parası verir', (
    tester,
  ) async {
    late TransferOffer offer;
    final container = await pumpClub(
      tester,
      setup: (base, world) {
        offer = offerFrom(world);
        return base.copyWith(offers: [offer]);
      },
    );
    final before = container.read(activeCareerProvider)!.state;

    await tester.ensureVisible(find.text('Kabul Et'));
    await tester.tap(find.text('Kabul Et'));
    await tester.pumpAndSettle();

    final after = container.read(activeCareerProvider)!.state;
    expect(after.contract!.clubId, offer.clubId);
    expect(after.contract!.weeklyWage, 2000);
    expect(after.offers, isEmpty);
    expect(after.finance.balance, before.finance.balance + 2000 * 8);
    expect(find.textContaining('ile imzaladın!'), findsOneWidget);
    // Kalıcı kayıt
    expect(
      container.read(saveRepositoryProvider).load(0)!.contract!.clubId,
      offer.clubId,
    );
  });

  testWidgets('teklifi reddetmek listeden kaldırır', (tester) async {
    final container = await pumpClub(
      tester,
      setup: (base, world) => base.copyWith(offers: [offerFrom(world)]),
    );
    await tester.ensureVisible(find.text('Reddet'));
    await tester.tap(find.text('Reddet'));
    await tester.pumpAndSettle();
    expect(container.read(activeCareerProvider)!.state.offers, isEmpty);
    expect(find.text('Şu an bekleyen teklif yok.'), findsOneWidget);
  });

  testWidgets(
    'pazarlık: en yüksek istek üst sınırı aşarsa karşı teklif gelir',
    (tester) async {
      // maxWage 2100, istek: 2000 * 1.4 = 2800 > 2100 * 1.12 -> kulüp çekilir.
      final container = await pumpClub(
        tester,
        setup: (base, world) =>
            base.copyWith(offers: [offerFrom(world, maxWage: 2100)]),
      );
      await tester.ensureVisible(find.text('Pazarlık Et'));
      await tester.tap(find.text('Pazarlık Et'));
      await tester.pumpAndSettle();
      expect(find.text('Maaş pazarlığı'), findsOneWidget);

      // Kaydırıcıyı sonuna çek.
      await tester.drag(find.byType(Slider), const Offset(600, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Teklif Et'));
      await tester.pumpAndSettle();

      expect(find.textContaining('teklifi geri çekti'), findsOneWidget);
      expect(container.read(activeCareerProvider)!.state.offers, isEmpty);
    },
  );

  testWidgets('pazarlık: makul istek kabul edilir', (tester) async {
    final container = await pumpClub(
      tester,
      setup: (base, world) =>
          base.copyWith(offers: [offerFrom(world, maxWage: 3000)]),
    );
    await tester.ensureVisible(find.text('Pazarlık Et'));
    await tester.tap(find.text('Pazarlık Et'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(600, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Teklif Et'));
    await tester.pumpAndSettle();

    final c = container.read(activeCareerProvider)!.state.contract!;
    expect(c.weeklyWage, 2800, reason: '2000 + %40');
  });

  testWidgets('menajer tut ve bırak, yaşam tarzı seç', (tester) async {
    final container = await pumpClub(tester);
    final notifier = container.read(activeCareerProvider.notifier);

    await tester.ensureVisible(find.text('Amatör menajer'));
    await tester.tap(find.text('Anlaş').first);
    await tester.pumpAndSettle();
    expect(container.read(activeCareerProvider)!.state.agent!.level, 1);
    expect(find.text('Ayrıl'), findsOneWidget);

    await tester.ensureVisible(find.text('Rahat'));
    await tester.tap(find.text('Rahat'));
    await tester.pumpAndSettle();
    expect(
      container.read(activeCareerProvider)!.state.finance.lifestyle,
      Lifestyle.comfortable,
    );

    await tester.ensureVisible(find.text('Ayrıl'));
    await tester.tap(find.text('Ayrıl'));
    await tester.pumpAndSettle();
    expect(container.read(activeCareerProvider)!.state.agent, isNull);
    expect(notifier, isNotNull);
  });

  testWidgets('serbest oyuncu uyarısı görünür ve antrenmanda maç yok', (
    tester,
  ) async {
    await pumpClub(
      tester,
      setup: (base, world) => base.copyWith(clearContract: true, week: 10),
    );
    expect(find.text('Serbest oyuncusun'), findsOneWidget);
    expect(find.text('Lig Tablosu'), findsNothing);
  });
}
