import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../modules/module_registry.dart';
import '../theme/app_theme.dart';

/// Drawer berisi kelima modul. Beranda dan Akun ada di bottom navigation.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    final user = context.watch<ApiClient>().user;

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pantry Necromancer', style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    user == null ? 'Masuk sebagai tamu' : 'Halo, ${user.username}',
                    style: theme.textTheme.bodyMedium?.copyWith(color: palette.muted),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('MODUL'),
            ),
            for (final module in appModules)
              ListTile(
                key: Key('drawer-module-${module.number}'),
                leading: Icon(module.icon, color: palette.tone(module.tone)),
                title: Text(module.title),
                subtitle: Text(module.owner),
                onTap: () {
                  final navigator = Navigator.of(context);
                  navigator.pop(); // tutup drawer dulu
                  navigator.push(module.route());
                },
              ),
          ],
        ),
      ),
    );
  }
}
