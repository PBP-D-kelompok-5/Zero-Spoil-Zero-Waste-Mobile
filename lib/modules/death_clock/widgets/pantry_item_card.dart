import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/pantry_item.dart';

/// Kartu satu bahan: nama, status, sisa hari, dan meter sisa umur
/// (padanan `templates/death_clock/partials/item_card.html` di situs).
class PantryItemCard extends StatelessWidget {
  const PantryItemCard({super.key, required this.item});

  final PantryItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    final color = palette.tone(item.status.tone);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: color, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(label: item.statusLabel, color: color),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item.quantityLabel} · ${item.storageLabel} · ${item.categoryLabel}',
              style: theme.textTheme.bodySmall?.copyWith(color: palette.muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  item.isResurrected ? Icons.auto_awesome : Icons.hourglass_bottom,
                  size: 18,
                  color: color,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.isResurrected
                        ? 'Sudah diolah'
                        : item.expiryIsEstimate
                            ? '${item.countdownLabel} (perkiraan)'
                            : item.countdownLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (!item.isResurrected) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: item.lifePercent / 100,
                  minHeight: 6,
                  color: color,
                  backgroundColor: palette.raised,
                  semanticsLabel: 'Sisa umur',
                  semanticsValue: '${item.lifePercent}%',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
      ),
    );
  }
}
