import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import 'grimoire_detail_screen.dart';
import 'models/guide.dart';
import 'widgets/grimoire_guide_card.dart';

/// Modul 5 · Preservation Grimoire & Smell Test, milik Syarif.
class GrimoireScreen extends StatefulWidget {
  const GrimoireScreen({super.key});

  @override
  State<GrimoireScreen> createState() => _GrimoireScreenState();
}

class _GrimoireScreenState extends State<GrimoireScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = '';
  List<Guide> _guides = [];
  bool _isLoading = true;
  String? _error;

  static const Map<String, String> _categories = {
    '': 'Semua',
    'VEG': 'Sayur & Buah',
    'MEAT': 'Daging & Protein',
    'DAIRY': 'Susu',
    'GRAIN': 'Biji-bijian',
    'OTHER': 'Lainnya',
  };

  @override
  void initState() {
    super.initState();
    _fetchGuides();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchGuides() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiClient>();
      final query = <String, String>{};
      final keyword = _searchController.text.trim();
      if (keyword.isNotEmpty) query['q'] = keyword;
      if (_selectedCategory.isNotEmpty) query['category'] = _selectedCategory;

      final data = await api.get(
        '/api/grimoire/guides/',
        query: query.isNotEmpty ? query : null,
      );
      if (!mounted) return;
      final list = (data as List)
          .map((item) => Guide.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
      setState(() {
        _guides = list;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat daftar Preservation Grimoire.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preservation Grimoire')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _fetchGuides(),
              decoration: InputDecoration(
                hintText: 'Cari judul, metode, atau isi panduan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _fetchGuides();
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final entry = _categories.entries.elementAt(index);
                final selected = _selectedCategory == entry.key;
                return ChoiceChip(
                  label: Text(entry.value),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _selectedCategory = entry.key);
                    _fetchGuides();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _fetchGuides,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : _guides.isEmpty
                        ? RefreshIndicator(
                            onRefresh: _fetchGuides,
                            child: ListView(
                              children: const [
                                SizedBox(height: 120),
                                Center(
                                  child: Text('Belum ada panduan Grimoire.'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchGuides,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _guides.length,
                              itemBuilder: (context, index) {
                                final guide = _guides[index];
                                return GrimoireGuideCard(
                                  guide: guide,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => GrimoireDetailScreen(
                                          guideId: guide.id,
                                          initialGuide: guide,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}