import 'package:flutter/material.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';

const _formats = [
  (Icons.picture_as_pdf_rounded, 'PDF', 'Formatted and ready to share'),
  (Icons.table_chart_rounded, 'Excel', 'Spreadsheet with all figures'),
  (Icons.description_rounded, 'CSV', 'Raw data for other tools'),
];

/// Export options. UI-only in Phase 1; real exports are a Phase 3 item.
Future<void> showExportSheet(
  BuildContext context, {
  required String reportName,
  required String rangeLabel,
}) async {
  final format = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);

      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'Export $reportName',
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                2,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                rangeLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final (icon, label, hint) in _formats)
              ListTile(
                leading: Icon(icon),
                title: Text(label),
                subtitle: Text(hint),
                onTap: () => Navigator.of(sheetContext).pop(label),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      );
    },
  );

  if (format != null && context.mounted) {
    context.showSnack('Exporting as $format arrives in Phase 3.');
  }
}