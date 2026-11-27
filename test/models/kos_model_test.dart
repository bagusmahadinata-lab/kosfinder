import 'package:flutter_test/flutter_test.dart';
import 'package:kosfinder/models/kos_model.dart';

void main() {
  group('KosModel Unit Tests', () {
    test('fromJson harus memetakan data JSON Supabase dengan benar', () {
      final json = {
        'id': 'kos-123',
        'owner_id': 'owner-abc',
        'name': 'Kos Putri Melati',
        'address': 'Jl. Udayana No. 10',
        'area': 'Singaraja',
        'price': 750000,
        'rental_period': 'monthly',
        'type': 'putri',
        'image_url': 'https://example.com/image.jpg',
        'whatsapp_number': '081234567890',
        'facilities': ['WiFi', 'AC', 'Kamar Mandi Dalam'],
        'total_rooms': 10,
        'available_rooms': 2,
        'is_available': true,
        'is_active': true,
        'created_at': '2026-11-27T10:00:00.000Z',
        'updated_at': '2026-11-27T10:00:00.000Z',
      };

      final kos = KosModel.fromJson(json);

      expect(kos.id, 'kos-123');
      expect(kos.ownerId, 'owner-abc');
      expect(kos.name, 'Kos Putri Melati');
      expect(kos.price, 750000.0);
      expect(kos.facilities.length, 3);
      expect(kos.facilities, contains('WiFi'));
      expect(kos.availableRooms, 2);
      expect(kos.isFull, false);
      expect(kos.rentalPeriodLabel, 'bulan');
    });

    test('isFull harus bernilai true ketika available_rooms bernilai 0', () {
      final json = {
        'id': 'kos-124',
        'owner_id': 'owner-abc',
        'name': 'Kos Putra Anggrek',
        'address': 'Jl. Sudirman',
        'area': 'Singaraja',
        'price': 800000,
        'rental_period': 'monthly',
        'type': 'putra',
        'whatsapp_number': '081234567891',
        'facilities': ['WiFi'],
        'total_rooms': 5,
        'available_rooms': 0,
        'is_available': true,
        'is_active': true,
      };

      final kos = KosModel.fromJson(json);

      expect(kos.availableRooms, 0);
      expect(kos.isFull, true);
    });

    test('toJson harus menghasilkan map yang valid untuk dikirim ke Supabase', () {
      const kos = KosModel(
        id: 'kos-999',
        ownerId: 'owner-xyz',
        name: 'Kos Campur Asri',
        address: 'Jl. Ahmad Yani',
        area: 'Singaraja',
        price: 12000000,
        rentalPeriod: 'yearly',
        type: 'campur',
        imageUrl: null,
        whatsappNumber: '081999888777',
        facilities: ['WiFi', 'Parkir Mobil'],
        totalRooms: 8,
        availableRooms: 3,
        isAvailable: true,
        isActive: true,
      );

      final json = kos.toJson();

      expect(json['id'], 'kos-999');
      expect(json['owner_id'], 'owner-xyz');
      expect(json['price'], 12000000.0);
      expect(json['rental_period'], 'yearly');
      expect(json['facilities'], ['WiFi', 'Parkir Mobil']);
    });

    test('copyWith harus berhasil memperbarui atribut tertentu', () {
      const kos = KosModel(
        id: 'kos-1',
        ownerId: 'owner-1',
        name: 'Kos A',
        address: 'Alamat A',
        area: 'Area A',
        price: 500000,
        rentalPeriod: 'monthly',
        type: 'campur',
        whatsappNumber: '081111',
        facilities: [],
        totalRooms: 4,
        availableRooms: 4,
      );

      final updated = kos.copyWith(
        availableRooms: 0,
        isAvailable: false,
      );

      expect(updated.id, 'kos-1');
      expect(updated.availableRooms, 0);
      expect(updated.isAvailable, false);
      expect(updated.isFull, true);
    });
  });
}
