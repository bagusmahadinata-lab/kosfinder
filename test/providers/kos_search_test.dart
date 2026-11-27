import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';

class MockSearchKosRepository extends KosRepository {
  final List<KosModel> allKos = const [
    KosModel(
      id: '1',
      ownerId: 'owner-1',
      name: 'Kos Bintang Singaraja',
      address: 'Jl. Udayana No. 1',
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
      id: '2',
      ownerId: 'owner-2',
      name: 'Kos Melati Kampus Bawah',
      address: 'Jl. Ahmad Yani No. 5',
      area: 'Singaraja Tengah',
      price: 850000,
      rentalPeriod: 'monthly',
      type: 'putri',
      whatsappNumber: '0822222222',
      facilities: ['WiFi', 'AC'],
      totalRooms: 6,
      availableRooms: 1,
    ),
    KosModel(
      id: '3',
      ownerId: 'owner-3',
      name: 'Kos Renon Denpasar',
      address: 'Jl. Puputan',
      area: 'Denpasar',
      price: 1500000,
      rentalPeriod: 'monthly',
      type: 'campur',
      whatsappNumber: '0833333333',
      facilities: ['AC'],
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
    return allKos.where((kos) {
      if (searchArea != null && searchArea.trim().isNotEmpty) {
        final query = searchArea.trim().toLowerCase();
        final matchesArea = kos.area.toLowerCase().contains(query);
        final matchesName = kos.name.toLowerCase().contains(query);
        final matchesAddress = kos.address.toLowerCase().contains(query);
        if (!matchesArea && !matchesName && !matchesAddress) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}

void main() {
  group('Pencarian Area Case-Insensitive (US03-AC1 & US03-AC3)', () {
    test(
        'Pencarian "singaraja" dan "Singaraja" harus menghasilkan data yang sama (US03-AC1)',
        () async {
      final repository = MockSearchKosRepository();
      final provider = KosProvider(repository: repository);

      // Cari huruf kecil
      provider.setSearchArea('singaraja');
      await Future.delayed(Duration.zero);
      final hasilKecil = List<KosModel>.from(provider.kosList);

      expect(hasilKecil.length, 2);
      expect(hasilKecil.every((k) => k.area.contains('Singaraja')), isTrue);

      // Cari huruf kapital
      provider.setSearchArea('Singaraja');
      await Future.delayed(Duration.zero);
      final hasilKapital = List<KosModel>.from(provider.kosList);

      expect(hasilKapital.length, 2);
      expect(hasilKapital.map((k) => k.id), equals(hasilKecil.map((k) => k.id)));
    });

    test(
        'Pencarian area yang tidak cocok menghasilkan list kosong & isSearchingOrFiltering true (US03-AC3)',
        () async {
      final repository = MockSearchKosRepository();
      final provider = KosProvider(repository: repository);

      provider.setSearchArea('Surabaya');
      await Future.delayed(Duration.zero);

      expect(provider.kosList, isEmpty);
      expect(provider.isEmpty, isTrue);
      expect(provider.isSearchingOrFiltering, isTrue);
    });

    test('Reset filter mengembalikan seluruh daftar kos', () async {
      final repository = MockSearchKosRepository();
      final provider = KosProvider(repository: repository);

      provider.setSearchArea('Denpasar');
      await Future.delayed(Duration.zero);
      expect(provider.kosList.length, 1);

      provider.resetFilters();
      await Future.delayed(Duration.zero);
      expect(provider.kosList.length, 3);
      expect(provider.searchArea, isEmpty);
      expect(provider.isSearchingOrFiltering, isFalse);
    });
  });
}
