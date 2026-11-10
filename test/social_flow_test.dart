import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/app/router.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/social/event_models.dart';
import 'package:son_dusuk/domain/social/relationships.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<ProviderContainer> pumpSocial(
  WidgetTester tester, {
  List<String> events = const [],
  String route = '/game/social',
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

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
  ).copyWith(week: 10);
  final career = base.copyWith(
    pendingEvents: [
      for (final id in events)
        PendingEvent(
          id: id,
          createdAt: base.absoluteWeek,
          expiresAt: base.absoluteWeek + 3,
          params: const {'opponent': 'Rakip SK', 'score': '2-1'},
        ),
    ],
  );
  await container.read(activeCareerProvider.notifier).start(0, career);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  container.read(routerProvider).go(route);
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('boş sosyal sekmesi: ilişkiler ve boş durum görünür', (
    tester,
  ) async {
    await pumpSocial(tester);
    expect(find.text('Cevap bekleyenler'), findsOneWidget);
    expect(
      find.textContaining('cevap bekleyen bir gelişme yok'),
      findsOneWidget,
    );
    expect(find.text('İlişkiler'), findsOneWidget);
    for (final n in [
      'Teknik direktör',
      'Takım arkadaşları',
      'Taraftar',
      'Aile',
      'Medya',
    ]) {
      expect(find.text(n), findsOneWidget);
    }
    expect(find.text('Haber akışı'), findsOneWidget);
    expect(find.text('Henüz haber yok.'), findsOneWidget);
  });

  testWidgets('bekleyen olay rozet olarak görünür ve karta basınca açılır', (
    tester,
  ) async {
    await pumpSocial(tester, events: ['fanMeet']);
    expect(find.text('Taraftar buluşması'), findsOneWidget);
    expect(find.text('1'), findsWidgets, reason: 'rozet');

    await tester.tap(find.text('Taraftar buluşması'));
    await tester.pumpAndSettle();
    expect(find.textContaining('kapıda onlarca taraftar'), findsOneWidget);
    expect(find.text('Durup herkesle fotoğraf çektir.'), findsOneWidget);
  });

  testWidgets('seçim yapınca sonuç görünür, etkiler uygulanır, olay düşer', (
    tester,
  ) async {
    final container = await pumpSocial(
      tester,
      events: ['fanMeet'],
      route: '/game/event/fanMeet',
    );
    final before = container.read(activeCareerProvider)!.state;

    await tester.tap(find.text('Durup herkesle fotoğraf çektir.'));
    await tester.pumpAndSettle();

    expect(find.text('Sonuç'), findsOneWidget);
    expect(find.textContaining('Taraftarlar bu ilgiyi'), findsOneWidget);
    expect(find.text('Taraftar'), findsOneWidget);
    expect(find.text('+6'), findsOneWidget);

    final after = container.read(activeCareerProvider)!.state;
    expect(after.pendingEvents, isEmpty);
    expect(after.relations[Relation.fans], before.relations[Relation.fans] + 6);
    expect(after.news.first.kind, NewsKind.event);
    // Kalıcı kayıt
    expect(
      container.read(saveRepositoryProvider).load(0)!.pendingEvents,
      isEmpty,
    );

    await tester.tap(find.text('Tamam'));
    await tester.pumpAndSettle();
    expect(find.text('Haber akışı'), findsOneWidget);
    expect(find.textContaining('Taraftar buluşması:'), findsOneWidget);
  });

  testWidgets('riskli seçenek "Riskli" etiketi taşır', (tester) async {
    await pumpSocial(
      tester,
      events: ['partyInvite'],
      route: '/game/event/partyInvite',
    );
    expect(find.text('Riskli'), findsOneWidget);
    expect(
      find.text('Medya'),
      findsOneWidget,
      reason: 'etkilenen alan etiketi',
    );
  });

  testWidgets('basın toplantısı rakip ve skoru gösterir', (tester) async {
    await pumpSocial(
      tester,
      events: ['pressWin'],
      route: '/game/event/pressWin',
    );
    expect(find.textContaining('Rakip SK karşısında 2-1'), findsOneWidget);
    expect(find.text('Röportaj'), findsOneWidget);
  });

  testWidgets('röportaj: muhabir sorusu, ton etiketleri, gazete manşeti', (
    tester,
  ) async {
    await pumpSocial(
      tester,
      events: ['pressFood'],
      route: '/game/event/pressFood',
    );
    expect(find.text('Muhabir'), findsOneWidget);
    expect(find.text('Menüde ne vardı?'), findsOneWidget);
    expect(find.text('Cevabını seç'), findsOneWidget);
    // Her cevapta tavır rozeti.
    expect(find.text('Dürüst'), findsOneWidget);
    expect(find.text('Komik'), findsOneWidget);
    expect(find.text('Havalı'), findsOneWidget);

    await tester.tap(find.textContaining('Şampiyonların yemeği'));
    await tester.pumpAndSettle();

    expect(find.text('GÜNÜN GAZETESİ'), findsOneWidget);
    expect(find.text('SIR YEMEK GÜNDEMDE!'), findsOneWidget);
    expect(find.text('Gizemli cevabın bütün gün konuşuldu.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('olmayan olay açılırsa sosyal sekmesine döner', (tester) async {
    await pumpSocial(tester, route: '/game/event/fanMeet');
    expect(find.text('Cevap bekleyenler'), findsOneWidget);
  });

  testWidgets('ana sayfada bekleyen olay kartı çıkar', (tester) async {
    await pumpSocial(tester, events: ['fanMeet', 'charity'], route: '/game');
    expect(find.text('2 gelişme cevap bekliyor'), findsOneWidget);
  });

  testWidgets('dar telefon ekranında taşma olmaz (sosyal, olay, sonuç)', (
    tester,
  ) async {
    final container = await pumpSocial(tester, events: ['pressWin', 'charity']);
    tester.view.physicalSize = const Size(360, 740);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final id in ['pressWin', 'partyInvite', 'sponsorOffer']) {
      container.read(routerProvider).go('/game/event/$id');
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: id);
    }
    // Olmayan olaylar sosyal sekmesine döner; sonuç ekranını da dene.
    container.read(routerProvider).go('/game/event/pressWin');
    await tester.pumpAndSettle();
    final first = find.byType(InkWell).evaluate().isNotEmpty;
    expect(first, isTrue);
    await tester.tap(find.textContaining('Bu takımın başarısı'));
    await tester.pumpAndSettle();
    expect(find.text('Tamam'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
