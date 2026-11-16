/// Konfigurasi alamat server Django.
///
/// Default-nya situs PWS. Untuk tes dengan Django lokal, jalankan misalnya:
///   flutter run --dart-define=BASE_URL=http://10.0.2.2:8000   (emulator Android)
///   flutter run -d chrome --web-port 5000 --dart-define=BASE_URL=http://localhost:8000
class AppConfig {
  AppConfig._();

  static const String pwsUrl =
      'https://michael-evan51-pantry-necromancer.pws.cs.ui.ac.id';

  static const String baseUrl =
      String.fromEnvironment('BASE_URL', defaultValue: pwsUrl);
}
