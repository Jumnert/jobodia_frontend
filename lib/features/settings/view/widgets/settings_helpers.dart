import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

/// Section title label used throughout settings.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, required this.color});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w800),
    );
  }
}

/// A grouped container for settings tiles.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({
    super.key,
    required this.children,
    required this.color,
    required this.borderColor,
  });

  final List<Widget> children;
  final Color color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(height: 1, indent: 52, color: borderColor),
          ],
        ],
      ),
    );
  }
}

/// A single settings tile row.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showChevron = false,
    this.isDestructive = false,
    this.onTap,
    this.foregroundColor = Colors.black,
    this.mutedColor = const Color(0xFF84888D),
    this.leading,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showChevron;
  final bool isDestructive;
  final VoidCallback? onTap;
  final Color foregroundColor;
  final Color mutedColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isDestructive
        ? const Color(0xFFE53935)
        : foregroundColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            leading ??
                Icon(
                  icon,
                  color: isDestructive
                      ? effectiveColor
                      : effectiveColor.withValues(alpha: 0.8),
                  size: 22,
                ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: effectiveColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: mutedColor,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
            if (showChevron)
              Icon(
                FLucideIcons.chevronRight,
                color: mutedColor.withValues(alpha: 0.6),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
