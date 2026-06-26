import 'package:flutter/material.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/feature_discovery/controller/feature_discovery_controller.dart';

class FeatureTooltip {
  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context, {
    required GlobalKey targetKey,
    required FeatureInfo feature,
    required VoidCallback onTryIt,
    required VoidCallback onDismiss,
  }) {
    if (_currentEntry != null) return;

    final renderBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      onDismiss();
      return;
    }

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _currentEntry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        targetSize: size,
        targetOffset: offset,
        feature: feature,
        onTryIt: () {
          _remove();
          onTryIt();
        },
        onDismiss: () {
          _remove();
          onDismiss();
        },
      ),
    );

    Overlay.of(context).insert(_currentEntry!);
  }

  static void _remove() {
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _TooltipOverlay extends StatefulWidget {
  const _TooltipOverlay({
    required this.targetSize,
    required this.targetOffset,
    required this.feature,
    required this.onTryIt,
    required this.onDismiss,
  });

  final Size targetSize;
  final Offset targetOffset;
  final FeatureInfo feature;
  final VoidCallback onTryIt;
  final VoidCallback onDismiss;

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    // Determine if tooltip should be above or below the target
    final showAbove = widget.targetOffset.dy > screenSize.height / 2;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark background
          GestureDetector(
            onTap: widget.onDismiss,
            child: Container(color: Colors.black.withAlpha(150)),
          ),
          // Highlight cutout
          Positioned(
            left: widget.targetOffset.dx - 4,
            top: widget.targetOffset.dy - 4,
            width: widget.targetSize.width + 8,
            height: widget.targetSize.height + 8,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brandTeal, width: 2),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandTeal.withAlpha(100),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          // Tooltip card
          Positioned(
            left: 20,
            right: 20,
            top: showAbove
                ? widget.targetOffset.dy - 160
                : widget.targetOffset.dy + widget.targetSize.height + 16,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.feature.icon, color: AppColors.brandTeal),
                        const SizedBox(width: 8),
                        Text(
                          widget.feature.title,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.feature.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: widget.onDismiss,
                          child: const Text(
                            'Maybe later',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: widget.onTryIt,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandTeal,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try it'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
