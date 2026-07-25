import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

/// Accent color per template index, shared between the on-screen preview and
/// the exported PDF so they stay visually matched.
const _accents = <PdfColor>[
  PdfColor.fromInt(0xFF0EA5A4), // Classic — teal
  PdfColor.fromInt(0xFF18A999), // Editorial — green
  PdfColor.fromInt(0xFF173E3C), // Impact — deep green
];

PdfColor accentForTemplate(int index) =>
    _accents[index.clamp(0, _accents.length - 1)];

/// Builds the PDF document for [cv], selecting the layout that matches the
/// template stored on the model.
Future<Uint8List> buildCvPdf(CvData cv) async {
  assert(
    cv.templateIndex >= 0 && cv.templateIndex < _accents.length,
    'templateIndex ${cv.templateIndex} out of range 0..${_accents.length - 1}',
  );
  final doc = pw.Document(
    title: '${cv.fullName} — CV',
    author: cv.fullName,
    creator: 'Jobodia CV Builder',
    subject: cv.title,
    keywords: cv.skills.join(', '),
  );
  final image = cv.hasHeadshot ? pw.MemoryImage(cv.headshotBytes!) : null;
  final accent = accentForTemplate(cv.templateIndex);

  pw.Widget body;
  switch (cv.templateIndex) {
    case 1:
      body = _balanced(cv, image, accent);
      break;
    case 2:
      body = _modern(cv, image, accent);
      break;
    default:
      body = _classic(cv, image, accent);
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(0),
      build: (context) => [body],
    ),
  );

  return doc.save();
}

// ---------------------------------------------------------------------------
// Classic — editorial single column with a structured masthead.
// ---------------------------------------------------------------------------
pw.Widget _classic(CvData cv, pw.MemoryImage? image, PdfColor accent) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(36),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                    style: pw.TextStyle(
                      fontSize: 30,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (cv.title.isNotEmpty)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 5),
                      child: pw.Text(
                        cv.title.toUpperCase(),
                        style: pw.TextStyle(
                          fontSize: 11,
                          color: accent,
                          letterSpacing: 1.8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            pw.SizedBox(width: 20),
            if (image != null)
              pw.Container(
                width: 64,
                height: 76,
                decoration: pw.BoxDecoration(
                  borderRadius: pw.BorderRadius.circular(5),
                  image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
                ),
              )
            else
              pw.SizedBox(
                width: 170,
                child: pw.Text(
                  _contactLine(cv).replaceAll('  |  ', '\n'),
                  textAlign: pw.TextAlign.right,
                  style: const pw.TextStyle(
                    fontSize: 9.5,
                    lineSpacing: 3,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
          ],
        ),
        if (image != null) ...[
          pw.SizedBox(height: 8),
          pw.Text(
            _contactLine(cv),
            style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey700),
          ),
        ],
        pw.Container(
          margin: const pw.EdgeInsets.only(top: 14, bottom: 18),
          height: 3,
          width: 52,
          color: accent,
        ),
        if (cv.summary.isNotEmpty) ...[
          _classicSection('Profile', accent),
          pw.Text(cv.summary, style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 16),
        ],
        if (cv.workExperiences.isNotEmpty) ...[
          _classicSection('Experience', accent),
          ...cv.workExperiences.map(
            (w) => _classicEntry(w.role, w.company, w.dateRange, w.description),
          ),
          pw.SizedBox(height: 6),
        ],
        if (cv.educations.isNotEmpty) ...[
          _classicSection('Education', accent),
          ...cv.educations.map(
            (e) =>
                _classicEntry(e.degree, e.school, e.dateRange, e.description),
          ),
          pw.SizedBox(height: 6),
        ],
        if (cv.skills.isNotEmpty) ...[
          _classicSection('Skills', accent),
          pw.Wrap(
            spacing: 6,
            runSpacing: 6,
            children: cv.skills.map((s) => _chip(s, accent)).toList(),
          ),
        ],
      ],
    ),
  );
}

