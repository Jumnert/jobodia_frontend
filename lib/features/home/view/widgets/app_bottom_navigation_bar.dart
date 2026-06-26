import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSearchPressed,
    this.interviewHasBadge = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSearchPressed;
  final bool interviewHasBadge;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final palette = context.palette;

    // Shift up slightly so the glass bar overlaps the content edge, but
    // ensure the total height still respects the device safe area.
    final shiftUp = bottomInset > 0 ? 8.0 : 0.0;

    return Transform.translate(
      offset: Offset(0, shiftUp),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = constraints.maxWidth;
            // Interview tab is 4th of 4. Center = barWidth * (3.5/4).
            final interviewCenter = barWidth * 3.5 / 4;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                GlassSearchableBottomBar(
                  selectedIndex: selectedIndex,
                  onTabSelected: onDestinationSelected,
                  isSearchActive: false,
                  searchConfig: GlassSearchBarConfig(
                    hintText: 'Search',
                    onSearchToggle: (_) => onSearchPressed(),
                    searchIconColor: palette.iconPrimary,
                    searchIcon: Icon(
                      Icons.search_rounded,
                      color: palette.iconPrimary,
                    ),
                    autoFocusOnExpand: false,
                    showsCancelButton: false,
                  ),
                  horizontalPadding: 12,
                  verticalPadding: 10,
                  barHeight: 64,
                  iconSize: 23,
                  labelFontSize: 11,
                  selectedIconColor: palette.iconPrimary,
                  unselectedIconColor: palette.iconMuted,
                  indicatorColor: palette.textPrimary.withValues(alpha: 0.10),
                  quality: GlassQuality.premium,
                  settings: const LiquidGlassSettings(
                    glassColor: Color(0x26FFFFFF),
                    thickness: 30,
                    blur: 2,
                    chromaticAberration: 0.01,
                    lightIntensity: 0.55,
                    ambientStrength: 0.08,
                    saturation: 1.2,
                  ),
                  tabs: const [
                    GlassBottomBarTab(
                      icon: Icon(Icons.home_outlined),
                      activeIcon: Icon(Icons.home_rounded),
                      label: 'Home',
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.layers_outlined),
                      activeIcon: Icon(Icons.layers_rounded),
                      label: 'CV',
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.chat_bubble_outline),
                      activeIcon: Icon(Icons.chat_bubble_rounded),
                      label: 'Chat',
                    ),
                    GlassBottomBarTab(
                      icon: Icon(Icons.record_voice_over_outlined),
                      activeIcon: Icon(Icons.record_voice_over_rounded),
                      label: 'Interview',
                    ),
                  ],
                ),
                // ── Badge dot on Interview tab (4th icon) ──
                if (interviewHasBadge)
                  Positioned(
                    top: 6,
                    left: interviewCenter - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD93B3B),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
