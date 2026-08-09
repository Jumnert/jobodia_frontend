import 'dart:io' show Platform, ProcessInfo;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jobodia_frontend/core/utils/app_logger.dart';
import 'package:jobodia_frontend/core/widgets/blurred_header.dart';
import 'package:jobodia_frontend/features/home/controller/main_nav_controller.dart';
import 'package:jobodia_frontend/features/role/controller/role_controller.dart';

/// Local diagnostics for development builds. No information is uploaded.
class DevLogsScreen extends StatefulWidget {
  const DevLogsScreen({super.key});

  @override
  State<DevLogsScreen> createState() => _DevLogsScreenState();
}

class _DevLogsScreenState extends State<DevLogsScreen> {
  late DateTime _refreshedAt;

  @override
  void initState() {
    super.initState();
    _refreshedAt = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);
    final media = MediaQuery.of(context);
    final storage = GetStorage();
    final role = Get.isRegistered<RoleController>()
        ? Get.find<RoleController>().role.value?.label ?? 'Not selected'
        : 'Controller unavailable';
    final selectedTab = Get.isRegistered<MainNavController>()
        ? Get.find<MainNavController>().selectedTab.value.toString()
        : 'Controller unavailable';

    final runtimeEntries = <(IconData, String, String)>[
      (
        FLucideIcons.hammer,
        'Build mode',
        kReleaseMode
            ? 'Release'
            : kProfileMode
            ? 'Profile'
            : 'Debug',
      ),
      (FLucideIcons.smartphone, 'Platform', _platformLabel()),
      (FLucideIcons.route, 'Current route', Get.currentRoute),
      (
        FLucideIcons.activity,
        'Lifecycle',
        WidgetsBinding.instance.lifecycleState?.name ?? 'Unknown',
      ),
      (
        FLucideIcons.memoryStick,
        'Process memory',
        kIsWeb ? 'Unavailable on web' : _formatBytes(ProcessInfo.currentRss),
      ),
      (FLucideIcons.clock3, 'Last refreshed', _formatTime(_refreshedAt)),
    ];

    final displayEntries = <(IconData, String, String)>[
      (
        FLucideIcons.monitorSmartphone,
        'Logical display',
        '${media.size.width.toStringAsFixed(0)} × '
            '${media.size.height.toStringAsFixed(0)}',
      ),
      (
        FLucideIcons.scan,
        'Pixel ratio',
        media.devicePixelRatio.toStringAsFixed(2),
      ),
      (
        FLucideIcons.languages,
        'Locale',
        Localizations.localeOf(context).toString(),
      ),
      (
        FLucideIcons.type,
        'Text scale',
        media.textScaler.scale(1).toStringAsFixed(2),
      ),
      (FLucideIcons.contrast, 'Brightness', Theme.of(context).brightness.name),
      (
        FLucideIcons.accessibility,
        'Accessible navigation',
        media.accessibleNavigation.toString(),
      ),
    ];

    final appEntries = <(IconData, String, String)>[
      (FLucideIcons.userCog, 'Selected role', role),
      (FLucideIcons.panelBottom, 'Selected main tab', selectedTab),
      (
        FLucideIcons.circleCheck,
        'Onboarding seen',
        '${storage.read<bool>('hasSeenOnboarding') ?? false}',
      ),
      (
        FLucideIcons.database,
        'Local storage keys',
        '${storage.getKeys().length}',
      ),
      (FLucideIcons.wifiOff, 'Backend mode', 'Mock / local data'),
    ];

