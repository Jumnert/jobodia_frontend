import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:jobodia_frontend/features/cv_builder/model/cv_data.dart';

/// Accent color per template index, shared between the on-screen preview and
/// the exported PDF so they stay visually matched.
const _accents = <PdfColor>[
  PdfColor.fromInt(0xFF0EA5A4), // Classic — teal
  PdfColor.fromInt(0xFF2B5DF0), // Balanced — blue
  PdfColor.fromInt(0xFF202428), // Modern — near-black band
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
  final doc = pw.Document();
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
// Classic — single column, centered header, teal section underlines.
// ---------------------------------------------------------------------------
pw.Widget _classic(CvData cv, pw.MemoryImage? image, PdfColor accent) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(36),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        if (image != null)
          pw.Container(
            width: 86,
            height: 86,
            margin: const pw.EdgeInsets.only(bottom: 12),
            decoration: pw.BoxDecoration(
              shape: pw.BoxShape.circle,
              image: pw.DecorationImage(image: image, fit: pw.BoxFit.cover),
            ),
          ),
        pw.Text(
          cv.fullName.isEmpty ? 'Your Name' : cv.fullName,
          style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold),
        ),
        if (cv.title.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              cv.title.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 12,
                color: accent,
                letterSpacing: 2,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        pw.SizedBox(height: 8),
        pw.Text(
          _contactLine(cv),
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.SizedBox(height: 20),
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
    margin: const pw.EdgeInsets.only(bottom: 8),
    padding: const pw.EdgeInsets.only(bottom: 4),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: accent, width: 1.4)),
    ),
    child: pw.Text(
      label.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: pw.FontWeight.bold,
      ),
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
            child: pw.Text(
              description,
              style: const pw.TextStyle(fontSize: 10, lineSpacing: 2),
            ),
          ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Balanced — split column: tinted left sidebar + main content column.
// ---------------------------------------------------------------------------
pw.Widget _balanced(CvData cv, pw.MemoryImage? image, PdfColor accent) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      // Sidebar
      pw.Container(
        width: 180,
        color: PdfColor.fromInt(0xFFF1F5FB),
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
            if (cv.email.isNotEmpty) _sidebarText(cv.email),
            if (cv.phone.isNotEmpty) _sidebarText(cv.phone),
            if (cv.location.isNotEmpty) _sidebarText(cv.location),
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
                          style: const pw.TextStyle(fontSize: 10),
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

pw.Widget _sidebarText(String text) => pw.Padding(
  padding: const pw.EdgeInsets.only(bottom: 4),
  child: pw.Text(text, style: const pw.TextStyle(fontSize: 9.5)),
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
    color: PdfColor(accent.red, accent.green, accent.blue, 0.12),
    borderRadius: pw.BorderRadius.circular(10),
  ),
  child: pw.Text(label, style: pw.TextStyle(fontSize: 9.5, color: accent)),
);

String _contactLine(CvData cv) {
  return [
    cv.email,
    cv.phone,
    cv.location,
  ].where((e) => e.isNotEmpty).join('  •  ');
}
