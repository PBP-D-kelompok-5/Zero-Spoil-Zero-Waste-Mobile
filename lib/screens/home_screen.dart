import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../modules/module_registry.dart';
import '../theme/app_theme.dart';

/// Beranda: sapaan dan kartu kelima modul (padanan halaman depan situs).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    final user = context.watch<ApiClient>().user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          user == null ? 'Selamat datang, Tamu' : 'Halo, ${user.username}',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Selamatkan sisa bahan sebelum terbuang.',
          style: theme.textTheme.bodyMedium?.copyWith(color: palette.muted),
        ),
        const SizedBox(height: 16),
        for (final module in appModules)
          Card(
            key: Key('home-module-${module.number}'),
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: palette.tone(module.tone), width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Icon(module.icon, color: palette.tone(module.tone), size: 32),
              title: Text(module.title, style: theme.textTheme.titleMedium),
              subtitle: Text(module.description),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => module.open(context),
            ),
          ),
      ],
    );
  }
}
