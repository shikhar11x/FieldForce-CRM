import 'package:flutter/material.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.color,
  });

  final String name;
  final double radius;
  final Color? color;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = color ?? theme.colorScheme.primary;

    return CircleAvatar(
      radius: radius,
      backgroundColor: tint.withValues(alpha: 0.14),
      child: Text(
        _initials,
        style: theme.textTheme.labelLarge?.copyWith(color: tint),
      ),
    );
  }
}