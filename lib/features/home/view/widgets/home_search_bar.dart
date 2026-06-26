import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/debouncer.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

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

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: const LiquidRoundedSuperellipse(borderRadius: 12),
            child: Row(
              children: [
                Icon(Icons.search_rounded, color: palette.iconMuted),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
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
                      Icons.close_rounded,
                      size: 18,
                      color: palette.iconMuted,
                    ),
                    onPressed: widget.onClear,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (widget.salaryRangeLabel != null)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
                    Icons.filter_alt_rounded,
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
    );
  }
}
