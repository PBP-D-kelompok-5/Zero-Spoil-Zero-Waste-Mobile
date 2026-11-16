import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:zero_spoil_zero_waste_mobile/core/api_client.dart';

const _base = 'https://pws.example';

http.Response _json(Object body, int status, {String? setCookie}) =>
    http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json', 'set-cookie': ?setCookie},
    );

void main() {
  test('splitSetCookieHeader tidak memotong tanggal expires', () {
    final parts = splitSetCookieHeader(
      'csrftoken=abc; expires=Tue, 16 Nov 2027 10:00:00 GMT; Max-Age=31449600; Path=/,'
      'sessionid=xyz; expires=Mon, 30 Nov 2026 10:00:00 GMT; HttpOnly; Path=/',
    );
    expect(parts, hasLength(2));
    expect(parts[0], startsWith('csrftoken=abc'));
    expect(parts[1], startsWith('sessionid=xyz'));
  });

  test('login menyimpan session, lalu request tulis membawa cookie, CSRF, dan Origin', () async {
    final requests = <http.Request>[];
    final api = ApiClient(
      baseUrl: _base,
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path == '/api/auth/login/') {
          return _json(
            {
              'status': true,
              'message': 'ok',
              'username': 'evan',
              'user': {'id': 7, 'username': 'evan'},
              'csrf_token': 'token-dari-json',
            },
            200,
            setCookie:
                'csrftoken=cookie-token; expires=Tue, 16 Nov 2027 10:00:00 GMT; Path=/,'
                'sessionid=sesi123; expires=Mon, 30 Nov 2026 10:00:00 GMT; HttpOnly; Path=/',
          );
        }
        return _json({'ok': true}, 200);
      }),
    );

    final user = await api.login('evan', 'rahasia');
    expect(user.id, 7);
    expect(api.isLoggedIn, isTrue);
    expect(jsonDecode(requests.first.body), {
      'username': 'evan',
      'password': 'rahasia',
    });

    await api.get(
      '/api/grimoire/guides/',
      query: {'q': 'tempe', 'category': ''},
    );
    final read = requests.last;
    expect(read.url.toString(), '$_base/api/grimoire/guides/?q=tempe');
    expect(read.headers['Cookie'], contains('sessionid=sesi123'));
    expect(read.headers.containsKey('X-CSRFToken'), isFalse);

    await api.post('/api/dead-drop/listings/1/reserve/', {'note': 'x'});
    final write = requests.last;
    expect(write.method, 'POST');
    expect(write.headers['X-CSRFToken'], isNotEmpty);
    expect(write.headers['Origin'], _base);
    expect(write.headers['Cookie'], contains('csrftoken='));
    expect(write.headers['Content-Type'], startsWith('application/json'));
  });

  test('error per field dari server dibaca sebagai ApiException', () async {
    final api = ApiClient(
      baseUrl: _base,
      httpClient: MockClient(
        (_) async => _json({
          'status': false,
          'message': 'Kedua password tidak sama.',
          'errors': {
            'password2': ['Kedua password tidak sama.'],
          },
        }, 400),
      ),
    );

    await expectLater(
      api.register('baru', 'a', 'b'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)
            .having(
              (e) => e.fieldError('password2'),
              'password2',
              'Kedua password tidak sama.',
            ),
      ),
    );
  });

  test('error DRF {"detail": ...} dan 403 tamu', () async {
    final api = ApiClient(
      baseUrl: _base,
      httpClient: MockClient(
        (_) async => _json({'detail': 'Kredensial tidak diberikan.'}, 403),
      ),
    );
    await expectLater(
      api.get('/api/death-clock/items/'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
            .having((e) => e.message, 'message', 'Kredensial tidak diberikan.'),
      ),
    );
  });

  test('logout menghapus session lokal walaupun server gagal', () async {
    var loggedIn = false;
    final api = ApiClient(
      baseUrl: _base,
      httpClient: MockClient((request) async {
        if (request.url.path == '/api/auth/login/') {
          loggedIn = true;
          return _json({
            'user': {'id': 1, 'username': 'evan'},
            'csrf_token': 't',
          }, 200);
        }
        return http.Response('server error', 500);
      }),
    );
    await api.login('evan', 'x');
    expect(loggedIn, isTrue);
    await expectLater(api.logout(), throwsA(isA<ApiException>()));
    expect(api.isLoggedIn, isFalse);
  });

  test('server tidak terjangkau menjadi ApiException kode 0', () async {
    final api = ApiClient(
      baseUrl: _base,
      httpClient: MockClient(
        (_) async => throw http.ClientException('offline'),
      ),
    );
    await expectLater(
      api.get('/api/auth/me/'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 0)),
    );
  });
}
