import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onSearchPressed,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final palette = context.palette;

    return Transform.translate(
      offset: const Offset(0, 8),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset),
        child: GlassSearchableBottomBar(
          selectedIndex: selectedIndex,
          onTabSelected: onDestinationSelected,
          isSearchActive: false,
          searchConfig: GlassSearchBarConfig(
            hintText: 'Search',
            onSearchToggle: (_) => onSearchPressed(),
            searchIconColor: palette.iconPrimary,
            searchIcon: Icon(Icons.search_rounded, color: palette.iconPrimary),
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
      ),
    );
  }
}
