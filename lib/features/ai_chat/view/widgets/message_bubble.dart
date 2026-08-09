import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/app/routes/app_routes.dart';
import 'package:jobodia_frontend/core/constants/app_colors.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/model/resume_analysis.dart';

/// A lightweight chat bubble. Only the newest item receives the paint-only
/// fade/slide transition, keeping long conversations smooth.
class MessageBubble extends StatefulWidget {
  const MessageBubble({
    required this.message,
    required this.shouldAnimate,
    required this.revealText,
    required this.showDelivery,
    this.onRegenerate,
    this.onRevealProgress,
    super.key,
  });

  final ChatMessageModel message;
  final bool shouldAnimate;
  final bool revealText;
  final bool showDelivery;
  final VoidCallback? onRegenerate;
  final VoidCallback? onRevealProgress;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late String _visibleBotText;
  bool _isRevealing = false;
  int _feedback = 0;

  bool get _isUser => widget.message.sender == ChatMessageSender.user;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0.2, end: 1).animate(curve);
    _slide = Tween<Offset>(
      begin: Offset(_isUser ? 0.08 : -0.05, 0.035),
      end: Offset.zero,
    ).animate(curve);
    _visibleBotText = widget.message.text;

    if (!_isUser &&
        widget.message.resumeAnalysis == null &&
        widget.revealText &&
        widget.message.text.isNotEmpty) {
      _visibleBotText = '';
      _isRevealing = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _revealResponse());
    }

    if (widget.shouldAnimate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.value = 1;
    }
  }

  Future<void> _revealResponse() async {
    final words = RegExp(r'\S+\s*')
        .allMatches(widget.message.text)
        .map((match) => match.group(0)!)
        .toList(growable: false);
    final baseDelay = words.length <= 40
        ? 38
        : words.length <= 120
        ? 26
        : 16;
    final buffer = StringBuffer();

    for (var index = 0; index < words.length; index++) {
      if (index > 0) {
        final previous = words[index - 1].trimRight();
        final punctuationPause = RegExp(r'[.!?]$').hasMatch(previous)
            ? 70
            : RegExp(r'[,;:]$').hasMatch(previous)
            ? 28
            : 0;
        await Future<void>.delayed(
          Duration(milliseconds: baseDelay + punctuationPause),
        );
      }
      if (!mounted) return;
      buffer.write(words[index]);
      setState(() => _visibleBotText = buffer.toString());
      if (index % 6 == 0) widget.onRevealProgress?.call();
    }
    if (!mounted) return;
    setState(() => _isRevealing = false);
    widget.onRevealProgress?.call();
  }

  String get _renderedBotText {
    if (!_isRevealing) return widget.message.text;
    final trailingWhitespace = RegExp(r'\s*$').firstMatch(_visibleBotText)![0]!;
    var value = _visibleBotText.substring(
      0,
      _visibleBotText.length - trailingWhitespace.length,
    );
    if (RegExp(r'\*\*').allMatches(value).length.isOdd) value += '**';
    if (RegExp(r'(?<!`)`(?!`)').allMatches(value).length.isOdd) value += '`';
    return '$value$trailingWhitespace';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    const userBubbleColor = AppColors.brandPrimary;
    const userTextColor = AppColors.textPrimary;
    final maxWidth = MediaQuery.sizeOf(context).width * (_isUser ? 0.76 : 0.84);
    final messageStyle = TextStyle(
      color: _isUser ? userTextColor : palette.textPrimary,
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w500,
    );
    final userBubble = Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
      decoration: BoxDecoration(
        color: userBubbleColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.message.resumeAttachment != null) ...[
            _ResumeAttachmentCard(
              attachment: widget.message.resumeAttachment!,
              foreground: userTextColor,
            ),
            const SizedBox(height: 9),
          ],
          Text(widget.message.text, style: messageStyle),
        ],
      ),
    );

    final content = _isUser
        ? Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                userBubble,
                if (widget.showDelivery) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Sent',
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.message.resumeAnalysis case final analysis?)
                  _ResumeAnalysisCard(analysis: analysis)
                else
                  _BotMarkdownText(
                    text: _renderedBotText,
                    style: messageStyle,
                    animateLastWord: _isRevealing,
                  ),
                if (!_isRevealing) ...[
                  const SizedBox(height: 7),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ResponseAction(
                        tooltip: 'Good response',
                        icon: _feedback == 1
                            ? FLucideIcons.thumbsUp
                            : FLucideIcons.thumbsUp,
                        selected: _feedback == 1,
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() => _feedback = _feedback == 1 ? 0 : 1);
                        },
                      ),
                      _ResponseAction(
                        tooltip: 'Bad response',
                        icon: _feedback == -1
                            ? FLucideIcons.thumbsDown
                            : FLucideIcons.thumbsDown,
                        selected: _feedback == -1,
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          setState(() => _feedback = _feedback == -1 ? 0 : -1);
                        },
                      ),
                      _ResponseAction(
                        tooltip: 'Regenerate response',
                        icon: FLucideIcons.refreshCw,
                        onPressed: widget.onRegenerate,
                      ),
                      _ResponseAction(
                        tooltip: 'Copy response',
                        icon: FLucideIcons.copy,
                        onPressed: () {
                          unawaited(HapticFeedback.selectionClick());
                          unawaited(
                            Clipboard.setData(
                              ClipboardData(text: widget.message.text),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7, top: 1),
                    child: Text(
                      'Jobodia AI can make mistakes. Check important information.',
                      style: TextStyle(
                        color: palette.textTertiary,
                        fontSize: 10,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(bottom: _isUser ? 12 : 18),
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(position: _slide, child: content),
        ),
      ),
    );
  }
}

