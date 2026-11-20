import 'package:flutter_test/flutter_test.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/dead_drop/models/food_listing.dart';

void main() {
  group('FoodListing.fromJson', () {
    test('parses an available listing with nullable fields', () {
      final listing = FoodListing.fromJson({
        'id': 1,
        'food_name': 'Kangkung',
        'description': 'Masih segar',
        'pickup_location': 'Asrama UI',
        'pickup_time': '2026-11-27T20:51:00+07:00',
        'pickup_notes': 'Temui saya di gerbang',
        'latitude': -6.34835,
        'longitude': 106.829771,
        'status': 'available',
        'status_label': 'Available',
        'owner': 'TesAPI',
        'reserved_by': null,
        'created_at': '2026-11-20T20:49:35+07:00',
        'updated_at': '2026-11-20T20:49:35+07:00',
        'claimed_at': null,
      });

      expect(listing.id, 1);
      expect(listing.foodName, 'Kangkung');
      expect(listing.latitude, -6.34835);
      expect(listing.longitude, 106.829771);
      expect(listing.reservedBy, isNull);
      expect(listing.claimedAt, isNull);
    });
  });

  group('FoodListing.listFromJson', () {
    test('parses a list of listing objects', () {
      final listings = FoodListing.listFromJson([
        {
          'id': 1,
          'food_name': 'Kangkung',
          'description': 'Masih segar',
          'pickup_location': 'Asrama UI',
          'pickup_time': '2026-11-27T20:51:00+07:00',
          'pickup_notes': 'Temui saya di gerbang',
          'latitude': -6.34835,
          'longitude': 106.829771,
          'status': 'available',
          'status_label': 'Available',
          'owner': 'TesAPI',
          'reserved_by': null,
          'created_at': '2026-11-20T20:49:35+07:00',
          'updated_at': '2026-11-20T20:49:35+07:00',
          'claimed_at': null,
        },
      ]);

      expect(listings, hasLength(1));
      expect(listings.first.foodName, 'Kangkung');
    });
  });
}