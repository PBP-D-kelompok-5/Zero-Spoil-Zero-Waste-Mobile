import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';
import 'package:zero_spoil_zero_waste_mobile/main.dart';
import 'package:zero_spoil_zero_waste_mobile/theme/app_theme.dart';

/// Server palsu: tamu belum login, dan login "evan" selalu berhasil.
ApiClient _fakeApi() => ApiClient(
      baseUrl: 'https://pws.example',
      httpClient: MockClient((request) async {
        final body = switch (request.url.path) {
          '/api/auth/me/' => {'status': true, 'is_authenticated': false, 'user': null},
          '/api/auth/login/' => {
              'status': true,
              'user': {'id': 1, 'username': 'evan'},
              'csrf_token': 't',
            },
          _ => {'status': true},
        };
        return http.Response(jsonEncode(body), 200,
            headers: {'content-type': 'application/json'});
      }),
    );

void main() {
  setUpAll(() => AppTheme.googleFontsEnabled = false);

  testWidgets('tamu: login, lanjut sebagai tamu, drawer berisi lima modul', (tester) async {
    await tester.pumpWidget(PantryNecromancerApp(api: _fakeApi()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('login-submit')), findsOneWidget);

    await tester.tap(find.byKey(const Key('login-guest')));
    await tester.pumpAndSettle();

    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Selamat datang, Tamu'), findsOneWidget);

    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    for (var number = 1; number <= 5; number++) {
      expect(find.byKey(Key('drawer-module-$number')), findsOneWidget);
    }

    // Modul privat meminta tamu untuk masuk.
    await tester.tap(find.byKey(const Key('drawer-module-1')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Pantry Death Clock'), findsOneWidget);
    expect(find.textContaining('Masuk dulu'), findsOneWidget);
  });

  testWidgets('login berhasil membuka beranda dengan nama pengguna', (tester) async {
    await tester.pumpWidget(PantryNecromancerApp(api: _fakeApi()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('login-username')), 'evan');
    await tester.enterText(find.byKey(const Key('login-password')), 'rahasia');
    await tester.tap(find.byKey(const Key('login-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Halo, evan'), findsOneWidget);
    await tester.tap(find.text('Akun'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-logout')), findsOneWidget);

    // Biarkan SnackBar "Selamat datang" selesai supaya tidak ada timer tertinggal.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
