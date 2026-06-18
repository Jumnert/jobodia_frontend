import 'package:flutter/material.dart';
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
    return Row(
      children: [
        Expanded(
          child: GlassContainer(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: const LiquidRoundedSuperellipse(borderRadius: 12),
            child: Row(
              children: [
                const Icon(Icons.search_rounded, color: Color(0xFF8C8C8C)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: widget.onChanged,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search jobs',
                      hintStyle: TextStyle(
                        color: Color(0xFF8C8C8C),
                        fontSize: 14,
                      ),
                    ),
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                    ),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                if (widget.value.isNotEmpty)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF8C8C8C),
                    ),
                    onPressed: widget.onClear,
                  )
                else ...const [
                  Icon(
                    Icons.shortcut_rounded,
                    size: 18,
                    color: Color(0xFF8C8C8C),
                  ),
                  SizedBox(width: 4),
                  Text(
                    'K',
                    style: TextStyle(color: Color(0xFF8C8C8C), fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: widget.onFilterPressed,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(Icons.filter_alt_rounded, color: Colors.white),
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
