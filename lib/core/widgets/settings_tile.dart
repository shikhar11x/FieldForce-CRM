import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';

/// Card that stacks settings rows with dividers between them.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final (i, child) in children.indexed) ...[
            if (i > 0) const Divider(indent: 72),
            child,
          ],
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.mdAll,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    final sub = subtitle;

    return ListTile(
      onTap: onTap,
      leading: _IconBox(icon: icon, color: tint),
      title: Text(title),
      subtitle: sub == null ? null : Text(sub),
      trailing: trailing ??
          (onTap == null ? null : const Icon(Icons.chevron_right_rounded)),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.color,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? Theme.of(context).colorScheme.primary;
    final sub = subtitle;

    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: _IconBox(icon: icon, color: tint),
      title: Text(title),
      subtitle: sub == null ? null : Text(sub),
    );
  }
}