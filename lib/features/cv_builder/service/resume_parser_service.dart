/// Result of parsing raw resume/CV text.
///
/// Holds the extracted [fields] (keyed by the same names the CV builder
/// controller understands), human-readable [warnings] for anything that could
/// not be extracted, and a [confidence] score between 0 and 1.
class ParseResult {
  ParseResult({
    required this.fields,
    required this.warnings,
    required this.confidence,
  });

  /// Extracted values keyed by field name (e.g. `fullName`, `email`,
  /// `skills`, `company`). Only successfully extracted fields are present.
  final Map<String, dynamic> fields;

  /// One note per scored field that could not be extracted.
  final List<String> warnings;

  /// Fraction of the scored fields that were extracted, in the range 0..1.
  final double confidence;
}

/// Pure-Dart, regex-based resume parser. No AI/ML, no network, no plugins.
///
/// Extracts seven scored fields from plain text: name, email, phone, location,
/// skills, one work entry, and one education entry.
class ResumeParserService {
  /// Number of scored fields used to compute [ParseResult.confidence].
  static const int scoredFieldCount = 7;

  static final RegExp _emailRegex = RegExp(r'[\w.+-]+@[\w-]+\.[\w.-]+');
  static final RegExp _phoneRegex = RegExp(r'\+?\d[\d\s().-]{5,}\d');
  static final RegExp _yearRangeRegex = RegExp(r'^\d{4}\s*[—–-]\s*\d{4}$');
  static final RegExp _labeledLocationRegex = RegExp(
    r'(?:location|address)\s*[:\-]\s*(.+)',
    caseSensitive: false,
  );
  static final RegExp _labeledSkillsRegex = RegExp(
    r'^skills\s*[:\-]\s*(.+)',
    caseSensitive: false,
  );

  /// Matches `Left — Right (dates)` lines, e.g.
  /// `Tech Corp — Senior Developer (2020 - Present)`. Accepts em dash,
  /// en dash, or hyphen as the separator.
  static final RegExp _entryRegex = RegExp(
    r'^(.+?)\s*[—–-]\s*(.+?)\s*\((.+?)\)\s*$',
  );

  /// Header text (lowercased, trailing punctuation stripped) → section key.
  static const Map<String, String> _sectionAliases = <String, String>{
    'skills': 'skills',
    'technical skills': 'skills',
    'core skills': 'skills',
    'experience': 'experience',
    'work experience': 'experience',
    'employment': 'experience',
    'employment history': 'experience',
    'professional experience': 'experience',
    'education': 'education',
    'academic background': 'education',
    'summary': 'summary',
    'profile': 'summary',
    'about': 'summary',
    'about me': 'summary',
    'objective': 'summary',
  };

  /// Parses [text] into a [ParseResult] using regex heuristics.
  ParseResult parseFromText(String text) {
    final fields = <String, dynamic>{};
    final warnings = <String>[];

    final lines = text.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();
    final sections = _splitSections(lines);
    final headLines = sections['_head'] ?? const <String>[];

    var extracted = 0;

    // --- Name: first non-empty line in the document. ---
    final firstNonEmpty = lines.firstWhere(
      (l) => l.isNotEmpty,
      orElse: () => '',
    );
    if (firstNonEmpty.isNotEmpty) {
      fields['fullName'] = firstNonEmpty;
      extracted++;
    } else {
      warnings.add('Name: no text found to read a name from.');
    }

    // --- Email. ---
    final email = _emailRegex.firstMatch(text)?.group(0);
    if (email != null) {
      fields['email'] = email;
      extracted++;
    } else {
      warnings.add('Email: no address matched.');
    }

    // --- Phone. ---
    final phone = _findPhone(text, headLines);
    if (phone != null) {
      fields['phone'] = phone;
      extracted++;
    } else {
      warnings.add('Phone: no number with 7 or more digits found.');
    }

    // --- Location. ---
    final location = _findLocation(lines, headLines, firstNonEmpty);
    if (location != null) {
      fields['location'] = location;
      extracted++;
    } else {
      warnings.add(
        'Location: no "Location:" label or comma-separated line found.',
      );
    }

    // --- Title (bonus, not scored). ---
    final title = _findTitle(headLines, firstNonEmpty);
    if (title != null) fields['title'] = title;

    // --- Summary (bonus, not scored). ---
    final summaryLines = sections['summary'];
    if (summaryLines != null && summaryLines.isNotEmpty) {
      fields['summary'] = summaryLines.join(' ');
    }

    // --- Skills. ---
    final skills = _findSkills(sections, lines);
    if (skills.isNotEmpty) {
      fields['skills'] = skills;
      extracted++;
    } else {
      warnings.add(
        'Skills: no "Skills" section or comma-separated list found.',
      );
    }

    // --- Work experience (one entry). ---
    final work = _findEntry(sections['experience']);
    if (work != null) {
      fields['company'] = work.left;
      fields['role'] = work.right;
      fields['workStart'] = work.start;
      fields['workEnd'] = work.end;
      if (work.description != null) fields['workDesc'] = work.description;
      extracted++;
    } else {
      warnings.add(
        'Work experience: no "Company — Role (dates)" line or '
        'Experience section found.',
      );
    }

    // --- Education (one entry). ---
    final edu = _findEntry(sections['education']);
    if (edu != null) {
      fields['school'] = edu.left;
      fields['degree'] = edu.right;
      fields['eduStart'] = edu.start;
      fields['eduEnd'] = edu.end;
      extracted++;
    } else {
      warnings.add(
        'Education: no "School — Degree (dates)" line or '
        'Education section found.',
      );
    }

    return ParseResult(
      fields: fields,
      warnings: warnings,
      confidence: extracted / scoredFieldCount,
    );
  }

