import 'package:flutter/material.dart';

import '../widgets/app_drawer.dart';
import 'account_screen.dart';
import 'home_screen.dart';

/// Kerangka utama: bottom navigation (Beranda, Akun) dan drawer (lima modul).
/// Halaman modul dibuka di atas kerangka ini dengan tombol kembali.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Pantry Necromancer', 'Akun'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), AccountScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
