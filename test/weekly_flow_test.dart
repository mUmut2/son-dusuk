import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/app/router.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<ProviderContainer> pumpGame(
  WidgetTester tester, {
  int week = 1,
  PlayerStatus status = const PlayerStatus(),
}) async {
  tester.view.physicalSize = const Size(800, 2200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);

  final career = CareerState(
    player: PlayerFactory.create(
      name: 'Deniz',
      birthplace: 'Bursa',
      position: PlayerPosition.forward,
      foot: PreferredFoot.right,
      appearance: const Appearance(),
      random: GameRandom(1),
    ),
    week: week,
    status: status,
  );
  await container.read(activeCareerProvider.notifier).start(0, career);

  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  container.read(routerProvider).go('/game');
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('maçsız hafta: plan seç, haftayı geçir, özeti gör', (
    tester,
  ) async {
    final container = await pumpGame(tester);

    // Ana sayfa: durum çubukları ve hafta bilgisi.
    expect(find.text('Kondisyon'), findsOneWidget);
    expect(find.textContaining('Hazırlık dönemi'), findsOneWidget);

    await tester.tap(find.text('Haftayı Planla'));
    await tester.pumpAndSettle();
    expect(find.text('Haftalık Plan'), findsOneWidget);

    await tester.tap(find.text('Şut'));
    await tester.tap(find.text('Sert'));
    await tester.tap(find.text('Aile'));
    await tester.pump();
    final plan = container.read(weeklyPlanProvider);
    expect(plan.focus.name, 'shooting');
    expect(plan.intensity.name, 'hard');
    expect(plan.social.name, 'family');

    await tester.tap(find.text('Haftayı Geçir'));
    await tester.pumpAndSettle();

    expect(find.text('Hafta Özeti'), findsOneWidget);
    expect(find.text('Sezon 1, Hafta 1'), findsOneWidget);
    expect(find.text('Sert antrenman'), findsWidgets);
    expect(find.text('Aileyle zaman'), findsWidgets);
    expect(find.text('Gelişim'), findsOneWidget);

    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    final career = container.read(activeCareerProvider)!.state;
    expect(career.week, 2);
    expect(container.read(lastWeekProvider)!.report.attributeGains, isNotEmpty);
    // Otomatik kayıt: diskteki kayıt da ilerlemiş olmalı.
    expect(container.read(saveRepositoryProvider).load(0)!.week, 2);
  });

  testWidgets('lig haftası: maç oynanır, istatistik ve form güncellenir', (
    tester,
  ) async {
    final container = await pumpGame(tester, week: 5);
    expect(find.textContaining('Lig turu 1'), findsOneWidget);

    await tester.tap(find.text('Haftayı Planla'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Maçı Oyna ve Haftayı Bitir'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hızlı Simüle Et'));
    await tester.pumpAndSettle();
    expect(find.text('Maç Sonu'), findsOneWidget);

    await tester.tap(find.text('Haftayı Bitir'));
    await tester.pumpAndSettle();
    expect(find.text('Hafta Özeti'), findsOneWidget);
    expect(find.text('Son maç reytingleri'), findsOneWidget);

    await tester.tap(find.text('Devam'));
    await tester.pumpAndSettle();

    final career = container.read(activeCareerProvider)!.state;
    expect(career.week, 6);
    expect(career.stats.matches, 1);
    expect(career.status.recentRatings, hasLength(1));
  });

  testWidgets('sakatken: banner, kilitli antrenman, riskli erken dönüş', (
    tester,
  ) async {
    final container = await pumpGame(
      tester,
      week: 5,
      status: const PlayerStatus(
        injury: Injury(type: InjuryType.ligament, weeksLeft: 6, totalWeeks: 6),
      ),
    );

    expect(find.textContaining('Bağ sakatlığı'), findsOneWidget);
    expect(find.text('Bu hafta sakatsın.'), findsNothing);
    expect(find.text('Sakatsın, bu hafta maçta yoksun.'), findsOneWidget);

    await tester.tap(find.text('Haftayı Planla'));
    await tester.pumpAndSettle();
    // Sakatken maç yok: "Haftayı Geçir" görünür.
    expect(find.text('Haftayı Geçir'), findsOneWidget);
    expect(find.text('Maçı Oyna ve Haftayı Bitir'), findsNothing);

    await tester.tap(find.text('Riskli Erken Dönüş'));
    await tester.pumpAndSettle();
    expect(find.textContaining('tekrar sakatlanma riskin'), findsOneWidget);

    // Vazgeçersen sakatlık sürer.
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(
      container.read(activeCareerProvider)!.state.status.isInjured,
      isTrue,
    );

    await tester.tap(find.text('Riskli Erken Dönüş'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dön'));
    await tester.pumpAndSettle();

    final status = container.read(activeCareerProvider)!.state.status;
    expect(status.isInjured, isFalse);
    expect(status.relapseRisk, greaterThan(0.3));
    // Eski kayıt formatı yok: durum diske yazıldı.
    expect(
      container.read(saveRepositoryProvider).load(0)!.status.relapseRisk,
      greaterThan(0.3),
    );
    expect(find.text('Maçı Oyna ve Haftayı Bitir'), findsOneWidget);
  });
}
