import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/core/game_random.dart';
import 'package:son_dusuk/data/save_repository.dart';
import 'package:son_dusuk/domain/career/career_state.dart';
import 'package:son_dusuk/domain/career/difficulty.dart';
import 'package:son_dusuk/domain/player/player.dart';
import 'package:son_dusuk/domain/player/player_factory.dart';
import 'package:son_dusuk/domain/player/position.dart';
import 'package:son_dusuk/presentation/providers.dart';

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Future<void> Function(SaveRepository repo)? seed,
}) async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  if (seed != null) await seed(SaveRepository(sp));
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sp)],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SonDusukApp()),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('açılışta Türkçe menü ve 3 boş slot görünür', (tester) async {
    await pumpApp(tester);

    expect(find.text('Son Düdük'), findsOneWidget);
    expect(find.text('Boş — yeni kariyer başlat'), findsNWidgets(3));
  });

  testWidgets('oyuncu yaratma: isim zorunlu, sonra kariyer kaydedilir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final container = await pumpApp(tester);

    await tester.tap(find.text('Boş — yeni kariyer başlat').first);
    await tester.pumpAndSettle();
    expect(find.text('Yeni Oyuncu'), findsOneWidget);

    // İsimsiz denenirse hata gösterilir, kayıt oluşmaz.
    await tester.tap(find.text('Kariyere Başla'));
    await tester.pumpAndSettle();
    expect(find.text('Bir isim gir.'), findsOneWidget);
    expect(container.read(saveRepositoryProvider).load(0), isNull);

    await tester.enterText(find.byType(TextFormField), 'Deniz Yıldız');
    await tester.tap(find.text('Defans'));
    await tester.pump();
    await tester.tap(find.text('Kariyere Başla'));
    await tester.pumpAndSettle();

    // Ana ekran: oyuncu kartı ve alt navigasyon.
    expect(find.text('Deniz Yıldız'), findsOneWidget);
    expect(find.text('Genel Güç'), findsOneWidget);
    expect(find.text('Antrenman'), findsOneWidget);

    final saved = container.read(saveRepositoryProvider).load(0)!;
    expect(saved.player.name, 'Deniz Yıldız');
    expect(saved.player.age, 16);
    expect(container.read(saveSlotsProvider)[0].status, SlotStatus.ok);

    // Profil sekmesi nitelikleri gösterir.
    await tester.tap(find.text('Profil'));
    await tester.pumpAndSettle();
    expect(find.text('Nitelikler'), findsOneWidget);
    expect(find.text('Şut'), findsOneWidget);
  });

  testWidgets('dolu slot özet gösterir; silme onay ister', (tester) async {
    await pumpApp(
      tester,
      seed: (repo) => repo.save(
        1,
        CareerState(
          player: PlayerFactory.create(
            name: 'Kerem Aksoy',
            birthplace: 'Bursa',
            position: PlayerPosition.winger,
            foot: PreferredFoot.left,
            appearance: const Appearance(),
            random: GameRandom(2),
          ),
        ),
      ),
    );

    expect(find.text('Kerem Aksoy'), findsOneWidget);
    expect(find.textContaining('16 yaş · Kanat'), findsOneWidget);
    expect(find.text('Boş — yeni kariyer başlat'), findsNWidgets(2));

    // Vazgeçersen kayıt durur.
    await tester.tap(find.byTooltip('Kaydı sil'));
    await tester.pumpAndSettle();
    expect(find.textContaining('geri alınamaz'), findsOneWidget);
    await tester.tap(find.text('Vazgeç'));
    await tester.pumpAndSettle();
    expect(find.text('Kerem Aksoy'), findsOneWidget);

    // Onaylarsan silinir.
    await tester.tap(find.byTooltip('Kaydı sil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sil'));
    await tester.pumpAndSettle();
    expect(find.text('Kerem Aksoy'), findsNothing);
    expect(find.text('Boş — yeni kariyer başlat'), findsNWidgets(3));
  });

  testWidgets('ayarlar ekranı zorluğu kaydeder', (tester) async {
    final container = await pumpApp(tester);
    await tester.tap(find.byTooltip('Ayarlar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Zor'));
    await tester.pumpAndSettle();
    expect(container.read(settingsProvider).difficulty, Difficulty.hard);
  });
}
