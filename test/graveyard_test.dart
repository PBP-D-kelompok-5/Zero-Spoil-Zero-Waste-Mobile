import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/graveyard/graveyard_screen.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/graveyard/models/graveyard_item.dart';
import 'package:zero_spoil_zero_waste_mobile/theme/app_theme.dart';

Map<String, dynamic> _sampleItemJson({
  int id = 1,
  String name = 'Susu UHT',
  String category = 'DAIRY',
  String categoryLabel = 'Produk Olahan Susu',
  String reason = 'EXPIRED',
  String reasonLabel = 'Sudah melewati tanggal kedaluwarsa',
  String notes = 'Terlupa di belakang kulkas',
  double estimatedLoss = 18000.0,
  double estimatedCarbonKg = 8.0,
}) =>
    {
      'id': id,
      'name': name,
      'category': category,
      'category_label': categoryLabel,
      'reason': reason,
      'reason_label': reasonLabel,
      'notes': notes,
      'expiry_date': '2026-11-15',
      'disposed_at': '2026-11-16',
      'quantity': 1,
      'unit': 'l',
      'unit_label': 'liter',
      'weight_g': 1000.0,
      'effective_weight_kg': 1.0,
      'estimated_loss': estimatedLoss,
      'estimated_carbon_kg': estimatedCarbonKg,
      'created_at': '2026-11-16T18:00:00+07:00',
      'updated_at': '2026-11-16T18:00:00+07:00',
    };

Widget _wrapScreen(ApiClient api) => ChangeNotifierProvider<ApiClient>.value(
      value: api,
      child: MaterialApp(
        theme: AppTheme.dark(),
        home: const GraveyardScreen(),
      ),
    );

void main() {
  setUpAll(() => AppTheme.googleFontsEnabled = false);

  test('GraveyardItem.fromJson mem-parsing seluruh field dan helper format bekerja', () {
    final item = GraveyardItem.fromJson(_sampleItemJson());
    expect(item.id, 1);
    expect(item.name, 'Susu UHT');
    expect(item.category, 'DAIRY');
    expect(item.categoryLabel, 'Produk Olahan Susu');
    expect(item.effectiveWeightKg, 1.0);
    expect(item.estimatedLoss, 18000.0);
    expect(item.estimatedCarbonKg, 8.0);
    expect(item.toJson()['name'], 'Susu UHT');

    expect(formatRupiah(18000), 'Rp 18.000');
    expect(formatRupiah(1250000), 'Rp 1.250.000');
    expect(formatGraveyardDate('2026-11-16'), '16 Nov 2026');
    expect(formatGraveyardDate(null), '—');
  });

  testWidgets('tamu melihat ajakan masuk di GraveyardScreen', (tester) async {
    final api = ApiClient(
      baseUrl: 'https://pws.example',
      httpClient: MockClient((_) async => http.Response('{}', 200)),
    );

    await tester.pumpWidget(_wrapScreen(api));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'The Graveyard'), findsOneWidget);
    expect(find.textContaining('Masuk dulu'), findsOneWidget);
  });

  testWidgets('pengguna login melihat daftar, ringkasan, filter kategori, dan detail',
      (tester) async {
    final requestedUrls = <Uri>[];
    final items = [
      _sampleItemJson(id: 1, name: 'Susu UHT', category: 'DAIRY', estimatedLoss: 18000),
      _sampleItemJson(
        id: 2,
        name: 'Bayam Segar',
        category: 'VEG',
        categoryLabel: 'Sayur & Buah',
        reason: 'FORGOTTEN',
        reasonLabel: 'Terlupa di sudut kulkas / rak',
        notes: 'Layu di laci bawah',
        estimatedLoss: 5000,
        estimatedCarbonKg: 0.5,
      ),
    ];

    final api = ApiClient(
      baseUrl: 'https://pws.example',
      httpClient: MockClient((request) async {
        requestedUrls.add(request.url);
        if (request.url.path == '/api/auth/login/') {
          return http.Response(
            jsonEncode({
              'status': true,
              'user': {'id': 1, 'username': 'adam'},
              'csrf_token': 'csrf',
            }),
            200,
          );
        }
        if (request.url.path == '/api/graveyard/items/') {
          final cat = request.url.queryParameters['category'];
          final q = request.url.queryParameters['q']?.toLowerCase();
          final filtered = items.where((item) {
            if (cat != null && cat.isNotEmpty && item['category'] != cat) return false;
            if (q != null &&
                q.isNotEmpty &&
                !(item['name'] as String).toLowerCase().contains(q) &&
                !(item['notes'] as String).toLowerCase().contains(q)) {
              return false;
            }
            return true;
          }).toList();
          return http.Response(jsonEncode(filtered), 200);
        }
        if (request.url.path == '/api/graveyard/items/2/') {
          return http.Response(jsonEncode(items[1]), 200);
        }
        return http.Response('{}', 404);
      }),
    );

    await api.login('adam', 'rahasia');
    await tester.pumpWidget(_wrapScreen(api));
    await tester.pumpAndSettle();

    expect(find.text('Susu UHT'), findsOneWidget);
    expect(find.text('Bayam Segar'), findsOneWidget);
    expect(find.text('Rp 23.000'), findsOneWidget);
    expect(find.text('2 bahan'), findsOneWidget);
    expect(find.text('8.50 kg CO₂e'), findsOneWidget);

    // Filter kategori VEG
    await tester.tap(find.byKey(const Key('graveyard-cat-VEG')));
    await tester.pumpAndSettle();
    expect(find.text('Susu UHT'), findsNothing);
    expect(find.text('Bayam Segar'), findsOneWidget);
    expect(requestedUrls.last.queryParameters['category'], 'VEG');

    // Tap item untuk membuka halaman detail (/api/graveyard/items/2/)
    await tester.tap(find.byKey(const Key('graveyard-item-2')));
    await tester.pumpAndSettle();

    expect(requestedUrls.any((u) => u.path == '/api/graveyard/items/2/'), isTrue);
    expect(find.text('Layu di laci bawah'), findsOneWidget);
    expect(find.text('RINCIAN PENCATATAN'), findsOneWidget);
  });

  testWidgets('error server menampilkan pesan dan tombol coba lagi berhasil', (tester) async {
    var shouldFail = true;
    final api = ApiClient(
      baseUrl: 'https://pws.example',
      httpClient: MockClient((request) async {
        if (request.url.path == '/api/auth/login/') {
          return http.Response(
            jsonEncode({
              'status': true,
              'user': {'id': 1, 'username': 'adam'},
              'csrf_token': 'csrf',
            }),
            200,
          );
        }
        if (request.url.path == '/api/graveyard/items/') {
          if (shouldFail) {
            return http.Response(jsonEncode({'detail': 'Server sibuk'}), 500);
          }
          return http.Response(jsonEncode([_sampleItemJson()]), 200);
        }
        return http.Response('{}', 404);
      }),
    );

    await api.login('adam', 'rahasia');
    await tester.pumpWidget(_wrapScreen(api));
    await tester.pumpAndSettle();

    expect(find.text('Server sibuk'), findsOneWidget);
    shouldFail = false;
    await tester.tap(find.byKey(const Key('graveyard-retry')));
    await tester.pumpAndSettle();

    expect(find.text('Susu UHT'), findsOneWidget);
  });
}