pw.Widget _classicSection(String label, PdfColor accent) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 9),
    child: pw.Row(
      children: [
        pw.Container(width: 7, height: 7, color: accent),
        pw.SizedBox(width: 8),
        pw.Text(
          label.toUpperCase(),
          style: pw.TextStyle(
            fontSize: 11,
            letterSpacing: 1.6,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(child: pw.Container(height: 0.6, color: PdfColors.grey400)),
      ],
    ),
  );
}

pw.Widget _classicEntry(
  String title,
  String subtitle,
  String dates,
  String description,
) {
  return pw.Container(
    width: double.infinity,
    margin: const pw.EdgeInsets.only(bottom: 12),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (dates.isNotEmpty)
              pw.Text(
                dates,
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
          ],
        ),
        if (subtitle.isNotEmpty)
          pw.Text(
            subtitle,
            style: pw.TextStyle(
              fontSize: 10.5,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        if (description.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 3),
            child: _achievementText(description),
          ),
      ],
    ),
  );
}

pw.Widget _achievementText(String description) {
  final lines = description
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim().replaceFirst(RegExp(r'^[•\-–]\s*'), ''))
      .where((line) => line.isNotEmpty)
      .toList();

  if (lines.length <= 1) {
    return pw.Text(
      description.trim(),
      style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: lines
        .map(
          (line) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 2),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4, right: 6),
                  child: pw.Container(
                    width: 3,
                    height: 3,
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey800,
                      shape: pw.BoxShape.circle,
                    ),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    line,
                    style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
                  ),
                ),
              ],
            ),
          ),
        )
        .toList(),
  );
}

// ---------------------------------------------------------------------------
// Editorial — deep sidebar with a clean reading column.
// ---------------------------------------------------------------------------
pw.Widget _balanced(CvData cv, pw.MemoryImage? image, PdfColor accent) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Sidebar
      pw.Container(
        width: 180,
        color: PdfColor.fromInt(0xFF102D2B),
        padding: const pw.EdgeInsets.all(20),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (image != null)
              pw.Center(
                child: pw.Container(
                  width: 96,
                  height: 96,
                  margin: const pw.EdgeInsets.only(bottom: 16),
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    border: pw.Border.all(color: accent, width: 2),
                    image: pw.DecorationImage(
                      image: image,
                      fit: pw.BoxFit.cover,
                    ),
                  ),
                ),
              ),
            _sidebarHeading('Contact', accent),
            if (cv.email.isNotEmpty) _sidebarText(cv.email, PdfColors.white),
            if (cv.phone.isNotEmpty) _sidebarText(cv.phone, PdfColors.white),
            if (cv.location.isNotEmpty)
              _sidebarText(cv.location, PdfColors.white),
            if (cv.skills.isNotEmpty) ...[
              pw.SizedBox(height: 16),
              _sidebarHeading('Skills', accent),
              ...cv.skills.map(
                (s) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 5),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        width: 5,
                        height: 5,
                        margin: const pw.EdgeInsets.only(top: 3, right: 6),
                        decoration: pw.BoxDecoration(
                          color: accent,
                          shape: pw.BoxShape.circle,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          s,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      // Main
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (cv.title.isNotEmpty)
                pw.Text(
                  cv.title,
                  style: pw.TextStyle(fontSize: 13, color: accent),
                ),
              pw.SizedBox(height: 16),
              if (cv.summary.isNotEmpty) ...[
                _mainHeading('Profile', accent),
                pw.Text(cv.summary, style: const pw.TextStyle(fontSize: 11)),
                pw.SizedBox(height: 14),
              ],
              if (cv.workExperiences.isNotEmpty) ...[
                _mainHeading('Experience', accent),
                ...cv.workExperiences.map(
                  (w) => _classicEntry(
                    w.role,
                    w.company,
                    w.dateRange,
                    w.description,
                  ),
                ),
              ],
              if (cv.educations.isNotEmpty) ...[
                _mainHeading('Education', accent),
                ...cv.educations.map(
                  (e) => _classicEntry(
                    e.degree,
                    e.school,
                    e.dateRange,
                    e.description,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ],
  );
}

pw.Widget _sidebarHeading(String label, PdfColor accent) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 6),
  child: pw.Text(
    label.toUpperCase(),
    style: pw.TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: pw.FontWeight.bold,
      color: accent,
    ),
  ),
);

