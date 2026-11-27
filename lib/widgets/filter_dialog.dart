import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Daftar fasilitas standar untuk filter pencarian.
const List<String> kStandardFacilities = [
  'WiFi',
  'AC',
  'Kamar Mandi Dalam',
  'Kasur',
  'Lemari',
  'Parkir Motor',
];

/// Modal Bottom Sheet untuk menyaring harga sewa maksimal dan checklist fasilitas.
class FilterBottomSheet extends StatefulWidget {
  final double? initialMaxPrice;
  final List<String> initialFacilities;
  final Function(double? maxPrice, List<String> facilities) onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    this.initialMaxPrice,
    required this.initialFacilities,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _maxPrice;
  late bool _hasPriceFilter;
  late Set<String> _selectedFacilities;

  @override
  void initState() {
    super.initState();
    _hasPriceFilter = widget.initialMaxPrice != null && widget.initialMaxPrice! > 0;
    _maxPrice = widget.initialMaxPrice ?? 3000000;
    _selectedFacilities = Set.from(widget.initialFacilities);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Dialog
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Kos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _hasPriceFilter = false;
                      _maxPrice = 3000000;
                      _selectedFacilities.clear();
                    });
                    widget.onReset();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Filter Harga Maksimum
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Harga Maksimum',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Switch(
                  value: _hasPriceFilter,
                  onChanged: (val) {
                    setState(() {
                      _hasPriceFilter = val;
                    });
                  },
                ),
              ],
            ),
            if (_hasPriceFilter) ...[
              Text(
                'Maksimal: ${currencyFormatter.format(_maxPrice)} / bulan',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Slider(
                value: _maxPrice,
                min: 300000,
                max: 5000000,
                divisions: 47,
                label: currencyFormatter.format(_maxPrice),
                onChanged: (val) {
                  setState(() {
                    _maxPrice = val;
                  });
                },
              ),
            ] else ...[
              const Text(
                'Semua rentang harga (tanpa batas maksimum)',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Filter Checklist Fasilitas (US03-AC2)
            const Text(
              'Fasilitas Tersedia',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
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

            const SizedBox(height: 24),

            // Tombol Terapkan Filter
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(
                    _hasPriceFilter ? _maxPrice : null,
                    _selectedFacilities.toList(),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Terapkan Filter',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
