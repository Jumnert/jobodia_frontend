import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

class HomeTabBar extends StatelessWidget {
  const HomeTabBar({
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const labels = ['All Jobs', 'Best Matches', 'Saved Jobs'];
    return Row(
      children: List.generate(
        labels.length,
        (index) => Expanded(
          child: GestureDetector(
            onTap: () => onChanged(index),
            child: Column(
              children: [
                Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedIndex == index
                        ? palette.textPrimary
                        : palette.textTertiary,
                    fontSize: 14,
                    fontWeight: selectedIndex == index
                        ? FontWeight.w700
                        : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? palette.textPrimary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
