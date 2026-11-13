import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/app/router.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_factory.dart';
import 'package:son_dusuk/domain/goals/goal_models.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/domain/spending/spending_models.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<ProviderContainer> pumpHome(
  WidgetTester tester, {
  int week = 40,
  Goals goals = const Goals(),
  Spending spending = const Spending(),
  Size size = const Size(800, 2400),
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
  ).copyWith(week: week, goals: goals, spending: spending);
  await container.read(activeCareerProvider.notifier).start(0, base);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  container.read(routerProvider).go('/game');
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('ana sayfada üç hedef, ödül ve ipucu görünür', (tester) async {
    await pumpHome(tester);
    expect(find.text('Haftalık hedefler'), findsOneWidget);
    // 40. hafta maçsız: üç maçtan bağımsız hedef.
    expect(find.text('Ağır tempoda antrenman yap'), findsOneWidget);
    expect(find.text('Sosyal ağda paylaşım yap'), findsOneWidget);
    expect(find.text('Bu hafta hiç bahis oynama'), findsOneWidget);
    expect(find.textContaining('hepsi tamamlanırsa'), findsOneWidget);
    expect(find.textContaining('serin büyüsün'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(3));
  });

  testWidgets('seri rozeti ve en iyi seri görünür', (tester) async {
    await pumpHome(
      tester,
      goals: const Goals(streak: 4, best: 7, lastWeek: 39, lastDone: 2),
    );
    expect(find.text('Seri: 4 hafta'), findsOneWidget);
    expect(find.text('En iyi seri: 7'), findsOneWidget);
    expect(find.textContaining('Geçen hafta: 2/3'), findsOneWidget);
  });

  testWidgets('bahis oynayınca "bahis oynama" hedefi kaçırıldı görünür', (
    tester,
  ) async {
    await pumpHome(tester, spending: const Spending(weekStaked: 200));
    expect(find.byIcon(Icons.cancel), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
  });

  testWidgets('paylaşım yapılınca paylaşım hedefi tamamlanır', (tester) async {
    final c = await pumpHome(tester);
    final career = c.read(activeCareerProvider)!.state;
    await c
        .read(activeCareerProvider.notifier)
        .update(
          career.copyWith(
            feed: career.feed.copyWith(lastOwnPostWeek: career.absoluteWeek),
          ),
        );
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('dar telefon ekranında taşma olmaz', (tester) async {
    await pumpHome(
      tester,
      size: const Size(320, 568),
      goals: const Goals(streak: 12, best: 12, lastWeek: 39, lastDone: 3),
    );
    expect(tester.takeException(), isNull);
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 4; i++) {
      await tester.drag(list, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
