import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/graveyard_item.dart';

/// Kartu satu catatan limbah pangan ("batu nisan") pada daftar The Graveyard.
class GraveyardItemCard extends StatelessWidget {
  const GraveyardItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final GraveyardItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = PnPalette.of(context);
    final mono = AppTheme.mono(context);

    return Card(
      key: Key('graveyard-item-${item.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.55),
          width: 1.2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.info_outline, size: 15, color: palette.ember),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.reasonLabel.isEmpty ? item.reason : item.reasonLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '"${item.notes.trim()}"',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.muted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      '${item.quantity} ${item.unitLabel} · ${formatGraveyardDate(item.disposedAt)}',
                      style: mono.copyWith(color: palette.muted),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatRupiah(item.estimatedLoss),
                          style: mono.copyWith(
                            color: palette.blood,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${item.estimatedCarbonKg.toStringAsFixed(2)} kg CO₂e',
                          style: mono.copyWith(color: palette.frost),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
