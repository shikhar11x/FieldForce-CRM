import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/animate_extensions.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/responsive_body.dart';
import '../../../data/models/app_user.dart';
import 'dashboard_header.dart';
import 'dashboard_skeleton.dart';

/// Shared scaffold for dashboards: header, pull-to-refresh, skeleton,
/// error state and responsive width. Screens only supply the content.
class DashboardPage<T> extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.user,
    required this.value,
    required this.onRefresh,
    required this.onRetry,
    required this.builder,
  });

  final AppUser user;
  final AsyncValue<T> value;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ResponsiveBody(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DashboardHeader(user: user).entrance(),
                    AsyncValueView<T>(
                      value: value,
                      onRetry: onRetry,
                      loading: const DashboardSkeleton(),
                      data: builder,
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