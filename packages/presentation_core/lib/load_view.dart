import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'presentation_core.dart';

/// Renders the standard loading, empty, failure and success states.
class LoadView<T> extends StatelessWidget {
  const LoadView({
    super.key,
    required this.state,
    required this.builder,
    required this.emptyMessage,
    required this.onRetry,
  });

  final LoadState<T> state;
  final Widget Function(BuildContext context, T value) builder;
  final String emptyMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
    Initial<T>() || Loading<T>() => const HareupLoading(),
    Empty<T>() => EmptyNotice(message: emptyMessage),
    Failed<T>(:final failure) => ErrorNotice(
      message: failure.message,
      onRetry: onRetry,
    ),
    Loaded<T>(:final data) => builder(context, data),
  };
}
