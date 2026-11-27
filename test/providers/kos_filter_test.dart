import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockFilterKosRepository extends KosRepository {
  final List<KosModel> testKosList = const [
    KosModel(
      id: 'k1',
      ownerId: 'owner-1',
      name: 'Kos Murah Bersih',
      address: 'Jl. Melati',
      area: 'Singaraja',
      price: 600000,
      rentalPeriod: 'monthly',
      type: 'putra',
      whatsappNumber: '0811111111',
      facilities: ['WiFi'],
      totalRooms: 5,
      availableRooms: 2,
    ),
    KosModel(
      id: 'k2',
      ownerId: 'owner-2',
      name: 'Kos Lengkap Nyaman',
      address: 'Jl. Mawar',
      area: 'Singaraja',
      price: 900000,
      rentalPeriod: 'monthly',
      type: 'putri',
      whatsappNumber: '0822222222',
      facilities: ['WiFi', 'AC'],
      totalRooms: 6,
      availableRooms: 1,
    ),
    KosModel(
      id: 'k3',
      ownerId: 'owner-3',
      name: 'Kos Premium Mewah',
      address: 'Jl. Anggrek',
      area: 'Singaraja',
      price: 2500000,
      rentalPeriod: 'monthly',
      type: 'campur',
      whatsappNumber: '0833333333',
      facilities: ['WiFi', 'AC', 'Kamar Mandi Dalam'],
      totalRooms: 10,
      availableRooms: 4,
    ),
  ];

  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return testKosList.where((k) {
      if (maxPrice != null && maxPrice > 0) {
        if (k.price > maxPrice) return false;
      }
      if (facilities != null && facilities.isNotEmpty) {
        for (final f in facilities) {
          if (!k.facilities.contains(f)) return false;
        }
      }
      return true;
    }).toList();
  }
}

void main() {
  group('Filter Harga dan Fasilitas (US03-AC2 & US03-AC3)', () {
    test(
        'Filter harga maks Rp1.000.000 dan fasilitas WiFi harus menampilkan k1 dan k2 (US03-AC2)',
        () async {
      final repository = MockFilterKosRepository();
      final provider = KosProvider(repository: repository);

      provider.setFilters(maxPrice: 1000000, facilities: ['WiFi']);
      await Future.delayed(Duration.zero);

      // k1 (600rb, WiFi) & k2 (900rb, WiFi, AC) memenuhi kriteria
      // k3 (2.5jt) tersaring karena melebihi harga maksimum
      expect(provider.kosList.length, 2);
      expect(provider.kosList.map((k) => k.id), containsAll(['k1', 'k2']));
      expect(provider.kosList.any((k) => k.id == 'k3'), isFalse);
    });

    test(
        'Filter harga maks Rp800.000 dan fasilitas AC menghasilkan hasil kosong (US03-AC3)',
        () async {
      final repository = MockFilterKosRepository();
      final provider = KosProvider(repository: repository);

      // Tidak ada kos <= 800rb yang memiliki AC
      provider.setFilters(maxPrice: 800000, facilities: ['AC']);
      await Future.delayed(Duration.zero);

      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, isTrue);
      expect(provider.isSearchingOrFiltering, isTrue);
    });
  });
}
