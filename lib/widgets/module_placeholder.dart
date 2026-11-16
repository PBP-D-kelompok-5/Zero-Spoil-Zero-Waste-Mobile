import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../theme/app_theme.dart';
import 'login_required.dart';

/// Isi sementara halaman modul. Setiap anggota mengganti widget ini dengan
/// halaman daftar yang memanggil endpoint DRF modulnya.
class ModulePlaceholder extends StatelessWidget {
  const ModulePlaceholder({
    super.key,
    required this.icon,
    required this.tone,
    required this.owner,
    required this.endpoint,
    required this.requiresLogin,
  });

  final IconData icon;
  final PnTone tone;
  final String owner;
  final String endpoint;
  final bool requiresLogin;

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiClient>();
    if (requiresLogin && !api.isLoggedIn) {
      return const LoginRequired(
        message: 'Data modul ini bersifat pribadi. Masuk dulu untuk melihatnya.',
      );
    }

    final theme = Theme.of(context);
    final color = PnPalette.of(context).tone(tone);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: color),
            const SizedBox(height: 16),
            Text(
              'Halaman ini sedang disiapkan',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Dikerjakan oleh $owner',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(endpoint, style: AppTheme.mono(context)),
            ),
          ],
        ),
      ),
    );
  }
}
