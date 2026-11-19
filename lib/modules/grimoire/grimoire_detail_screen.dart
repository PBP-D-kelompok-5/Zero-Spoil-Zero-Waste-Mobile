import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import 'models/guide.dart';

class GrimoireDetailScreen extends StatefulWidget {
  final int guideId;
  final Guide? initialGuide;

  const GrimoireDetailScreen({
    super.key,
    required this.guideId,
    this.initialGuide,
  });

  @override
  State<GrimoireDetailScreen> createState() => _GrimoireDetailScreenState();
}

class _GrimoireDetailScreenState extends State<GrimoireDetailScreen> {
  Guide? _guide;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _guide = widget.initialGuide;
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = context.read<ApiClient>();
      final data = await api.get('/api/grimoire/guides/${widget.guideId}/');
      if (!mounted) return;
      setState(() {
        _guide = Guide.fromJson(Map<String, dynamic>.from(data as Map));
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
        _error = 'Gagal memuat detail panduan.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = PnPalette.of(context);
    final guide = _guide;

    return Scaffold(
      appBar: AppBar(title: Text(guide?.title ?? 'Detail Grimoire')),
      body: _isLoading && guide == null
          ? const Center(child: CircularProgressIndicator())
          : _error != null && guide == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _fetchDetail,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDetail,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (guide!.categoryLabel.isNotEmpty)
                            Chip(
                              label: Text(guide.categoryLabel),
                              backgroundColor:
                                  palette.hex.withValues(alpha: 0.15),
                            ),
                          if (guide.preservationMethod.isNotEmpty)
                            Chip(
                              label: Text(guide.preservationMethod),
                              backgroundColor:
                                  palette.ecto.withValues(alpha: 0.15),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        guide.title,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Oleh @${guide.author} • ${guide.totalUpvotes} upvotes',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Divider(height: 24),
                      _InfoSection(
                        title: 'Panduan Pengawetan',
                        content: guide.content,
                        accent: palette.ecto,
                      ),
                      _InfoSection(
                        title: 'Indikator Bau (Smell Test)',
                        content: guide.smellIndicator,
                        accent: palette.ember,
                      ),
                      _InfoSection(
                        title: 'Indikator Tekstur',
                        content: guide.textureIndicator,
                        accent: palette.frost,
                      ),
                      _InfoSection(
                        title: 'Indikator Visual',
                        content: guide.visualIndicator,
                        accent: palette.blood,
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String content;
  final Color accent;

  const _InfoSection({
    required this.title,
    required this.content,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: accent, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(content),
          ],
        ),
      ),
    );
  }
}