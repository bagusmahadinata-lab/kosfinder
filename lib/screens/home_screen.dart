import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/filter_dialog.dart';
import '../widgets/kos_card.dart';
import 'about_screen.dart';
import 'kos_detail_screen.dart';

/// Halaman utama katalog kos publik pencari kos dengan pencarian teks dan filter harga/fasilitas.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KosProvider>().fetchActiveKos();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterBottomSheet(BuildContext context) {
    final provider = context.read<KosProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FilterBottomSheet(
        initialMaxPrice: provider.maxPrice,
        initialFacilities: provider.selectedFacilities,
        onApply: (maxPrice, facilities) {
          provider.setFilters(
            maxPrice: maxPrice,
            facilities: facilities,
          );
        },
        onReset: () {
          provider.setFilters(maxPrice: null, facilities: []);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KosProvider>();
    final hasActiveFilter =
        (provider.maxPrice != null && provider.maxPrice! > 0) ||
        provider.selectedFacilities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KosFinder',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Tentang Aplikasi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Bilah Pencarian Area & Tombol Filter (US03-AC1, US03-AC2)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari area, kampus, nama...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<KosProvider>().setSearchArea('');
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    onChanged: (value) {
                      setState(() {});
                      context.read<KosProvider>().setSearchArea(value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                // Tombol Buka Filter
                Badge(
                  isLabelVisible: hasActiveFilter,
                  child: IconButton.filledTonal(
                    onPressed: () => _openFilterBottomSheet(context),
                    icon: const Icon(Icons.tune),
                    tooltip: 'Filter Harga & Fasilitas',
                  ),
                ),
              ],
            ),
          ),

          // Konten Katalog Kos
          Expanded(
            child: Builder(
              builder: (context) {
                // Kondisi 1: Sedang Memuat Data
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Kondisi 2: Koneksi Internet Gagal atau Error (US01-AC2)
                if (provider.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.wifi_off_rounded,
                            size: 64,
                            color: Colors.redAccent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            provider.errorMessage ?? 'Gagal memuat data kos.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => provider.fetchActiveKos(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Kondisi 3: Data Kos Kosong (US01-AC3 & US03-AC3)
                if (provider.isEmpty) {
                  final isFiltered = provider.isSearchingOrFiltering;
                  return RefreshIndicator(
                    onRefresh: () => provider.fetchActiveKos(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isFiltered
                                        ? Icons.search_off_rounded
                                        : Icons.apartment_outlined,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isFiltered
                                        ? 'Tidak ada kos yang cocok dengan kriteria pencarian Anda'
                                        : 'Belum ada kos yang tersedia saat ini.',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  if (isFiltered) ...[
                                    const SizedBox(height: 16),
                                    OutlinedButton.icon(
                                      onPressed: () {
                                        _searchController.clear();
                                        provider.resetFilters();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.clear_all),
                                      label: const Text('Reset Pencarian & Filter'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Kondisi 4: Data Kos Sukses Tampil (US01-AC1)
                return RefreshIndicator(
                  onRefresh: () => provider.fetchActiveKos(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: provider.kosList.length,
                    itemBuilder: (context, index) {
                      final kos = provider.kosList[index];
                      return KosCard(
                        kos: kos,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KosDetailScreen(kos: kos),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