  /// Groups lines into sections keyed by [_sectionAliases]. Lines before the
  /// first recognised header land under the `_head` key.
  Map<String, List<String>> _splitSections(List<String> lines) {
    final result = <String, List<String>>{'_head': <String>[]};
    var current = '_head';
    for (final line in lines) {
      final key = _headerKey(line);
      if (key != null) {
        current = key;
        result.putIfAbsent(current, () => <String>[]);
        continue;
      }
      if (line.isEmpty) continue;
      result.putIfAbsent(current, () => <String>[]).add(line);
    }
    return result;
  }

  /// Returns the section key when [line] is a standalone header, else null.
  String? _headerKey(String line) {
    if (line.isEmpty) return null;
    final normalized = line
        .toLowerCase()
        .replaceAll(RegExp(r'[:\-]+$'), '')
        .trim();
    if (normalized.length > 24) return null;
    return _sectionAliases[normalized];
  }

  /// Finds a phone-like substring with 7+ digits, preferring the header block
  /// (where contact info usually sits) and skipping bare year ranges.
  String? _findPhone(String text, List<String> headLines) {
    final candidates = <String>[
      for (final m in _phoneRegex.allMatches(headLines.join('\n')))
        m.group(0)!.trim(),
      for (final m in _phoneRegex.allMatches(text)) m.group(0)!.trim(),
    ];
    for (final candidate in candidates) {
      if (_yearRangeRegex.hasMatch(candidate)) continue;
      final digitCount = candidate.replaceAll(RegExp(r'\D'), '').length;
      if (digitCount >= 7) return candidate;
    }
    return null;
  }

  /// Finds a location via a `Location:`/`Address:` label, or the first
  /// comma-containing line in the header block that is not the name or email.
  String? _findLocation(
    List<String> lines,
    List<String> headLines,
    String nameLine,
  ) {
    for (final line in lines) {
      final match = _labeledLocationRegex.firstMatch(line);
      final value = match?.group(1)?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    for (final line in headLines) {
      if (line == nameLine) continue;
      if (!line.contains(',')) continue;
      if (_emailRegex.hasMatch(line)) continue;
      return line;
    }
    return null;
  }

  /// Picks the first descriptive header line after the name as a job title.
  String? _findTitle(List<String> headLines, String nameLine) {
    for (final line in headLines) {
      if (line == nameLine) continue;
      if (line.contains(',')) continue;
      if (_emailRegex.hasMatch(line)) continue;
      if (_phoneRegex.hasMatch(line)) continue;
      if (_labeledLocationRegex.hasMatch(line)) continue;
      return line;
    }
    return null;
  }

  /// Reads skills from a `Skills` section, or an inline `Skills: a, b, c` line.
  List<String> _findSkills(
    Map<String, List<String>> sections,
    List<String> lines,
  ) {
    final section = sections['skills'];
    if (section != null && section.isNotEmpty) {
      final skills = _splitSkills(section.join(', '));
      if (skills.isNotEmpty) return skills;
    }
    for (final line in lines) {
      final match = _labeledSkillsRegex.firstMatch(line);
      if (match != null) {
        final skills = _splitSkills(match.group(1)!);
        if (skills.isNotEmpty) return skills;
      }
    }
    return const <String>[];
  }

  List<String> _splitSkills(String raw) => raw
      .split(RegExp(r'[,;•|]'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  /// Extracts a single `Left — Right (dates)` entry from [sectionLines],
  /// falling back to the first one or two lines when no pattern matches.
  _Entry? _findEntry(List<String>? sectionLines) {
    if (sectionLines == null || sectionLines.isEmpty) return null;

    for (var i = 0; i < sectionLines.length; i++) {
      final match = _entryRegex.firstMatch(sectionLines[i]);
      if (match == null) continue;

      final dates = _splitDates(match.group(3)!.trim());
      String? description;
      if (i + 1 < sectionLines.length &&
          _entryRegex.firstMatch(sectionLines[i + 1]) == null) {
        description = sectionLines[i + 1];
      }
      return _Entry(
        left: match.group(1)!.trim(),
        right: match.group(2)!.trim(),
        start: dates.start,
        end: dates.end,
        description: description,
      );
    }

    return _Entry(
      left: sectionLines.first,
      right: sectionLines.length > 1 ? sectionLines[1] : '',
      start: '',
      end: '',
      description: null,
    );
  }

  /// Splits a `2020 - Present` style range into start/end parts.
  _DateRange _splitDates(String dates) {
    final parts = dates.split(RegExp(r'\s*[—–-]\s*'));
    if (parts.length >= 2) {
      return _DateRange(
        start: parts.first.trim(),
        end: parts.sublist(1).join('-').trim(),
      );
    }
    return _DateRange(start: dates.trim(), end: '');
  }
}

/// A single parsed work/education entry.
class _Entry {
  _Entry({
    required this.left,
    required this.right,
    required this.start,
    required this.end,
    required this.description,
  });

  final String left;
  final String right;
  final String start;
  final String end;
  final String? description;
}

/// A start/end date pair parsed from a date range string.
class _DateRange {
  _DateRange({required this.start, required this.end});

  final String start;
  final String end;
}
