import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../qr/providers/qr_provider.dart';
import '../providers/customer_provider.dart';

/// Customer ka QR: isse print karke customer ki jagah par lagao. Employee
/// visit par ise scan karke apni maujoodgi verify karta hai.
class CustomerQrScreen extends ConsumerWidget {
  const CustomerQrScreen({super.key, required this.customerId});

  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final payload = ref.watch(customerQrPayloadProvider(customerId));
    final customers = ref.watch(customersProvider).value;
    final customer =
        customers == null ? null : findCustomer(customers, customerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Customer QR code')),
      body: ResponsiveBody(
        maxWidth: 520,
        child: AsyncValueView<String>(
          value: payload,
          onRetry: () => ref.invalidate(customerQrPayloadProvider(customerId)),
          loading: const SkeletonBox(height: 320, radius: AppRadius.lg),
          data: (data) => ListView(
            children: [
              AppCard(
                child: Column(
                  children: [
                    if (customer != null) ...[
                      Text(
                        customer.company,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    // QR ke peeche safed background zaroori hai (dark mode me bhi).
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.mdAll,
                      ),
                      child: QrImageView(
                        data: data,
                        version: QrVersions.auto,
                        size: 240,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Print this code and place it at the customer. '
                      'Employees scan it during a visit, and their GPS '
                      'location is checked against the customer.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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