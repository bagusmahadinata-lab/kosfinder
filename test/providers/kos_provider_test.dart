import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class FakeSuccessKosRepository extends KosRepository {
  final List<KosModel> dummyList;
  FakeSuccessKosRepository(this.dummyList);

  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return dummyList;
  }
}

class FakeFailureKosRepository extends KosRepository {
  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    throw Exception('Connection timeout or offline');
  }
}

void main() {
  group('KosProvider Unit Tests (US01)', () {
    final sampleKos = [
      const KosModel(
        id: 'kos-01',
        ownerId: 'owner-01',
        name: 'Kos Melati Singaraja',
        address: 'Jl. Udayana',
        area: 'Singaraja',
        price: 850000,
        rentalPeriod: 'monthly',
        type: 'putri',
        whatsappNumber: '081234567890',
        facilities: ['WiFi', 'AC'],
        totalRooms: 5,
        availableRooms: 2,
      ),
    ];

    test('Initial state KosProvider harus kosong dan tidak sedang loading', () {
      final provider = KosProvider(repository: FakeSuccessKosRepository([]));
      expect(provider.kosList, isEmpty);
      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.isEmpty, true);
    });

    test(
        'fetchActiveKos sukses harus mengisi kosList dan mematikan loading (US01-AC1)',
        () async {
      final provider =
          KosProvider(repository: FakeSuccessKosRepository(sampleKos));

      expect(provider.isLoading, false);

      final future = provider.fetchActiveKos();
      expect(provider.isLoading, true);

      await future;

      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.isEmpty, false);
      expect(provider.kosList.length, 1);
      expect(provider.kosList.first.name, 'Kos Melati Singaraja');
    });

    test(
        'fetchActiveKos gagal harus mengatur errorMessage dan tidak crash (US01-AC2, NFR03)',
        () async {
      final provider =
          KosProvider(repository: FakeFailureKosRepository());

      await provider.fetchActiveKos();

      expect(provider.isLoading, false);
      expect(provider.hasError, true);
      expect(provider.errorMessage,
          contains('Gagal memuat data kos. Periksa koneksi internet Anda.'));
      expect(provider.kosList, isEmpty);
    });

    test(
        'fetchActiveKos dengan data kosong harus menandai isEmpty = true (US01-AC3)',
        () async {
      final provider = KosProvider(repository: FakeSuccessKosRepository([]));

      await provider.fetchActiveKos();

      expect(provider.isLoading, false);
      expect(provider.hasError, false);
      expect(provider.isEmpty, true);
      expect(provider.kosList, isEmpty);
    });
  });
}
