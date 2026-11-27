import 'package:flutter/foundation.dart';
import '../models/kos_model.dart';
import '../repositories/kos_repository.dart';

/// Provider untuk mengelola state katalog kos publik dan filter pencarian.
class KosProvider extends ChangeNotifier {
  final KosRepository _repository;

  List<KosModel> _kosList = [];
  bool _isLoading = false;
  String? _errorMessage;

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

  String get searchArea => _searchArea;
  double? get maxPrice => _maxPrice;
  List<String> get selectedFacilities => _selectedFacilities;

  /// Memuat daftar kos aktif dari Supabase.
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

  /// Memperbarui kata kunci pencarian area.
  void setSearchArea(String query) {
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
