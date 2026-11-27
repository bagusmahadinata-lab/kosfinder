import 'package:flutter/material.dart';

/// Halaman About aplikasi KosFinder.
/// Wajib memuat identitas SE sesuai pedoman AGENTS.md (2415051023 - Dewa Putu Bagus Mahadinata).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.apartment_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'KosFinder',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Versi 1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'KosFinder adalah platform pencarian dan pengelolaan kos '
                  'yang menghubungkan mahasiswa dan masyarakat pencari kos '
                  'dengan pemilik kos di sekitar kampus secara mudah, transparan, dan cepat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Identitas Pengembang',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Divider(height: 20),
                    ListTile(
                      leading: Icon(Icons.person, color: Colors.indigo),
                      title: Text(
                        '2415051023 - Dewa Putu Bagus Mahadinata',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Software Engineer (SE) • PTI 5 IKI'),
                    ),
                    ListTile(
                      leading: Icon(Icons.school, color: Colors.indigo),
                      title: Text('Universitas Pendidikan Ganesha'),
                      subtitle: Text('Pemrograman Mobile • Worksheet 11b'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Dibuat dengan Flutter & Supabase',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
