import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/kos_model.dart';

/// Halaman detail informasi kos publik dan aksi hubungi WhatsApp pemilik.
class KosDetailScreen extends StatelessWidget {
  final KosModel kos;

  const KosDetailScreen({super.key, required this.kos});

  /// Membuka tautan WhatsApp pemilik kos secara aman.
  Future<void> _launchWhatsApp(BuildContext context) async {
    // Bersihkan nomor: hapus karakter selain digit
    var rawNumber = kos.whatsappNumber.replaceAll(RegExp(r'\D'), '');
    if (rawNumber.startsWith('0')) {
      rawNumber = '62${rawNumber.substring(1)}';
    } else if (!rawNumber.startsWith('62')) {
      rawNumber = '62$rawNumber';
    }

    final message = Uri.encodeComponent(
      'Halo, saya melihat kos "${kos.name}" di KosFinder. Apakah masih tersedia kamar?',
    );
    final url = Uri.parse('https://wa.me/$rawNumber?text=$message');

    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka WhatsApp. Pastikan aplikasi terpasang.'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghubungi pemilik: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final typeColor = switch (kos.type.toLowerCase()) {
      'putra' => Colors.blue,
      'putri' => Colors.pink,
      _ => Colors.teal,
    };

    final isPenuh = kos.isFull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          kos.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Utama
            SizedBox(
              height: 240,
              width: double.infinity,
              child: kos.imageUrl != null && kos.imageUrl!.isNotEmpty
                  ? Image.network(
                      kos.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges Tipe & Status Ketersediaan
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          kos.type.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPenuh ? Colors.red : Colors.green.shade700,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPenuh
                              ? 'PENUH'
                              : 'Sisa ${kos.availableRooms} Kamar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Nama Kos
                  Text(
                    kos.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Alamat & Area
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${kos.address}, Area ${kos.area}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Harga Sewa
                  const Text(
                    'Harga Sewa',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${currencyFormatter.format(kos.price)} / ${kos.rentalPeriodLabel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 32),

                  // Kapasitas Kamar
                  const Text(
                    'Kapasitas Kamar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoTile('Total Kamar', '${kos.totalRooms} Kamar'),
                      const SizedBox(width: 24),
                      _buildInfoTile('Tersedia', '${kos.availableRooms} Kamar'),
                    ],
                  ),
                  const Divider(height: 32),

                  // Fasilitas
                  const Text(
                    'Fasilitas Kos',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (kos.facilities.isEmpty)
                    const Text(
                      'Tidak ada informasi fasilitas khusus.',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: kos.facilities.map((f) {
                        return Chip(
                          avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          label: Text(f),
                          backgroundColor: Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 80), // Jarak untuk floating button
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _launchWhatsApp(context),
          icon: const Icon(Icons.chat, color: Colors.white),
          label: const Text(
            'Hubungi via WhatsApp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25D366), // Warna khas WhatsApp
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.apartment, size: 64, color: Colors.grey),
      ),
    );
  }
}
