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
              child: OutlinedButton.icon(
                onPressed: () => _showImportSheet(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandTeal,
                  side: const BorderSide(
                    color: AppColors.brandTeal,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(FLucideIcons.scrollText, size: 20),
                label: const Text(
                  'Import from text',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _confirmFillFromProfile(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(FLucideIcons.userRoundPen, size: 20),
                label: const Text(
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
          child: TextButton.icon(
            onPressed: () => _confirmSampleFill(context),
            style: TextButton.styleFrom(
              foregroundColor: palette.textSecondary,
              padding: const EdgeInsets.symmetric(vertical: 11),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(FLucideIcons.flaskConical, size: 19),
            label: const Text(
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
    final palette = context.palette;
    final textController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Import from text',
                style: TextStyle(
                  color: palette.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Paste your resume text below and we will fill in what we can.',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: textController,
                minLines: 6,
                maxLines: 10,
                style: TextStyle(color: palette.textPrimary),
                decoration: InputDecoration(
                  hintText:
                      'Alex Johnson\nalex.j@example.com\n+1 234 567 890\n...',
                  filled: true,
                  fillColor: palette.surfaceMuted,
                  hintStyle: TextStyle(
                    color: palette.textTertiary,
                    fontSize: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final text = textController.text;
                    Navigator.of(sheetContext).pop();
                    controller.importFromText(text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(FLucideIcons.sparkles, size: 19),
                  label: const Text('Import my resume'),
                ),
              ),
            ],
          ),
        );
      },
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
