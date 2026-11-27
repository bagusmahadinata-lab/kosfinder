/// Model data properti KosFinder.
/// Merepresentasikan baris data pada tabel 'kos' di PostgreSQL Supabase.
class KosModel {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String area;
  final double price;
  final String rentalPeriod; // 'monthly' | 'yearly'
  final String type; // 'putra' | 'putri' | 'campur'
  final String? imageUrl;
  final String whatsappNumber;
  final List<String> facilities;
  final int totalRooms;
  final int availableRooms;
  final bool isAvailable;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.area,
    required this.price,
    required this.rentalPeriod,
    required this.type,
    this.imageUrl,
    required this.whatsappNumber,
    required this.facilities,
    required this.totalRooms,
    required this.availableRooms,
    this.isAvailable = true,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Factory constructor untuk memetakan JSON dari Supabase ke KosModel.
  factory KosModel.fromJson(Map<String, dynamic> json) {
    // Parsing harga numerik secara aman (bisa int, double, atau num)
    final rawPrice = json['price'];
    final double parsedPrice = rawPrice is num
        ? rawPrice.toDouble()
        : double.tryParse(rawPrice?.toString() ?? '0') ?? 0.0;

    // Parsing facilities array
    final rawFacilities = json['facilities'];
    final List<String> parsedFacilities;
    if (rawFacilities is List) {
      parsedFacilities = rawFacilities.map((e) => e.toString()).toList();
    } else {
      parsedFacilities = const [];
    }

    return KosModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      price: parsedPrice,
      rentalPeriod: json['rental_period']?.toString() ?? 'monthly',
      type: json['type']?.toString() ?? 'campur',
      imageUrl: json['image_url']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString() ?? '',
      facilities: parsedFacilities,
      totalRooms: (json['total_rooms'] as num?)?.toInt() ?? 1,
      availableRooms: (json['available_rooms'] as num?)?.toInt() ?? 1,
      isAvailable: json['is_available'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Mengonversi model ke JSON untuk operasi insert/update ke Supabase.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
      'address': address,
      'area': area,
      'price': price,
      'rental_period': rentalPeriod,
      'type': type,
      'image_url': imageUrl,
      'whatsapp_number': whatsappNumber,
      'facilities': facilities,
      'total_rooms': totalRooms,
      'available_rooms': availableRooms,
      'is_available': isAvailable,
      'is_active': isActive,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat salinan model dengan beberapa nilai yang diubah.
  KosModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? address,
    String? area,
    double? price,
    String? rentalPeriod,
    String? type,
    String? imageUrl,
    String? whatsappNumber,
    List<String>? facilities,
    int? totalRooms,
    int? availableRooms,
    bool? isAvailable,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KosModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      address: address ?? this.address,
      area: area ?? this.area,
      price: price ?? this.price,
      rentalPeriod: rentalPeriod ?? this.rentalPeriod,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      facilities: facilities ?? this.facilities,
      totalRooms: totalRooms ?? this.totalRooms,
      availableRooms: availableRooms ?? this.availableRooms,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Helper untuk teks periode sewa yang mudah dibaca.
  String get rentalPeriodLabel =>
      rentalPeriod.toLowerCase() == 'yearly' ? 'tahun' : 'bulan';

  /// Helper untuk status ketersediaan kamar.
  bool get isFull => availableRooms <= 0 || !isAvailable;
}
