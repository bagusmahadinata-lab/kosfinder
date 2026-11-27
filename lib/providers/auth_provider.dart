import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';

/// Provider untuk mengelola state otentikasi pemilik kos.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  User? _user;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _user = _repository.currentUser;
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Mendaftarkan akun pemilik kos baru (US04-AC1).
  Future<bool> register(String email, String password) async {
    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Format email tidak valid.';
      notifyListeners();
      return false;
    }

    if (password.length < 6) {
      _errorMessage = 'Password minimal harus 6 karakter.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.signUp(
        email: email,
        password: password,
      );
      _user = response.user;
      return true;
    } catch (e) {
      _errorMessage = 'Pendaftaran gagal: ${e is AuthException ? e.message : e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Masuk ke akun pemilik kos (US04-AC2).
  Future<bool> login(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      _errorMessage = 'Email dan kata sandi wajib diisi.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.signIn(
        email: email,
        password: password,
      );
      _user = response.user;
      return true;
    } catch (e) {
      // Menampilkan pesan standar sesuai AC2: Email atau kata sandi salah
      _errorMessage = 'Email atau kata sandi salah.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Keluar dari sesi login pemilik kos (US04-AC3).
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.signOut();
      _user = null;
      _errorMessage = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
