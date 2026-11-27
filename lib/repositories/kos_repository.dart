import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';

/// Repository untuk mengakses tabel 'kos' di Supabase PostgreSQL.
/// Penegakan hak akses (siapa boleh edit/hapus) diatur oleh Row Level Security (RLS).
class KosRepository {
  final SupabaseClient _client;

  KosRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Mengambil semua kos aktif untuk katalog publik pencari.
  Future<List<KosModel>> getActiveKos({
    String? searchArea,
    double? maxPrice,
    List<String>? facilities,
  }) async {
    var query = _client.from('kos').select().eq('is_active', true);

    if (searchArea != null && searchArea.trim().isNotEmpty) {
      final term = '%${searchArea.trim()}%';
      query = query.or('name.ilike.$term,area.ilike.$term,address.ilike.$term');
    }

    if (maxPrice != null && maxPrice > 0) {
      query = query.lte('price', maxPrice);
    }

    if (facilities != null && facilities.isNotEmpty) {
      query = query.contains('facilities', facilities);
    }

    final response = await query.order('created_at', ascending: false);
    return (response as List)
        .map((item) => KosModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil detail satu kos berdasarkan ID.
  Future<KosModel?> getKosById(String id) async {
    final response =
        await _client.from('kos').select().eq('id', id).maybeSingle();
    if (response == null) return null;
    return KosModel.fromJson(response);
  }

  /// Mengambil semua kos milik pemilik yang sedang login.
  Future<List<KosModel>> getOwnerKos(String ownerId) async {
    final response = await _client
        .from('kos')
        .select()
        .eq('owner_id', ownerId)
        .order('created_at', ascending: false);
    return (response as List)
        .map((item) => KosModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Menambah kos baru. Hanya user terotentikasi yang diizinkan (RLS).
  Future<KosModel> createKos(KosModel kos) async {
    final response =
        await _client.from('kos').insert(kos.toJson()).select().single();
    return KosModel.fromJson(response);
  }

  /// Memperbarui data kos. Hanya pemilik sah yang diizinkan (RLS).
  Future<KosModel> updateKos(KosModel kos) async {
    final response = await _client
        .from('kos')
        .update(kos.toJson())
        .eq('id', kos.id)
        .select()
        .single();
    return KosModel.fromJson(response);
  }

  /// Menghapus kos. Hanya pemilik sah yang diizinkan (RLS).
  Future<void> deleteKos(String id) async {
    await _client.from('kos').delete().eq('id', id);
  }
}
