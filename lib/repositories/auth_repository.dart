import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository untuk otentikasi akun Pemilik Kos via Supabase Auth.
class AuthRepository {
  final SupabaseClient? client;

  AuthRepository({this.client});

  SupabaseClient? get _dbClient {
    if (client != null) return client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Mengambil data user yang sedang login saat ini.
  User? get currentUser => _dbClient?.auth.currentUser;

  /// Memeriksa apakah ada user yang aktif login.
  bool get isAuthenticated => currentUser != null;

  /// Mendaftarkan akun pemilik kos baru (email & password).
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    final client = _dbClient;
    if (client == null) throw Exception('Supabase belum diinisialisasi');
    return await client.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  /// Masuk dengan akun pemilik kos terdaftar.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    final client = _dbClient;
    if (client == null) throw Exception('Supabase belum diinisialisasi');
    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Keluar dari sesi login.
  Future<void> signOut() async {
    final client = _dbClient;
    if (client != null) {
      await client.auth.signOut();
    }
  }
}
