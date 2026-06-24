import 'package:dompet_kampus_global/injection/injection_container.dart'
    as di;
import 'package:dompet_kampus_global/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    FlutterSecureStorage.setMockInitialValues({});
    await di.init();
  });

  tearDownAll(() async {
    await di.sl.reset();
  });

  testWidgets('menampilkan halaman awal Dompet Kampus',
      (WidgetTester tester) async {
    await tester.pumpWidget(const DompetKampusApp());
    await tester.pumpAndSettle();

    expect(find.text('Dompet Kampus'), findsOneWidget);
    expect(find.text('GLOBAL'), findsOneWidget);
    expect(find.text('Buat Akun Baru'), findsOneWidget);
    expect(find.text('Masuk ke Akun'), findsOneWidget);
  });
}
