import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';
import 'package:kosfinder/widgets/kos_card.dart';

void main() {
  group('KosCard Widget Tests — Ketersediaan Kamar (US06-Bonus)', () {
    const baseKos = KosModel(
      id: 'kos-card-1',
      ownerId: 'owner-1',
      name: 'Kos Sejahtera',
      address: 'Jl. Pahlawan No. 5',
      area: 'Singaraja Utara',
      price: 900000,
      rentalPeriod: 'monthly',
      type: 'campur',
      imageUrl: null,
      whatsappNumber: '08123456789',
      facilities: ['WiFi'],
      totalRooms: 5,
      availableRooms: 3,
    );

    testWidgets(
        'KosCard menampilkan sisa kamar ketika availableRooms > 0 (US06-Bonus)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KosCard(kos: baseKos),
          ),
        ),
      );

      // Badge harus menampilkan sisa kamar, bukan "PENUH"
      expect(find.text('Sisa 3 Kamar'), findsOneWidget);
      expect(find.text('PENUH'), findsNothing);
    });

    testWidgets(
        'KosCard menampilkan badge PENUH otomatis saat availableRooms = 0 (US06-Bonus)',
        (WidgetTester tester) async {
      final kosPenuh = baseKos.copyWith(availableRooms: 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: KosCard(kos: kosPenuh),
          ),
        ),
      );

      // Badge harus berubah otomatis menjadi "PENUH"
      expect(find.text('PENUH'), findsOneWidget);
      expect(find.textContaining('Sisa'), findsNothing);
    });
  });
}
