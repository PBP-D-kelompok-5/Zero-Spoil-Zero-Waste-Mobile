import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'screens/home_shell.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(PantryNecromancerApp(api: ApiClient()));
}

class PantryNecromancerApp extends StatelessWidget {
  const PantryNecromancerApp({super.key, required this.api});

  /// Satu klien untuk seluruh aplikasi, supaya session login dipakai bersama
  /// oleh semua modul. Ambil dengan `context.read<ApiClient>()`.
  final ApiClient api;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ApiClient>.value(
      value: api,
      child: MaterialApp(
        title: 'Pantry Necromancer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const StartupGate(),
      ),
    );
  }
}

/// Cek session yang masih aktif (mis. cookie browser di Flutter web),
/// lalu buka beranda atau halaman login.
class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  late final Future<void> _restore;

  @override
  void initState() {
    super.initState();
    _restore = Provider.of<ApiClient>(context, listen: false).restoreSession();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _restore,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        // Hanya dibaca sekali saat start; perpindahan setelah login/logout diatur Navigator.
        final api = Provider.of<ApiClient>(context, listen: false);
        return api.isLoggedIn
            ? const HomeShell()
            : const LoginScreen();
      },
    );
  }
}
