import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/confirmation_dialog.dart';
import 'package:jobodia_frontend/features/cv_builder/controller/cv_builder_controller.dart';
import 'package:jobodia_frontend/features/cv_builder/view/widgets/cv_builder_helpers.dart';

class BasicInfoStep extends StatelessWidget {
  const BasicInfoStep({super.key, required this.controller});

  final CvBuilderController controller;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const ResumeSectionIntro(
          title: 'Identity and contact',
          description:
              'Use the details recruiters should see at the top of your resume.',
        ),
        const SizedBox(height: 18),
        Text(
          'QUICK START',
          style: TextStyle(
            color: palette.textTertiary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 9),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: () => _showImportSheet(context),
                prefix: const Icon(FLucideIcons.scrollText, size: 18),
                child: const Text(
                  'Import from text',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FButton(
                variant: FButtonVariant.outline,
                onPress: () => _confirmFillFromProfile(context),
                prefix: const Icon(FLucideIcons.userRoundPen, size: 18),
                child: const Text(
                  'Fill from profile',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FButton(
            variant: FButtonVariant.ghost,
            onPress: () => _confirmSampleFill(context),
            prefix: const Icon(FLucideIcons.flaskConical, size: 18),
            child: const Text(
              'Use complete sample CV',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Divider(color: palette.divider),
        const SizedBox(height: 14),
        HeadshotUploadTile(controller: controller),
        const SizedBox(height: 18),
        CompactInput(
          label: 'Full name',
          hintText: 'Your full name',
          controller: controller.fullNameController,
        ),
        const SizedBox(height: 16),
        CompactInput(
          label: 'Email',
          hintText: 'example@gmail.com',
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        CompactInput(
          label: 'Phone number',
          hintText: '+855 12 345 678',
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CompactInput(
          label: 'Location',
          hintText: 'City, Country',
          controller: controller.locationController,
        ),
      ],
    );
  }

  /// Opens a bottom sheet with a multiline field for pasting resume text.
  void _showImportSheet(BuildContext context) {
    final textController = TextEditingController();

    showFSheet<void>(
      context: context,
      side: FLayout.btt,
      mainAxisMaxRatio: 0.82,
      useSafeArea: true,
      barrierDismissible: true,
      builder: (sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: ColoredBox(
          color: FTheme.of(sheetContext).colors.background,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Import from text',
                  style: FTheme.of(
                    sheetContext,
                  ).typography.display.sm.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Paste your resume text and we will fill in what we can.',
                  style: FTheme.of(sheetContext).typography.body.sm.copyWith(
                    color: FTheme.of(sheetContext).colors.mutedForeground,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                FTextField.multiline(
                  control: FTextFieldControl.managed(
                    controller: textController,
                  ),
                  hint: 'Alex Johnson\nalex.j@example.com\n+1 234 567 890\n...',
                  minLines: 7,
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                FButton(
                  onPress: () {
                    final text = textController.text;
                    Navigator.of(sheetContext).pop();
                    controller.importFromText(text);
                  },
                  prefix: const Icon(FLucideIcons.sparkles, size: 18),
                  child: const Text('Import my resume'),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(textController.dispose);
  }

  /// Confirms before overwriting current fields, then fills from the profile.
  Future<void> _confirmFillFromProfile(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      title: 'Overwrite current fields?',
      message:
          'This will replace the basic info, skills, and first experience '
          'with details from your profile.',
      confirmLabel: 'Overwrite',
      cancelLabel: 'Cancel',
    );

    if (confirmed) {
      controller.fillFromProfile();
    }
  }

  Future<void> _confirmSampleFill(BuildContext context) async {
    final confirmed = await showConfirmationDialog(
      title: 'Load the sample CV?',
      message:
          'This fills every section with realistic test content and opens the design preview. Your current form entries will be replaced.',
      confirmLabel: 'Load sample',
      cancelLabel: 'Cancel',
    );

    if (confirmed) controller.fillWithSampleCv();
  }
}
