import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/context_extensions.dart';
import '../../../core/extensions/map_style_extensions.dart';
import '../../../core/extensions/task_style_extensions.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/skeleton_box.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../data/models/map_models.dart';
import '../../../data/models/user_role.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/map_provider.dart';
import '../widgets/map_canvas.dart';

enum _Layer {
  team('Team', Icons.groups_rounded, MapMarkerKind.employee),
  customers('Customers', Icons.storefront_rounded, MapMarkerKind.customer),
  visits('Visit stops', Icons.place_rounded, MapMarkerKind.visit);

  const _Layer(this.label, this.icon, this.kind);
  final String label;
  final IconData icon;
  final MapMarkerKind kind;
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Set<_Layer> _layers = {..._Layer.values};
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    // Employees don't see other team members' locations.
    if (ref.read(authProvider).user?.role == UserRole.employee) {
      _layers.remove(_Layer.team);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(mapDataProvider);
    try {
      await ref.read(mapDataProvider.future);
    } catch (_) {
      // The error state is rendered by AsyncValueView.
    }
  }

  void _select(MapMarkerData marker) {
    setState(() => _selectedId = marker.id == _selectedId ? null : marker.id);
  }

  List<Widget> _content(BuildContext context, MapData data, bool isEmployee) {
    final byId = {for (final m in data.markers) m.id: m};

    final visible = [
      for (final m in data.markers)
        if (m.kind == MapMarkerKind.me || _layers.any((l) => l.kind == m.kind))
          m,
    ];

    final routeStops = _layers.contains(_Layer.visits)
        ? [
            for (final id in data.route)
              if (byId[id] != null) byId[id]!,
          ]
        : <MapMarkerData>[];

    final people =
        visible.where((m) => m.kind == MapMarkerKind.employee).toList();

    MapMarkerData? selected;
    for (final m in visible) {
      if (m.id == _selectedId) selected = m;
    }

    final theme = Theme.of(context);
    final layers =
        _Layer.values.where((l) => !(isEmployee && l == _Layer.team));

    return [
      Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final layer in layers)
            FilterChip(
              avatar: Icon(layer.icon, size: 18),
              label: Text(layer.label),
              selected: _layers.contains(layer),
              showCheckmark: false,
              onSelected: (on) => setState(() {
                if (on) {
                  _layers.add(layer);
                } else {
                  _layers.remove(layer);
                }
              }),
            ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      MapCanvas(
        markers: visible,
        route: routeStops,
        selectedId: selected?.id,
        onSelect: _select,
        height: context.isPhone ? 340 : 460,
      ),
      const SizedBox(height: AppSpacing.md),
      if (selected != null)
        _DetailCard(
          marker: selected,
          onClose: () => setState(() => _selectedId = null),
        )
      else
        Text(
          'Tap a marker to see details.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      if (routeStops.isNotEmpty) ...[
        const SectionHeader(title: "Today's route"),
        _MarkerList(markers: routeStops, onTap: _select),
      ],
      if (people.isNotEmpty) ...[
        const SectionHeader(title: 'Team locations'),
        _MarkerList(markers: people, onTap: _select),
      ],
      const SizedBox(height: AppSpacing.xl),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final data = ref.watch(mapDataProvider);

    // Briefly null while the router redirects after logout.
    if (user == null) return const SizedBox.shrink();

    final isEmployee = user.role == UserRole.employee;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEmployee ? 'My map' : 'Live map'),
        actions: [
          IconButton(
            tooltip: 'My location',
            icon: const Icon(Icons.my_location_rounded),
            onPressed: () =>
                context.showSnack('Live GPS location arrives in Phase 2.'),
          ),
        ],
      ),
      body: ResponsiveBody(
        maxWidth: 1000,
        child: AsyncValueView<MapData>(
          value: data,
          onRetry: () => ref.invalidate(mapDataProvider),
          loading: const _MapSkeleton(),
          data: (d) => RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: _content(context, d, isEmployee),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.marker, required this.onClose});

  final MapMarkerData marker;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = marker.color;
    final status = marker.visitStatus;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(marker.kind.icon, color: color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(marker.title, style: theme.textTheme.titleSmall),
                    Text(
                      marker.subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              StatusChip(label: marker.kind.label, color: color),
              if (status != null) ...[
                const SizedBox(width: 6),
                StatusChip(label: status.label, color: status.color),
              ],
              const Spacer(),
              if (marker.kind != MapMarkerKind.me)
                FilledButton.tonalIcon(
                  onPressed: () => context.showSnack(
                    'Turn-by-turn navigation arrives with real maps in Phase 2.',
                  ),
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: const Text('Navigate'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkerList extends StatelessWidget {
  const _MarkerList({required this.markers, required this.onTap});

  final List<MapMarkerData> markers;
  final ValueChanged<MapMarkerData> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          for (final (i, m) in markers.indexed) ...[
            if (i > 0) const Divider(indent: 72),
            ListTile(
              onTap: () => onTap(m),
              leading: CircleAvatar(
                backgroundColor: m.color,
                child: m.stopNumber != null
                    ? Text(
                        '${m.stopNumber}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                        ),
                      )
                    : Icon(m.kind.icon, size: 20, color: Colors.white),
              ),
              title: Text(m.title, style: theme.textTheme.titleSmall),
              subtitle: Text(
                m.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: m.visitStatus == null
                  ? null
                  : StatusChip(
                      label: m.visitStatus!.label,
                      color: m.visitStatus!.color,
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MapSkeleton extends StatelessWidget {
  const _MapSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 40, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 340, radius: AppRadius.lg),
        SizedBox(height: AppSpacing.md),
        SkeletonBox(height: 120, radius: AppRadius.lg),
      ],
    );
  }
}