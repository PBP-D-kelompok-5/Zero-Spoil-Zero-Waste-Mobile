import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/module_placeholder.dart';

/// Modul 2 · Recipe Alchemist, milik Nuno.
///
/// TODO (Checkpoint 1): ganti `ModulePlaceholder` dengan halaman daftar resep dengan tab Koleksi Saya dan Komunitas (Koleksi Saya butuh login),
/// yang memanggil `GET /api/recipes/?scope=community` lewat `context.read<ApiClient>().get(...)`.
/// Taruh model Dart (fromJson) di `lib/modules/recipe_alchemist/models/` dan widget
/// tambahan di `lib/modules/recipe_alchemist/widgets/`. Ubah file di folder modul ini saja.
class RecipeAlchemistScreen extends StatelessWidget {
  const RecipeAlchemistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Alchemist')),
      body: const ModulePlaceholder(
        icon: Icons.science_outlined,
        tone: PnTone.hex,
        owner: 'Nuno Mikael Nugroho',
        endpoint: 'GET /api/recipes/?scope=community',
        requiresLogin: false,
      ),
    );
  }
}