    return FScaffold(
      header: BlurredHeader(
        child: FHeader.nested(
          title: const Text('Dev Logs'),
          prefixes: [FHeaderAction.back(onPress: () => Get.back<void>())],
          suffixes: [
            FHeaderAction(
              icon: const Icon(FLucideIcons.refreshCw),
              onPress: _refresh,
            ),
          ],
        ),
      ),
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          MediaQuery.paddingOf(context).bottom + 32,
        ),
        children: [
          _DiagnosticGroup(label: 'Runtime', entries: runtimeEntries),
          const SizedBox(height: 20),
          _DiagnosticGroup(
            label: 'Display & accessibility',
            entries: displayEntries,
          ),
          const SizedBox(height: 20),
          _DiagnosticGroup(label: 'App state', entries: appEntries),
          const SizedBox(height: 20),
          FTileGroup(
            label: const Text('Debug tools'),
            description: const Text('Local actions only. Nothing is uploaded.'),
            children: [
              FTile(
                prefix: const Icon(FLucideIcons.clipboardCopy),
                title: const Text('Copy diagnostic report'),
                subtitle: const Text(
                  'Copy runtime and app state as plain text.',
                ),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => _copyDiagnostics(context, [
                  ...runtimeEntries,
                  ...displayEntries,
                  ...appEntries,
                ]),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.databaseZap),
                title: const Text('Inspect local storage'),
                subtitle: const Text('View keys and redacted values.'),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () => _showStorageSheet(context, storage),
              ),
              FTile(
                prefix: const Icon(FLucideIcons.bug),
                title: const Text('Generate test log'),
                subtitle: const Text('Verify the in-app logging pipeline.'),
                suffix: const Icon(FLucideIcons.chevronRight),
                onPress: () {
                  AppLogger.info('Manual test event from Dev Logs');
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<List<AppLogEntry>>(
            valueListenable: AppLogger.entries,
            builder: (context, logs, _) => _RecentLogs(
              logs: logs,
              onClear: logs.isEmpty ? null : AppLogger.clear,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'The log buffer stores the latest 100 debug events in memory and '
              'is cleared when the app restarts.',
              style: theme.typography.body.xs.copyWith(
                color: theme.colors.mutedForeground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _refresh() => setState(() => _refreshedAt = DateTime.now());

  Future<void> _copyDiagnostics(
    BuildContext context,
    List<(IconData, String, String)> entries,
  ) async {
    final report = StringBuffer('Jobodia diagnostics\n');
    for (final (_, title, value) in entries) {
      report.writeln('$title: $value');
    }
    await Clipboard.setData(ClipboardData(text: report.toString()));
    if (!context.mounted) return;
    Get.snackbar(
      'Diagnostics copied',
      'The report is ready to paste into a bug report.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void _showStorageSheet(BuildContext context, GetStorage storage) {
    final keys = storage.getKeys().map((key) => key.toString()).toList()
      ..sort();
    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.78,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ColoredBox(
          color: FTheme.of(sheetContext).colors.background,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Local storage',
                        style: FTheme.of(sheetContext).typography.display.sm
                            .copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    FButton.icon(
                      variant: FButtonVariant.ghost,
                      onPress: () => Navigator.of(sheetContext).pop(),
                      child: const Icon(FLucideIcons.x),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: keys.isEmpty
                    ? Center(
                        child: Text(
                          'No local keys found.',
                          style: FTheme.of(sheetContext).typography.body.sm,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          FTileGroup(
                            children: [
                              for (final key in keys)
                                FTile(
                                  prefix: const Icon(FLucideIcons.keyRound),
                                  title: Text(key),
                                  subtitle: Text(
                                    _displayStorageValue(
                                      key,
                                      storage.read(key),
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _displayStorageValue(String key, Object? value) {
    final normalized = key.toLowerCase();
    const sensitiveWords = [
      'token',
      'password',
      'secret',
      'pin',
      'credential',
      'profile',
    ];
    if (sensitiveWords.any(normalized.contains)) return '•••••• (redacted)';
    final text = value?.toString() ?? 'null';
    return text.length > 180 ? '${text.substring(0, 180)}…' : text;
  }

  String _platformLabel() {
    if (kIsWeb) return 'Web';
    final version = Platform.operatingSystemVersion.trim();
    return '${Platform.operatingSystem} · $version';
  }

  String _formatBytes(int bytes) {
    const megabyte = 1024 * 1024;
    return '${(bytes / megabyte).toStringAsFixed(1)} MB';
  }

  String _formatTime(DateTime time) =>
      '${time.hour.toString().padLeft(2, '0')}:'
      '${time.minute.toString().padLeft(2, '0')}:'
      '${time.second.toString().padLeft(2, '0')}';
}

class _DiagnosticGroup extends StatelessWidget {
  const _DiagnosticGroup({required this.label, required this.entries});

  final String label;
  final List<(IconData, String, String)> entries;

  @override
  Widget build(BuildContext context) => FTileGroup(
    label: Text(label),
    children: [
      for (final (icon, title, value) in entries)
        FTile(prefix: Icon(icon), title: Text(title), details: Text(value)),
    ],
  );
}

class _RecentLogs extends StatelessWidget {
  const _RecentLogs({required this.logs, required this.onClear});

  final List<AppLogEntry> logs;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final visible = logs.reversed.take(25).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent app logs (${logs.length})',
                style: FTheme.of(
                  context,
                ).typography.body.sm.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            FButton(
              variant: FButtonVariant.ghost,
              onPress: onClear,
              child: const Text('Clear'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FTileGroup(
          children: visible.isEmpty
              ? [
                  FTile(
                    prefix: const Icon(FLucideIcons.logs),
                    title: const Text('No events captured'),
                    subtitle: const Text(
                      'Use Generate test log to verify the buffer.',
                    ),
                  ),
                ]
              : [
                  for (final log in visible)
                    FTile(
                      prefix: Icon(_logIcon(log.level)),
                      title: Text(log.message),
                      subtitle: log.error == null ? null : Text(log.error!),
                      details: Text(_logDetails(log)),
                    ),
                ],
        ),
      ],
    );
  }

  static IconData _logIcon(AppLogLevel level) => switch (level) {
    AppLogLevel.info => FLucideIcons.info,
    AppLogLevel.warning => FLucideIcons.triangleAlert,
    AppLogLevel.error => FLucideIcons.circleX,
  };

  static String _logDetails(AppLogEntry log) {
    final time = log.timestamp;
    final label = log.level.name.toUpperCase();
    return '$label · '
        '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
