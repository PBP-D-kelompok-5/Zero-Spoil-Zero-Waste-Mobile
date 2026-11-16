import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/module_placeholder.dart';

/// Modul 4 · The Graveyard & Waste Analytics, milik Adam.
///
/// TODO (Checkpoint 1): ganti `ModulePlaceholder` dengan halaman daftar riwayat pembuangan,
/// yang memanggil `GET /api/graveyard/items/` lewat `context.read<ApiClient>().get(...)`.
/// Taruh model Dart (fromJson) di `lib/modules/graveyard/models/` dan widget
/// tambahan di `lib/modules/graveyard/widgets/`. Ubah file di folder modul ini saja.
class GraveyardScreen extends StatelessWidget {
  const GraveyardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Graveyard')),
      body: const ModulePlaceholder(
        icon: Icons.delete_sweep_outlined,
        tone: PnTone.blood,
        owner: 'Adam Wahyu Syaputra',
        endpoint: 'GET /api/graveyard/items/',
        requiresLogin: true,
      ),
    );
  }
}
