/// Model Dart untuk satu catatan limbah makanan di modul The Graveyard,
/// mengikuti skema JSON dari `/api/graveyard/items/` (`GraveyardItemSerializer`).
class GraveyardItem {
  const GraveyardItem({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryLabel,
    required this.reason,
    required this.reasonLabel,
    required this.notes,
    required this.expiryDate,
    required this.disposedAt,
    required this.quantity,
    required this.unit,
    required this.unitLabel,
    required this.weightG,
    required this.effectiveWeightKg,
    required this.estimatedLoss,
    required this.estimatedCarbonKg,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GraveyardItem.fromJson(Map<String, dynamic> json) => GraveyardItem(
        id: _parseInt(json['id']),
        name: (json['name'] as String?) ?? '',
        category: (json['category'] as String?) ?? 'OTHER',
        categoryLabel: (json['category_label'] as String?) ?? 'Lainnya',
        reason: (json['reason'] as String?) ?? 'EXPIRED',
        reasonLabel: (json['reason_label'] as String?) ?? '',
        notes: (json['notes'] as String?) ?? '',
        expiryDate: json['expiry_date'] as String?,
        disposedAt: json['disposed_at'] as String?,
        quantity: _parseInt(json['quantity'], fallback: 1),
        unit: (json['unit'] as String?) ?? 'pcs',
        unitLabel: (json['unit_label'] as String?) ?? 'buah',
        weightG: _parseDouble(json['weight_g']),
        effectiveWeightKg: _parseDouble(json['effective_weight_kg']),
        estimatedLoss: _parseDouble(json['estimated_loss']),
        estimatedCarbonKg: _parseDouble(json['estimated_carbon_kg']),
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
      );

  final int id;
  final String name;
  final String category;
  final String categoryLabel;
  final String reason;
  final String reasonLabel;
  final String notes;
  final String? expiryDate;
  final String? disposedAt;
  final int quantity;
  final String unit;
  final String unitLabel;
  final double weightG;
  final double effectiveWeightKg;
  final double estimatedLoss;
  final double estimatedCarbonKg;
  final String? createdAt;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'category_label': categoryLabel,
        'reason': reason,
        'reason_label': reasonLabel,
        'notes': notes,
        'expiry_date': expiryDate,
        'disposed_at': disposedAt,
        'quantity': quantity,
        'unit': unit,
        'unit_label': unitLabel,
        'weight_g': weightG,
        'effective_weight_kg': effectiveWeightKg,
        'estimated_loss': estimatedLoss,
        'estimated_carbon_kg': estimatedCarbonKg,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  static int _parseInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _parseDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}

/// Pilihan kategori pangan yang selaras dengan `Category` di Django `graveyard/models.py`.
const Map<String, String> graveyardCategories = {
  '': 'Semua',
  'VEG': 'Sayur & Buah',
  'MEAT': 'Daging & Protein',
  'DAIRY': 'Produk Olahan Susu',
  'GRAIN': 'Biji-bijian & Kering',
  'OTHER': 'Lainnya',
};

const List<String> _indonesianMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

/// Memformat angka rupiah dengan pemisah ribuan titik, mis. `Rp 18.000`.
String formatRupiah(double amount) {
  final rounded = amount.round();
  final isNegative = rounded < 0;
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return '${isNegative ? '-' : ''}Rp $buffer';
}

/// Memformat string tanggal ISO (`YYYY-MM-DD` atau ISO-8601) menjadi `DD MMM YYYY`.
String formatGraveyardDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final parsed = DateTime.tryParse(raw.trim());
  if (parsed == null) return raw;
  final local = raw.contains('T') ? parsed.toLocal() : parsed;
  final month = _indonesianMonths[local.month - 1];
  return '${local.day.toString().padLeft(2, '0')} $month ${local.year}';
}
