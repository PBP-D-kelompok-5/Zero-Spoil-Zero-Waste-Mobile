import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_user.dart';
import 'config.dart';
import 'http_client_factory.dart';

/// Klien HTTP bersama untuk semua modul. Ambil lewat Provider:
///
/// ```dart
/// final api = context.read<ApiClient>();
/// final data = await api.get('/api/grimoire/guides/', query: {'q': 'tempe'});
/// ```
///
/// - Login memakai session Django yang sama dengan situs web (cookie `sessionid`).
/// - Request tulis (POST/PUT/PATCH/DELETE) otomatis membawa header `X-CSRFToken`
///   dan `Origin`, sesuai syarat DRF di repo Django (`docs/API_MOBILE.md`).
/// - Respons 4xx/5xx dilempar sebagai [ApiException] berisi pesan dan error per field.
class ApiClient extends ChangeNotifier {
  ApiClient({String? baseUrl, http.Client? httpClient})
      : baseUrl = _withoutTrailingSlash(baseUrl ?? AppConfig.baseUrl),
        _http = httpClient ?? createHttpClient();

  final String baseUrl;
  final http.Client _http;

  /// Cookie dari server (hanya Android/desktop; di web cookie diurus browser).
  final Map<String, String> _cookies = {};
  String? _csrfToken;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;

  // ---------- Request umum ----------

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send('GET', path, query: query);

  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, Object? body) =>
      _send('PUT', path, body: body);

  Future<dynamic> patch(String path, Object? body) =>
      _send('PATCH', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Uri uri(String path, [Map<String, dynamic>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    final params = <String, String>{};
    query?.forEach((key, value) {
      if (value != null && '$value'.isNotEmpty) params[key] = '$value';
    });
    final url = Uri.parse('$baseUrl$normalized');
    return params.isEmpty ? url : url.replace(queryParameters: params);
  }

  // ---------- Autentikasi ----------

  /// Login lalu simpan user dan token CSRF. Melempar [ApiException] jika gagal.
  Future<AppUser> login(String username, String password) async {
    final data = await post('/api/auth/login/', {
      'username': username,
      'password': password,
    }) as Map<String, dynamic>;
    _csrfToken = data['csrf_token'] as String? ?? _csrfToken;
    final user = AppUser.fromJson(data['user'] as Map<String, dynamic>);
    _user = user;
    notifyListeners();
    return user;
  }

  /// Daftar akun baru. Tidak otomatis login; arahkan pengguna ke halaman login.
  Future<String> register(
    String username,
    String password1,
    String password2,
  ) async {
    final data = await post('/api/auth/register/', {
      'username': username,
      'password1': password1,
      'password2': password2,
    }) as Map<String, dynamic>;
    return data['message'] as String? ?? 'Akun berhasil dibuat.';
  }

  Future<void> logout() async {
    try {
      await post('/api/auth/logout/');
    } finally {
      _cookies.clear();
      _csrfToken = null;
      _user = null;
      notifyListeners();
    }
  }

  /// Cek apakah session masih aktif (berguna di web, tempat browser menyimpan cookie).
  Future<void> restoreSession() async {
    try {
      final data = await get('/api/auth/me/');
      _user = data is Map<String, dynamic> && data['is_authenticated'] == true
          ? AppUser.fromJson(data['user'] as Map<String, dynamic>)
          : null;
    } on ApiException {
      _user = null; // server tidak terjangkau: lanjut sebagai tamu
    }
    notifyListeners();
  }

  // ---------- Internal ----------

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
  }) async {
    final isWrite = method != 'GET';
    if (isWrite && isLoggedIn && _csrfToken == null) {
      await _refreshCsrfToken();
    }

    final request = http.Request(method, uri(path, query))
      ..headers.addAll(_headers(isWrite: isWrite, hasBody: body != null));
    if (body != null) request.body = jsonEncode(body);

    final response = await _perform(request);
    _storeCookies(response);
    return _decode(response);
  }

  Future<void> _refreshCsrfToken() async {
    final data = await get('/api/auth/csrf/') as Map<String, dynamic>;
    _csrfToken = data['csrf_token'] as String?;
  }

  Map<String, String> _headers({required bool isWrite, required bool hasBody}) {
    final headers = <String, String>{'Accept': 'application/json'};
    if (hasBody) headers['Content-Type'] = 'application/json; charset=utf-8';
    if (!kIsWeb) {
      if (_cookies.isNotEmpty) {
        headers['Cookie'] =
            _cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
      }
      // Browser mengisi Origin sendiri; klien native harus menambahkannya.
      if (isWrite) headers['Origin'] = Uri.parse(baseUrl).origin;
    }
    final token = _csrfToken;
    if (isWrite && token != null) headers['X-CSRFToken'] = token;
    return headers;
  }

  Future<http.Response> _perform(http.BaseRequest request) async {
    try {
      return await http.Response.fromStream(await _http.send(request));
    } on Exception {
      throw const ApiException(
        0,
        'Tidak bisa terhubung ke server. Cek koneksi internet kamu.',
      );
    }
  }

  void _storeCookies(http.Response response) {
    if (kIsWeb) return;
    final header = response.headers['set-cookie'];
    if (header == null || header.isEmpty) return;

    for (final cookie in splitSetCookieHeader(header)) {
      final pair = cookie.split(';').first;
      final separator = pair.indexOf('=');
      if (separator <= 0) continue;
      final name = pair.substring(0, separator).trim();
      var value = pair.substring(separator + 1).trim();
      if (value.length >= 2 && value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      final expired =
          RegExp(r'max-age=0(;|$)', caseSensitive: false).hasMatch(cookie);
      if (value.isEmpty || expired) {
        _cookies.remove(name);
      } else {
        _cookies[name] = value;
        if (name == 'csrftoken') _csrfToken = value;
      }
    }
  }

  dynamic _decode(http.Response response) {
    dynamic data;
    if (response.bodyBytes.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        data = null; // misalnya halaman error HTML
      }
    }
    final status = response.statusCode;
    if (status >= 200 && status < 300) return data;
    throw ApiException.fromResponse(status, data);
  }

  static String _withoutTrailingSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}

