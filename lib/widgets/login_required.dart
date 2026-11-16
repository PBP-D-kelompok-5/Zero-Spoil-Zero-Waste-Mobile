import 'package:flutter/material.dart';

import '../screens/login_screen.dart';

/// Ditampilkan ke tamu di halaman yang datanya butuh login, seperti
/// halaman pengenalan modul untuk tamu di situs web.
class LoginRequired extends StatelessWidget {
  const LoginRequired({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(message, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const LoginScreen(popOnSuccess: true),
                ),
              ),
              child: const Text('Masuk'),
            ),
          ],
        ),
      ),
    );
  }
}