class _ResumeAttachmentCard extends StatelessWidget {
  const _ResumeAttachmentCard({
    required this.attachment,
    required this.foreground,
  });

  final ResumeAttachment attachment;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      attachment.extension.toUpperCase(),
      attachment.formattedSize,
      if (attachment.pageCount != null)
        '${attachment.pageCount} ${attachment.pageCount == 1 ? 'page' : 'pages'}',
    ].join('  •  ');

    return Container(
      constraints: const BoxConstraints(minWidth: 230, maxWidth: 280),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: foreground.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 50,
            decoration: BoxDecoration(
              color: foreground.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: foreground.withValues(alpha: 0.18)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(FLucideIcons.fileText, color: foreground, size: 23),
                Positioned(
                  left: 5,
                  right: 5,
                  bottom: 5,
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: foreground.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  metadata,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: foreground.withValues(alpha: 0.66),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(FLucideIcons.sparkles, size: 11, color: foreground),
                    const SizedBox(width: 4),
                    Text(
                      'Ready for AI review',
                      style: TextStyle(
                        color: foreground,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeAnalysisCard extends StatelessWidget {
  const _ResumeAnalysisCard({required this.analysis});

  final ResumeAnalysis analysis;

  Color _scoreColor() {
    if (analysis.overallScore >= 80) return AppColors.success;
    if (analysis.overallScore >= 60) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final scoreColor = _scoreColor();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox.square(
              dimension: 58,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: analysis.overallScore / 100,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    backgroundColor: palette.border,
                    valueColor: AlwaysStoppedAnimation(scoreColor),
                  ),
                  Center(
                    child: Text(
                      '${analysis.overallScore}',
                      style: TextStyle(
                        color: palette.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resume score · ${analysis.overallScore}/100',
                    style: TextStyle(
                      color: palette.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (analysis.targetRole != null)
                    Text(
                      'For ${analysis.targetRole}',
                      style: TextStyle(
                        color: scoreColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  const SizedBox(height: 5),
                  Text(
                    analysis.summary,
                    style: TextStyle(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Divider(color: palette.divider, height: 1),
        const SizedBox(height: 16),
        _AnalysisSectionTitle(
          icon: FLucideIcons.chartLine,
          label: 'Score breakdown',
          palette: palette,
        ),
        const SizedBox(height: 12),
        ...analysis.categories.map(
          (category) =>
              _CategoryScoreRow(category: category, accent: scoreColor),
        ),
        if (analysis.strengths.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AnalysisSectionTitle(
            icon: FLucideIcons.badgeCheck,
            label: 'What works',
            palette: palette,
          ),
          const SizedBox(height: 9),
          ...analysis.strengths.map(
            (strength) => _AnalysisBullet(
              text: strength,
              icon: FLucideIcons.check,
              color: AppColors.success,
            ),
          ),
        ],
        if (analysis.priorityFixes.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AnalysisSectionTitle(
            icon: FLucideIcons.wrench,
            label: 'Fix these first',
            palette: palette,
          ),
          const SizedBox(height: 9),
          ...analysis.priorityFixes.asMap().entries.map(
            (entry) => _PriorityFixCard(index: entry.key + 1, fix: entry.value),
          ),
        ],
        if (analysis.rewrites.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AnalysisSectionTitle(
            icon: FLucideIcons.sparkles,
            label: 'Stronger wording',
            palette: palette,
          ),
          const SizedBox(height: 9),
          ...analysis.rewrites.map(_RewriteCard.new),
        ],
        if (analysis.missingInformation.isNotEmpty) ...[
          const SizedBox(height: 8),
          _AnalysisSectionTitle(
            icon: FLucideIcons.info,
            label: 'Missing or unclear',
            palette: palette,
          ),
          const SizedBox(height: 9),
          ...analysis.missingInformation.map(
            (item) => _AnalysisBullet(
              text: item,
              icon: FLucideIcons.alertTriangle,
              color: AppColors.warning,
            ),
          ),
        ],
        if (analysis.targetRoleFit case final fit?) ...[
          const SizedBox(height: 8),
          _AnalysisSectionTitle(
            icon: FLucideIcons.target,
            label: 'Target-role fit',
            palette: palette,
          ),
          const SizedBox(height: 7),
          Text(
            fit,
            style: TextStyle(
              color: palette.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 10),
        TextButton.icon(
          onPressed: () => Get.toNamed(AppRoutes.cvBuilder),
          style: TextButton.styleFrom(
            foregroundColor: palette.textPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          ),
          icon: const Icon(FLucideIcons.arrowRight, size: 18),
          label: const Text(
            'Improve in CV Builder',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          'AI guidance only—not a hiring result or guaranteed ATS score.',
          style: TextStyle(
            color: palette.textTertiary,
            fontSize: 9.5,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _AnalysisSectionTitle extends StatelessWidget {
  const _AnalysisSectionTitle({
    required this.icon,
    required this.label,
    required this.palette,
  });

  final IconData icon;
  final String label;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: palette.iconPrimary),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    ],
  );
}

class _CategoryScoreRow extends StatelessWidget {
  const _CategoryScoreRow({required this.category, required this.accent});

  final ResumeScoreCategory category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category.label,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${category.score}/${category.maxScore}',
                style: TextStyle(
                  color: palette.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: category.progress,
              minHeight: 6,
              backgroundColor: palette.border,
              valueColor: AlwaysStoppedAnimation(accent),
            ),
          ),
          if (category.reason.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              category.reason,
              style: TextStyle(
                color: palette.textTertiary,
                fontSize: 10.5,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AnalysisBullet extends StatelessWidget {
  const _AnalysisBullet({
    required this.text,
    required this.icon,
    required this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 12, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.palette.textSecondary,
              fontSize: 11.5,
              height: 1.35,
            ),
          ),
        ),
      ],
    ),
  );
}

class _PriorityFixCard extends StatelessWidget {
  const _PriorityFixCard({required this.index, required this.fix});

  final int index;
  final ResumePriorityFix fix;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 23,
            height: 23,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.brandTeal,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fix.title,
                  style: TextStyle(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (fix.why.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    fix.why,
                    style: TextStyle(
                      color: palette.textTertiary,
                      fontSize: 10.5,
                      height: 1.3,
                    ),
                  ),
                ],
                if (fix.action.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    fix.action,
                    style: const TextStyle(
                      color: AppColors.brandTeal,
                      fontSize: 10.5,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RewriteCard extends StatelessWidget {
  const _RewriteCard(this.rewrite);

  final ResumeRewrite rewrite;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Before',
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rewrite.original,
            style: TextStyle(
              color: palette.textTertiary,
              fontSize: 10.5,
              height: 1.3,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Better',
            style: TextStyle(
              color: AppColors.brandTeal,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            rewrite.improved,
            style: TextStyle(
              color: palette.textPrimary,
              fontSize: 11.5,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseAction extends StatelessWidget {
  const _ResponseAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(7),
      constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      iconSize: 18,
      color: selected ? palette.textPrimary : palette.iconMuted,
      icon: Icon(icon),
    );
  }
}

/// Small, dependency-free Markdown renderer for AI replies. It supports the
/// formatting DeepSeek commonly returns: headings, lists, quotes, fenced code,
/// bold, italic, inline code, and links.
class _BotMarkdownText extends StatelessWidget {
  const _BotMarkdownText({
    required this.text,
    required this.style,
    this.animateLastWord = false,
  });

  final String text;
  final TextStyle style;
  final bool animateLastWord;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final lines = text.trim().split('\n');
    final blocks = <Widget>[];
    final codeLines = <String>[];
    var inCodeBlock = false;
    var lastContentLine = -1;
    for (var index = lines.length - 1; index >= 0; index--) {
      if (lines[index].trim().isNotEmpty &&
          !lines[index].trimLeft().startsWith('```')) {
        lastContentLine = index;
        break;
      }
    }

    void addCodeBlock() {
      if (codeLines.isEmpty) return;
      blocks.add(
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: palette.border),
          ),
          child: Text(
            codeLines.join('\n'),
            style: style.copyWith(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ),
      );
      codeLines.clear();
    }

    for (var lineIndex = 0; lineIndex < lines.length; lineIndex++) {
      final rawLine = lines[lineIndex];
      final line = rawLine.trimRight();
      final animateLine = animateLastWord && lineIndex == lastContentLine;
      if (line.trimLeft().startsWith('```')) {
        if (inCodeBlock) addCodeBlock();
        inCodeBlock = !inCodeBlock;
        continue;
      }
      if (inCodeBlock) {
        codeLines.add(rawLine);
        continue;
      }
      if (line.trim().isEmpty) {
        if (blocks.isNotEmpty) blocks.add(const SizedBox(height: 7));
        continue;
      }

      final heading = RegExp(r'^(#{1,3})\s+(.+)$').firstMatch(line);
      final bullet = RegExp(r'^\s*[-*]\s+(.+)$').firstMatch(line);
      final numbered = RegExp(r'^\s*(\d+)[.)]\s+(.+)$').firstMatch(line);
      final quote = RegExp(r'^\s*>\s?(.+)$').firstMatch(line);

      if (heading != null) {
        final level = heading.group(1)!.length;
        blocks.add(
          Padding(
            padding: EdgeInsets.only(top: blocks.isEmpty ? 0 : 5, bottom: 3),
            child: _InlineMarkdownText(
              text: heading.group(2)!,
              animateLastWord: animateLine,
              style: style.copyWith(
                fontSize: level == 1 ? 19 : (level == 2 ? 17 : 15.5),
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      } else if (bullet != null) {
        blocks.add(
          _MarkdownListRow(
            marker: '•',
            text: bullet.group(1)!,
            style: style,
            animateLastWord: animateLine,
          ),
        );
      } else if (numbered != null) {
        blocks.add(
          _MarkdownListRow(
            marker: '${numbered.group(1)}.',
            text: numbered.group(2)!,
            style: style,
            animateLastWord: animateLine,
          ),
        );
      } else if (quote != null) {
        blocks.add(
          Container(
            margin: const EdgeInsets.symmetric(vertical: 3),
            padding: const EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: palette.info, width: 3)),
            ),
            child: _InlineMarkdownText(
              text: quote.group(1)!,
              animateLastWord: animateLine,
              style: style.copyWith(
                color: palette.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      } else {
        blocks.add(
          _InlineMarkdownText(
            text: line,
            style: style,
            animateLastWord: animateLine,
          ),
        );
      }
    }
    if (inCodeBlock) addCodeBlock();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: blocks,
    );
  }
}

class _MarkdownListRow extends StatelessWidget {
  const _MarkdownListRow({
    required this.marker,
    required this.text,
    required this.style,
    this.animateLastWord = false,
  });

  final String marker;
  final String text;
  final TextStyle style;
  final bool animateLastWord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              marker,
              style: style.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          Expanded(
            child: _InlineMarkdownText(
              text: text,
              style: style,
              animateLastWord: animateLastWord,
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineMarkdownText extends StatelessWidget {
  const _InlineMarkdownText({
    required this.text,
    required this.style,
    this.animateLastWord = false,
  });

  final String text;
  final TextStyle style;
  final bool animateLastWord;

  static final _tokenPattern = RegExp(
    r'(\*\*[^*\n]+\*\*|__[^_\n]+__|`[^`\n]+`|\*[^*\n]+\*|_[^_\n]+_|\[[^\]\n]+\]\([^)\n]+\))',
  );

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (animateLastWord && text.trim().isNotEmpty) {
      final trimmed = text.trimRight();
      final whitespaceMatches = RegExp(r'\s').allMatches(trimmed);
      final lastWhitespace = whitespaceMatches.isEmpty
          ? -1
          : whitespaceMatches.last.start;
      final prefix = lastWhitespace < 0
          ? ''
          : trimmed.substring(0, lastWhitespace + 1);
      final token = trimmed.substring(lastWhitespace + 1);
      final decoded = _decodeToken(token, palette);

      return Text.rich(
        TextSpan(
          style: style,
          children: [
            ..._buildSpans(prefix, palette),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: _BlurRevealWord(
                key: ValueKey('$text-${decoded.$1}'),
                text: decoded.$1,
                style: style.merge(decoded.$2),
              ),
            ),
          ],
        ),
      );
    }

    return Text.rich(
      TextSpan(style: style, children: _buildSpans(text, palette)),
    );
  }

  List<InlineSpan> _buildSpans(String source, AppPalette palette) {
    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _tokenPattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**') || token.startsWith('__')) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        );
      } else if (token.startsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: (style.fontSize ?? 15) - 1,
              color: palette.info,
              backgroundColor: palette.surface,
            ),
          ),
        );
      } else if (token.startsWith('[')) {
        final endLabel = token.indexOf('](');
        spans.add(
          TextSpan(
            text: token.substring(1, endLabel),
            style: TextStyle(
              color: palette.info,
              decoration: TextDecoration.underline,
              decorationColor: palette.info,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
        );
      }
      cursor = match.end;
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor)));
    }

    return spans;
  }

  (String, TextStyle) _decodeToken(String token, AppPalette palette) {
    if ((token.startsWith('**') && token.endsWith('**')) ||
        (token.startsWith('__') && token.endsWith('__'))) {
      return (
        token.substring(2, token.length - 2),
        const TextStyle(fontWeight: FontWeight.w800),
      );
    }
    if (token.startsWith('`') && token.endsWith('`')) {
      return (
        token.substring(1, token.length - 1),
        TextStyle(
          fontFamily: 'monospace',
          fontSize: (style.fontSize ?? 15) - 1,
          color: palette.info,
          backgroundColor: palette.surface,
        ),
      );
    }
    if ((token.startsWith('*') && token.endsWith('*')) ||
        (token.startsWith('_') && token.endsWith('_'))) {
      return (
        token.substring(1, token.length - 1),
        const TextStyle(fontStyle: FontStyle.italic),
      );
    }
    return (token, const TextStyle());
  }
}

class _BlurRevealWord extends StatelessWidget {
  const _BlurRevealWord({required this.text, required this.style, super.key});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 4.5, end: 0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      builder: (context, blur, child) {
        return Opacity(
          opacity: (1 - (blur / 5.5)).clamp(0.18, 1),
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: child,
          ),
        );
      },
      child: Text(text, style: style),
    );
  }
}
