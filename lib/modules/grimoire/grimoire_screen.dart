import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/module_placeholder.dart';

/// Modul 5 · Preservation Grimoire & Smell Test, milik Syarif.
///
/// TODO (Checkpoint 1): ganti `ModulePlaceholder` dengan halaman daftar panduan pengawetan,
/// yang memanggil `GET /api/grimoire/guides/` lewat `context.read<ApiClient>().get(...)`.
/// Taruh model Dart (fromJson) di `lib/modules/grimoire/models/` dan widget
/// tambahan di `lib/modules/grimoire/widgets/`. Ubah file di folder modul ini saja.
class GrimoireScreen extends StatelessWidget {
  const GrimoireScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preservation Grimoire')),
      body: const ModulePlaceholder(
        icon: Icons.menu_book_outlined,
        tone: PnTone.frost,
        owner: 'Muhammad Syarifudin',
        endpoint: 'GET /api/grimoire/guides/',
        requiresLogin: false,
      ),
    );
  }
}
