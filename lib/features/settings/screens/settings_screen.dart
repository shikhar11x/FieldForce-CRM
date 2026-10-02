import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../../core/routing/app_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_logo.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/logout_dialog.dart';
import '../providers/settings_provider.dart';

Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
  final current = ref.read(settingsProvider).language;

  final picked = await showModalBottomSheet<AppLanguage>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Language',
              style: Theme.of(sheetContext).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final language in AppLanguage.values)
            ListTile(
              title: Text(language.label),
              trailing:
                  language == current ? const Icon(Icons.check_rounded) : null,
              onTap: () => Navigator.of(sheetContext).pop(language),
            ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    ),
  );

  if (picked == null || !context.mounted) return;
  ref.read(settingsProvider.notifier).setLanguage(picked);
  context.showSnack(
    '${picked.label} selected. Translations arrive in a later phase.',
  );
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(settingsProvider.notifier);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final base = user.role.basePath;

    final pushSummary = settings.pushEnabled
        ? 'On · ${settings.enabledCategoryCount} of 5 categories'
        : 'Push notifications are off';

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ResponsiveBody(
        maxWidth: 700,
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            const SectionHeader(title: 'Account'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: user.name,
                  subtitle: user.email,
                  onTap: () => context.openProfile(user.role),
                ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change password',
                  onTap: () => context.push('$base/profile/password'),
                ),
              ],
            ),
            const SectionHeader(title: 'Notifications'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notification settings',
                  subtitle: pushSummary,
                  onTap: () => context.push('$base/settings/notifications'),
                ),
              ],
            ),
            const SectionHeader(title: 'Appearance'),
            SettingsGroup(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Theme', style: theme.textTheme.titleSmall),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<ThemeMode>(
                          showSelectedIcon: false,
                          segments: const [
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.light,
                              icon: Icon(Icons.light_mode_outlined),
                              label: Text('Light'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.dark,
                              icon: Icon(Icons.dark_mode_outlined),
                              label: Text('Dark'),
                            ),
                            ButtonSegment<ThemeMode>(
                              value: ThemeMode.system,
                              icon: Icon(Icons.brightness_auto_outlined),
                              label: Text('System'),
                            ),
                          ],
                          selected: {themeMode},
                          onSelectionChanged: (s) => ref
                              .read(themeModeProvider.notifier)
                              .set(s.first),
                        ),
                      ),
                    ],
                  ),
                ),
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  subtitle: settings.language.label,
                  onTap: () => _pickLanguage(context, ref),
                ),
              ],
            ),
            const SectionHeader(title: 'Privacy'),
            SettingsGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.my_location_rounded,
                  title: 'Share location during work hours',
                  subtitle: 'Lets your manager see your position while '
                      'you are checked in',
                  value: settings.shareLocation,
                  onChanged: notifier.setShareLocation,
                ),
                SettingsSwitchTile(
                  icon: Icons.insights_rounded,
                  title: 'Usage analytics',
                  subtitle: 'Help improve FieldForce Pro',
                  value: settings.analytics,
                  onChanged: notifier.setAnalytics,
                ),
                SettingsTile(
                  icon: Icons.download_rounded,
                  title: 'Download my data',
                  onTap: () => context.showSnack(
                    'Data export arrives in Phase 3.',
                  ),
                ),
                SettingsTile(
                  icon: Icons.policy_outlined,
                  title: 'Privacy policy',
                  onTap: () => context.showSnack(
                    'The privacy policy page is added before release.',
                  ),
                ),
              ],
            ),
            const SectionHeader(title: 'Security'),
            SettingsGroup(
              children: [
                SettingsSwitchTile(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric unlock',
                  subtitle: 'Use fingerprint or face to open the app',
                  value: settings.biometricLock,
                  onChanged: notifier.setBiometric,
                ),
                SettingsSwitchTile(
                  icon: Icons.security_rounded,
                  title: 'Two-step verification',
                  subtitle: 'Ask for a code when signing in on a new device',
                  value: settings.twoFactor,
                  onChanged: notifier.setTwoFactor,
                ),
                SettingsTile(
                  icon: Icons.devices_rounded,
                  title: 'Active sessions',
                  subtitle: 'See where you are signed in',
                  onTap: () => context.showSnack(
                    'Session management arrives in Phase 2.',
                  ),
                ),
              ],
            ),
            const SectionHeader(title: 'About'),
            SettingsGroup(
              children: [
                SettingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About ${AppConstants.appName}',
                  subtitle: 'Version 1.0.0 (Phase 1 preview)',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: AppConstants.appName,
                    applicationVersion: '1.0.0 (Phase 1 preview)',
                    applicationIcon: const AppLogo(size: 48),
                    children: const [
                      SizedBox(height: AppSpacing.md),
                      Text(AppConstants.tagline),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton.icon(
              onPressed: () => confirmAndLogout(context, ref),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}