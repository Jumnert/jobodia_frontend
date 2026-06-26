import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';

const _template =
    'Dear Hiring Manager,\n\nI am excited to apply for the position at your company. I believe my skills and experience make me a strong candidate.\n\nBest regards';

class ApplyConfirmationDialog extends StatefulWidget {
  const ApplyConfirmationDialog({
    required this.jobTitle,
    required this.companyName,
    super.key,
  });

  final String jobTitle;
  final String companyName;

  @override
  State<ApplyConfirmationDialog> createState() =>
      _ApplyConfirmationDialogState();
}

class _ApplyConfirmationDialogState extends State<ApplyConfirmationDialog> {
  int _step = 0;
  bool _coverLetterExpanded = false;
  late final TextEditingController _coverLetterCtrl = TextEditingController(
    text: _template,
  );

  @override
  void dispose() {
    _coverLetterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 30),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: _step == 0 ? _buildStep1(context) : _buildStep2(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — info + optional cover letter
  // ---------------------------------------------------------------------------

  Widget _buildStep1(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you absolutely sure?',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'This will apply you to ${widget.jobTitle} at ${widget.companyName}. Please confirm before continuing.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 20),
        _buildCoverLetterExpansion(),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Get.back<String?>(result: null),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => setState(() => _step = 1),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 17),
                      child: Center(
                        child: Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverLetterExpansion() {
    final palette = context.palette;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        initiallyExpanded: _coverLetterExpanded,
        onExpansionChanged: (v) => setState(() => _coverLetterExpanded = v),
        title: Text(
          'Add a cover letter (optional)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _coverLetterExpanded
                ? palette.textPrimary
                : palette.textSecondary,
          ),
        ),
        children: [
          TextField(
            controller: _coverLetterCtrl,
            maxLines: 6,
            minLines: 4,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: palette.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Write your cover letter...',
              hintStyle: TextStyle(color: palette.textTertiary),
              filled: true,
              fillColor: palette.surfaceMuted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — final confirmation
  // ---------------------------------------------------------------------------

  Widget _buildStep2(BuildContext context) {
    final palette = context.palette;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm application',
          style: TextStyle(
            color: palette.textPrimary,
            fontSize: 31,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your application will be submitted.',
          style: TextStyle(
            color: palette.textSecondary,
            fontSize: 21,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 74),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    unawaited(HapticFeedback.mediumImpact());
                    final cl = _coverLetterCtrl.text.trim();
                    Get.back<String?>(result: cl.isEmpty ? '' : cl);
                  },
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.primary,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 17),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
