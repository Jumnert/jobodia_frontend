import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:file_selector/file_selector.dart';
import 'package:jobodia_frontend/features/ai_chat/model/chat_message_model.dart';
import 'package:read_pdf_text/read_pdf_text.dart';

class ExtractedResume {
  const ExtractedResume({required this.attachment, required this.text});

  final ResumeAttachment attachment;
  final String text;
}

class ResumeTextExtractor {
  static const _maxFileBytes = 10 * 1024 * 1024;
  static const _maxResumeCharacters = 120000;
  static const _acceptedTypes = XTypeGroup(
    label: 'Resume',
    extensions: <String>['pdf', 'docx', 'txt', 'md'],
    uniformTypeIdentifiers: <String>[
      'com.adobe.pdf',
      'org.openxmlformats.wordprocessingml.document',
      'public.plain-text',
    ],
  );

  Future<ExtractedResume?> pickAndExtract() async {
    final file = await openFile(
      acceptedTypeGroups: const [_acceptedTypes],
      confirmButtonText: 'Analyze Resume',
    );
    if (file == null) return null;

    final size = await file.length();
    if (size > _maxFileBytes) {
      throw const ResumeExtractionException(
        'Please choose a resume smaller than 10 MB.',
      );
    }

    final extension = _extensionOf(file.name);
    int? pageCount;
    final String rawText;
    switch (extension) {
      case 'pdf':
        if (file.path.isEmpty) {
          throw const ResumeExtractionException(
            'This PDF could not be opened from the device.',
          );
        }
        rawText = await ReadPdfText.getPDFtext(file.path);
        pageCount = await ReadPdfText.getPDFlength(file.path);
      case 'docx':
        rawText = _extractDocxText(await file.readAsBytes());
      case 'txt' || 'md':
        rawText = await file.readAsString();
      default:
        throw const ResumeExtractionException(
          'Use a PDF, DOCX, TXT, or Markdown resume.',
        );
    }

    final text = _normalize(rawText);
    if (text.length < 80) {
      throw const ResumeExtractionException(
        'No readable resume text was found. If this is a scanned PDF, export it as a searchable PDF first.',
      );
    }
    if (text.length > _maxResumeCharacters) {
      throw const ResumeExtractionException(
        'This document is unusually long for a resume. Please upload a resume under 120,000 characters.',
      );
    }

    return ExtractedResume(
      attachment: ResumeAttachment(
        fileName: file.name,
        extension: extension,
        sizeBytes: size,
        pageCount: pageCount,
      ),
      text: text,
    );
  }

  String _extractDocxText(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    final document = archive.findFile('word/document.xml');
    final documentBytes = document?.readBytes();
    if (documentBytes == null) {
      throw const ResumeExtractionException(
        'This DOCX file does not contain a readable document.',
      );
    }

    var xml = utf8.decode(documentBytes, allowMalformed: true);
    xml = xml
        .replaceAll(RegExp(r'</w:p>'), '\n')
        .replaceAll(RegExp(r'<w:tab[^>]*/>'), '\t')
        .replaceAll(RegExp(r'<w:br[^>]*/>'), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '');
    return _decodeXmlEntities(xml);
  }

  String _decodeXmlEntities(String value) {
    return value
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&apos;', "'");
  }

  String _normalize(String value) {
    return value
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'[ \t]+'), ' ').trim())
        .join('\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}

class ResumeExtractionException implements Exception {
  const ResumeExtractionException(this.message);

  final String message;

  @override
  String toString() => message;
}
