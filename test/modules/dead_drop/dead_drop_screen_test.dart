import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/dead_drop/dead_drop_screen.dart';

void main() {
  testWidgets('shows the fetched listing and pickup location', (tester) async {
    final api = ApiClient(
      baseUrl: 'https://example.test',
      httpClient: MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/api/dead-drop/listings/');
        expect(request.url.queryParameters['status'], 'available');

        return http.Response(
          jsonEncode([
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
          ]),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<ApiClient>.value(
        value: api,
        child: const MaterialApp(home: DeadDropScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kangkung'), findsOneWidget);
    expect(find.text('Asrama UI'), findsOneWidget);
  });
}