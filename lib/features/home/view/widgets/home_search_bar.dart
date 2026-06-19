import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({
    super.key,
    required this.value,
    required this.onChanged,
    required this.onClear,
    required this.onFilterPressed,
    required this.hasActiveFilters,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final VoidCallback onFilterPressed;
  final bool hasActiveFilters;

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;

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
                    onChanged: widget.onChanged,
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
                  )
                else ...[
                  Icon(
                    Icons.shortcut_rounded,
                    size: 18,
                    color: palette.iconMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'K',
                    style: TextStyle(color: palette.iconMuted, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: palette.textPrimary,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onFilterPressed,
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFC857),
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
