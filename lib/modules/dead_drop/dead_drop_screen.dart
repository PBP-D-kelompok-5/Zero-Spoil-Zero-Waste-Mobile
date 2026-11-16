import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/module_placeholder.dart';

/// Modul 3 · The Dead Drop, milik Joshua.
///
/// TODO (Checkpoint 1): ganti `ModulePlaceholder` dengan papan listing yang menampilkan listing berstatus available,
/// yang memanggil `GET /api/dead-drop/listings/?status=available` lewat `context.read<ApiClient>().get(...)`.
/// Taruh model Dart (fromJson) di `lib/modules/dead_drop/models/` dan widget
/// tambahan di `lib/modules/dead_drop/widgets/`. Ubah file di folder modul ini saja.
class DeadDropScreen extends StatelessWidget {
  const DeadDropScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Dead Drop')),
      body: const ModulePlaceholder(
        icon: Icons.volunteer_activism_outlined,
        tone: PnTone.ember,
        owner: 'Joshua Carnsyn Suyanto Sidik',
        endpoint: 'GET /api/dead-drop/listings/?status=available',
        requiresLogin: false,
      ),
    );
  }
}
