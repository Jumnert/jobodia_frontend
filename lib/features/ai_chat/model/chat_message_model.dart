import 'package:jobodia_frontend/features/ai_chat/model/resume_analysis.dart';

enum ChatMessageSender { user, bot }

class ChatMessageModel {
  ChatMessageModel({
    required this.text,
    required this.sender,
    this.resumeAttachment,
    this.resumeAnalysis,
    this.aiContext,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String text;
  final ChatMessageSender sender;
  final DateTime timestamp;
  final ResumeAttachment? resumeAttachment;
  final ResumeAnalysis? resumeAnalysis;

  /// Extra text sent to the AI but intentionally hidden from the chat bubble.
  /// Chat history is persisted through secure storage by the controller.
  final String? aiContext;

  String get apiText {
    final context = aiContext?.trim();
    if (context == null || context.isEmpty) return text;
    return '$text\n\n$context';
  }

  ChatMessageModel copyWith({
    String? text,
    ChatMessageSender? sender,
    DateTime? timestamp,
    ResumeAttachment? resumeAttachment,
    ResumeAnalysis? resumeAnalysis,
    String? aiContext,
  }) {
    return ChatMessageModel(
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      resumeAttachment: resumeAttachment ?? this.resumeAttachment,
      resumeAnalysis: resumeAnalysis ?? this.resumeAnalysis,
      aiContext: aiContext ?? this.aiContext,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'sender': sender.name,
    'timestamp': timestamp.toIso8601String(),
    if (resumeAttachment != null)
      'resumeAttachment': resumeAttachment!.toJson(),
    if (resumeAnalysis != null) 'resumeAnalysis': resumeAnalysis!.toJson(),
    if (aiContext != null) 'aiContext': aiContext,
  };

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    final senderName = json['sender'] as String?;
    final sender =
        ChatMessageSender.values.asNameMap()[senderName] ??
        ChatMessageSender.user;
    return ChatMessageModel(
      text: json['text'] as String? ?? '',
      sender: sender,
      resumeAttachment: json['resumeAttachment'] is Map
          ? ResumeAttachment.fromJson(
              Map<String, dynamic>.from(json['resumeAttachment'] as Map),
            )
          : null,
      resumeAnalysis: json['resumeAnalysis'] is Map
          ? ResumeAnalysis.fromJson(
              Map<String, dynamic>.from(json['resumeAnalysis'] as Map),
              targetRole: (json['resumeAnalysis'] as Map)['targetRole']
                  ?.toString(),
            )
          : null,
      aiContext: json['aiContext'] as String?,
      timestamp:
          DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class ResumeAttachment {
  const ResumeAttachment({
    required this.fileName,
    required this.extension,
    required this.sizeBytes,
    this.pageCount,
  });

  final String fileName;
  final String extension;
  final int sizeBytes;
  final int? pageCount;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
    'fileName': fileName,
    'extension': extension,
    'sizeBytes': sizeBytes,
    if (pageCount != null) 'pageCount': pageCount,
  };

  factory ResumeAttachment.fromJson(Map<String, dynamic> json) {
    return ResumeAttachment(
      fileName: json['fileName'] as String? ?? 'Resume',
      extension: json['extension'] as String? ?? 'file',
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      pageCount: json['pageCount'] as int?,
    );
  }
}
