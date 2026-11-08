import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:son_dusuk/app/app.dart';

void main() {
  testWidgets('uygulama açılır ve Türkçe başlığı gösterir', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SonDusukApp()));
    await tester.pumpAndSettle();

    expect(find.text('Son Düdük'), findsOneWidget);
    expect(find.textContaining('Faz 0'), findsOneWidget);
  });
}
