import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/screens/about_screen.dart';
import 'package:kosfinder/screens/kos_detail_screen.dart';

void main() {
  group('KosDetailScreen Widget Tests (US02)', () {
    const testKos = KosModel(
      id: 'kos-detail-1',
      ownerId: 'owner-1',
      name: 'Kos Bintang Timur',
      address: 'Jl. Ahmad Yani No. 12',
      area: 'Singaraja Kampus Tengah',
      price: 1500000,
      rentalPeriod: 'monthly',
      type: 'campur',
      imageUrl: null,
      whatsappNumber: '081234567890',
      facilities: ['WiFi Cepat', 'AC Dingin', 'Parkir Motor'],
      totalRooms: 8,
      availableRooms: 3,
    );

    testWidgets('Menampilkan detail lengkap kos dan tombol Hubungi WhatsApp',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: KosDetailScreen(kos: testKos),
        ),
      );

      // Verifikasi nama dan area
      expect(find.text('Kos Bintang Timur'), findsWidgets);
      expect(find.textContaining('Singaraja Kampus Tengah'), findsOneWidget);

      // Verifikasi badge dan kamar
      expect(find.text('CAMPUR'), findsOneWidget);
      expect(find.text('Sisa 3 Kamar'), findsOneWidget);

      // Verifikasi fasilitas
      expect(find.text('WiFi Cepat'), findsOneWidget);
      expect(find.text('AC Dingin'), findsOneWidget);
      expect(find.text('Parkir Motor'), findsOneWidget);

      // Verifikasi tombol WhatsApp
      expect(find.text('Hubungi via WhatsApp'), findsOneWidget);
      expect(find.byIcon(Icons.chat), findsOneWidget);
    });

    testWidgets('Kos dengan kamar 0 menampilkan badge PENUH',
        (WidgetTester tester) async {
      final kosPenuh = testKos.copyWith(availableRooms: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: KosDetailScreen(kos: kosPenuh),
        ),
      );

      expect(find.text('PENUH'), findsOneWidget);
    });
  });

  group('AboutScreen Widget Tests (DoD Identitas)', () {
    testWidgets('AboutScreen memuat identitas wajib pengembang',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      // Verifikasi judul dan identitas
      expect(find.text('Tentang Aplikasi'), findsOneWidget);
      expect(
        find.text('2415051023 - Dewa Putu Bagus Mahadinata'),
        findsOneWidget,
      );
      expect(find.text('Universitas Pendidikan Ganesha'), findsOneWidget);
    });
  });
}
