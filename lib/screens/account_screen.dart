import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api_client.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final api = context.read<ApiClient>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await api.logout();
      messenger.showSnackBar(
        const SnackBar(content: Text('Kamu sudah keluar. Sampai jumpa lagi!')),
      );
    } on ApiException catch (e) {
      // Session lokal tetap dihapus oleh ApiClient walaupun server gagal dihubungi.
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    }
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final api = context.watch<ApiClient>();
    final user = api.user;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          leading: const Icon(Icons.account_circle, size: 40),
          title: Text(user?.username ?? 'Tamu', style: theme.textTheme.titleLarge),
          subtitle: Text(user == null ? 'Belum masuk' : 'Masuk dengan akun situs web'),
        ),
        const SizedBox(height: 16),
        if (user == null)
          FilledButton(
            key: const Key('account-login'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LoginScreen(popOnSuccess: true),
              ),
            ),
            child: const Text('Masuk atau daftar'),
          )
        else
          OutlinedButton.icon(
            key: const Key('account-logout'),
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
          ),
        const SizedBox(height: 32),
        Text('Server', style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        SelectableText(api.baseUrl, style: AppTheme.mono(context)),
      ],
    );
  }
}