/// Error dari web service. [fieldErrors] berisi error per field dari serializer/form
/// Django, misalnya `{"password2": ["Kedua password tidak sama."]}`.
class ApiException implements Exception {
  const ApiException(
    this.statusCode,
    this.message, {
    this.fieldErrors = const {},
  });

  factory ApiException.fromResponse(int statusCode, dynamic data) {
    final fieldErrors = <String, List<String>>{};
    String? message;

    if (data is Map) {
      final detail = data['detail'] ?? data['message'];
      if (detail is String) message = detail;
      final errors = data['errors'] is Map ? data['errors'] as Map : data;
      errors.forEach((key, value) {
        if (key is String && value is List) {
          fieldErrors[key] = value.map((item) => '$item').toList();
        }
      });
    }

    message ??= fieldErrors.isNotEmpty
        ? fieldErrors.values.first.first
        : _defaultMessage(statusCode);
    return ApiException(statusCode, message, fieldErrors: fieldErrors);
  }

  final int statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;

  /// Pesan error pertama untuk [field], atau null.
  String? fieldError(String field) {
    final errors = fieldErrors[field];
    return errors == null || errors.isEmpty ? null : errors.first;
  }

  bool get isUnauthorized => statusCode == 401 || statusCode == 403;

  static String _defaultMessage(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return 'Silakan masuk terlebih dahulu.';
    }
    if (statusCode == 404) return 'Data tidak ditemukan.';
    if (statusCode == 429) return 'Terlalu banyak permintaan. Coba lagi nanti.';
    if (statusCode >= 500) return 'Terjadi kesalahan di server.';
    return 'Permintaan gagal (kode $statusCode).';
  }

  @override
  String toString() => message;
}

/// Memecah header `set-cookie` yang digabung dengan koma tanpa memotong
/// tanggal `expires=Tue, 16 Nov 2027 ...`.
@visibleForTesting
List<String> splitSetCookieHeader(String header) => header
    .split(RegExp(r',(?=\s*[^;,\s=]+=)'))
    .map((part) => part.trim())
    .where((part) => part.isNotEmpty)
    .toList();
