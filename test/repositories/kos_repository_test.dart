import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/providers/kos_provider.dart';
import 'package:kosfinder/repositories/kos_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockRLSKosRepository extends KosRepository {
  final Map<String, KosModel> database = {};

  @override
  Future<KosModel> updateKos(KosModel kos) async {
    final existing = database[kos.id];
    if (existing == null) {
      throw const PostgrestException(
        message: 'JSON object requested, multiple (or no) rows returned',
        code: 'PGRST116',
      );
    }

    // Simulasi Penegakan Row Level Security (RLS) Supabase:
    // USING (auth.uid() = owner_id)
    if (kos.ownerId != existing.ownerId) {
      throw const PostgrestException(
        message: 'new row violates row-level security policy for table "kos"',
        code: '42501',
      );
    }

    database[kos.id] = kos;
    return kos;
  }

  @override
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    return database.values.toList();
  }
}

void main() {
  group('Pembaruan Kos & Penegakan Keamanan RLS (US06 & NFR01)', () {
    const kosPemilikA = KosModel(
      id: 'kos-milik-A',
      ownerId: 'owner-A-uuid',
      name: 'Kos Anggrek Pemilik A',
      address: 'Jl. Melati',
      area: 'Singaraja',
      price: 800000,
      rentalPeriod: 'monthly',
      type: 'putri',
      whatsappNumber: '0811111111',
      facilities: ['WiFi'],
      totalRooms: 5,
      availableRooms: 2,
    );

    test('Pemilik A berhasil mengubah data kos miliknya sendiri (US06-AC1)',
        () async {
      final repo = MockRLSKosRepository();
      repo.database[kosPemilikA.id] = kosPemilikA;

      final provider = KosProvider(repository: repo);

      // Pemilik A mengubah kamar menjadi 0 (penuh)
      final kosDiperbarui = kosPemilikA.copyWith(
        availableRooms: 0,
        isAvailable: false,
      );

      final success = await provider.updateKos(kosDiperbarui);

      expect(success, isTrue);
      expect(provider.errorMessage, isNull);
      expect(repo.database[kosPemilikA.id]?.availableRooms, 0);
      expect(repo.database[kosPemilikA.id]?.isFull, isTrue);
    });

    test(
        'Pemilik B mencoba mengubah kos milik Pemilik A ditolak oleh RLS Backend (US06-AC2, NFR01)',
        () async {
      final repo = MockRLSKosRepository();
      repo.database[kosPemilikA.id] = kosPemilikA;

      final provider = KosProvider(repository: repo);

      // Pemilik B (ownerId: owner-B-uuid) mencoba mengubah data milik Pemilik A
      final seranganPemilikB = kosPemilikA.copyWith(
        ownerId: 'owner-B-uuid',
        name: 'Diubah Secara Ilegal oleh Pemilik B',
      );

      final success = await provider.updateKos(seranganPemilikB);

      // Verifikasi operasi gagal
      expect(success, isFalse);
      expect(
        provider.errorMessage,
        contains('Akses ditolak: Anda tidak memiliki izin untuk mengubah kos ini (Proteksi RLS).'),
      );

      // Verifikasi data asli Pemilik A tetap aman dan tidak berubah
      expect(repo.database[kosPemilikA.id]?.name, 'Kos Anggrek Pemilik A');
      expect(repo.database[kosPemilikA.id]?.ownerId, 'owner-A-uuid');
    });
  });
}
