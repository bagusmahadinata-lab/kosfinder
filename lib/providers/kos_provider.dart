import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

/// Provider untuk mengelola state katalog kos publik, filter pencarian, dan pengelolaan kos pemilik.
class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  List<KosModel> _kosList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<KosModel> _ownerKosList = [];
  bool _isOwnerLoading = false;

  String _searchArea = '';
  double? _maxPrice;
  List<String> _selectedFacilities = [];

  KosProvider({KosRepository? repository})
      : _repository = repository ?? KosRepository();

  List<KosModel> get kosList => _kosList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => !_isLoading && !hasError && _kosList.isEmpty;

  List<KosModel> get ownerKosList => _ownerKosList;
  bool get isOwnerLoading => _isOwnerLoading;

  String get searchArea => _searchArea;
  double? get maxPrice => _maxPrice;
  List<String> get selectedFacilities => _selectedFacilities;

  /// Menandakan apakah sedang menerapkan pencarian atau filter
  bool get isSearchingOrFiltering =>
      _searchArea.trim().isNotEmpty ||
      (_maxPrice != null && _maxPrice! > 0) ||
      _selectedFacilities.isNotEmpty;

  /// Memuat daftar kos aktif dari Supabase (Publik).
  Future<void> fetchActiveKos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _kosList = await _repository.getActiveKos(
        searchArea: _searchArea,
        maxPrice: _maxPrice,
        facilities:
            _selectedFacilities.isNotEmpty ? _selectedFacilities : null,
      );
    } catch (e) {
      _errorMessage = 'Gagal memuat data kos. Periksa koneksi internet Anda.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memuat daftar kos milik pemilik yang sedang login.
  Future<void> fetchOwnerKos(String ownerId) async {
    _isOwnerLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _ownerKosList = await _repository.getOwnerKos(ownerId);
    } catch (e) {
      _errorMessage = 'Gagal memuat kos kelolaan Anda: $e';
    } finally {
      _isOwnerLoading = false;
      notifyListeners();
    }
  }

  /// Menambah kos baru (US05-AC1).
  Future<bool> createKos(KosModel kos) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createKos(kos);
      _ownerKosList.insert(0, created);
      await fetchActiveKos();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menambah kos: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui data kos milik sendiri (US06-AC1 & US06-AC2).
  Future<bool> updateKos(KosModel kos) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _repository.updateKos(kos);
      final idx = _ownerKosList.indexWhere((k) => k.id == kos.id);
      if (idx != -1) {
        _ownerKosList[idx] = updated;
      }
      await fetchActiveKos();
      return true;
    } on PostgrestException catch (e) {
      // Penegakan RLS: Jika bukan pemilik asli, baris 0 atau izin ditolak
      if (e.code == 'PGRST116' ||
          e.message.toLowerCase().contains('policy') ||
          e.message.toLowerCase().contains('permission') ||
          e.message.toLowerCase().contains('row-level security')) {
        _errorMessage =
            'Akses ditolak: Anda tidak memiliki izin untuk mengubah kos ini (Proteksi RLS).';
      } else {
        _errorMessage = 'Gagal memperbarui kos: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui kos: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Menghapus kos milik sendiri (US07-AC1).
  Future<bool> deleteKos(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteKos(id);
      _ownerKosList.removeWhere((k) => k.id == id);
      await fetchActiveKos();
      return true;
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116' ||
          e.message.toLowerCase().contains('policy') ||
          e.message.toLowerCase().contains('permission')) {
        _errorMessage =
            'Akses ditolak: Anda tidak memiliki izin untuk menghapus kos ini (Proteksi RLS).';
      } else {
        _errorMessage = 'Gagal menghapus kos: ${e.message}';
      }
      return false;
    } catch (e) {
      _errorMessage = 'Gagal menghapus kos: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui kata kunci pencarian area.
  void setSearchArea(String query) {
    if (_searchArea == query) return;
    _searchArea = query;
    fetchActiveKos();
  }

  /// Memperbarui filter harga dan checklist fasilitas.
  void setFilters({double? maxPrice, List<String>? facilities}) {
    _maxPrice = maxPrice;
    _selectedFacilities = facilities ?? [];
    fetchActiveKos();
  }

  /// Menghapus seluruh filter yang diterapkan.
  void resetFilters() {
    _searchArea = '';
    _maxPrice = null;
    _selectedFacilities = [];
    fetchActiveKos();
  }
}
