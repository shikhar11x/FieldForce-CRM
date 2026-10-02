import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/qr_provider.dart';
import '../widgets/scanner_view.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  bool _busy = false;

  static const _steps = [
    (Icons.place_outlined, 'Reach the customer location'),
    (Icons.qr_code_scanner_rounded, "Point the camera at the customer's QR code"),
    (Icons.verified_outlined, 'Hold steady until the code is verified'),
  ];

  static const _demos = [
    (
      Icons.check_circle_outline_rounded,
      'Valid code: Apex Pharma',
      'fieldforce://customer/c4',
    ),
    (
      Icons.wrong_location_outlined,
      'Valid code, but too far away',
      'fieldforce://customer/c4?sim=far',
    ),
    (
      Icons.event_busy_outlined,
      'Customer with no visit: Ocean Logistics',
      'fieldforce://customer/c8',
    ),
    (
      Icons.error_outline_rounded,
      'Unrecognised code',
      'not-a-fieldforce-code',
    ),
  ];

  Future<void> _simulate(String payload) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() => _busy = true);
    try {
      await ref.read(qrScanProvider.notifier).scan(payload, user.name);
      if (!mounted) return;
      await context.push('${user.role.basePath}/qr/result');
    } catch (_) {
      if (mounted) {
        context.showSnack('Could not verify the code. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR code')),
      body: ResponsiveBody(
        maxWidth: 520,
        child: ListView(
          children: [
            ScannerView(busy: _busy),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => context.showSnack(
                              'Torch control arrives with the camera in Phase 2.',
                            ),
                    icon: const Icon(Icons.flashlight_on_outlined),
                    label: const Text('Torch'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => context.showSnack(
                              'Scanning from the gallery arrives in Phase 2.',
                            ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SectionHeader(title: 'How it works'),
            AppCard(
              child: Column(
                children: [
                  for (final (i, step) in _steps.indexed) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Icon(step.$1, color: theme.colorScheme.primary),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            step.$2,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SectionHeader(title: 'Demo scans'),
            Text(
              'There is no camera in Phase 1. Use these buttons to simulate '
              'what a scan would return.',
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: AppSpacing.md),
            for (final demo in _demos) ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : () => _simulate(demo.$3),
                icon: Icon(demo.$1),
                label: Text(demo.$2),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}