import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../models/guide.dart';

class GrimoireGuideCard extends StatelessWidget {
  final Guide guide;
  final VoidCallback onTap;

  const GrimoireGuideCard({
    super.key,
    required this.guide,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = PnPalette.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.menu_book_outlined,
          color: palette.frost,
        ),
        title: Text(guide.title),
        subtitle: Text(
          [
            if (guide.categoryLabel.isNotEmpty) guide.categoryLabel,
            if (guide.preservationMethod.isNotEmpty) guide.preservationMethod,
            '▲ ${guide.totalUpvotes}',
          ].join(' • '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}