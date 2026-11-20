import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/testing.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/dead_drop/dead_drop_service.dart';

const _listingJson = {
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
};

void main() {
  test(
    'fetchListings requests the list endpoint and parses its response',
    () async {
      final api = ApiClient(
        baseUrl: 'https://example.test',
        httpClient: MockClient(
          (_) async => http.Response(jsonEncode([_listingJson]), 200),
        ),
      );
      final service = DeadDropService(api);

      final listings = await service.fetchListings(status: 'available');

      expect(listings, hasLength(1));
      expect(listings.first.foodName, 'Kangkung');
    },
  );

  test(
    'fetchListing requests the detail endpoint and parses its response',
    () async {
      final api = ApiClient(
        baseUrl: 'https://example.test',
        httpClient: MockClient((request) async {
          expect(request.url.path, '/api/dead-drop/listings/1/');
          return http.Response(jsonEncode(_listingJson), 200);
        }),
      );
      final service = DeadDropService(api);

      final listing = await service.fetchListing(1);

      expect(listing.id, 1);
      expect(listing.foodName, 'Kangkung');
    },
  );
}
