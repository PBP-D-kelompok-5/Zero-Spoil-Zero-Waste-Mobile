import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/login_required.dart';
import 'death_clock_service.dart';
import 'models/pantry_item.dart';
import 'widgets/pantry_item_card.dart';

/// Modul 1 · Pantry Death Clock, milik Michael Evan.
///
/// Checkpoint 1: daftar bahan dari `GET /api/death-clock/items/`, dengan filter status
/// dan pencarian. Data bersifat pribadi, jadi tamu diminta masuk dulu.
class DeathClockScreen extends StatelessWidget {
  const DeathClockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loggedIn = context.select<ApiClient, bool>((api) => api.isLoggedIn);
    return Scaffold(
      appBar: AppBar(title: const Text('Pantry Death Clock')),
      body: loggedIn
          ? const PantryListView()
          : const LoginRequired(
              message: 'Data modul ini bersifat pribadi. Masuk dulu untuk melihatnya.',
            ),
    );
  }
}

class PantryListView extends StatefulWidget {
  const PantryListView({super.key});

  @override
  State<PantryListView> createState() => _PantryListViewState();
}

class _PantryListViewState extends State<PantryListView> {
  /// null = semua bahan aktif (default situs web).
  static const List<PantryStatus?> _filters = [
    null,
    PantryStatus.flatlining,
    PantryStatus.critical,
    PantryStatus.stable,
    PantryStatus.resurrected,
  ];

  final _search = TextEditingController();
  PantryStatus? _status;
  String _query = '';
  late Future<List<PantryItem>> _items;

  @override
  void initState() {
    super.initState();
    _items = _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<List<PantryItem>> _load() =>
      DeathClockService(context.read<ApiClient>()).fetchItems(status: _status, query: _query);

  void _reload() => setState(() => _items = _load());

  Future<void> _refresh() async {
    final items = _load();
    setState(() => _items = items);
    try {
      await items;
    } on ApiException {
      // Pesan error ditampilkan oleh FutureBuilder.
    }
  }

  void _selectStatus(PantryStatus? status) {
    if (status == _status) return;
    _status = status;
    _reload();
  }

  void _submitSearch(String value) {
    _query = value.trim();
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final palette = PnPalette.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const Key('death-clock-search'),
            controller: _search,
            textInputAction: TextInputAction.search,
            onSubmitted: _submitSearch,
            decoration: InputDecoration(
              hintText: 'Cari nama bahan atau catatan…',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Hapus pencarian',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        _submitSearch('');
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _filters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = _filters[index];
              return ChoiceChip(
                key: Key('death-clock-chip-${status?.code ?? 'ALL'}'),
                label: Text(status?.label ?? 'Semua aktif'),
                selected: _status == status,
                selectedColor: status == null
                    ? null
                    : palette.tone(status.tone).withValues(alpha: 0.25),
                onSelected: (_) => _selectStatus(status),
              );
            },
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<PantryItem>>(
              future: _items,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return _MessageList(
                    icon: Icons.cloud_off,
                    message: error is ApiException
                        ? error.message
                        : 'Data tidak bisa dimuat.',
                    action: OutlinedButton(
                      key: const Key('death-clock-retry'),
                      onPressed: _reload,
                      child: const Text('Coba lagi'),
                    ),
                  );
                }
                final items = snapshot.data ?? const <PantryItem>[];
                if (items.isEmpty) {
                  return _MessageList(
                    icon: Icons.inventory_2_outlined,
                    message: _status == null && _query.isEmpty
                        ? 'Inventarismu masih kosong. Bahan yang ditambahkan di situs web akan muncul di sini.'
                        : 'Tidak ada bahan yang cocok dengan filter ini.',
                  );
                }
                return ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => PantryItemCard(
                    key: Key('death-clock-item-${items[index].id}'),
                    item: items[index],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Pesan kosong/error yang tetap bisa ditarik untuk refresh.
class _MessageList extends StatelessWidget {
  const _MessageList({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 48),
        Icon(icon, size: 48, color: PnPalette.of(context).muted),
        const SizedBox(height: 16),
        Text(message, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
        if (action != null) ...[
          const SizedBox(height: 16),
          Center(child: action),
        ],
      ],
    );
  }
}
