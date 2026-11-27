import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:kosfinder/screens/owner_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockOwnerDashboardRepository extends KosRepository {
  final List<KosModel> kosList = [
    const KosModel(
      id: 'k-own-1',
      ownerId: 'owner-me',
      name: 'Kos Bunga Asri',
      address: 'Jl. Ngurah Rai',
      area: 'Singaraja',
      price: 700000,
      rentalPeriod: 'monthly',
      type: 'campur',
      whatsappNumber: '081234567890',
      facilities: ['WiFi'],
      totalRooms: 4,
      availableRooms: 1,
      isActive: true,
    ),
  ];

  @override
  Future<List<KosModel>> getOwnerKos(String ownerId) async {
    return List.from(kosList);
  }

  @override
  Future<KosModel> updateKos(KosModel kos) async {
    final idx = kosList.indexWhere((k) => k.id == kos.id);
    if (idx != -1) {
      kosList[idx] = kos;
    }
    return kos;
  }

  @override
  Future<void> deleteKos(String id) async {
    kosList.removeWhere((k) => k.id == id);
  }

  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return kosList.where((k) => k.isActive).toList();
  }
}

class MockOwnerAuthRepository extends AuthRepository {
  @override
  User? get currentUser => User(
        id: 'owner-me',
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
  Widget buildDashboardWidget(MockOwnerDashboardRepository repo) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => KosProvider(repository: repo),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(repository: MockOwnerAuthRepository()),
        ),
      ],
      child: const MaterialApp(
        home: OwnerDashboardScreen(),
      ),
    );
  }

  group('OwnerDashboardScreen Hapus & Toggle Nonaktif (US07)', () {
    testWidgets('Toggle nonaktif mengubah status kos dan menyimpannya (US07-AC2)',
        (WidgetTester tester) async {
      final repo = MockOwnerDashboardRepository();

      await tester.pumpWidget(buildDashboardWidget(repo));
      await tester.pumpAndSettle();

      expect(find.text('Kos Bunga Asri'), findsOneWidget);
      expect(find.text('Publik (Aktif)'), findsOneWidget);

      // Ketuk switch toggle
      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      // Verifikasi status pada repository berubah menjadi nonaktif
      expect(repo.kosList.first.isActive, isFalse);
    });

    testWidgets('Hapus kos memunculkan dialog konfirmasi dan menghapus data (US07-AC1)',
        (WidgetTester tester) async {
      final repo = MockOwnerDashboardRepository();

      await tester.pumpWidget(buildDashboardWidget(repo));
      await tester.pumpAndSettle();

      // Ketuk tombol Hapus
      final deleteBtn = find.text('Hapus');
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // Dialog konfirmasi harus muncul
      expect(find.text('Konfirmasi Hapus'), findsOneWidget);
      expect(
        find.textContaining('Apakah Anda yakin ingin menghapus'),
        findsOneWidget,
      );

      // Tekan tombol Hapus Permanen di dalam dialog
      final confirmDeleteBtn = find.text('Hapus Permanen');
      await tester.tap(confirmDeleteBtn);
      await tester.pumpAndSettle();

      // Verifikasi kos terhapus dari repository
      expect(repo.kosList, isEmpty);
      expect(find.text('Belum ada kos terdaftar'), findsOneWidget);
    });
  });
}
