import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/location/device_location.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_colors.dart';
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
  final _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool _busy = false;
  bool _canOpenSettings = false;
  String? _message;

  // Result screen se wapas aane par wahi QR dobara scan na ho jaye.
  DateTime _cooldownUntil = DateTime.fromMillisecondsSinceEpoch(0);

  static const _steps = [
    (Icons.place_outlined, 'Reach the customer location'),
    (Icons.qr_code_scanner_rounded, "Point the camera at the customer's QR code"),
    (Icons.my_location_rounded, 'Allow location so we can confirm you are there'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy || DateTime.now().isBefore(_cooldownUntil)) return;

    String? raw;
    for (final barcode in capture.barcodes) {
      final value = barcode.rawValue;
      if (value != null && value.isNotEmpty) {
        raw = value;
        break;
      }
    }
    if (raw == null) return;

    final user = ref.read(authProvider).user;
    if (user == null) return;

    setState(() {
      _busy = true;
      _message = null;
      _canOpenSettings = false;
    });

    try {
      final fix = await getDeviceFix();
      await ref.read(qrScanProvider.notifier).scan(raw, fix);
      if (!mounted) return;
      await context.push('${user.role.basePath}/qr/result');
    } on LocationException catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _canOpenSettings = e.canOpenSettings;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not verify the code. Try again.');
      }
    } finally {
      _cooldownUntil = DateTime.now().add(const Duration(seconds: 3));
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      // Is device me torch nahi hai.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR code')),
      body: ResponsiveBody(
        maxWidth: 520,
        child: ListView(
          children: [
            ScannerView(
              busy: _busy,
              caption: _busy
                  ? 'Checking the code and your location...'
                  : "Point the camera at the customer's QR code",
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  ValueListenableBuilder<MobileScannerState>(
                    valueListenable: _controller,
                    builder: (context, state, _) {
                      if (state.error == null) return const SizedBox.shrink();
                      return const ColoredBox(
                        color: Colors.black,
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Text(
                              'The camera is not available. Allow camera '
                              'access for this app in your phone settings.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _busy ? null : _toggleTorch,
              icon: const Icon(Icons.flashlight_on_outlined),
              label: const Text('Torch'),
            ),
            if (_message != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            _message!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    if (_canOpenSettings)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: openLocationAppSettings,
                          child: const Text('Open settings'),
                        ),
                      ),
                  ],
                ),
              ),
            ],
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
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}