import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/kos_model.dart';
import '../providers/auth_provider.dart';
import '../providers/kos_provider.dart';
import '../widgets/filter_dialog.dart';

/// Formulir untuk menambah kos baru (US05) atau mengedit kos (US06).
class KosFormScreen extends StatefulWidget {
  final KosModel? existingKos;

  const KosFormScreen({super.key, this.existingKos});

  @override
  State<KosFormScreen> createState() => _KosFormScreenState();
}

class _KosFormScreenState extends State<KosFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;
  late TextEditingController _whatsappController;
  late TextEditingController _imageUrlController;
  late TextEditingController _totalRoomsController;
  late TextEditingController _availableRoomsController;

  late String _rentalPeriod;
  late String _type;
  late Set<String> _selectedFacilities;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final k = widget.existingKos;
    _nameController = TextEditingController(text: k?.name ?? '');
    _addressController = TextEditingController(text: k?.address ?? '');
    _areaController = TextEditingController(text: k?.area ?? '');
    _priceController = TextEditingController(
      text: k != null ? k.price.toInt().toString() : '',
    );
    _whatsappController = TextEditingController(text: k?.whatsappNumber ?? '');
    _imageUrlController = TextEditingController(text: k?.imageUrl ?? '');
    _totalRoomsController = TextEditingController(
      text: (k?.totalRooms ?? 1).toString(),
    );
    _availableRoomsController = TextEditingController(
      text: (k?.availableRooms ?? 1).toString(),
    );

    _rentalPeriod = k?.rentalPeriod ?? 'monthly';
    _type = k?.type ?? 'campur';
    _selectedFacilities = Set.from(k?.facilities ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _whatsappController.dispose();
    _imageUrlController.dispose();
    _totalRoomsController.dispose();
    _availableRoomsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Validasi form (US05-AC2)
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final kosProvider = context.read<KosProvider>();

    final ownerId = authProvider.user?.id ?? widget.existingKos?.ownerId ?? '';
    if (ownerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sesi pemilik tidak valid. Silakan login ulang.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final totalRooms = int.tryParse(_totalRoomsController.text.trim()) ?? 1;
    final availableRooms = int.tryParse(_availableRoomsController.text.trim()) ?? 1;

    final kos = KosModel(
      id: widget.existingKos?.id ?? '',
      ownerId: ownerId,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      area: _areaController.text.trim(),
      price: price,
      rentalPeriod: _rentalPeriod,
      type: _type,
      imageUrl: _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null,
      whatsappNumber: _whatsappController.text.trim(),
      facilities: _selectedFacilities.toList(),
      totalRooms: totalRooms,
      availableRooms: availableRooms,
      isAvailable: availableRooms > 0,
      isActive: widget.existingKos?.isActive ?? true,
    );

    setState(() => _isSaving = true);

    final bool success;
    if (widget.existingKos == null) {
      success = await kosProvider.createKos(kos);
    } else {
      success = await kosProvider.updateKos(kos);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingKos == null
                  ? 'Kos berhasil ditambahkan!'
                  : 'Data kos berhasil diperbarui!',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              kosProvider.errorMessage ?? 'Gagal menyimpan kos. Coba lagi.',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingKos != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Ubah Data Kos' : 'Tambah Kos Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nama Kos (Wajib)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Kos *',
                  hintText: 'Contoh: Kos Melati Asri',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_work_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Area & Alamat (Wajib)
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(
                  labelText: 'Area / Sekitar Kampus *',
                  hintText: 'Contoh: Singaraja, Kampus Tengah',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Area kos wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Lengkap *',
                  hintText: 'Contoh: Jl. Udayana No. 12',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pin_drop_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Alamat lengkap wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga & Periode Sewa (Wajib Angka)
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Harga (Rp) *',
                        hintText: '850000',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Harga wajib diisi';
                        }
                        final num = double.tryParse(val.trim());
                        if (num == null || num <= 0) {
                          return 'Harga harus angka positif';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _rentalPeriod,
                      decoration: const InputDecoration(
                        labelText: 'Periode',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'monthly', child: Text('Per Bulan')),
                        DropdownMenuItem(value: 'yearly', child: Text('Per Tahun')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _rentalPeriod = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tipe Kos
              DropdownButtonFormField<String>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Tipe Kos',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'campur', child: Text('Campur (Putra & Putri)')),
                  DropdownMenuItem(value: 'putra', child: Text('Khusus Putra')),
                  DropdownMenuItem(value: 'putri', child: Text('Khusus Putri')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _type = val);
                },
              ),
              const SizedBox(height: 16),

              // Nomor WhatsApp (Wajib)
              TextFormField(
                controller: _whatsappController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor WhatsApp Pemilik *',
                  hintText: '081234567890',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor WhatsApp wajib diisi';
                  }
                  if (val.trim().length < 9) {
                    return 'Nomor WhatsApp minimal 9 digit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL Foto Kos
              TextFormField(
                controller: _imageUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'URL Foto Kos (Direct Link)',
                  hintText: 'https://images.unsplash.com/...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Jumlah Kamar
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalRoomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Total Kamar',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(val) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _availableRoomsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kamar Tersedia',
                        border: OutlineInputBorder(),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Wajib diisi';
                        if (int.tryParse(val) == null) return 'Harus angka';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Checklist Fasilitas
              const Text(
                'Fasilitas Kos:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: kStandardFacilities.map((f) {
                  final isSelected = _selectedFacilities.contains(f);
                  return FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedFacilities.add(f);
                        } else {
                          _selectedFacilities.remove(f);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),

              // Tombol Simpan
              ElevatedButton(
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEdit ? 'Simpan Perubahan' : 'Terbitkan Kos',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
