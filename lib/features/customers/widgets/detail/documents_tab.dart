import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../data/models/customer_models.dart';

class DocumentsTab extends StatelessWidget {
  const DocumentsTab({super.key, required this.documents});

  final List<CustomerDocument> documents;

  void _upload(BuildContext context) =>
      context.showSnack('Document uploads arrive in Phase 2.');

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No documents',
        message: 'Contracts, certificates and proposals will be stored here.',
        actionLabel: 'Upload document',
        onAction: () => _upload(context),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.tonalIcon(
            onPressed: () => _upload(context),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Upload'),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (final doc in documents) ...[
          _DocumentCard(document: doc),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.document});

  final CustomerDocument document;

  (IconData, Color) get _style => switch (document.kind) {
        'PDF' => (Icons.picture_as_pdf_rounded, AppColors.error),
        'XLS' => (Icons.table_chart_rounded, AppColors.success),
        _ => (Icons.description_rounded, AppColors.primary),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _style;

    return AppCard(
      onTap: () => context.showSnack('Document preview arrives in Phase 2.'),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.mdAll,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${document.size} · ${document.uploaded.shortDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}