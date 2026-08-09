import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/report/controller/report_controller.dart';
import 'package:jobodia_frontend/features/report/view/widgets/screenshot_upload_box.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  bool _allowPop = false;
  bool _wasDirty = false;

  bool get _isDirty => _commentController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _commentController.addListener(_handleCommentChanged);
  }

  void _handleCommentChanged() {
    final dirty = _isDirty;
    if (dirty == _wasDirty) return;
    _wasDirty = dirty;
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.removeListener(_handleCommentChanged);
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final jobId = args is Map ? (args['jobId'] as String?) ?? '' : '';
    final jobTitle = args is Map ? (args['jobTitle'] as String?) ?? '' : '';
    final controller = Get.find<ReportController>();
    final theme = FTheme.of(context);

    return PopScope(
      canPop: _allowPop || !_isDirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _attemptClose();
      },
      child: FScaffold(
        header: FHeader.nested(
          title: const Text('Report'),
          prefixes: [FHeaderAction.back(onPress: _attemptClose)],
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.paddingOf(context).bottom + 28,
            ),
            children: [
              Text(
                'Tell us what went wrong',
                style: theme.typography.display.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Provide enough detail for us to understand and review the issue.',
                style: theme.typography.body.sm.copyWith(
                  color: theme.colors.mutedForeground,
                  height: 1.4,
                ),
              ),
              if (jobTitle.isNotEmpty) ...[
                const SizedBox(height: 20),
                FTileGroup(
                  label: const Text('Reporting'),
                  children: [
                    FTile(
                      prefix: const Icon(FLucideIcons.briefcaseBusiness),
                      title: Text(jobTitle),
                      subtitle: const Text('Job listing'),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 22),
              FTextFormField.multiline(
                control: FTextFieldControl.managed(
                  controller: _commentController,
                ),
                label: const Text('What happened?'),
                description: const Text(
                  'Do not include passwords or other sensitive information.',
                ),
                hint: 'Describe the issue...',
                minLines: 6,
                maxLines: 9,
                maxLength: 2000,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please describe the issue.'
                    : null,
              ),
              const SizedBox(height: 22),
              Text(
                'Screenshot',
                style: theme.typography.body.sm.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional. Add one image that helps explain the issue.',
                style: theme.typography.body.xs.copyWith(
                  color: theme.colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => ScreenshotUploadBox(
                  onTap: controller.pickScreenshot,
                  imageBytes: controller.screenshotBytes.value,
                  onRemove: controller.removeScreenshot,
                ),
              ),
              Obx(() {
                final error = controller.submitError.value;
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    error,
                    style: theme.typography.body.sm.copyWith(
                      color: theme.colors.destructive,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Obx(
                () => FButton(
                  onPress: controller.isSubmitting.value
                      ? null
                      : () => _submit(
                          controller,
                          jobId: jobId,
                          jobTitle: jobTitle,
                        ),
                  child: controller.isSubmitting.value
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FCircularProgress.loader(size: .sm),
                            SizedBox(width: 8),
                            Text('Submitting...'),
                          ],
                        )
                      : const Text('Submit report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit(
    ReportController controller, {
    required String jobId,
    required String jobTitle,
  }) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.lightImpact();
    controller.submit(
      jobId: jobId,
      jobTitle: jobTitle,
      comment: _commentController.text.trim(),
    );
  }

  Future<void> _attemptClose() async {
    if (!_isDirty) {
      Get.back<void>();
      return;
    }

    final discard = await showFDialog<bool>(
      context: context,
      builder: (dialogContext, _, animation) => FDialog(
        animation: animation,
        semanticsLabel: 'Discard report confirmation',
        builder: (dialogContext, _) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Discard report?',
                style: FTheme.of(
                  dialogContext,
                ).typography.display.lg.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Your unsaved report text will be lost.',
                style: FTheme.of(dialogContext).typography.body.sm.copyWith(
                  color: FTheme.of(dialogContext).colors.mutedForeground,
                ),
              ),
              const SizedBox(height: 20),
              FButton(
                variant: FButtonVariant.destructive,
                onPress: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Discard'),
              ),
              const SizedBox(height: 10),
              FButton(
                variant: FButtonVariant.secondary,
                onPress: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Keep editing'),
              ),
            ],
          ),
        ),
      ),
    );

    if (discard == true && mounted) {
      setState(() => _allowPop = true);
      await Future<void>.delayed(Duration.zero);
      if (mounted) Get.back<void>();
    }
  }
}
