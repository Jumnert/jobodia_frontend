import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jobodia_frontend/features/interview/data/recruiter_messages.dart';

/// Resource section with professional message templates job seekers can copy.
class RecruiterMessagesScreen extends StatelessWidget {
  const RecruiterMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? const Color(0xFF101214)
        : const Color(0xFFF5F6F8);
    final foregroundColor = isDark ? Colors.white : Colors.black;
    final mutedColor = isDark
        ? const Color(0xFFA5ABB1)
        : const Color(0xFF6F7378);
    final cardColor = isDark ? const Color(0xFF1A1D20) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2A2E33)
        : const Color(0xFFEDEDED);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: Get.back,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 30,
                    color: foregroundColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Chat to Recruiter',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                itemCount: recruiterMessages.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Tap the copy icon to grab a ready-to-send template, '
                        'then fill in the bracketed details.',
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    );
                  }
                  final message = recruiterMessages[index - 1];
                  return _MessageCard(
                    message: message,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    foregroundColor: foregroundColor,
                    mutedColor: mutedColor,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.message,
    required this.cardColor,
    required this.borderColor,
    required this.foregroundColor,
    required this.mutedColor,
  });

  final RecruiterMessage message;
  final Color cardColor;
  final Color borderColor;
  final Color foregroundColor;
  final Color mutedColor;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: message.body));
    Get.snackbar(
      'Copied',
      '"${message.title}" is ready to paste.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.title,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message.category.toUpperCase(),
                      style: TextStyle(
                        color: const Color(0xFF7C3AED),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _copy,
                tooltip: 'Copy to clipboard',
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Color(0xFF7C3AED),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message.body,
            style: TextStyle(color: mutedColor, fontSize: 13.5, height: 1.5),
          ),
        ],
      ),
    );
  }
}
