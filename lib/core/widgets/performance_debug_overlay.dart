import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

/// A testing-only floating view of recent Flutter frame timings.
class PerformanceDebugOverlay extends StatefulWidget {
  const PerformanceDebugOverlay({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  State<PerformanceDebugOverlay> createState() =>
      _PerformanceDebugOverlayState();
}

class _PerformanceDebugOverlayState extends State<PerformanceDebugOverlay> {
  static const _sampleCount = 36;
  final List<double> _frameSamples = List<double>.filled(_sampleCount, 16.7);
  final List<double> _cpuSamples = List<double>.filled(_sampleCount, 4);
  double _latestFrameMs = 16.7;
  double _latestCpu = 4;
  Offset _dragOffset = Offset.zero;
  Timer? _sampleTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addTimingsCallback(_onTimings);
    _sampleTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      setState(() {
        _push(_frameSamples, _latestFrameMs.clamp(0.0, 40.0));
        _push(_cpuSamples, _latestCpu);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeTimingsCallback(_onTimings);
    _sampleTimer?.cancel();
    super.dispose();
  }

  void _onTimings(List<FrameTiming> timings) {
    if (!mounted || timings.isEmpty) return;
    final latest = timings.last;
    final frameMs =
        (latest.buildDuration + latest.rasterDuration).inMicroseconds / 1000;
    // Flutter does not expose process CPU usage. This gives a useful engine
    // load estimate based on how much of a 16.7ms frame budget was consumed.
    final cpuEstimate = (frameMs / 16.7 * 100).clamp(0.0, 100.0);
    setState(() {
      _latestFrameMs = frameMs;
      _latestCpu = cpuEstimate;
    });
  }

  void _push(List<double> values, double value) {
    if (values.isEmpty) return;
    // The sample buffers are intentionally fixed-size. Shift values in place
    // instead of calling remove/add, which throws on fixed-length lists.
    for (var index = 1; index < values.length; index++) {
      values[index - 1] = values[index];
    }
    values[values.length - 1] = value;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Transform.translate(
      offset: _dragOffset,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _dragOffset += details.delta),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 264,
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 14),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.97),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.brandTeal.withValues(alpha: .45),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      FLucideIcons.chartNoAxesCombined,
                      color: AppColors.brandTeal,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Performance overlay',
                            style: FTheme.of(context).typography.body.sm
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'LIVE · 250ms',
                            style: FTheme.of(context).typography.body.xs
                                .copyWith(
                                  color: AppColors.brandTeal,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onClose,
                      icon: const Icon(FLucideIcons.x, size: 17),
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Close overlay',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _MetricGraph(
                  label: 'Frame time',
                  value: '${_latestFrameMs.toStringAsFixed(1)} ms',
                  samples: _frameSamples,
                  max: 40,
                  target: 16.7,
                ),
                const SizedBox(height: 12),
                _MetricGraph(
                  label: 'CPU load (est.)',
                  value: '${_latestCpu.toStringAsFixed(0)}%',
                  samples: _cpuSamples,
                  max: 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricGraph extends StatelessWidget {
  const _MetricGraph({
    required this.label,
    required this.value,
    required this.samples,
    required this.max,
    this.target,
  });

  final String label;
  final String value;
  final List<double> samples;
  final double max;
  final double? target;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FTheme.of(context).typography.body.xs,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: FTheme.of(context).typography.body.xs.copyWith(
                color: AppColors.brandTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        SizedBox(
          height: 44,
          child: CustomPaint(
            painter: _PerformanceGraphPainter(
              samples: samples,
              max: max,
              grid: palette.border,
              target: target,
            ),
          ),
        ),
      ],
    );
  }
}

class _PerformanceGraphPainter extends CustomPainter {
  const _PerformanceGraphPainter({
    required this.samples,
    required this.max,
    required this.grid,
    this.target,
  });

  final List<double> samples;
  final double max;
  final Color grid;
  final double? target;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid.withValues(alpha: .65)
      ..strokeWidth = 1;
    for (var line = 1; line < 3; line++) {
      final y = size.height * line / 3;
      canvas.drawLine(
        Offset.zero + Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (target != null) {
      final y = size.height * (1 - (target! / max).clamp(0.0, 1.0));
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        Paint()
          ..color = AppColors.warning.withValues(alpha: .6)
          ..strokeWidth = 1,
      );
    }

    final line = Path();
    final fill = Path();
    for (var index = 0; index < samples.length; index++) {
      final x = size.width * index / math.max(1, samples.length - 1);
      final y = size.height * (1 - (samples[index] / max).clamp(0.0, 1.0));
      if (index == 0) {
        line.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        line.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.brandTeal.withValues(alpha: .35),
            AppColors.brandTeal.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      line,
      Paint()
        ..color = AppColors.brandTeal
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PerformanceGraphPainter oldDelegate) =>
      oldDelegate.samples != samples || oldDelegate.grid != grid;
}
