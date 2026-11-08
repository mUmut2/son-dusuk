import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/career/player_status.dart';
import 'package:son_dusuk/domain/match/critical_moment.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/game/mini_game_types.dart';
import 'package:son_dusuk/game/mini_game_view.dart';

MiniGameLabels labels() => MiniGameLabels(
  hints: {for (final t in MomentType.values) t: 'ipucu ${t.name}'},
  invalidSwipe: 'geçersiz',
  goal: 'GOL',
  saved: 'KURTARDI',
  blocked: 'ENGELLENDİ',
  offTarget: 'AUT',
  woodwork: 'DİREK',
  timeout: 'SÜRE',
  perfect: 'MÜKEMMEL',
  passComplete: 'PAS',
  passAssist: 'ASİST',
  passIntercepted: 'KESİLDİ',
  dribbleBeaten: 'ÇALIM',
  dribbleFail: 'ALINDI',
  tackleWon: 'KAZANDI',
  tackleFoul: 'FAUL',
  tackleBeaten: 'GEÇİLDİ',
  shootButton: 'DURDUR',
  tooEarly: 'ERKEN',
);

Future<MiniGameFinish?> Function() mount(
  WidgetTester tester,
  MomentType type, {
  Difficulty difficulty = Difficulty.normal,
  PlayerStatus status = const PlayerStatus(),
}) {
  MiniGameFinish? finished;
  return () async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniGameView(
            type: type,
            player: PlayerFactory.create(
              name: 'T',
              birthplace: 'Ankara',
              position: PlayerPosition.forward,
              foot: PreferredFoot.right,
              appearance: const Appearance(),
              random: GameRandom(1),
            ),
            status: status,
            difficulty: difficulty,
            labels: labels(),
            penaltyHistory: const [0, 0, 0, 0, 0, 0],
            vibration: false,
            random: GameRandom(7),
            onFinished: (f) => finished = f,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return finished;
  };
}

/// Oyunu [seconds] saniye ilerletir (100 ms'lik karelerle).
Future<void> run(WidgetTester tester, double seconds) async {
  for (var i = 0; i < seconds * 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  group('hiçbir girdi verilmese de her mini oyun süre dolunca biter', () {
    for (final type in MomentType.values) {
      testWidgets(type.name, (tester) async {
        MiniGameFinish? finished;
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MiniGameView(
                type: type,
                player: PlayerFactory.create(
                  name: 'T',
                  birthplace: 'Ankara',
                  position: PlayerPosition.forward,
                  foot: PreferredFoot.right,
                  appearance: const Appearance(),
                  random: GameRandom(1),
                ),
                status: const PlayerStatus(),
                difficulty: Difficulty.normal,
                labels: labels(),
                penaltyHistory: const [0, 0, 0, 0, 0, 0],
                vibration: false,
                random: GameRandom(7),
                onFinished: (f) => finished = f,
              ),
            ),
          ),
        );
        await tester.pump();
        await run(tester, 25);

        expect(finished, isNotNull, reason: '${type.name} bitmedi');
        expect(tester.takeException(), isNull);
        expect(finished!.penaltyZone, isNull);
      });
    }
  });

  testWidgets('penaltı: bölge seç, ibreyi durdur, sonuç bölgeyi taşır', (
    tester,
  ) async {
    MiniGameFinish? finished;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniGameView(
            type: MomentType.penalty,
            player: PlayerFactory.create(
              name: 'T',
              birthplace: 'Ankara',
              position: PlayerPosition.forward,
              foot: PreferredFoot.right,
              appearance: const Appearance(),
              random: GameRandom(1),
            ),
            status: const PlayerStatus(),
            difficulty: Difficulty.normal,
            labels: labels(),
            penaltyHistory: const [0, 0, 0, 0, 0, 0],
            vibration: false,
            random: GameRandom(3),
            onFinished: (f) => finished = f,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Kale: x 400 civarı, y 192-432 arası. Sağ üst bölge.
    await tester.tapAt(const Offset(620, 230));
    await run(tester, 0.4);
    // Aşağıya dokunarak ibreyi durdur.
    await tester.tapAt(const Offset(400, 1200));
    await run(tester, 4);

    expect(finished, isNotNull);
    expect(finished!.penaltyZone, 5, reason: 'sağ üst = bölge 5');
    expect(tester.takeException(), isNull);
  });

  testWidgets('müdahale: dokununca hemen çözülür', (tester) async {
    MiniGameFinish? finished;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniGameView(
            type: MomentType.tackle,
            player: PlayerFactory.create(
              name: 'T',
              birthplace: 'Ankara',
              position: PlayerPosition.defender,
              foot: PreferredFoot.right,
              appearance: const Appearance(),
              random: GameRandom(1),
            ),
            status: const PlayerStatus(),
            difficulty: Difficulty.normal,
            labels: labels(),
            penaltyHistory: const [0, 0, 0, 0, 0, 0],
            vibration: false,
            random: GameRandom(3),
            onFinished: (f) => finished = f,
          ),
        ),
      ),
    );
    await tester.pump();
    await run(tester, 1.5);
    await tester.tapAt(const Offset(400, 900));
    await run(tester, 3);
    expect(finished, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dribling: hızlı yatay swipe çalımı çözer', (tester) async {
    MiniGameFinish? finished;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniGameView(
            type: MomentType.dribble,
            player: PlayerFactory.create(
              name: 'T',
              birthplace: 'Ankara',
              position: PlayerPosition.winger,
              foot: PreferredFoot.right,
              appearance: const Appearance(),
              random: GameRandom(1),
            ),
            status: const PlayerStatus(),
            difficulty: Difficulty.normal,
            labels: labels(),
            penaltyHistory: const [0, 0, 0, 0, 0, 0],
            vibration: false,
            random: GameRandom(3),
            onFinished: (f) => finished = f,
          ),
        ),
      ),
    );
    await tester.pump();
    await run(tester, 1.8);
    await tester.flingFrom(const Offset(400, 1300), const Offset(300, 0), 2500);
    await run(tester, 3);
    expect(finished, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('şut: topa dokunup kaydırmak şutu atar', (tester) async {
    MiniGameFinish? finished;
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MiniGameView(
            type: MomentType.shot,
            player: PlayerFactory.create(
              name: 'T',
              birthplace: 'Ankara',
              position: PlayerPosition.forward,
              foot: PreferredFoot.right,
              appearance: const Appearance(),
              random: GameRandom(1),
            ),
            status: const PlayerStatus(),
            difficulty: Difficulty.normal,
            labels: labels(),
            penaltyHistory: const [0, 0, 0, 0, 0, 0],
            vibration: false,
            random: GameRandom(3),
            onFinished: (f) => finished = f,
          ),
        ),
      ),
    );
    await tester.pump();
    await run(tester, 1.0);
    // Top (400, 1312) civarında; yukarı, kaleye doğru hızlı kaydır.
    await tester.flingFrom(
      const Offset(400, 1312),
      const Offset(40, -900),
      2000,
    );
    // Kısa sürede (halka dolmadan) bitmiş olmalı: uçuş + sonuç ~2.5 sn.
    await run(tester, 3.5);
    expect(finished, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
