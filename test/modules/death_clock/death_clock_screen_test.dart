import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';
import 'package:zero_spoil_zero_waste_mobile/modules/death_clock/death_clock_screen.dart';
import 'package:zero_spoil_zero_waste_mobile/theme/app_theme.dart';

import 'fixtures.dart';

/// Server palsu yang meniru /api/death-clock/items/ (termasuk filter status dan q).
class _FakeServer {
  final requests = <Uri>[];
  bool failItems = false;

  late final ApiClient api = ApiClient(
    baseUrl: 'https://pws.example',
    httpClient: MockClient((request) async {
      requests.add(request.url);
      if (request.url.path == '/api/auth/login/') {
        return _json({'user': {'id': 1, 'username': 'evan'}, 'csrf_token': 't'});
      }
      if (request.url.path == '/api/death-clock/items/') {
        if (failItems) return http.Response('error', 500);
        final status = request.url.queryParameters['status'];
        final query = (request.url.queryParameters['q'] ?? '').toLowerCase();
        final items = (jsonDecode(pantryItemsJson) as List).cast<Map<String, dynamic>>().where((item) {
          final matchesStatus =
              status == null ? item['status'] != 'RESURRECTED' : item['status'] == status;
          final matchesQuery = (item['name'] as String).toLowerCase().contains(query);
          return matchesStatus && matchesQuery;
        }).toList();
        return _json(items);
      }
      return http.Response('not found', 404);
    }),
  );

  static http.Response _json(Object body) => http.Response(
        jsonEncode(body),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}

Widget _app(ApiClient api) => ChangeNotifierProvider<ApiClient>.value(
      value: api,
      child: MaterialApp(theme: AppTheme.dark(), home: const DeathClockScreen()),
    );

/// Layar setinggi HP supaya semua kartu fixture ikut dirender oleh ListView.
void _useTallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() => AppTheme.googleFontsEnabled = false);

  testWidgets('tamu diminta masuk dan tidak memanggil API', (tester) async {
    final server = _FakeServer();
    await tester.pumpWidget(_app(server.api));
    await tester.pumpAndSettle();

    expect(find.textContaining('Masuk dulu'), findsOneWidget);
    expect(server.requests, isEmpty);
  });

  testWidgets('menampilkan bahan aktif, lalu filter status dan pencarian', (tester) async {
    _useTallScreen(tester);
    final server = _FakeServer();
    await server.api.login('evan', 'rahasia');

    await tester.pumpWidget(_app(server.api));
    await tester.pumpAndSettle();

    // Default: bahan aktif saja (Kaldu Ayam sudah diolah, jadi tidak tampil).
    expect(find.text('Tahu Putih'), findsOneWidget);
    expect(find.text('Susu UHT'), findsOneWidget);
    expect(find.text('Beras'), findsOneWidget);
    expect(find.text('Kaldu Ayam'), findsNothing);
    expect(find.text('Lewat 1 hari'), findsOneWidget);
    expect(find.text('60 hari lagi (perkiraan)'), findsOneWidget);

    await tester.tap(find.byKey(const Key('death-clock-chip-CRITICAL')));
    await tester.pumpAndSettle();
    expect(server.requests.last.queryParameters['status'], 'CRITICAL');
    expect(find.text('Susu UHT'), findsOneWidget);
    expect(find.text('Tahu Putih'), findsNothing);

    await tester.tap(find.byKey(const Key('death-clock-chip-RESURRECTED')));
    await tester.pumpAndSettle();
    expect(find.text('Kaldu Ayam'), findsOneWidget);
    expect(find.text('Sudah diolah'), findsOneWidget);

    await tester.tap(find.byKey(const Key('death-clock-chip-ALL')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('death-clock-search')), 'beras');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(server.requests.last.queryParameters['q'], 'beras');
    expect(find.text('Beras'), findsOneWidget);
    expect(find.text('Susu UHT'), findsNothing);
  });

  testWidgets('error server menampilkan pesan dan tombol coba lagi', (tester) async {
    _useTallScreen(tester);
    final server = _FakeServer()..failItems = true;
    await server.api.login('evan', 'rahasia');

    await tester.pumpWidget(_app(server.api));
    await tester.pumpAndSettle();
    expect(find.text('Terjadi kesalahan di server.'), findsOneWidget);

    server.failItems = false;
    await tester.tap(find.byKey(const Key('death-clock-retry')));
    await tester.pumpAndSettle();
    expect(find.text('Tahu Putih'), findsOneWidget);
  });
}
