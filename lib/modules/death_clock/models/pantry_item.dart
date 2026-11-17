import '../../../theme/app_theme.dart';

/// Status peluruhan bahan, dihitung server dari tanggal kedaluwarsa.
enum PantryStatus {
  flatlining('FLATLINING', 'Flatlining', PnTone.blood),
  critical('CRITICAL', 'Critical', PnTone.ember),
  stable('STABLE', 'Stable', PnTone.ecto),
  resurrected('RESURRECTED', 'Resurrected', PnTone.hex);

  const PantryStatus(this.code, this.label, this.tone);

  /// Nilai yang dikirim/diterima API, misalnya `?status=CRITICAL`.
  final String code;
  final String label;

  /// Warna aksen, sama dengan situs (`STATUS_TONES` di death_clock/models.py).
  final PnTone tone;

  static PantryStatus fromCode(String code) => PantryStatus.values.firstWhere(
        (status) => status.code == code,
        orElse: () => PantryStatus.stable,
      );
}

/// Satu bahan di inventaris, dari `GET /api/death-clock/items/` atau `.../items/<id>/`.
/// Field mengikuti `PantryItemSerializer` (sama dengan `PantryItem.to_dict()` di Django).
class PantryItem {
  const PantryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryLabel,
    required this.quantity,
    required this.unit,
    required this.unitLabel,
    required this.storage,
    required this.storageLabel,
    required this.purchaseDate,
    required this.expiryDate,
    required this.expiryIsEstimate,
    required this.daysLeft,
    required this.countdownLabel,
    required this.status,
    required this.statusLabel,
    required this.lifePercent,
    required this.notes,
    required this.isResurrected,
    this.resurrectedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String,
        categoryLabel: json['category_label'] as String,
        quantity: json['quantity'] as int,
        unit: json['unit'] as String,
        unitLabel: json['unit_label'] as String,
        storage: json['storage'] as String,
        storageLabel: json['storage_label'] as String,
        purchaseDate: DateTime.parse(json['purchase_date'] as String),
        expiryDate: DateTime.parse(json['expiry_date'] as String),
        expiryIsEstimate: json['expiry_is_estimate'] as bool,
        daysLeft: json['days_left'] as int,
        countdownLabel: json['countdown_label'] as String,
        status: PantryStatus.fromCode(json['status'] as String),
        statusLabel: json['status_label'] as String,
        lifePercent: json['life_percent'] as int,
        notes: json['notes'] as String? ?? '',
        isResurrected: json['is_resurrected'] as bool,
        resurrectedAt: _parseDateTime(json['resurrected_at']),
        createdAt: _parseDateTime(json['created_at']),
        updatedAt: _parseDateTime(json['updated_at']),
      );

  static List<PantryItem> listFromJson(dynamic data) => (data as List)
      .map((item) => PantryItem.fromJson(item as Map<String, dynamic>))
      .toList();

  static DateTime? _parseDateTime(Object? value) =>
      value is String ? DateTime.parse(value) : null;

  final int id;
  final String name;
  final String category;
  final String categoryLabel;
  final int quantity;
  final String unit;
  final String unitLabel;
  final String storage;
  final String storageLabel;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final bool expiryIsEstimate;
  final int daysLeft;
  final String countdownLabel;
  final PantryStatus status;
  final String statusLabel;

  /// Sisa umur 0-100, untuk meter di kartu.
  final int lifePercent;
  final String notes;
  final bool isResurrected;
  final DateTime? resurrectedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Contoh: "2 liter".
  String get quantityLabel => '$quantity $unitLabel';
}