pw.Widget _sidebarText(String text, PdfColor color) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Text(text, style: pw.TextStyle(fontSize: 9.5, color: color)),
);

pw.Widget _mainHeading(String label, PdfColor accent) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 8),
  child: pw.Row(
    children: [
      pw.Container(width: 16, height: 3, color: accent),
      pw.SizedBox(width: 6),
      pw.Text(
        label.toUpperCase(),
        style: pw.TextStyle(
          fontSize: 12,
          letterSpacing: 1.2,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    ],
  ),
);

// ---------------------------------------------------------------------------
// Modern — full-width dark header band with headshot, compact body.
// ---------------------------------------------------------------------------
pw.Widget _modern(CvData cv, pw.MemoryImage? image, PdfColor accent) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        width: double.infinity,
        color: accent,
        padding: const pw.EdgeInsets.all(28),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            if (image != null)
              pw.Container(
                width: 76,
                height: 76,
                margin: const pw.EdgeInsets.only(right: 18),
                decoration: pw.BoxDecoration(
                  shape: pw.BoxShape.circle,
                  border: pw.Border.all(color: PdfColors.white, width: 2),
                  image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
                ),
              ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
                    style: pw.TextStyle(
                      fontSize: 26,
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (cv.title.isNotEmpty)
                    pw.Text(
                      cv.title.toUpperCase(),
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    _contactLine(cv),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.Container(height: 6, width: double.infinity, color: PdfColors.grey300),
      pw.Padding(
        padding: const pw.EdgeInsets.all(28),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (cv.summary.isNotEmpty) ...[
              _modernHeading('Profile', accent),
              pw.Text(cv.summary, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 14),
            ],
            if (cv.skills.isNotEmpty) ...[
              _modernHeading('Skills', accent),
              pw.Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cv.skills.map((s) => _chip(s, accent)).toList(),
              ),
              pw.SizedBox(height: 14),
            ],
            if (cv.workExperiences.isNotEmpty) ...[
              _modernHeading('Experience', accent),
              ...cv.workExperiences.map(
                (w) => _classicEntry(
                  w.role,
                  w.company,
                  w.dateRange,
                  w.description,
                ),
              ),
            ],
            if (cv.educations.isNotEmpty) ...[
              _modernHeading('Education', accent),
              ...cv.educations.map(
                (e) => _classicEntry(
                  e.degree,
                  e.school,
                  e.dateRange,
                  e.description,
                ),
              ),
            ],
          ],
        ),
      ),
    ],
  );
}

pw.Widget _modernHeading(String label, PdfColor accent) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 8),
  child: pw.Text(
    label.toUpperCase(),
    style: pw.TextStyle(
      fontSize: 13,
      letterSpacing: 1.5,
      fontWeight: pw.FontWeight.bold,
      color: accent,
    ),
  ),
);

pw.Widget _chip(String label, PdfColor accent) => pw.Container(
  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: pw.BoxDecoration(
    color: PdfColors.grey100,
    border: pw.Border.all(color: accent, width: 0.6),
    borderRadius: pw.BorderRadius.circular(10),
  ),
  child: pw.Text(
    label,
    style: const pw.TextStyle(fontSize: 9.5, color: PdfColors.grey900),
  ),
);

String _contactLine(CvData cv) {
  return [
    cv.email,
    cv.phone,
    cv.location,
  ].where((e) => e.isNotEmpty).join('  |  ');
}
