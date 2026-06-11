import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/custom_button.dart';
import 'package:jobodia_frontend/core/widgets/feature_card_container.dart';
import 'package:jobodia_frontend/core/widgets/feature_header.dart';
import 'package:jobodia_frontend/features/report/view/widgets/screenshot_upload_box.dart';

/// Static report form. Submission and image upload will be added later.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.headerStart,
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
                              'Write Your Unsettlement Comment below for improvement',
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

class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _FieldLabel('Describe Your Issue'),
        const SizedBox(height: 8),
        TextFormField(
          minLines: 6,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            hintText: 'Write your comment here...',
            hintStyle: const TextStyle(color: AppColors.hint, fontSize: 14),
            filled: true,
            fillColor: AppColors.background,
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
        const SizedBox(height: 20),
        const _FieldLabel('Screen shots'),
        const SizedBox(height: 10),
        const Align(
          alignment: Alignment.centerLeft,
          child: ScreenshotUploadBox(),
        ),
        const SizedBox(height: 24),
        CustomButton(
          label: 'Proceed to Report',
          onPressed: () {
            Get.snackbar(
              'Coming soon',
              'Report feature will be available later',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.primary,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
