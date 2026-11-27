import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/providers/auth_provider.dart';
import 'package:kosfinder/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockAuthRepository extends AuthRepository {
  User? _mockUser;
  bool shouldFailLogin = false;

  @override
  User? get currentUser => _mockUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    _mockUser = User(
      id: 'mock-user-id-123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    return AuthResponse(user: _mockUser);
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (shouldFailLogin || email != 'pemilik@example.com' || password != 'password123') {
      throw const AuthException('Invalid login credentials');
    }
    _mockUser = User(
      id: 'mock-user-id-123',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
      email: email,
    );
    return AuthResponse(user: _mockUser);
  }

  @override
  Future<void> signOut() async {
    _mockUser = null;
  }
}

void main() {
  group('AuthProvider Unit Tests (US04)', () {
    test('Registrasi berhasil dengan data valid (US04-AC1)', () async {
      final repository = MockAuthRepository();
      final provider = AuthProvider(repository: repository);

      final success = await provider.register('pemilik@example.com', 'password123');

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.user?.email, 'pemilik@example.com');
      expect(provider.errorMessage, isNull);
    });

    test('Registrasi gagal jika password kurang dari 6 karakter', () async {
      final repository = MockAuthRepository();
      final provider = AuthProvider(repository: repository);

      final success = await provider.register('pemilik@example.com', '12345');

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.errorMessage, 'Password minimal harus 6 karakter.');
    });

    test('Login gagal menampilkan pesan error "Email atau kata sandi salah" (US04-AC2)', () async {
      final repository = MockAuthRepository();
      final provider = AuthProvider(repository: repository);

      final success = await provider.login('salah@example.com', 'passwordsalah');

      expect(success, isFalse);
      expect(provider.isAuthenticated, isFalse);
      expect(provider.errorMessage, 'Email atau kata sandi salah.');
    });

    test('Login berhasil dengan kredensial benar', () async {
      final repository = MockAuthRepository();
      final provider = AuthProvider(repository: repository);

      final success = await provider.login('pemilik@example.com', 'password123');

      expect(success, isTrue);
      expect(provider.isAuthenticated, isTrue);
      expect(provider.user?.email, 'pemilik@example.com');
    });

    test('Logout menghapus sesi login pengguna (US04-AC3)', () async {
      final repository = MockAuthRepository();
      final provider = AuthProvider(repository: repository);

      // Login dulu
      await provider.login('pemilik@example.com', 'password123');
      expect(provider.isAuthenticated, isTrue);

      // Logout
      await provider.logout();
      expect(provider.isAuthenticated, isFalse);
      expect(provider.user, isNull);
    });
  });
}
