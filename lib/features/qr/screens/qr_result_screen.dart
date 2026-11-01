import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/datetime_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/detail_row.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/qr_models.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/qr_provider.dart';

class QrResultScreen extends ConsumerWidget {
  const QrResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final result = ref.watch(qrScanProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Verification result')),
      body: ResponsiveBody(
        maxWidth: 560,
        child: result == null
            ? const EmptyState(
                icon: Icons.qr_code_2_rounded,
                title: 'No scan result',
                message: 'Scan a customer QR code to see the result here.',
              )
            : _ResultContent(result: result, basePath: user.role.basePath),
      ),
    );
  }
}

class _ResultContent extends StatelessWidget {
  const _ResultContent({required this.result, required this.basePath});

  final QrScanResult result;
  final String basePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final distance = result.distanceMeters;
    final accuracy = result.accuracyMeters;

    final (icon, color, title, message) = switch (result.status) {
      QrVerificationStatus.verified => (
          Icons.verified_rounded,
          AppColors.success,
          'Visit verified',
          'The QR code and your location match. You can start the visit.',
        ),
      QrVerificationStatus.locationMismatch => (
          Icons.wrong_location_rounded,
          AppColors.warning,
          'Too far from the customer',
          'You are about ${distance ?? '?'} m away (limit '
              '${result.geofenceMeters} m). Move closer and scan again.',
        ),
      QrVerificationStatus.lowAccuracy => (
          Icons.gps_not_fixed_rounded,
          AppColors.warning,
          'GPS signal is too weak',
          'Your location is only accurate to about ${accuracy ?? '?'} m. '
              'Step outside or near a window, wait a few seconds and scan again.',
        ),
      QrVerificationStatus.customerNotLocated => (
          Icons.location_off_rounded,
          AppColors.info,
          "Customer location isn't set",
          'Ask a manager or admin to add this customer\'s location, then try again.',
        ),
      QrVerificationStatus.noVisit => (
          Icons.event_busy_rounded,
          AppColors.info,
          'No active visit',
          'You have no scheduled or started visit for this customer.',
        ),
      QrVerificationStatus.invalid => (
          Icons.error_outline_rounded,
          AppColors.error,
          'Unrecognised QR code',
          'This is not a valid FieldForce customer code. Try again.',
        ),
    };

    final customer = result.customerName;
    final address = result.address;
    final purpose = result.visitPurpose;
    final scheduled = result.visitScheduledAt;
    final visitId = result.visitId;
    final scannedTime =
        TimeOfDay.fromDateTime(result.scannedAt).format(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      children: [
        AppCard(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: color),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              StatusChip(label: result.status.label, color: color),
            ],
          ),
        ),
        const SectionHeader(title: 'Scan details'),
        AppCard(
          child: Column(
            children: [
              if (customer != null)
                DetailRow(
                  icon: Icons.business_rounded,
                  label: 'Customer',
                  value: customer,
                ),
              if (address != null)
                DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Location',
                  value: address,
                ),
              if (purpose != null)
                DetailRow(
                  icon: Icons.flag_outlined,
                  label: 'Visit',
                  value: scheduled == null
                      ? purpose
                      : '$purpose\n${scheduled.dayLabel}',
                ),
              if (distance != null)
                DetailRow(
                  icon: Icons.social_distance_rounded,
                  label: 'Distance from customer',
                  value: '$distance m (limit ${result.geofenceMeters} m)',
                ),
              if (accuracy != null)
                DetailRow(
                  icon: Icons.gps_fixed_rounded,
                  label: 'GPS accuracy',
                  value: 'about $accuracy m',
                ),
              DetailRow(
                icon: Icons.schedule_rounded,
                label: 'Scanned at',
                value: scannedTime,
              ),
              if (customer == null)
                const DetailRow(
                  icon: Icons.info_outline_rounded,
                  label: 'Customer',
                  value: 'Could not be identified',
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        if (result.status == QrVerificationStatus.verified &&
            visitId != null) ...[
          FilledButton.icon(
            onPressed: () => context.go('$basePath/visits/$visitId'),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open visit'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        OutlinedButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.qr_code_scanner_rounded),
          label: const Text('Scan another code'),
        ),
      ],
    );
  }
}