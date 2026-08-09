import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/app/theme/app_theme.dart';
import 'package:jobodia_frontend/core/widgets/performance_debug_overlay.dart';
import 'package:jobodia_frontend/theme/theme.dart' as forui_theme;

void main() {
  testWidgets(
    'performance overlay samples without mutating fixed list length',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: FTheme(
            data: forui_theme.lightTheme,
            child: Scaffold(body: PerformanceDebugOverlay(onClose: () {})),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 800));

      expect(tester.takeException(), isNull);
      expect(find.text('Performance overlay'), findsOneWidget);
    },
  );
}
