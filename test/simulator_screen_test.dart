import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:son_dusuk/app/app.dart';
import 'package:son_dusuk/presentation/providers.dart';

void main() {
  testWidgets('lig simülatörü sezonu oynatır ve tabloyu gösterir', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const SonDusukApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Lig Simülatörü'));
    await tester.pumpAndSettle();

    // Geçersiz seed reddedilir.
    await tester.enterText(find.byType(TextField), 'abc');
    await tester.tap(find.text('Sezonu Simüle Et'));
    await tester.pumpAndSettle();
    expect(find.text('Seed bir tam sayı olmalı.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '42');
    await tester.tap(find.text('Sezonu Simüle Et'));
    await tester.pumpAndSettle();

    expect(find.textContaining('306 maç'), findsOneWidget);
    expect(find.byType(DataTable), findsOneWidget);
    // 18 takım satırı.
    expect(
      tester.widget<DataTable>(find.byType(DataTable)).rows,
      hasLength(18),
    );
  });
}
