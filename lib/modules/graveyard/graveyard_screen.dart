import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import '../../widgets/login_required.dart';
import 'graveyard_detail_screen.dart';
import 'models/graveyard_item.dart';
import 'widgets/graveyard_item_card.dart';
import 'widgets/graveyard_summary_card.dart';

/// Modul 4 · The Graveyard & Waste Analytics, milik Adam.
///
/// Menampilkan riwayat bahan makanan yang terbuang milik pengguna dari
/// `GET /api/graveyard/items/`, ringkasan kerugian finansial serta jejak
/// karbon, pencarian & filter kategori, dan navigasi ke detail item.
class GraveyardScreen extends StatefulWidget {
  const GraveyardScreen({super.key});

  @override
  State<GraveyardScreen> createState() => _GraveyardScreenState();
}

class _GraveyardScreenState extends State<GraveyardScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<GraveyardItem> _items = const [];
  String _selectedCategory = '';
  bool _loading = false;
  String? _error;
  bool _wasLoggedIn = false;
  int _requestSeq = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isLoggedIn = context.watch<ApiClient>().isLoggedIn;
    if (isLoggedIn && !_wasLoggedIn) {
      _wasLoggedIn = true;
      Future.microtask(_fetchItems);
    } else if (!isLoggedIn && _wasLoggedIn) {
      _wasLoggedIn = false;
      _items = const [];
      _error = null;
      _loading = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter =>
      _selectedCategory.isNotEmpty || _searchController.text.trim().isNotEmpty;

  Future<void> _fetchItems() async {
    if (!mounted) return;
    final api = context.read<ApiClient>();
    if (!api.isLoggedIn) return;

    final seq = ++_requestSeq;
    setState(() {
      _loading = true;
      _error = null;
    });

    final query = <String, dynamic>{};
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) query['q'] = keyword;
    if (_selectedCategory.isNotEmpty) query['category'] = _selectedCategory;

    try {
      final data = await api.get(
        '/api/graveyard/items/',
        query: query.isEmpty ? null : query,
      );
      if (!mounted || seq != _requestSeq) return;
      if (data is List) {
        final parsed = data
            .whereType<Map<String, dynamic>>()
            .map(GraveyardItem.fromJson)
            .toList();
        setState(() {
          _items = parsed;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Format respons server tidak valid.';
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() => _selectedCategory = '');
    _fetchItems();
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiClient>();
    if (!api.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('The Graveyard')),
        body: const LoginRequired(
          message: 'Data riwayat limbah bersifat pribadi. Masuk dulu untuk melihatnya.',
        ),
      );
    }

    final theme = Theme.of(context);
    final palette = PnPalette.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Graveyard'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetchItems,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  key: const Key('graveyard-search'),
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _fetchItems(),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama bahan atau catatan...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _fetchItems();
                            },
                            icon: const Icon(Icons.clear),
                            tooltip: 'Bersihkan pencarian',
                          ),
                        IconButton(
                          key: const Key('graveyard-search-submit'),
                          onPressed: _fetchItems,
                          icon: const Icon(Icons.arrow_forward),
                          tooltip: 'Cari',
                        ),
                      ],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final entry in graveyardCategories.entries)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            key: Key('graveyard-cat-${entry.key.isEmpty ? 'ALL' : entry.key}'),
                            label: Text(entry.value),
                            selected: _selectedCategory == entry.key,
                            selectedColor: palette.blood.withValues(alpha: 0.22),
                            side: BorderSide(
                              color: _selectedCategory == entry.key
                                  ? palette.blood
                                  : theme.colorScheme.outline.withValues(alpha: 0.5),
                            ),
                            onSelected: (_) {
                              setState(() => _selectedCategory = entry.key);
                              _fetchItems();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildListArea(context, theme, palette),
          ),
        ],
      ),
    );
  }

  Widget _buildListArea(
    BuildContext context,
    ThemeData theme,
    PnPalette palette,
  ) {
    if (_loading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: palette.blood),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('graveyard-retry'),
                onPressed: _fetchItems,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchItems,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (_loading) ...[
            LinearProgressIndicator(color: palette.blood),
            const SizedBox(height: 12),
          ],
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: palette.blood.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: palette.blood),
              ),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(color: palette.blood),
              ),
            ),
          ],
          GraveyardSummaryCard(items: _items),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Batu Nisan Pangan (${_items.length})',
                style: theme.textTheme.titleMedium,
              ),
              if (_hasActiveFilter)
                TextButton(
                  key: const Key('graveyard-reset-filter'),
                  onPressed: _resetFilters,
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.45),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.delete_sweep_outlined,
                    size: 44,
                    color: palette.muted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _hasActiveFilter
                        ? 'Tidak ada catatan limbah yang sesuai dengan pencarian atau filter.'
                        : 'Belum ada bahan makanan yang masuk ke Graveyard.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: palette.muted,
                    ),
                  ),
                  if (_hasActiveFilter) ...[
                    const SizedBox(height: 14),
                    OutlinedButton(
                      onPressed: _resetFilters,
                      child: const Text('Tampilkan semua'),
                    ),
                  ],
                ],
              ),
            )
          else
            for (final item in _items)
              GraveyardItemCard(
                item: item,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => GraveyardDetailScreen(
                      itemId: item.id,
                      initialItem: item,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
