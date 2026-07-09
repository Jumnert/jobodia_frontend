import 'package:flutter/material.dart';

/// A pull-to-refresh scrollable list. Wraps a [RefreshIndicator] around a
/// [ListView.builder] and keeps the gesture working even when [items] is empty
/// by rendering [emptyState] inside an always-scrollable scroll view.
///
/// ```dart
/// RefreshableList<Job>(
///   items: controller.jobs,
///   onRefresh: controller.reload,
///   emptyState: const EmptyState(
///     icon: Icons.work_outline,
///     title: 'No jobs yet',
///   ),
///   itemBuilder: (context, job, index) => JobCard(job: job),
/// )
/// ```
class RefreshableList<T> extends StatelessWidget {
  const RefreshableList({
    super.key,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
    this.padding,
    this.emptyState,
    this.controller,
  });

  /// The items to render, one per row.
  final List<T> items;

  /// Called when the user pulls to refresh. Completes when the refresh ends.
  final Future<void> Function() onRefresh;

  /// Builds a row for [items] at the given index.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Padding applied around the list (and the empty state).
  final EdgeInsets? padding;

  /// Shown when [items] is empty. Pull-to-refresh stays available.
  final Widget? emptyState;

  /// Optional external scroll controller.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && emptyState != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: controller,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: emptyState,
              ),
            );
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        itemCount: items.length,
        itemBuilder: (context, index) =>
            itemBuilder(context, items[index], index),
      ),
    );
  }
}
