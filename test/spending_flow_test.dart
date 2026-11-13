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
import 'package:son_dusuk/domain/spending/spending_models.dart';
import 'package:son_dusuk/game/sound_service.dart';
import 'package:son_dusuk/presentation/providers.dart';

class _NoSound extends SoundService {
  @override
  Future<void> play(Sfx sfx) async {}
}

Future<ProviderContainer> pumpSpending(
  WidgetTester tester, {
  int week = 10,
  int balance = 100000,
  Spending spending = const Spending(),
  String route = '/game/spending',
  Size size = const Size(800, 2400),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      soundServiceProvider.overrideWithValue(_NoSound()),
    ],
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
  ).copyWith(week: week);
  final career = base.copyWith(
    spending: spending,
    finance: base.finance.copyWith(balance: balance),
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
  testWidgets('ana sayfada harcama kartı çıkar ve ekranı açar', (tester) async {
    await pumpSpending(tester, route: '/game');
    expect(find.text('Harcama ve Şans Köşesi'), findsOneWidget);
    await tester.tap(find.text('Harcama ve Şans Köşesi'));
    await tester.pumpAndSettle();
    expect(find.text('Mülkler'), findsOneWidget);
    expect(find.text('Şans Köşesi'), findsOneWidget);
  });

  testWidgets('mülk satın alınır: bakiye düşer, "Sahipsin" görünür', (
    tester,
  ) async {
    final c = await pumpSpending(tester);
    expect(find.text('Saat'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Satın al').first);
    await tester.pumpAndSettle();
    final career = c.read(activeCareerProvider)!.state;
    expect(career.spending.owns(Property.watch), isTrue);
    expect(career.finance.balance, lessThan(100000));
    expect(find.text('Sahipsin'), findsOneWidget);
    expect(find.text('Satın aldın!'), findsOneWidget);
  });

  testWidgets('parası yetmeyen mülk düğmesi kapalı', (tester) async {
    await pumpSpending(tester, balance: 100);
    final buttons = tester.widgetList<FilledButton>(
      find.widgetWithText(FilledButton, 'Satın al'),
    );
    expect(buttons, isNotEmpty);
    for (final b in buttons) {
      expect(b.onPressed, isNull);
    }
  });

  testWidgets('kupondan bahis yapılır, alışkanlık ve bakiye değişir', (
    tester,
  ) async {
    final c = await pumpSpending(tester);
    expect(find.text('Haftanın kuponu'), findsOneWidget);
    await tester.ensureVisible(find.text('Beraberlik').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Beraberlik').first);
    await tester.pumpAndSettle();
    final career = c.read(activeCareerProvider)!.state;
    expect(career.spending.bets, hasLength(1));
    expect(career.spending.bets.first.pick, BetPick.draw);
    expect(career.spending.habit, greaterThan(0));
    expect(career.finance.balance, lessThan(100000));
    expect(find.text('Bu maça bahis yaptın'), findsOneWidget);
  });

  testWidgets('hazırlık haftasında kupon yok', (tester) async {
    await pumpSpending(tester, week: 2);
    await tester.scrollUntilVisible(
      find.textContaining('Bu hafta kupon yok'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Bu hafta kupon yok'), findsOneWidget);
  });

  testWidgets('ceza durumunda kadro dışı uyarısı ve kritik düzey görünür', (
    tester,
  ) async {
    await pumpSpending(
      tester,
      spending: const Spending(habit: 90, suspendedWeeks: 2, totalStaked: 500),
    );
    await tester.scrollUntilVisible(
      find.text('Kadro dışısın: 2 hafta'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Kadro dışısın: 2 hafta'), findsOneWidget);
    expect(find.text('Kritik'), findsOneWidget);
  });

  testWidgets('dar telefon ekranında taşma olmaz', (tester) async {
    await pumpSpending(
      tester,
      size: const Size(320, 568),
      spending: const Spending(habit: 50, totalStaked: 1234),
    );
    expect(tester.takeException(), isNull);
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 6; i++) {
      await tester.drag(list, const Offset(0, -500));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });

  group('at yarışı ekranı', () {
    testWidgets('altı at listelenir, at seçmeden başlatılamaz', (tester) async {
      await pumpSpending(tester, route: '/game/race');
      expect(find.text('At Yarışı'), findsOneWidget);
      expect(find.textContaining('Form:'), findsNWidgets(6));
      expect(find.text('Önce bir at seç'), findsOneWidget);
      final button = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Önce bir at seç'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('bahissiz izleme: yarış oynanır, sonuç görünür, para aynı', (
      tester,
    ) async {
      final c = await pumpSpending(tester, route: '/game/race');
      await tester.tap(find.textContaining('Form:').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yarışı başlat'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      expect(find.textContaining('Önde:'), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.text('Varış sırası'), findsOneWidget);
      final career = c.read(activeCareerProvider)!.state;
      expect(career.finance.balance, 100000);
      expect(career.spending.raceWeek, career.absoluteWeek);
      expect(career.spending.habit, 0);
    });

    testWidgets('bahisli izleme parayı etkiler ve alışkanlığı artırır', (
      tester,
    ) async {
      final c = await pumpSpending(tester, route: '/game/race');
      await tester.tap(find.textContaining('Form:').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2.000 ₺'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yarışı başlat'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 12));
      await tester.pumpAndSettle();

      final career = c.read(activeCareerProvider)!.state;
      expect(career.spending.totalStaked, 2000);
      expect(career.spending.habit, greaterThan(0));
      expect(find.text('Varış sırası'), findsOneWidget);
    });

    testWidgets('aynı hafta ikinci yarış yok', (tester) async {
      await pumpSpending(
        tester,
        route: '/game/race',
        spending: const Spending(raceWeek: 10),
      );
      expect(find.textContaining('Bu hafta yarışı izledin'), findsOneWidget);
      expect(find.text('Yarışı başlat'), findsNothing);
    });

    testWidgets('harcama ekranından yarışa gidilir', (tester) async {
      await pumpSpending(tester);
      await tester.ensureVisible(find.text('At Yarışı'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('At Yarışı'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Form:'), findsNWidgets(6));
    });

    testWidgets('dar telefon ekranında taşma olmaz', (tester) async {
      await pumpSpending(
        tester,
        route: '/game/race',
        size: const Size(320, 568),
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.textContaining('Form:').first);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Yarışı başlat'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Yarışı başlat'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 4));
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Varış sırası'), findsOneWidget);
    });
  });
}
