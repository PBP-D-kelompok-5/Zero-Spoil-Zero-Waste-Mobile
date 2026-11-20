class FoodListing {
  const FoodListing({
    required this.id,
    required this.foodName,
    required this.description,
    required this.pickupLocation,
    required this.pickupTime,
    required this.pickupNotes,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.statusLabel,
    required this.owner,
    this.reservedBy,
    required this.createdAt,
    required this.updatedAt,
    this.claimedAt,
  });

  final int id;
  final String foodName;
  final String description;
  final String pickupLocation;
  final DateTime pickupTime;
  final String pickupNotes;
  final double latitude;
  final double longitude;
  final String status;
  final String statusLabel;
  final String owner;
  final String? reservedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? claimedAt;

  factory FoodListing.fromJson(Map<String, dynamic> json) {
    return FoodListing(
      id: json['id'] as int,
      foodName: json['food_name'] as String,
      description: json['description'] as String,
      pickupLocation: json['pickup_location'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      pickupNotes: json['pickup_notes'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] as String,
      statusLabel: json['status_label'] as String,
      owner: json['owner'] as String,
      reservedBy: json['reserved_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      claimedAt: json['claimed_at'] == null
          ? null
          : DateTime.parse(json['claimed_at'] as String),
    );
  }

  static List<FoodListing> listFromJson(dynamic data) {
    if (data is! List) {
      throw const FormatException('Expected a list of food listings.');
    }

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException(
          'Expected each listing to be a JSON object.',
        );
      }
      return FoodListing.fromJson(item);
    }).toList();
  }
}
