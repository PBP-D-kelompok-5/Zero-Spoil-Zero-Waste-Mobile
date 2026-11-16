// Memilih klien HTTP sesuai platform: Android/desktop memakai klien biasa
// (cookie diatur manual oleh ApiClient), web memakai BrowserClient yang
// mengirim cookie lewat browser (withCredentials).
export 'http_client_factory_io.dart'
    if (dart.library.js_interop) 'http_client_factory_web.dart';
