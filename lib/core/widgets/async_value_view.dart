import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_state.dart';

/// One place that maps loading / error / empty / data for any provider.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    required this.loading,
    this.onRetry,
    this.isEmpty,
    this.empty,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget loading;
  final VoidCallback? onRetry;
  final bool Function(T data)? isEmpty;
  final Widget? empty;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () => loading,
      error: (error, _) => ErrorState(onRetry: onRetry),
      data: (result) {
        final emptyView = empty;
        if (emptyView != null && (isEmpty?.call(result) ?? false)) {
          return emptyView;
        }
        return data(result);
      },
    );
  }
}