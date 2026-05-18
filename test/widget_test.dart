import 'package:flutter_test/flutter_test.dart';
import 'package:karyarasa/main.dart';

void main() {
  testWidgets('KaryaRasa home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const KaryaRasaApp());

    expect(find.text('KaryaRasa'), findsOneWidget);
    expect(
      find.text('Selamat Datang!\nTemukan Jiwa Kuliner\nNusantara'),
      findsOneWidget,
    );
    expect(find.text('Rekomendasi Minggu Ini'), findsOneWidget);
  });
}
