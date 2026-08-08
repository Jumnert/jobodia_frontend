import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

const _template =
    'Dear Hiring Manager,\n\nI am excited to apply for the position at your company. I believe my skills and experience make me a strong candidate.\n\nBest regards';

class ApplyConfirmationDialog extends StatefulWidget {
  const ApplyConfirmationDialog({
    required this.jobTitle,
    required this.companyName,
    required this.animation,
    super.key,
  });

  final String jobTitle;
  final String companyName;
  final Animation<double> animation;

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
    return FDialog(
      animation: widget.animation,
      clipBehavior: Clip.antiAlias,
      semanticsLabel: 'Application confirmation',
      builder: (context, _) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
        child: _step == 0 ? _buildStep1(context) : _buildStep2(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Step 1 — info + optional cover letter
  // ---------------------------------------------------------------------------

  Widget _buildStep1(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ready to apply?',
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This will apply you to ${widget.jobTitle} at ${widget.companyName}. Please confirm before continuing.',
          style: theme.typography.body.sm,
        ),
        const SizedBox(height: 16),
        _buildCoverLetterExpansion(),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.secondary,
                onPress: () => Navigator.of(context).pop<String?>(null),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FButton(
                onPress: () => setState(() => _step = 1),
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverLetterExpansion() {
    final theme = FTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(
              () => _coverLetterExpanded = !_coverLetterExpanded,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add a cover letter (optional)',
                      style: theme.typography.body.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _coverLetterExpanded
                        ? FLucideIcons.chevronUp
                        : FLucideIcons.chevronDown,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_coverLetterExpanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _coverLetterCtrl,
            maxLines: 6,
            minLines: 4,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: theme.colors.foreground,
            ),
            decoration: InputDecoration(
              hintText: 'Write your cover letter...',
              hintStyle: TextStyle(color: theme.colors.mutedForeground),
              filled: true,
              fillColor: theme.colors.muted,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Step 2 — final confirmation
  // ---------------------------------------------------------------------------

  Widget _buildStep2(BuildContext context) {
    final theme = FTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirm application',
          style: theme.typography.display.lg.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your application will be submitted.',
          style: theme.typography.body.sm,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: FButton(
                variant: FButtonVariant.secondary,
                onPress: () => setState(() => _step = 0),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FButton(
                onPress: () {
                  unawaited(HapticFeedback.lightImpact());
                  final cl = _coverLetterCtrl.text.trim();
                  Navigator.of(context).pop<String?>(
                    cl.isEmpty ? '' : cl,
                  );
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
