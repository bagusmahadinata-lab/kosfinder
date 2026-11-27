/// Konfigurasi aplikasi KosFinder.
/// Membaca kredensial dari environment variable melalui --dart-define.
/// Dilarang keras menulis URL atau API Key secara hardcoded di berkas ini.
class AppConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Memeriksa apakah konfigurasi Supabase telah disetel via --dart-define.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
