import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/kos_form_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockCreateKosRepository extends KosRepository {
  final List<KosModel> stored = [];

  @override
  Future<KosModel> createKos(KosModel kos) async {
    final created = kos.copyWith(id: 'created-id-123');
    stored.add(created);
    return created;
  }

  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return stored;
  }
}

class MockLoggedInAuthRepository extends AuthRepository {
  @override
  User? get currentUser => User(
        id: 'owner-uuid-1',
        appMetadata: {},
        userMetadata: {},
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'pemilik@example.com',
      );

  @override
  bool get isAuthenticated => true;
}

void main() {
  Widget buildTestableWidget({
    required KosRepository kosRepository,
    required AuthRepository authRepository,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KosProvider(repository: kosRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: authRepository),
        ),
      ],
      child: const MaterialApp(
        home: KosFormScreen(),
      ),
    );
  }

  group('KosFormScreen Form Validation & Creation (US05)', () {
    testWidgets(
        'Submit form kosong memicu pesan validasi merah dan data tidak dikirim (US05-AC2)',
        (WidgetTester tester) async {
      final kosRepo = MockCreateKosRepository();
      final authRepo = MockLoggedInAuthRepository();

      await tester.pumpWidget(buildTestableWidget(
        kosRepository: kosRepo,
        authRepository: authRepo,
      ));

      // Tekan tombol simpan saat form masih kosong
      final submitButton = find.text('Terbitkan Kos');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verifikasi pesan validasi muncul pada field wajib
      expect(find.text('Nama kos wajib diisi'), findsOneWidget);
      expect(find.text('Area kos wajib diisi'), findsOneWidget);
      expect(find.text('Alamat lengkap wajib diisi'), findsOneWidget);
      expect(find.text('Harga wajib diisi'), findsOneWidget);
      expect(find.text('Nomor WhatsApp wajib diisi'), findsOneWidget);

      // Verifikasi tidak ada data yang dikirim ke repository
      expect(kosRepo.stored, isEmpty);
    });

    testWidgets('Mengisi form valid berhasil membuat kos baru (US05-AC1)',
        (WidgetTester tester) async {
      final kosRepo = MockCreateKosRepository();
      final authRepo = MockLoggedInAuthRepository();

      await tester.pumpWidget(buildTestableWidget(
        kosRepository: kosRepo,
        authRepository: authRepo,
      ));

      // Isi Nama
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nama Kos *'),
        'Kos Jasmine Bahagia',
      );

      // Isi Area
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Area / Sekitar Kampus *'),
        'Singaraja Tengah',
      );

      // Isi Alamat
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Alamat Lengkap *'),
        'Jl. Veteran No. 8',
      );

      // Isi Harga
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Harga (Rp) *'),
        '850000',
      );

      // Isi Nomor WhatsApp
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nomor WhatsApp Pemilik *'),
        '081234567890',
      );

      // Tekan tombol Simpan
      final submitButton = find.text('Terbitkan Kos');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verifikasi kos tersimpan di repository dengan owner_id sesuai user yang login
      expect(kosRepo.stored.length, 1);
      final saved = kosRepo.stored.first;
      expect(saved.name, 'Kos Jasmine Bahagia');
      expect(saved.ownerId, 'owner-uuid-1');
      expect(saved.price, 850000.0);
      expect(saved.whatsappNumber, '081234567890');
    });
  });
}
