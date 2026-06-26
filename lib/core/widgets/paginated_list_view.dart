import 'package:flutter/material.dart';

/// A [ListView.builder] wrapper that triggers [onLoadMore] when the user
/// scrolls within [threshold] pixels of the bottom.
///
/// When [hasMore] is true and the list is loading, a progress indicator is
/// shown at the bottom. Set [hasMore] to false once all data is loaded.
class PaginatedListView extends StatefulWidget {
  const PaginatedListView({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.threshold = 200,
    this.padding,
    this.separatorBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
  });

  final IndexedWidgetBuilder itemBuilder;
  final int itemCount;
  final VoidCallback? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final double threshold;
  final EdgeInsetsGeometry? padding;
  final IndexedWidgetBuilder? separatorBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  late ScrollController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = ScrollController();
      _ownsController = true;
    }
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (!widget.hasMore || widget.isLoadingMore) return;
    if (!_controller.hasClients) return;
    final pos = _controller.position;
    if (pos.pixels >= pos.maxScrollExtent - widget.threshold) {
      widget.onLoadMore?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemCount =
        widget.itemCount + (widget.hasMore ? 1 : 0); // +1 for loader

    Widget itemBuilder(BuildContext context, int index) {
      if (index == widget.itemCount) {
        // Bottom loading indicator.
        return widget.isLoadingMore
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                ),
              )
            : const SizedBox.shrink();
      }
      return widget.itemBuilder(context, index);
    }

    if (widget.separatorBuilder != null) {
      return ListView.separated(
        controller: _controller,
        padding: widget.padding,
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        physics: widget.physics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: widget.separatorBuilder!,
      );
    }

    return ListView.builder(
      controller: _controller,
      padding: widget.padding,
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
