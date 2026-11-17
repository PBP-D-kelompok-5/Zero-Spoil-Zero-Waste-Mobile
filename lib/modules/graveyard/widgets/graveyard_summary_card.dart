import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/graveyard_item.dart';

/// Kartu ringkasan analitik dampak limbah makanan pada halaman The Graveyard.
class GraveyardSummaryCard extends StatelessWidget {
  const GraveyardSummaryCard({super.key, required this.items});

  final List<GraveyardItem> items;

  @override
  Widget build(BuildContext context) {
    final palette = PnPalette.of(context);
    final totalLoss = items.fold<double>(0, (sum, item) => sum + item.estimatedLoss);
    final totalCarbon =
        items.fold<double>(0, (sum, item) => sum + item.estimatedCarbonKg);
    final totalWeight =
        items.fold<double>(0, (sum, item) => sum + item.effectiveWeightKg);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'CATATAN NISAN',
                value: '${items.length} bahan',
                accent: palette.blood,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: 'TOTAL KERUGIAN',
                value: formatRupiah(totalLoss),
                accent: palette.blood,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                label: 'JEJAK KARBON',
                value: '${totalCarbon.toStringAsFixed(2)} kg CO₂e',
                accent: palette.frost,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                label: 'BOBOT LIMBAH',
                value: '${totalWeight.toStringAsFixed(2)} kg',
                accent: palette.ember,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: palette.muted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.mono(context).copyWith(
              color: accent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
