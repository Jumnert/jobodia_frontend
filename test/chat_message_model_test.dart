import 'package:flutter_test/flutter_test.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:jobodia_frontend/features/ai_chat/model/resume_analysis.dart';

void main() {
  test(
    'resume attachment and private AI context survive secure serialization',
    () {
      final message = ChatMessageModel(
        text: 'Analyze my resume',
        sender: ChatMessageSender.user,
        aiContext: 'Private extracted resume text',
        resumeAttachment: const ResumeAttachment(
          fileName: 'Jumnert Resume.pdf',
          extension: 'pdf',
          sizeBytes: 2048,
          pageCount: 2,
        ),
      );

      final restored = ChatMessageModel.fromJson(message.toJson());

      expect(restored.text, 'Analyze my resume');
      expect(restored.apiText, contains('Private extracted resume text'));
      expect(restored.resumeAttachment?.fileName, 'Jumnert Resume.pdf');
      expect(restored.resumeAttachment?.formattedSize, '2.0 KB');
      expect(restored.resumeAttachment?.pageCount, 2);
    },
  );

  test('structured resume rating survives secure serialization', () {
    final categories = ResumeAnalysis.expectedCategories.entries
        .map(
          (entry) => ResumeScoreCategory(
            id: entry.key,
            label: entry.value.$1,
            score: entry.value.$2,
            maxScore: entry.value.$2,
            reason: 'Complete.',
          ),
        )
        .toList();
    final message = ChatMessageModel(
      text: 'Resume score: 100/100',
      sender: ChatMessageSender.bot,
      resumeAnalysis: ResumeAnalysis(
        summary: 'Excellent resume.',
        categories: categories,
        strengths: const ['Clear impact'],
        priorityFixes: const [],
        rewrites: const [],
        missingInformation: const [],
        targetRole: 'Flutter Developer',
      ),
    );

    final restored = ChatMessageModel.fromJson(message.toJson());

    expect(restored.resumeAnalysis?.overallScore, 100);
    expect(restored.resumeAnalysis?.targetRole, 'Flutter Developer');
  });
}
