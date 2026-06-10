import 'package:flutter/material.dart';

class JobChip extends StatelessWidget {
  const JobChip({required this.label, this.isDark = false, super.key});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isDark ? 8 : 10, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF4B4B4B) : Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: isDark ? const Color(0xFF4B4B4B) : const Color(0xFFE0E0E0),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.w700,
          fontSize: isDark ? 12 : 14,
        ),
      ),
    );
  }
}
