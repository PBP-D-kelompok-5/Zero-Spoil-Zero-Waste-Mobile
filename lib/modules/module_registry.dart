import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'dead_drop/dead_drop_screen.dart';
import 'death_clock/death_clock_screen.dart';
import 'graveyard/graveyard_screen.dart';
import 'grimoire/grimoire_screen.dart';
import 'recipe_alchemist/recipe_alchemist_screen.dart';

/// Data satu modul untuk drawer dan kartu di beranda.
class ModuleInfo {
  const ModuleInfo({
    required this.number,
    required this.title,
    required this.owner,
    required this.description,
    required this.icon,
    required this.tone,
    required this.builder,
  });

  final int number;
  final String title;
  final String owner;
  final String description;
  final IconData icon;
  final PnTone tone;
  final WidgetBuilder builder;

  Route<void> route() => MaterialPageRoute<void>(builder: builder);

  void open(BuildContext context) => Navigator.of(context).push(route());
}

/// Urutan dan nama mengikuti situs web. Tambah/ubah modul cukup di sini.
final List<ModuleInfo> appModules = [
  ModuleInfo(
    number: 1,
    title: 'Pantry Death Clock',
    owner: 'Michael Evan Putra Nugroho',
    description: 'Inventaris bahan makanan dengan status Stable, Critical, dan Flatlining.',
    icon: Icons.hourglass_bottom,
    tone: PnTone.ecto,
    builder: (_) => const DeathClockScreen(),
  ),
  ModuleInfo(
    number: 2,
    title: 'Recipe Alchemist',
    owner: 'Nuno Mikael Nugroho',
    description: 'Resep penyelamat dari sisa bahan, termasuk resep komunitas.',
    icon: Icons.science_outlined,
    tone: PnTone.hex,
    builder: (_) => const RecipeAlchemistScreen(),
  ),
  ModuleInfo(
    number: 3,
    title: 'The Dead Drop',
    owner: 'Joshua Carnsyn Suyanto Sidik',
    description: 'Berbagi surplus bahan makanan dengan tetangga kost.',
    icon: Icons.volunteer_activism_outlined,
    tone: PnTone.ember,
    builder: (_) => const DeadDropScreen(),
  ),
  ModuleInfo(
    number: 4,
    title: 'The Graveyard',
    owner: 'Adam Wahyu Syaputra',
    description: 'Catatan bahan yang terbuang beserta kerugian uang dan emisi CO₂.',
    icon: Icons.delete_sweep_outlined,
    tone: PnTone.blood,
    builder: (_) => const GraveyardScreen(),
  ),
  ModuleInfo(
    number: 5,
    title: 'Preservation Grimoire',
    owner: 'Muhammad Syarifudin',
    description: 'Wiki teknik pengawetan dan panduan smell test.',
    icon: Icons.menu_book_outlined,
    tone: PnTone.frost,
    builder: (_) => const GrimoireScreen(),
  ),
];
