import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/module_placeholder.dart';

/// Modul 1 · Pantry Death Clock, milik Michael Evan.
///
/// TODO (Checkpoint 1): ganti `ModulePlaceholder` dengan halaman daftar kartu bahan (nama, status, sisa hari),
/// yang memanggil `GET /api/death-clock/items/` lewat `context.read<ApiClient>().get(...)`.
/// Taruh model Dart (fromJson) di `lib/modules/death_clock/models/` dan widget
/// tambahan di `lib/modules/death_clock/widgets/`. Ubah file di folder modul ini saja.
class DeathClockScreen extends StatelessWidget {
  const DeathClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pantry Death Clock')),
      body: const ModulePlaceholder(
        icon: Icons.hourglass_bottom,
        tone: PnTone.ecto,
        owner: 'Michael Evan Putra Nugroho',
        endpoint: 'GET /api/death-clock/items/',
        requiresLogin: true,
      ),
    );
  }
}
