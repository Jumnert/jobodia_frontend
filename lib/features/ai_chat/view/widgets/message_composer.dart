import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/core/widgets/confirmation_dialog.dart';
import 'package:jobodia_frontend/features/ai_chat/controller/ai_chat_controller.dart';
import 'package:jobodia_frontend/features/ai_chat/service/resume_text_extractor.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key, required this.controller});

  final AiChatController controller;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final FocusNode _focusNode = FocusNode();
  final ResumeTextExtractor _resumeExtractor = ResumeTextExtractor();

  AiChatController get controller => widget.controller;

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;
    final fg = isDark ? Colors.white : palette.iconPrimary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            constraints: const BoxConstraints(minHeight: 58),
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: isDark ? 0.72 : 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.72),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildAttachmentMenu(fg, palette),
                const SizedBox(width: 7),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 104),
                    child: TextField(
                      focusNode: _focusNode,
                      controller: controller.messageController,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      minLines: 1,
                      maxLines: 4,
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 15,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 11,
                        ),
                        hintText: 'Message Jobodia',
                        hintStyle: TextStyle(color: palette.textTertiary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                ListenableBuilder(
                  listenable: controller.messageController,
                  builder: (context, _) {
                    final canSend = controller.messageController.text
                        .trim()
                        .isNotEmpty;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: canSend
                            ? AppColors.onboardingCtaDark
                            : palette.surfaceMuted.withValues(alpha: 0.82),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: canSend ? _sendMessage : null,
                        padding: EdgeInsets.zero,
                        tooltip: 'Send message',
                        icon: Icon(
                          FLucideIcons.arrowUp,
                          size: 20,
                          color: canSend ? Colors.white : palette.iconMuted,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentMenu(Color foreground, AppPalette palette) {
    return PopupMenuButton<String>(
      color: palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 48),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'resume',
          child: Row(
            children: [
              Icon(FLucideIcons.fileText, color: palette.iconPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Upload Resume',
                style: TextStyle(color: palette.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: [
              Icon(FLucideIcons.camera, color: palette.iconPrimary, size: 20),
              const SizedBox(width: 12),
              Text('Camera', style: TextStyle(color: palette.textPrimary)),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(FLucideIcons.images, color: palette.iconPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Photo Library',
                style: TextStyle(color: palette.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'research',
          child: Row(
            children: [
              Icon(FLucideIcons.search, color: palette.iconPrimary, size: 20),
              const SizedBox(width: 12),
              Text(
                'Deep Research',
                style: TextStyle(color: palette.textPrimary),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'interview',
          child: Row(
            children: [
              Icon(
                FLucideIcons.circleHelp,
                color: palette.iconPrimary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Interview Guide',
                style: TextStyle(color: palette.textPrimary),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'resume':
            _pickResume();
          case 'camera':
            _pickImage(ImageSource.camera);
          case 'gallery':
            _pickImage(ImageSource.gallery);
          case 'research':
            _sendMessage('Help me do deep research for my job search.');
          case 'interview':
            _sendMessage('Give me an interview preparation guide.');
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: palette.surfaceMuted.withValues(alpha: 0.76),
          shape: BoxShape.circle,
        ),
        child: Icon(FLucideIcons.plus, color: foreground, size: 22),
      ),
    );
  }

  Future<void> _pickResume() async {
    _focusNode.unfocus();
    try {
      final resume = await _resumeExtractor.pickAndExtract();
      if (resume == null) return;
      if (!mounted) return;
      final options = await _showResumeOptions();
      if (options == null || !mounted) return;
      final confirmed = await showConfirmationDialog(
        title: 'Send resume for AI rating?',
        message:
            'Jobodia will send the extracted resume text${options.hasTarget ? ' and target-job details' : ''} to DeepSeek for analysis. It may contain personal information. Continue?',
        confirmLabel: 'Rate resume',
        cancelLabel: 'Cancel',
      );
      if (!confirmed) return;
      await controller.analyzeResume(
        attachment: resume.attachment,
        resumeText: resume.text,
        targetRole: options.targetRole,
        jobDescription: options.jobDescription,
      );
    } on ResumeExtractionException catch (error) {
      _showAttachmentError(error.message);
    } on Object {
      _showAttachmentError(
        'Could not read that resume. Try exporting it as a searchable PDF or DOCX.',
      );
    }
  }

  Future<_ResumeAnalysisOptions?> _showResumeOptions() async {
    final palette = context.palette;
    return showModalBottomSheet<_ResumeAnalysisOptions>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ResumeOptionsSheet(),
    );
  }

  void _showAttachmentError(String message) {
    Get.snackbar(
      'Resume not attached',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void _sendMessage([String? text]) {
    final message = (text ?? controller.messageController.text).trim();
    if (message.isEmpty) return;

    _focusNode.unfocus();
    controller.sendMessage(message);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (file == null) return;
      // Send the image path as a message for now.
      _sendMessage('\u{1F4F7} Image attached: ${file.name}');
    } on Exception {
      Get.snackbar(
        'Error',
        'Could not access ${source == ImageSource.camera ? "camera" : "gallery"}.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }
}

class _ResumeOptionsSheet extends StatefulWidget {
  const _ResumeOptionsSheet();

  @override
  State<_ResumeOptionsSheet> createState() => _ResumeOptionsSheetState();
}

class _ResumeOptionsSheetState extends State<_ResumeOptionsSheet> {
  final _roleController = TextEditingController();
  final _jobController = TextEditingController();

  @override
  void dispose() {
    _roleController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          18,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Rate your resume',
              style: TextStyle(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a target job for a more useful relevance score, or leave these blank for a general review.',
              style: TextStyle(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _roleController,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Target role (optional)',
                hintText: 'Flutter Developer',
                prefixIcon: const Icon(FLucideIcons.briefcase),
                filled: true,
                fillColor: palette.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _jobController,
              minLines: 4,
              maxLines: 7,
              maxLength: 8000,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Job description (optional)',
                alignLabelWithHint: true,
                hintText: 'Paste the job requirements here…',
                filled: true,
                fillColor: palette.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(
                  _ResumeAnalysisOptions(
                    targetRole: _roleController.text.trim(),
                    jobDescription: _jobController.text.trim(),
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(FLucideIcons.sparkles),
                label: const Text(
                  'Continue to rating',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeAnalysisOptions {
  const _ResumeAnalysisOptions({
    required this.targetRole,
    required this.jobDescription,
  });

  final String targetRole;
  final String jobDescription;

  bool get hasTarget => targetRole.isNotEmpty || jobDescription.isNotEmpty;
}
