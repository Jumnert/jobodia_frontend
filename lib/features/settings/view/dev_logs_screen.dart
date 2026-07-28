import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// A lightweight developer diagnostics screen surfaced from Settings → Dev Logs.
///
/// Uses forui [FScaffold] + [FTileGroup]/[FTile] to present the current runtime
/// state (build mode, platform, theme, persisted flags) — the closest useful
/// "dev logs" view for a mock/offline app with no backend logging.
class DevLogsScreen extends StatelessWidget {
  const DevLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final storage = GetStorage();
    final role = Get.isRegistered<RoleController>()
        ? Get.find<RoleController>().role.value?.label ?? 'Not selected'
        : 'Not selected';
    final brightness = Theme.of(context).brightness == Brightness.dark
        ? 'Dark'
        : 'Light';

    final entries = <(IconData, String, String)>[
      (FLucideIcons.hammer, 'Build mode', kReleaseMode ? 'Release' : 'Debug'),
      (FLucideIcons.smartphone, 'Platform', _platformLabel()),
      (FLucideIcons.palette, 'Theme', brightness),
      (FLucideIcons.userCog, 'Role', role),
      (
        FLucideIcons.circleCheck,
        'Onboarding seen',
        '${storage.read<bool>('hasSeenOnboarding') ?? false}',
      ),
      (FLucideIcons.database, 'Storage keys', '${storage.getKeys().length}'),
    ];

    return FScaffold(
      header: BlurredHeader(
        child: FHeader.nested(
          title: const Text('Dev Logs'),
          prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          FTileGroup(
            label: const Text('Runtime diagnostics'),
            description: const Text(
              'Read-only snapshot of the current app state.',
            ),
            children: [
              for (final (icon, title, value) in entries)
                FTile(
                  prefix: Icon(icon),
                  title: Text(title),
                  details: Text(value),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'No remote logging is configured in this build.',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _platformLabel() {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    return defaultTargetPlatform.name;
  }
}
