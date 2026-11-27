import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/main.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockTestKosRepository extends KosRepository {
  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return [
      const KosModel(
        id: 'kos-test-1',
        ownerId: 'owner-test',
        name: 'Kos Test Asri',
        address: 'Jl. Kampus Bawah',
        area: 'Singaraja',
        price: 900000,
        rentalPeriod: 'monthly',
        type: 'putra',
        whatsappNumber: '081234567890',
        facilities: ['WiFi'],
        totalRooms: 5,
        availableRooms: 3,
      ),
    ];
  }
}

class MockTestAuthRepository extends AuthRepository {
  @override
  bool get isAuthenticated => false;
}

void main() {
  testWidgets('HomeScreen menampilkan judul dan kartu kos (US01-AC1)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      KosFinderApp(
        kosRepository: MockTestKosRepository(),
        authRepository: MockTestAuthRepository(),
      ),
    );

    // Judul App Bar
    expect(find.text('KosFinder'), findsOneWidget);

    // Tunggu post frame callback fetchActiveKos
    await tester.pumpAndSettle();

    // Verifikasi nama kos dan badge tipe muncul
    expect(find.text('Kos Test Asri'), findsOneWidget);
    expect(find.text('PUTRA'), findsOneWidget);
    expect(find.text('Sisa 3 Kamar'), findsOneWidget);
  });
}
