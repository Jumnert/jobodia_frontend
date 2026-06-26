import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/auto_scroll_on_focus.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/feature_card_container.dart';
import 'package:jobodia_frontend/core/widgets/feature_header.dart';
import 'package:jobodia_frontend/features/report/controller/report_controller.dart';
import 'package:jobodia_frontend/features/report/view/widgets/screenshot_upload_box.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: palette.scaffold,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const headerHeight = 190.0;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        const FeatureHeader(
                          title: 'Report',
                          subtitle:
                              'Share your feedback or report an issue for improvement',
                          height: headerHeight,
                        ),
                        FeatureCardContainer(
                          minHeight: constraints.maxHeight - headerHeight,
                          padding: EdgeInsets.fromLTRB(
                            18,
                            18,
                            18,
                            MediaQuery.paddingOf(context).bottom + 32,
                          ),
                          child: const _ReportContent(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportContent extends StatefulWidget {
  const _ReportContent();

  @override
  State<_ReportContent> createState() => _ReportContentState();
}

class _ReportContentState extends State<_ReportContent> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();

  bool get _isDirty => _commentController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final jobId = args is Map ? (args['jobId'] as String?) ?? '' : '';
    final jobTitle = args is Map ? (args['jobTitle'] as String?) ?? '' : '';

    final controller = Get.isRegistered<ReportController>()
        ? Get.find<ReportController>()
        : Get.put(ReportController());

    final palette = context.palette;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (!_isDirty) {
          Navigator.of(context).pop();
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard report?'),
            content: const Text('You have unsaved text. Leave anyway?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Discard'),
              ),
            ],
          ),
        );
        if (discard == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (jobTitle.isNotEmpty) ...[
              Text(
                'Reporting: $jobTitle',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
            ],
            const _FieldLabel('Describe Your Issue'),
            const SizedBox(height: 8),
            AutoScrollOnFocus(
              child: TextFormField(
                controller: _commentController,
                minLines: 6,
                maxLines: 8,
                maxLength: 2000,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your issue';
                  }
                  return null;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  hintText: 'Write your comment here...',
                  hintStyle: const TextStyle(
                    color: AppColors.hint,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: palette.surfaceMuted,
                  contentPadding: const EdgeInsets.all(16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const _FieldLabel('Screenshots'),
            const SizedBox(height: 10),
            Obx(
              () => Align(
                alignment: Alignment.centerLeft,
                child: ScreenshotUploadBox(
                  onTap: controller.pickScreenshot,
                  imageBytes: controller.screenshotBytes.value,
                  onRemove: controller.removeScreenshot,
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Proceed to Report',
              onPressed: () {
                if (!(_formKey.currentState?.validate() ?? false)) return;
                unawaited(HapticFeedback.mediumImpact());
                controller.submit(
                  jobId: jobId,
                  jobTitle: jobTitle,
                  comment: _commentController.text.trim(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Text(
      text,
      style: TextStyle(
        color: palette.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
