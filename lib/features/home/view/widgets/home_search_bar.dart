import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/debouncer.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
    required this.onFilterPressed,
    required this.hasActiveFilters,
    this.onSubmitted,
    this.salaryRangeLabel,
    this.expandsOnFocus = false,
    this.isExpanded = false,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;
  final ValueChanged<String>? onSubmitted;

  /// When non-null, shows a small teal chip with this text next to the filter
  /// icon (e.g. "$3k–$6k") to indicate a salary filter is active.
  final String? salaryRangeLabel;

  /// Lets the full search screen give the field priority while typing.
  final bool expandsOnFocus;

  /// Lets a parent expand the field before it receives keyboard focus.
  final bool isExpanded;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();
  final _debouncer = Debouncer();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant HomeSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isExpanded =
        widget.isExpanded || (widget.expandsOnFocus && _isFocused);
    return Row(
      children: [
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: isExpanded ? 54 : 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: isExpanded ? palette.surface : palette.surfaceMuted,
              borderRadius: BorderRadius.circular(isExpanded ? 18 : 12),
              border: Border.all(
                color: isExpanded ? AppColors.brandTeal : palette.border,
                width: isExpanded ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(FLucideIcons.search, color: palette.iconMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: (v) => _debouncer.run(() => widget.onChanged(v)),
                    onSubmitted: widget.onSubmitted,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search jobs',
                      hintStyle: TextStyle(
                        color: palette.iconMuted,
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(color: palette.textPrimary, fontSize: 14),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (widget.value.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      FLucideIcons.x,
                      size: 18,
                      color: palette.iconMuted,
                    ),
                    onPressed: widget.onClear,
                  ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: isExpanded
              ? const SizedBox.shrink()
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 10),
                    if (widget.salaryRangeLabel != null)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Text(
                          widget.salaryRangeLabel!,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    Material(
                      color: palette.textPrimary,
                      borderRadius: BorderRadius.circular(999),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () {
                          unawaited(HapticFeedback.lightImpact());
                          widget.onFilterPressed();
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: 46,
                              height: 46,
                              child: Icon(
                                FLucideIcons.filter,
                                color: palette.scaffold,
                              ),
                            ),
                            if (widget.hasActiveFilters)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
