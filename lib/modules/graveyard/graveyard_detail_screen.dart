import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api_client.dart';
import '../../theme/app_theme.dart';
import 'models/graveyard_item.dart';

/// Halaman detail satu catatan bahan makanan yang berakhir di The Graveyard.
///
/// Mengambil data terbaru dari `GET /api/graveyard/items/<id>/` sambil tetap
/// menampilkan [initialItem] bila dikirim dari halaman daftar.
class GraveyardDetailScreen extends StatefulWidget {
  const GraveyardDetailScreen({
    super.key,
    required this.itemId,
    this.initialItem,
  });

  final int itemId;
  final GraveyardItem? initialItem;

  @override
  State<GraveyardDetailScreen> createState() => _GraveyardDetailScreenState();
}

class _GraveyardDetailScreenState extends State<GraveyardDetailScreen> {
  GraveyardItem? _item;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.initialItem;
    Future.microtask(_fetchDetail);
  }

  Future<void> _fetchDetail() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await context
          .read<ApiClient>()
          .get('/api/graveyard/items/${widget.itemId}/');
      if (!mounted) return;
      if (data is Map<String, dynamic>) {
        setState(() {
          _item = GraveyardItem.fromJson(data);
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Format respons detail tidak dikenali.';
          _loading = false;
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    final item = _item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.name ?? 'Detail Batu Nisan'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetchDetail,
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: _buildBody(context, theme, palette, item),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ThemeData theme,
    PnPalette palette,
    GraveyardItem? item,
  ) {
    if (_loading && item == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && item == null) {
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
                onPressed: _fetchDetail,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (item == null) {
      return const Center(child: Text('Catatan tidak ditemukan.'));
    }

    final mono = AppTheme.mono(context);

    return RefreshIndicator(
      onRefresh: _fetchDetail,
      child: ListView(
        padding: const EdgeInsets.all(16),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: palette.blood, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: palette.blood.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: palette.blood.withValues(alpha: 0.65),
                    ),
                  ),
                  child: Text(
                    item.categoryLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: palette.blood,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(item.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: palette.ember),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.reasonLabel.isEmpty ? item.reason : item.reasonLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _HighlightBox(
                  label: 'KERUGIAN UANG',
                  value: formatRupiah(item.estimatedLoss),
                  accent: palette.blood,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HighlightBox(
                  label: 'JEJAK KARBON',
                  value: '${item.estimatedCarbonKg.toStringAsFixed(2)} kg CO₂e',
                  accent: palette.frost,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RINCIAN PENCATATAN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.muted,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Kuantitas',
                  value: '${item.quantity} ${item.unitLabel}',
                  valueStyle: mono,
                ),
                _DetailRow(
                  label: 'Berat Tercatat',
                  value: '${item.weightG.toStringAsFixed(0)} g',
                  valueStyle: mono,
                ),
                _DetailRow(
                  label: 'Berat Efektif',
                  value: '${item.effectiveWeightKg.toStringAsFixed(2)} kg',
                  valueStyle: mono,
                ),
                _DetailRow(
                  label: 'Tanggal Dibuang',
                  value: formatGraveyardDate(item.disposedAt),
                  valueStyle: mono,
                ),
                _DetailRow(
                  label: 'Tanggal Kedaluwarsa',
                  value: formatGraveyardDate(item.expiryDate),
                  valueStyle: mono,
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.55),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CATATAN TAMBAHAN',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.muted,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.notes.trim().isEmpty
                      ? 'Tidak ada catatan tambahan.'
                      : item.notes.trim(),
                  style: item.notes.trim().isEmpty
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: palette.muted,
                          fontStyle: FontStyle.italic,
                        )
                      : theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightBox extends StatelessWidget {
  const _HighlightBox({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: palette.muted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTheme.mono(context).copyWith(
              color: accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.valueStyle,
    this.isLast = false,
  });

  final String label;
  final String value;
  final TextStyle valueStyle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final palette = PnPalette.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: palette.muted)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: valueStyle.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
